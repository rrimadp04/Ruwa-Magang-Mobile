<?php

namespace App\Http\Controllers\Api\Mobile\Dashboard;

use App\Http\Controllers\Controller;
use App\Models\Logbook;
use App\Models\Participant;
use App\Models\Pendaftaran;
use App\Models\Presensi;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

class DashboardController extends Controller
{
    /**
     * Profil ringkas untuk header dan kemajuan magang di aplikasi mobile.
     */
    public function profile(Request $request)
    {
        $user = $request->user();
        $participant = $user->participant;
        $isDummyProfile = ! $participant || $participant->status === 'pending';

        // TODO: Ganti fallback berikut dengan query profil/penempatan magang
        // setelah tabel peserta menyimpan NIM, jurusan, OPD, tanggal mulai,
        // dan tanggal selesai magang.
        $peserta = [
            'id' => $participant?->id ?? 0,
            'nim_nisn' => $isDummyProfile ? '2315061043' : null,
            'sekolah_kampus' => $user->university ?: 'Universitas Lampung',
            'jurusan' => $isDummyProfile ? 'Teknik Informatika' : null,
            'status' => $isDummyProfile ? 'aktif' : $participant->status,
            'start_date' => $isDummyProfile ? '2026-06-01' : null,
            'end_date' => $isDummyProfile ? '2026-08-31' : null,
        ];

        return response()->json([
            'status' => 'success',
            'data' => [
                'user' => [
                    'id' => $user->id,
                    'name' => $user->name,
                    'email' => $user->email,
                    'role' => $user->role,
                    'status' => $peserta['status'],
                ],
                'peserta' => $peserta,
                'opd' => null,
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
     * Sumber kebenaran: tabel pendaftarans (shared dengan ruwa-magang web).
     * Fallback ke tabel participants (mobile) dan pesertas (web).
     * Response: not_registered | pending | accepted | rejected
     */
    public function registrationStatus(Request $request)
    {
        $user = $request->user();

        // 1. Cek tabel pendaftarans (shared DB)
        $pendaftaran = \App\Models\Pendaftaran::where('user_id', $user->id)
            ->latest()
            ->first();

        if ($pendaftaran) {
            $status = match ($pendaftaran->status) {
                'accepted', 'diterima', 'aktif' => 'accepted',
                'rejected', 'ditolak'           => 'rejected',
                default                         => 'pending',
            };

            // Sync participants table agar konsisten
            $this->syncParticipant($user->id, $status);

            return response()->json([
                'registration_status' => $status,
                'pendaftaran_id'      => $pendaftaran->id,
                'opd_nama'            => $pendaftaran->opd?->name,
                'bidang'              => $pendaftaran->bidang,
                'catatan_penolakan'   => $pendaftaran->catatan_penolakan ?? $pendaftaran->admin_note,
            ]);
        }

        // 2. Fallback: cek tabel pesertas (web) via DB facade
        if (\Illuminate\Support\Facades\Schema::hasTable('pesertas')) {
            $peserta = \Illuminate\Support\Facades\DB::table('pesertas')
                ->where('user_id', $user->id)
                ->first();

            if ($peserta) {
                $status = in_array($peserta->status, ['aktif', 'accepted', 'diterima'])
                    ? 'accepted'
                    : ($peserta->status === 'ditolak' ? 'rejected' : 'pending');

                $this->syncParticipant($user->id, $status);
                return response()->json(['registration_status' => $status]);
            }
        }

        return response()->json(['registration_status' => 'not_registered']);
    }

    private function syncParticipant(int $userId, string $status): void
    {
        $participantStatus = match ($status) {
            'accepted' => 'aktif',
            'rejected' => 'ditolak',
            default    => 'pending',
        };

        \App\Models\Participant::updateOrCreate(
            ['user_id' => $userId],
            ['status'  => $participantStatus]
        );
    }

    /**
     * Kembalikan 403 jika peserta belum diterima (status bukan accepted/aktif).
     * Mengembalikan null jika akses diizinkan.
     */
    private function guardAccepted(Request $request): ?\Illuminate\Http\JsonResponse
    {
        $user = $request->user();

        // Cek dari pendaftarans (shared DB) — sumber kebenaran utama
        $pendaftaran = Pendaftaran::where('user_id', $user->id)
            ->whereIn('status', ['accepted'])
            ->exists();

        if ($pendaftaran) return null;

        // Fallback: cek pesertas (web)
        if (Schema::hasTable('pesertas')) {
            $peserta = DB::table('pesertas')->where('user_id', $user->id)->first();
            if ($peserta && in_array($peserta->status, ['aktif', 'accepted', 'diterima'], true)) {
                return null;
            }
        }

        return response()->json([
            'status'  => 'error',
            'message' => 'Pendaftaran Anda belum disetujui. Fitur ini akan tersedia setelah admin menerima pendaftaran Anda.',
        ], 403);
    }

    public function index(Request $request)
    {
        $user = $request->user();

        if ($user->role !== 'peserta') {
            return response()->json(['status' => 'error', 'message' => 'Dashboard ini hanya untuk peserta magang.'], 403);
        }

        $status = $user->participant?->status ?? 'pending';
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
                'has_presensi_today' => Presensi::where('user_id', $user->id)
                    ->whereDate('presensi_date', today())
                    ->exists(),
                'logbook_count' => Logbook::where('user_id', $user->id)->count(),
            ],
        ]);
    }
}
