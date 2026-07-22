<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StorePresensiRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    /**
     * @return array<string, mixed>
     */
    public function rules(): array
    {
        return [
            'action' => ['required', 'string', 'in:hadir,pulang,izin'],
            'latitude' => ['required', 'numeric', 'between:-90,90'],
            'longitude' => ['required', 'numeric', 'between:-180,180'],
            'location_accuracy' => ['nullable', 'numeric', 'min:0'],
            'location_address' => ['nullable', 'string', 'max:500'],
            'photo' => [
                'required_if:action,hadir',
                'required_if:action,pulang',
                'nullable',
                'string',
                'starts_with:data:image/',
            ],
            'note' => [
                'required_if:action,izin',
                'nullable',
                'string',
                'max:1000',
            ],
            'proof' => [
                'required_if:action,izin',
                'nullable',
                'string',
                'regex:/^data:(image\\/(?:jpeg|png)|application\\/pdf);base64,/',
            ],
            'proof_name' => ['nullable', 'string', 'max:255'],
        ];
    }

    /**
     * @return array<string, string>
     */
    public function messages(): array
    {
        return [
            'action.required' => 'Aksi presensi wajib diisi.',
            'action.in' => 'Aksi presensi tidak valid.',
            'latitude.required' => 'Koordinat lokasi (latitude) wajib dikirim.',
            'longitude.required' => 'Koordinat lokasi (longitude) wajib dikirim.',
            'photo.required_if' => 'Foto selfie wajib diambil untuk presensi datang/pulang.',
            'photo.starts_with' => 'Format foto tidak valid, gunakan base64 Data URI.',
            'note.required_if' => 'Catatan/alasan izin wajib diisi.',
            'proof.required_if' => 'Bukti pendukung wajib diunggah untuk izin.',
            'proof.regex' => 'Bukti harus berupa file JPG, PNG, atau PDF.',
        ];
    }
}
