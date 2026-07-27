<?php

use App\Http\Controllers\Api\Mobile\Auth\AuthController;
use App\Http\Controllers\Api\Mobile\Auth\PasswordResetController;
use App\Http\Controllers\Api\Mobile\Dashboard\DashboardController;
use App\Http\Controllers\Api\Mobile\Profile\AccountSettingsController;
use App\Http\Controllers\Api\PresensiController;
use Illuminate\Support\Facades\Route;

Route::post('/login', [AuthController::class, 'login']);
Route::post('/register', [AuthController::class, 'register']);
Route::post('/forgot-password', [PasswordResetController::class, 'sendOtp']);
Route::post('/reset-password', [PasswordResetController::class, 'resetWithOtp']);
Route::get('/peserta/profile/photo/{user}', [AccountSettingsController::class, 'photo']);

Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);

    Route::get('/peserta/dashboard', [DashboardController::class, 'index']);
    Route::get('/peserta/registration-status', [DashboardController::class, 'registrationStatus']);
    Route::get('/peserta/profile', [DashboardController::class, 'profile']);
    Route::get('/peserta/presensi', [DashboardController::class, 'presensi']);

    Route::post('/peserta/pengaturan-akun/update', [AccountSettingsController::class, 'update']);
    Route::post('/peserta/pengaturan-akun/password', [AccountSettingsController::class, 'updatePassword']);
    Route::post('/peserta/pengaturan-akun/photo', [AccountSettingsController::class, 'uploadPhoto']);

    // Modul Presensi
    Route::get('/peserta/presensi/settings', [PresensiController::class, 'settings']);
    Route::post('/peserta/presensi', [PresensiController::class, 'store']);
});
