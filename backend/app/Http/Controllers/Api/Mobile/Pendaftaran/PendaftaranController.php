<?php

namespace App\Http\Controllers\Api\Mobile\Pendaftaran;

use App\Http\Controllers\Controller;
use App\Models\Opd;
use App\Models\Pendaftaran;
use App\Models\Testimony;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Validator;

class PendaftaranController extends Controller
{
    // GET /api/peserta/pendaftaran
    public function status(Request $request)
    {
        $user         = $request->user();
        $pendaftaran  = Pendaftaran::where('user_id', $user->id)->latest()->first();

        $availableOpds = Opd::where('internship_status', 'terbuka')
            ->orderBy('name')
            ->get()
            ->map(fn(Opd $o) => [
                'id'           => $o->id,
                'name'         => $o->name,
                'code'         => $o->code,
                'peserta_aktif'=> $o->total_peserta_aktif,
                'bidangs'      => $o->bidangs()->with('bidang')->get()->map(fn($ob) => [
                    'id'        => $ob->bidang_id,
                    'name'      => $ob->bidang?->name ?? '-',
                    'kuota'     => $ob->kuota ?? 5,
                    'peserta_aktif' => $ob->peserta_aktif,
                    'remaining' => max(0, ($ob->kuota ?? 5) - $ob->peserta_aktif),
                    'is_full'   => $ob->is_full,
                ])->toArray(),
            ]);

        return response()->json([
            'status' => 'success',
            'data'   => [
                'pendaftaran'   => $pendaftaran ? $this->formatPendaftaran($pendaftaran) : null,
                'available_opds'=> $availableOpds,
            ],
        ]);
    }

    // POST /api/peserta/pendaftaran
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'opd_id'     => 'required|exists:opds,id',
            'prodi'      => 'required|string|max:255',
            'cv'         => 'required|file|mimes:pdf,doc,docx|max:3072',
            'surat'      => 'required|file|mimes:pdf,doc,docx|max:3072',
            'transkrip'  => 'required|file|mimes:pdf,jpg,jpeg,png,doc,docx|max:3072',
            'start_date' => 'required|date|after_or_equal:today',
            'end_date'   => 'required|date|after:start_date',
            'bidang_id'  => 'nullable|exists:bidangs,id',
            'bidang'     => 'nullable|string|max:255',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Validasi gagal.',
                'errors'  => $validator->errors(),
            ], 422);
        }

        $user = $request->user();

        // Cek pendaftaran aktif
        $existing = Pendaftaran::where('user_id', $user->id)
            ->whereIn('status', ['pending', 'accepted'])
            ->first();

        if ($existing) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Anda sudah memiliki pendaftaran aktif.',
            ], 409);
        }

        $cvPath        = $request->file('cv')->store('pendaftaran/cv', 'public');
        $suratPath     = $request->file('surat')->store('pendaftaran/surat', 'public');
        $transkripPath = $request->file('transkrip')->store('pendaftaran/transkrip', 'public');

        $opdId = (int) $request->opd_id;

        $pendaftaran = DB::transaction(function () use ($user, $request, $cvPath, $suratPath, $transkripPath, $opdId) {
            $pendaftaran = Pendaftaran::create([
                'user_id'        => $user->id,
                'opd_id'         => $opdId,
                'bidang_id'      => $request->bidang_id,
                'bidang'         => $request->bidang,
                'university'     => $user->university,
                'prodi'          => $request->prodi,
                'status'         => 'pending',
                'cv_path'        => $cvPath,
                'transkrip_path' => $transkripPath,
                'surat_path'     => $suratPath,
                'start_date'     => $request->start_date,
                'end_date'       => $request->end_date,
            ]);

            // Update users.opd_id dan status agar admin OPD bisa melihat
            DB::table('users')->where('id', $user->id)
                ->update(['opd_id' => $opdId, 'status' => 'pending']);

            // Sync ke tabel pesertas (ruwa-magang web)
            DB::table('pesertas')->updateOrInsert(
                ['user_id' => $user->id],
                [
                    'name'       => $user->name,
                    'university' => $user->university ?? '',
                    'prodi'      => $request->prodi,
                    'opd_id'     => $opdId,
                    'status'     => 'pending',
                    'updated_at' => now(),
                    'created_at' => now(),
                ]
            );

            return $pendaftaran;
        });

        return response()->json([
            'status'  => 'success',
            'message' => 'Pendaftaran berhasil dikirim. Tunggu konfirmasi admin OPD.',
            'data'    => $this->formatPendaftaran($pendaftaran),
        ], 201);
    }

    // GET /api/peserta/profil-opd
    public function profilOpd(Request $request)
    {
        $user        = $request->user();
        $pendaftaran = Pendaftaran::where('user_id', $user->id)
            ->whereIn('status', ['accepted', 'aktif'])
            ->latest()
            ->first();

        if (!$pendaftaran) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Anda belum memiliki penempatan OPD aktif.',
            ], 404);
        }

        $opd = Opd::findOrFail($pendaftaran->opd_id);

        $testimonies = Testimony::where('opd_id', $opd->id)
            ->with('peserta.user')
            ->latest()
            ->get()
            ->map(fn($t) => [
                'id'         => $t->id,
                'rating'     => $t->rating,
                'message'    => $t->message,
                'created_at' => $t->created_at?->toISOString(),
                'peserta'    => [
                    'name'       => $t->peserta?->user?->name ?? '-',
                    'university' => $t->peserta?->university ?? '-',
                    'prodi'      => $t->peserta?->prodi ?? '-',
                ],
            ]);

        return response()->json([
            'status' => 'success',
            'data'   => [
                'opd' => [
                    'id'                      => $opd->id,
                    'name'                    => $opd->name,
                    'code'                    => $opd->code,
                    'catalog_field'           => $opd->field,
                    'internship_status'       => $opd->internship_status,
                    'total_kuota'             => $opd->kuota,
                    'total_peserta_aktif'     => $opd->total_peserta_aktif,
                    'sisa_slot'               => $opd->sisa_slot,
                    'contact_email'           => $opd->contact_email,
                    'website'                 => $opd->website,
                    'bidangs'                 => $opd->bidangs()->with('bidang')->get()->map(fn($ob) => [
                        'id'           => $ob->bidang_id,
                        'name'         => $ob->bidang?->name ?? '-',
                        'kuota'        => $ob->kuota ?? 5,
                        'peserta_aktif'=> $ob->peserta_aktif,
                        'sisa'         => $ob->sisa,
                        'is_full'      => $ob->is_full,
                        'status'       => $ob->status,
                    ])->toArray(),
                ],
                'testimonies' => $testimonies,
            ],
        ]);
    }

    // POST /api/peserta/profil-opd/{opd}/testimony
    public function storeTestimony(Request $request, int $opdId)
    {
        $validator = Validator::make($request->all(), [
            'rating'  => 'required|integer|min:1|max:5',
            'message' => 'required|string|min:5',
        ]);

        if ($validator->fails()) {
            return response()->json(['status' => 'error', 'errors' => $validator->errors()], 422);
        }

        $user        = $request->user();
        $participant = $user->participant;

        if (!$participant || !in_array($participant->status, ['selesai', 'aktif'])) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Hanya alumni yang dapat memberikan testimoni.',
            ], 403);
        }

        $testimony = Testimony::create([
            'peserta_id' => $participant->id,
            'opd_id'     => $opdId,
            'rating'     => $request->rating,
            'message'    => $request->message,
        ]);

        return response()->json([
            'status'  => 'success',
            'message' => 'Testimoni Anda berhasil dikirim!',
            'data'    => [
                'id'         => $testimony->id,
                'peserta_id' => $testimony->peserta_id,
                'opd_id'     => $testimony->opd_id,
                'rating'     => $testimony->rating,
                'message'    => $testimony->message,
                'created_at' => $testimony->created_at?->toISOString(),
            ],
        ], 201);
    }

    private function formatPendaftaran(Pendaftaran $p): array
    {
        return [
            'id'         => $p->id,
            'user_id'    => $p->user_id,
            'opd_id'     => $p->opd_id,
            'opd_name'   => $p->opd?->name,
            'bidang'     => $p->bidang,
            'bidang_id'  => $p->bidang_id,
            'university' => $p->university,
            'prodi'      => $p->prodi,
            'status'     => $p->status,
            'start_date' => $p->start_date?->toDateString(),
            'end_date'   => $p->end_date?->toDateString(),
            'catatan_penolakan' => $p->catatan_penolakan ?? $p->admin_note,
            'cv_url'     => $p->cv_url,
            'transkrip_url' => $p->transkrip_url,
            'surat_url'  => $p->surat_url,
            'created_at' => $p->created_at?->toISOString(),
        ];
    }
}
