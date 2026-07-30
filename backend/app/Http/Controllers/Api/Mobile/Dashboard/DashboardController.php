<?php

namespace App\Http\Controllers\Api\Mobile\Dashboard;

use App\Http\Controllers\Controller;
use App\Models\Logbook;
use App\Models\Pendaftaran;
use App\Models\Presensi;
use App\Models\Sertifikat;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Schema;

class DashboardController extends Controller
{
    /**
     * Profil ringkas untuk header dan kemajuan magang di aplikasi mobile.
     */
    public function profile(Request $request)
    {
        $user = $request->user();
        $participant = $this->participantFor($user);
        $pendaftaran = $this->registrationFor($user);
        $status = $pendaftaran?->status ?? $participant?->status ?? 'pending';
        $statusLabel = match ($status) {
            'accepted', 'aktif' => 'Aktif Magang',
            'pending' => 'Menunggu Persetujuan',
            'rejected', 'ditolak' => 'Ditolak',
            'selesai' => 'Selesai',
            default => ucfirst($status),
        };

        // TODO: Ganti fallback berikut dengan query profil/penempatan magang
        // setelah tabel peserta menyimpan NIM, jurusan, OPD, tanggal mulai,
        // dan tanggal selesai magang.
        $peserta = [
            'id' => $participant?->id ?? $pendaftaran?->id ?? 0,
            'nim_nisn' => '-',
            'sekolah_kampus' => $pendaftaran?->university ?? $user->university ?? '-',
            'jurusan' => $pendaftaran?->prodi ?? '-',
            'status' => $status,
            'start_date' => $pendaftaran?->start_date?->toDateString(),
            'end_date' => $pendaftaran?->end_date?->toDateString(),
        ];

        return response()->json([
            'status' => 'success',
            'data' => [
                'user' => [
                    'id' => $user->id,
                    'name' => $user->name,
                    'email' => $user->email,
                    'role' => $user->role,
                    'status' => $status,
                ],
                'peserta' => $peserta,
                'status_label' => $statusLabel,
                'opd' => $pendaftaran?->opd ? [
                    'id' => $pendaftaran->opd->id,
                    'nama_opd' => $pendaftaran->opd->nama_opd ?? $pendaftaran->opd->name,
                ] : null,
                // Gunakan endpoint API agar gambar dapat diakses Flutter Web
                // dengan header CORS yang sama seperti endpoint profil.
                'photo_url' => $user->photo
                    ? $request->getSchemeAndHttpHost().'/api/peserta/profile/photo/'.$user->id
                    : null,
            ],
        ]);
    }

    /**
     * Riwayat presensi minimal yang kompatibel dengan model Flutter.
     * Hanya dapat diakses peserta dengan status accepted/aktif.
     */
    public function presensi(Request $request)
    {
        $forbidden = $this->guardAccepted($request);
        if ($forbidden) return $forbidden;

        $items = Presensi::where('user_id', $request->user()->id)
            ->latest('presensi_date')
            ->get()
            ->map(fn (Presensi $item) => [
                'id' => $item->id,
                'status' => 'hadir',
                'type' => 'datang',
                'presensi_date' => $item->presensi_date->toDateString(),
                'created_at' => $item->created_at->toISOString(),
            ]);

        // TODO: Hapus fallback setelah modul presensi menyimpan data ke tabel.
        // Respons tetap mengikuti kontrak model Presensi Flutter.
        if ($items->isEmpty()) {
            $now = now();
            $items = collect([[
                'id' => 0,
                'status' => 'hadir',
                'type' => 'datang',
                'presensi_date' => $now->toDateString(),
                'created_at' => $now->toISOString(),
            ]]);
        }

        return response()->json([
            'status' => 'success',
            'data' => $items,
        ]);
    }

    /**
     * Status proses pendaftaran peserta.
     * Response: not_registered | pending | accepted
     */
    public function registrationStatus(Request $request)
    {
        $user = $request->user();
        $participant = $this->participantFor($user);
        $pendaftaran = $this->registrationFor($user);

        if ($pendaftaran) {
            $status = in_array($pendaftaran->status, ['accepted', 'aktif'], true)
                ? 'accepted'
                : ($pendaftaran->status === 'pending' ? 'pending' : 'not_registered');
        } elseif (! $participant) {
            $status = 'not_registered';
        } elseif ($participant->status === 'aktif' || $participant->status === 'accepted') {
            $status = 'accepted';
        } elseif ($participant->status === 'pending') {
            $status = 'pending';
        } else {
            $status = 'not_registered';
        }

        return response()->json(['registration_status' => $status]);
    }

    /**
     * Kembalikan 403 jika peserta belum diterima (status bukan accepted/aktif).
     * Mengembalikan null jika akses diizinkan.
     */
    private function guardAccepted(Request $request): ?\Illuminate\Http\JsonResponse
    {
        $user = $request->user();
        $participant = $this->participantFor($user);
        $pendaftaran = $this->registrationFor($user);
        $accepted = ($pendaftaran && in_array($pendaftaran->status, ['aktif', 'accepted'], true)) ||
            ($participant && in_array($participant->status, ['aktif', 'accepted'], true));

        if (! $accepted) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Pendaftaran Anda belum disetujui. Fitur ini akan tersedia setelah admin menerima pendaftaran Anda.',
            ], 403);
        }

        return null;
    }

    public function index(Request $request)
    {
        $user = $request->user();

        if ($user->role !== 'peserta') {
            return response()->json(['status' => 'error', 'message' => 'Dashboard ini hanya untuk peserta magang.'], 403);
        }

        $status = $this->registrationFor($user)?->status ?? $this->participantFor($user)?->status ?? 'pending';
        $pendaftaran = $this->registrationFor($user);
        $statusLabel = match ($status) {
            'aktif' => 'Aktif',
            'selesai' => 'Selesai',
            'ditolak' => 'Ditolak',
            default => 'Pending',
        };

        return response()->json([
            'status' => 'success',
            'data' => [
                'status_label' => $statusLabel,
                'has_presensi_today' => $this->hasUserColumn('presensis') && Presensi::where('user_id', $user->id)
                    ->whereDate('presensi_date', today())->exists(),
                'presensi_count' => $this->hasUserColumn('presensis')
                    ? Presensi::where('user_id', $user->id)->count()
                    : 0,
                'logbook_count' => $this->hasUserColumn('logbooks')
                    ? Logbook::where('user_id', $user->id)->count()
                    : 0,
                'sertifikat_count' => $this->hasUserColumn('sertifikats')
                    ? Sertifikat::where('user_id', $user->id)->count()
                    : 0,
                'start_date' => $pendaftaran?->start_date?->toDateString(),
                'end_date' => $pendaftaran?->end_date?->toDateString(),
            ],
        ]);
    }

    /**
     * Database lama tidak memiliki tabel participants. Profil tetap dapat
     * memakai data users tanpa membuat tabel baru.
     */
    private function participantFor($user): ?\App\Models\Participant
    {
        return Schema::hasTable('participants') ? $user->participant : null;
    }

    private function registrationFor($user): ?Pendaftaran
    {
        return Schema::hasTable('pendaftarans')
            ? Pendaftaran::with('opd')->where('user_id', $user->id)->latest()->first()
            : null;
    }

    private function hasUserColumn(string $table): bool
    {
        return Schema::hasTable($table) && Schema::hasColumn($table, 'user_id');
    }
}
