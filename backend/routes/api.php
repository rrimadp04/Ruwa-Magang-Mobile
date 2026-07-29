<?php

use Illuminate\Support\Facades\Route;

use App\Http\Controllers\Api\Mobile\Auth\AuthController;
use App\Http\Controllers\Api\Mobile\Auth\PasswordResetController;
use App\Http\Controllers\Api\Mobile\Dashboard\DashboardController;
use App\Http\Controllers\Api\Mobile\Profile\AccountSettingsController;
use App\Http\Controllers\Api\Mobile\OPD\OpdController;
use App\Http\Controllers\Api\Mobile\Pendaftaran\PendaftaranController;
use App\Http\Controllers\Api\PresensiController;
use App\Http\Controllers\Api\PesertaPenilaianController;
use App\Http\Controllers\Api\PesertaSertifikatController;

// ── Public ────────────────────────────────────────────────────────────────────
Route::post('/login',           [AuthController::class, 'login']);
Route::post('/register',        [AuthController::class, 'register']);
Route::post('/forgot-password', [PasswordResetController::class, 'sendOtp']);
Route::post('/reset-password',  [PasswordResetController::class, 'resetWithOtp']);
Route::get('/peserta/profile/photo/{user}', [AccountSettingsController::class, 'photo']);

// OPD — public
Route::get('/opd',       [OpdController::class, 'index']);
Route::get('/opd/{id}',  [OpdController::class, 'show']);

// ── Authenticated ─────────────────────────────────────────────────────────────
Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);

    // Dashboard
    Route::get('/peserta/dashboard',           [DashboardController::class, 'index']);
    Route::get('/peserta/registration-status', [DashboardController::class, 'registrationStatus']);
    Route::get('/peserta/profile',             [DashboardController::class, 'profile']);
    Route::get('/peserta/presensi',            [DashboardController::class, 'presensi']);

    // Account Settings
    Route::post('/peserta/pengaturan-akun/update',   [AccountSettingsController::class, 'update']);
    Route::post('/peserta/pengaturan-akun/password', [AccountSettingsController::class, 'updatePassword']);
    Route::post('/peserta/pengaturan-akun/photo',    [AccountSettingsController::class, 'uploadPhoto']);

    // Presensi
    Route::get('/peserta/presensi/settings', [PresensiController::class, 'settings']);
    Route::post('/peserta/presensi',         [PresensiController::class, 'store']);

    // Penilaian & Sertifikat
    Route::get('/peserta/penilaian',  [PesertaPenilaianController::class, 'index']);
    Route::post('/peserta/penilaian', [PesertaPenilaianController::class, 'store']);
    Route::get('/peserta/sertifikat', [PesertaSertifikatController::class, 'index']);

    // Pendaftaran
    Route::get('/peserta/pendaftaran',  [PendaftaranController::class, 'status']);
    Route::post('/peserta/pendaftaran', [PendaftaranController::class, 'store']);

    // Profil OPD Penempatan + Testimony
    Route::get('/peserta/profil-opd',                          [PendaftaranController::class, 'profilOpd']);
    Route::post('/peserta/profil-opd/{opd}/testimony',         [PendaftaranController::class, 'storeTestimony']);
});
