<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Sertifikat;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class PesertaSertifikatController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $items = Sertifikat::query()
            ->where('user_id', $this->userId($request))
            ->latest()
            ->get()
            ->map(fn (Sertifikat $item) => [
                'id' => $item->id,
                'nama_sertifikat' => $item->nama_sertifikat,
                'nomor_sertifikat' => $item->nomor_sertifikat,
                'status' => $item->status,
                'tanggal_terbit' => $item->tanggal_terbit?->toDateString(),
                'penerbit' => $item->penerbit,
                'file_url' => $item->file_path ? Storage::disk('public')->url($item->file_path) : null,
            ]);

        return response()->json(['status' => 'success', 'data' => $items]);
    }

    private function userId(Request $request): int
    {
        abort_unless($request->user(), 401, 'Autentikasi diperlukan.');
        return $request->user()->id;
    }
}
