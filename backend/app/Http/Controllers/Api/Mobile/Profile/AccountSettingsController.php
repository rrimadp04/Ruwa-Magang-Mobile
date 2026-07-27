<?php

namespace App\Http\Controllers\Api\Mobile\Profile;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Storage;
use Illuminate\Validation\Rule;

class AccountSettingsController extends Controller
{
    /** Public image response used by Flutter Web's Image.network. */
    public function photo(User $user)
    {
        abort_unless($user->photo && Storage::disk('public')->exists($user->photo), 404);

        return Storage::disk('public')->response($user->photo);
    }

    public function update(Request $request)
    {
        $user = $request->user();
        $data = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'email', 'max:255', Rule::unique('users', 'email')->ignore($user->id)],
        ]);

        $user->forceFill([
            'name' => $data['name'],
            'email' => strtolower($data['email']),
        ])->save();

        return response()->json(['status' => 'success', 'message' => 'Profil berhasil diperbarui.']);
    }

    public function updatePassword(Request $request)
    {
        $data = $request->validate([
            'current_password' => ['required', 'string'],
            'password' => ['required', 'string', 'min:8', 'confirmed'],
        ]);
        $user = $request->user();

        if (! Hash::check($data['current_password'], $user->password)) {
            return response()->json(['status' => 'error', 'message' => 'Password lama tidak sesuai.'], 422);
        }

        $user->forceFill(['password' => Hash::make($data['password'])])->save();

        return response()->json(['status' => 'success', 'message' => 'Password berhasil diperbarui.']);
    }

    public function uploadPhoto(Request $request)
    {
        $data = $request->validate([
            'photo' => ['required', 'image', 'mimes:jpg,jpeg,png,webp', 'max:5120'],
        ]);
        $user = $request->user();

        if ($user->photo) {
            Storage::disk('public')->delete($user->photo);
        }
        $path = $data['photo']->store('profile-photos', 'public');
        $user->forceFill(['photo' => $path])->save();

        return response()->json([
            'status' => 'success',
            'message' => 'Foto profil berhasil diperbarui.',
            'data' => ['photo_url' => Storage::disk('public')->url($path)],
        ]);
    }
}
