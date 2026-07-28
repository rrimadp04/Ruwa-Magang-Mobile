<?php

namespace App\Http\Controllers\Api\Mobile\Auth;

use App\Http\Controllers\Controller;
use App\Models\Participant;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class AuthController extends Controller
{
    public function login(Request $request)
    {
        $credentials = $request->validate([
            'email' => ['required', 'email'],
            'password' => ['required', 'string'],
        ]);

        $user = User::where('email', strtolower($credentials['email']))->first();

        if (! $user || ! Hash::check($credentials['password'], $user->password)) {
            return response()->json(['status' => 'error', 'message' => 'Email atau password salah.'], 401);
        }

        return response()->json(['status' => 'success', 'message' => 'Login berhasil.', 'data' => [
            'token' => $this->issueToken($user), 'user' => $this->userPayload($user),
        ]]);
    }

    public function register(Request $request)
    {
        $validated = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'email', 'max:255', 'unique:users,email'],
            'university' => ['required', 'string', 'max:191'],
            'role' => ['required', 'in:peserta,pembimbing_external'],
            'password' => ['required', 'string', 'min:8', 'confirmed'],
        ]);

        $user = \Illuminate\Support\Facades\DB::transaction(function () use ($validated) {
            $user = User::create([
                'name' => $validated['name'], 'email' => strtolower($validated['email']),
                'university' => $validated['university'], 'role' => $validated['role'],
                'password' => Hash::make($validated['password']),
            ]);

            if ($user->role === 'peserta') {
                Participant::create(['user_id' => $user->id, 'status' => 'pending']);
            }

            return $user;
        });

        return response()->json(['status' => 'success', 'message' => 'Pendaftaran berhasil.', 'data' => [
            'token' => $this->issueToken($user), 'user' => $this->userPayload($user),
        ]], 201);
    }

    public function logout(Request $request)
    {
        $request->user()?->currentAccessToken()?->delete();

        return response()->json(['status' => 'success', 'message' => 'Logout berhasil.']);
    }

    private function issueToken(User $user): string
    {
        // Personal access token Sanctum disimpan dalam bentuk hash oleh
        // Laravel. Hanya token teks yang dikembalikan sekali ini yang boleh
        // disimpan aplikasi dan dikirim sebagai Bearer token.
        return $user->createToken('mobile-app')->plainTextToken;
    }

    private function userPayload(User $user): array
    {
        return ['id' => $user->id, 'name' => $user->name, 'email' => $user->email, 'role' => $user->role];
    }
}
