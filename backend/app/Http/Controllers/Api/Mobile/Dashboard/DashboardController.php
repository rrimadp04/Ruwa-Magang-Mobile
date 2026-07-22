<?php

namespace App\Http\Controllers\Api\Mobile\Dashboard;

use App\Http\Controllers\Controller;
use App\Models\Logbook;
use App\Models\Presensi;
use Illuminate\Http\Request;

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
     */
    public function presensi(Request $request)
    {
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
