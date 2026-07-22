<?php

use App\Http\Controllers\Api\PresensiController;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Semua route di bawah ini memerlukan Bearer token (Laravel Sanctum).
| Frontend Flutter mengirim header: Authorization: Bearer <token>
|
*/

Route::middleware('auth:sanctum')->prefix('peserta')->group(function () {
    Route::get('/presensi/settings', [PresensiController::class, 'settings']);
    Route::get('/presensi', [PresensiController::class, 'index']);
    Route::post('/presensi', [PresensiController::class, 'store']);
});
