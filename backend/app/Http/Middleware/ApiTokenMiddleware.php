<?php

namespace App\Http\Middleware;

use App\Models\User;
use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class ApiTokenMiddleware
{
    public function handle(Request $request, Closure $next): Response
    {
        $token = $this->normalizeToken($request->bearerToken());

        if (! $token) {
            return response()->json(['status' => 'error', 'message' => 'Token otorisasi tidak ditemukan.'], 401);
        }

        $user = User::where('api_token', $token)->first();
        if (! $user) {
            return response()->json(['status' => 'error', 'message' => 'Token otorisasi tidak valid.'], 401);
        }

        $request->setUserResolver(static fn () => $user);

        return $next($request);
    }

    /**
     * Token pada database disimpan tanpa skema Authorization. Normalisasi ini
     * menjaga kompatibilitas token lama yang pernah tersimpan sebagai
     * "Bearer <token>" lalu dikirim Flutter sebagai "Bearer Bearer <token>".
     */
    private function normalizeToken(?string $token): string
    {
        $token = trim((string) $token);

        while (str_starts_with(strtolower($token), 'bearer ')) {
            $token = trim(substr($token, strlen('bearer ')));
        }

        return $token;
    }
}
