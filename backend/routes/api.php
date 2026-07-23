<?php

use App\Http\Controllers\Api\Mobile\Auth\AuthController;
use App\Http\Controllers\Api\Mobile\Dashboard\DashboardController;
use App\Http\Controllers\Api\Mobile\Profile\AccountSettingsController;
use Illuminate\Support\Facades\Route;

Route::post('/login', [AuthController::class, 'login']);
Route::post('/register', [AuthController::class, 'register']);
Route::get('/peserta/profile/photo/{user}', [AccountSettingsController::class, 'photo']);
Route::middleware('api.token')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/peserta/dashboard', [DashboardController::class, 'index']);
    Route::get('/peserta/registration-status', [DashboardController::class, 'registrationStatus']);
    Route::get('/peserta/profile', [DashboardController::class, 'profile']);
    Route::get('/peserta/presensi', [DashboardController::class, 'presensi']);
    Route::post('/peserta/pengaturan-akun/update', [AccountSettingsController::class, 'update']);
    Route::post('/peserta/pengaturan-akun/password', [AccountSettingsController::class, 'updatePassword']);
    Route::post('/peserta/pengaturan-akun/photo', [AccountSettingsController::class, 'uploadPhoto']);
});
