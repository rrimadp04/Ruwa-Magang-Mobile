<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Penilaian;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class PesertaPenilaianController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        return response()->json([
            'status' => 'success',
            'data' => Penilaian::query()
                ->where('user_id', $this->userId($request))
                ->latest()
                ->get()
                ->map(fn (Penilaian $item) => $this->resource($item)),
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        $data = $request->validate([
            'file' => ['required', 'file', 'mimes:pdf,jpg,jpeg,png', 'max:5120'],
        ]);
        $path = $data['file']->store('penilaian', 'public');
        $penilaian = Penilaian::create([
            'user_id' => $this->userId($request),
            'file_path' => $path,
            'status' => 'pending',
        ]);

        return response()->json([
            'status' => 'success',
            'message' => 'Berkas penilaian berhasil diunggah.',
            'data' => $this->resource($penilaian),
        ], 201);
    }

    private function userId(Request $request): int
    {
        abort_unless($request->user(), 401, 'Autentikasi diperlukan.');
        return $request->user()->id;
    }

    private function resource(Penilaian $item): array
    {
        return [
            'id' => $item->id,
            'status' => $item->status,
            'nilai_akhir' => $item->nilai_akhir,
            'predikat' => $item->predikat,
            'reviewer' => $item->reviewer,
            'tanggal_review' => $item->tanggal_review?->toDateString(),
            'komentar' => $item->komentar,
            'file_url' => Storage::disk('public')->url($item->file_path),
        ];
    }
}
