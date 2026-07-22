<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\StorePresensiRequest;
use App\Models\Presensi;
use App\Models\AttendanceSetting;
use App\Services\PresensiAbsenceService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;
use Illuminate\Validation\ValidationException;

class PresensiController extends Controller
{
    /**
     * GET /api/peserta/presensi/settings
     * Jam kerja yang dikonfigurasi admin dan dipakai Flutter pada halaman awal.
     */
    public function settings(): JsonResponse
    {
        $setting = AttendanceSetting::query()->firstOrCreate([], [
            'check_in_time' => '07:30:00',
            'check_out_time' => '16:00:00',
            'timezone' => 'Asia/Jakarta',
            'applies_every_day' => true,
        ]);

        return response()->json([
            'status' => 'success',
            'data' => [
                'check_in_time' => substr((string) $setting->check_in_time, 0, 5),
                'check_out_time' => substr((string) $setting->check_out_time, 0, 5),
                'timezone' => $setting->timezone,
            ],
        ]);
    }

    /**
     * GET /api/peserta/presensi
     * Riwayat log absen (kehadiran) peserta yang sedang login.
     */
    public function index(Request $request): JsonResponse
    {
        // Fallback aman ketika scheduler belum aktif: riwayat yang dibuka
        // setelah jam pulang tetap langsung menampilkan Tanpa Keterangan.
        app(PresensiAbsenceService::class)->finalizeForDate(now('Asia/Jakarta'));

        $validated = $request->validate([
            'date_start' => ['nullable', 'date'],
            'date_end' => ['nullable', 'date', 'after_or_equal:date_start'],
            'status' => ['nullable', 'in:hadir,izin,tanpa_keterangan,libur'],
        ]);

        $query = Presensi::query()->where('user_id', $request->user()->id);
        if (isset($validated['date_start'])) {
            $query->whereDate('presensi_date', '>=', $validated['date_start']);
        }
        if (isset($validated['date_end'])) {
            $query->whereDate('presensi_date', '<=', $validated['date_end']);
        }
        if (isset($validated['status'])) {
            $query->where('status', $validated['status']);
        }

        $presensis = $query
            ->orderByDesc('presensi_date')
            ->orderByDesc('created_at')
            ->get();

        return response()->json([
            'status' => 'success',
            'data' => $presensis->map(fn (Presensi $item) => $this->formatPresensi($item)),
        ]);
    }

    /**
     * POST /api/peserta/presensi
     * Catat presensi datang / pulang (geofenced GPS + selfie) atau izin.
     */
    public function store(StorePresensiRequest $request): JsonResponse
    {
        $user = $request->user();
        $action = $request->string('action')->toString();
        $now = now('Asia/Jakarta');
        $today = $now->toDateString();

        app(PresensiAbsenceService::class)->finalizeForDate($now);

        $finalizedAbsent = Presensi::query()
            ->where('user_id', $user->id)
            ->where('presensi_date', $today)
            ->where('status', 'tanpa_keterangan')
            ->exists();

        if ($finalizedAbsent) {
            throw ValidationException::withMessages([
                'action' => 'Presensi hari ini sudah ditetapkan sebagai Tanpa Keterangan setelah pukul 16.00.',
            ])->status(422);
        }

        // Cegah pengajuan ganda pada hari & jenis (type) yang sama.
        $type = match ($action) {
            'hadir' => 'datang',
            'pulang' => 'pulang',
            'izin' => 'izin',
        };

        $alreadyExists = Presensi::query()
            ->where('user_id', $user->id)
            ->where('presensi_date', $today)
            ->where('type', $type)
            ->exists();

        if ($alreadyExists) {
            throw ValidationException::withMessages([
                'action' => "Anda sudah melakukan presensi \"{$type}\" untuk hari ini.",
            ])->status(422);
        }

        if ($action === 'izin') {
            $proof = $this->storeIzinProof(
                $request->input('proof'),
                $request->input('proof_name'),
            );

            $presensi = Presensi::create([
                'user_id' => $user->id,
                'status' => 'izin',
                'type' => 'izin',
                'presensi_date' => $today,
                'note' => $request->input('note'),
                'proof_path' => $proof['path'],
                'proof_mime_type' => $proof['mime_type'],
                'proof_size_bytes' => $proof['size_bytes'],
                'latitude' => $request->input('latitude'),
                'longitude' => $request->input('longitude'),
                'location_address' => $request->input('location_address'),
                'location_accuracy' => $request->input('location_accuracy'),
            ]);

            return response()->json([
                'status' => 'success',
                'message' => 'Permohonan izin berhasil dikirim.',
                'data' => $this->formatPresensi($presensi),
            ], 201);
        }

        // --- Aksi hadir / pulang: wajib lolos verifikasi geofencing ---
        $officeLat = (float) config('presensi.office_latitude');
        $officeLng = (float) config('presensi.office_longitude');
        $radius = (int) config('presensi.radius_meters');

        $distance = $this->haversineDistanceMeters(
            (float) $request->input('latitude'),
            (float) $request->input('longitude'),
            $officeLat,
            $officeLng,
        );

        $locationValid = $distance <= $radius;

        if (! $locationValid) {
            throw ValidationException::withMessages([
                'latitude' => "Lokasi Anda berada di luar radius kantor OPD penempatan magang (Selisih: {$distance} meter).",
            ])->status(422);
        }

        $photoPath = $this->storeSelfiePhoto($request->input('photo'));

        $presensi = Presensi::create([
            'user_id' => $user->id,
            // Presensi pulang tetap berstatus hadir; pembeda datang/pulang
            // disimpan pada kolom type.
            'status' => 'hadir',
            'type' => $type, // 'datang' | 'pulang'
            'presensi_date' => $today,
            'checked_at' => $now,
            'photo' => $photoPath,
            'latitude' => $request->input('latitude'),
            'longitude' => $request->input('longitude'),
            'location_address' => $request->input('location_address'),
            'location_distance_meters' => $distance,
            'location_accuracy' => $request->input('location_accuracy'),
            'location_valid' => $locationValid,
        ]);

        return response()->json([
            'status' => 'success',
            'message' => 'Presensi berhasil dicatat.',
            'data' => $this->formatPresensi($presensi),
        ], 201);
    }

    /**
     * Bentuk array respons agar konsisten dengan dokumentasi API.
     *
     * @return array<string, mixed>
     */
    private function formatPresensi(Presensi $item): array
    {
        return [
            'id' => $item->id,
            'user_id' => $item->user_id,
            'status' => $item->status,
            'type' => $item->type,
            'presensi_date' => $item->presensi_date->format('Y-m-d'),
            'note' => $item->note,
            'photo' => $item->photo,
            'latitude' => $item->latitude,
            'longitude' => $item->longitude,
            'location_address' => $item->location_address,
            'location_distance_meters' => $item->location_distance_meters,
            'location_accuracy' => $item->location_accuracy,
            'location_valid' => $item->location_valid,
            'proof_path' => $item->proof_path,
            'proof_mime_type' => $item->proof_mime_type,
            'proof_size_bytes' => $item->proof_size_bytes,
            'checked_at' => $item->checked_at?->toJSON(),
            'absence_finalized_at' => $item->absence_finalized_at?->toJSON(),
            'created_at' => $item->created_at?->toJSON(),
        ];
    }

    /**
     * Decode base64 Data URI foto selfie lalu simpan ke disk "public".
     * Hasilnya path relatif "storage/presensis/xxx.jpg" (sesuai dok API).
     */
    private function storeSelfiePhoto(string $base64DataUri): string
    {
        [$meta, $encoded] = array_pad(explode(',', $base64DataUri, 2), 2, null);

        if ($encoded === null) {
            throw ValidationException::withMessages([
                'photo' => 'Format foto tidak valid.',
            ])->status(422);
        }

        $extension = 'jpg';
        if (preg_match('/data:image\/(\w+);base64/', $meta, $matches)) {
            $extension = $matches[1] === 'jpeg' ? 'jpg' : $matches[1];
        }

        $binary = base64_decode($encoded, true);
        if ($binary === false) {
            throw ValidationException::withMessages([
                'photo' => 'Foto gagal diproses, silakan ulangi pengambilan foto.',
            ])->status(422);
        }

        $filename = Str::random(12).'_'.now()->format('His').'.'.$extension;
        Storage::disk('public')->put("presensis/{$filename}", $binary);

        return "storage/presensis/{$filename}";
    }

    /**
     * Simpan bukti izin (JPG, PNG, atau PDF). Ukuran biner dibatasi 2 MB,
     * bukan panjang teks base64, agar batasnya konsisten dengan ukuran file
     * yang dipilih pengguna pada Flutter.
     *
     * @return array{path: string, mime_type: string, size_bytes: int}
     */
    private function storeIzinProof(string $base64DataUri, ?string $originalName): array
    {
        [$meta, $encoded] = array_pad(explode(',', $base64DataUri, 2), 2, null);
        $mimeType = match (true) {
            str_starts_with((string) $meta, 'data:image/jpeg;') => 'image/jpeg',
            str_starts_with((string) $meta, 'data:image/png;') => 'image/png',
            str_starts_with((string) $meta, 'data:application/pdf;') => 'application/pdf',
            default => null,
        };

        $binary = $encoded === null ? false : base64_decode($encoded, true);
        if ($mimeType === null || $binary === false) {
            throw ValidationException::withMessages([
                'proof' => 'Format bukti tidak valid. Gunakan JPG, PNG, atau PDF.',
            ])->status(422);
        }

        $size = strlen($binary);
        if ($size > 2 * 1024 * 1024) {
            throw ValidationException::withMessages([
                'proof' => 'Gagal unggah file/foto, maks 2MB.',
            ])->status(422);
        }

        $extension = match ($mimeType) {
            'image/jpeg' => 'jpg',
            'image/png' => 'png',
            default => 'pdf',
        };
        $basename = pathinfo((string) $originalName, PATHINFO_FILENAME);
        $filename = Str::slug($basename ?: 'bukti-izin').'_'.Str::random(12).'.'.$extension;
        Storage::disk('public')->put("presensi-proofs/{$filename}", $binary);

        return [
            'path' => "storage/presensi-proofs/{$filename}",
            'mime_type' => $mimeType,
            'size_bytes' => $size,
        ];
    }

    /**
     * Hitung jarak dua koordinat (meter) memakai formula Haversine.
     */
    private function haversineDistanceMeters(
        float $lat1,
        float $lon1,
        float $lat2,
        float $lon2,
    ): int {
        $earthRadiusMeters = 6371000;

        $dLat = deg2rad($lat2 - $lat1);
        $dLon = deg2rad($lon2 - $lon1);

        $a = sin($dLat / 2) ** 2
            + cos(deg2rad($lat1)) * cos(deg2rad($lat2)) * sin($dLon / 2) ** 2;
        $c = 2 * atan2(sqrt($a), sqrt(1 - $a));

        return (int) round($earthRadiusMeters * $c);
    }
}
