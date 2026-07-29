<?php

namespace App\Http\Controllers\Api\Mobile\OPD;

use App\Http\Controllers\Controller;
use App\Models\Opd;
use App\Models\Testimony;
use Illuminate\Http\Request;

class OpdController extends Controller
{
    public function index(Request $request)
    {
        $query = Opd::query();

        if ($q = $request->q) {
            $query->where(function ($q2) use ($q) {
                $q2->where('name', 'like', "%$q%")
                   ->orWhere('short_description', 'like', "%$q%");
            });
        }

        if ($field = $request->field) {
            $query->where('field', $field);
        }

        if ($category = $request->category) {
            $query->where('category', $category);
        }

        if ($status = $request->status) {
            $query->where('internship_status', $status);
        }

        $sort = $request->sort ?? 'name';
        match ($sort) {
            'popular' => $query->withCount(['pendaftarans as peserta_count' => fn($q) => $q->whereIn('status', ['accepted', 'aktif'])])->orderByDesc('peserta_count'),
            'latest'  => $query->latest(),
            default   => $query->orderBy('name'),
        };

        $perPage = (int) ($request->per_page ?? 20);
        $paginated = $query->paginate($perPage);

        $data = $paginated->getCollection()->map(fn(Opd $opd) => $this->formatList($opd));

        return response()->json([
            'status' => 'success',
            'data'   => array_merge($paginated->toArray(), ['data' => $data]),
        ]);
    }

    public function show(int $id)
    {
        $opd = Opd::findOrFail($id);

        return response()->json([
            'status' => 'success',
            'data'   => $this->formatDetail($opd),
        ]);
    }

    // ── helpers ───────────────────────────────────────────────────────────────

    private function formatList(Opd $opd): array
    {
        return [
            'id'                      => $opd->id,
            'name'                    => $opd->name,
            'code'                    => $opd->code,
            'catalog_field'           => $opd->field,
            'catalog_category'        => $opd->category,
            'internship_status'       => $opd->internship_status,
            'internship_status_label' => $opd->internship_status_label,
            'logo_url'                => $opd->logo_url,
            'banner_url'              => $opd->banner_url,
            'short_description'       => $opd->short_description,
            'location'                => $opd->location ?? $opd->alamat,
            'total_kuota'             => $opd->kuota,
            'total_peserta_aktif'     => $opd->total_peserta_aktif,
            'sisa_slot'               => $opd->sisa_slot,
            'attendance_latitude'     => $opd->attendance_latitude,
            'attendance_longitude'    => $opd->attendance_longitude,
            'attendance_radius_meters'=> $opd->attendance_radius_meters,
            'bidangs'                 => $this->formatBidangs($opd),
        ];
    }

    private function formatDetail(Opd $opd): array
    {
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

        return array_merge($this->formatList($opd), [
            'profile_description'  => $opd->profile_description,
            'internship_tasks'     => $opd->internship_tasks,
            'divisions'            => $opd->divisions,
            'skills'               => $opd->skills,
            'kriteria'             => $opd->kriteria,
            'work_hours'           => $opd->work_hours,
            'contact_phone'        => $opd->contact_phone ?? $opd->kontak,
            'contact_email'        => $opd->contact_email,
            'website'              => $opd->website,
            'additional_info'      => $opd->additional_info,
            'documentation_images' => $opd->documentation_images ?? [],
            'mentors_count'        => $opd->mentors()->count(),
            'pendaftarans_count'   => $opd->pendaftarans()->count(),
            'testimonies'          => $testimonies,
        ]);
    }

    private function formatBidangs(Opd $opd): array
    {
        return $opd->bidangs()->with('bidang')->get()->map(function ($ob) {
            $pesertaAktif = $ob->peserta_aktif;
            $sisa         = max(0, ($ob->kuota ?? 5) - $pesertaAktif);
            return [
                'id'           => $ob->bidang_id,
                'name'         => $ob->bidang?->name ?? '-',
                'kuota'        => $ob->kuota ?? 5,
                'peserta_aktif'=> $pesertaAktif,
                'sisa'         => $sisa,
                'is_full'      => $sisa <= 0,
                'status'       => $sisa <= 0 ? 'penuh' : 'tersedia',
            ];
        })->toArray();
    }
}
