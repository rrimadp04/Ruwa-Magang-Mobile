<?php

namespace App\Http\Controllers\Api\Mobile\Auth;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Str;

class PasswordResetController extends Controller
{
    /**
     * Kirim kode OTP 6 digit ke email pengguna.
     * Kode disimpan di tabel password_reset_tokens (tabel bawaan Laravel).
     */
    public function sendOtp(Request $request)
    {
        $request->validate(['email' => ['required', 'email']]);

        $user = User::where('email', strtolower($request->email))->first();

        // Selalu kembalikan sukses agar email valid tidak bisa di-enumerate.
        if (! $user) {
            return response()->json([
                'status'  => 'success',
                'message' => 'Jika email terdaftar, kode OTP telah dikirim.',
            ]);
        }

        $otp = str_pad((string) random_int(0, 999999), 6, '0', STR_PAD_LEFT);

        DB::table('password_reset_tokens')->upsert(
            [
                'email'      => $user->email,
                'token'      => Hash::make($otp),
                'created_at' => now(),
            ],
            ['email'],
            ['token', 'created_at'],
        );

        // Kirim OTP via mail (MAIL_MAILER=log di development → tulis ke log).
        Mail::raw(
            "Kode OTP reset password Ruwa Magang Anda: $otp\n\nKode berlaku selama 15 menit.",
            static fn ($m) => $m->to($user->email)->subject('Kode OTP Reset Password – Ruwa Magang'),
        );

        return response()->json([
            'status'  => 'success',
            'message' => 'Jika email terdaftar, kode OTP telah dikirim.',
        ]);
    }

    /**
     * Verifikasi OTP dan reset password.
     */
    public function resetWithOtp(Request $request)
    {
        $request->validate([
            'email'                 => ['required', 'email'],
            'otp'                   => ['required', 'string', 'size:6'],
            'password'              => ['required', 'string', 'min:8', 'confirmed'],
        ]);

        $email = strtolower($request->email);

        $record = DB::table('password_reset_tokens')
            ->where('email', $email)
            ->first();

        if (! $record) {
            return response()->json(['status' => 'error', 'message' => 'Kode OTP tidak valid atau sudah kedaluwarsa.'], 422);
        }

        // OTP kedaluwarsa setelah 15 menit.
        if (now()->diffInMinutes($record->created_at) > 15) {
            DB::table('password_reset_tokens')->where('email', $email)->delete();
            return response()->json(['status' => 'error', 'message' => 'Kode OTP sudah kedaluwarsa. Silakan minta kode baru.'], 422);
        }

        if (! Hash::check($request->otp, $record->token)) {
            return response()->json(['status' => 'error', 'message' => 'Kode OTP tidak valid.'], 422);
        }

        $user = User::where('email', $email)->first();
        if (! $user) {
            return response()->json(['status' => 'error', 'message' => 'Akun tidak ditemukan.'], 404);
        }

        $user->forceFill(['password' => Hash::make($request->password)])->save();

        DB::table('password_reset_tokens')->where('email', $email)->delete();

        return response()->json(['status' => 'success', 'message' => 'Password berhasil direset. Silakan masuk dengan password baru.']);
    }
}
