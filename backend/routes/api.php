<?php

use App\Http\Controllers\Api\PesertaPenilaianController;
use App\Http\Controllers\Api\PesertaSertifikatController;
use Illuminate\Support\Facades\Route;

Route::prefix('peserta')->group(function (): void {
    Route::get('penilaian', [PesertaPenilaianController::class, 'index']);
    Route::post('penilaian', [PesertaPenilaianController::class, 'store']);
    Route::get('sertifikat', [PesertaSertifikatController::class, 'index']);
});
