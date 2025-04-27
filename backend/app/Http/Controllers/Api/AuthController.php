<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\RateLimiter;
use App\Exceptions\AuthException;
use Illuminate\Support\Facades\Validator;

class AuthController extends Controller
{
    public function register(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users',
            'password' => 'required|string|min:8|confirmed',
            'role' => 'nullable|string|in:user,admin',
        ]);

        if ($validator->fails()) {
            return response()->json(['error' => $validator->messages()], 422);
        }

        $role = $request->input('role', 'user');

        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'password' => Hash::make($request->password),
            'role' => $role,
        ]);

        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'success' => true,
            'message' => 'User  registered successfully!',
            'auth_token' => $token,
            'user' => $user
        ]);
    }

    public function login(Request $request)
    {
        $key = 'login.' . $request->ip();
        if (RateLimiter::tooManyAttempts($key, 15)) {
            throw new AuthException('Too many login attempts. Please try again later.', 429);
        }

        $validated = $request->validate([
            'email' => 'required|email',
            'password' => 'required',
        ]);

        $user = User::where('email', $validated['email'])->first();

        if (!$user) {
            RateLimiter::hit($key);
            Log::warning('Login attempt with non-existent email: ' . $validated['email']);
            throw new AuthException('Email does not exist.', 404);
        }

        /* if (!$user->hasVerifiedEmail()) {
            RateLimiter::hit($key);
            Log::warning('Login attempt by unverified user: ' . $validated['email']);
            throw new AuthException('Email not verified.', 403);
        } */

        if (!Hash::check($validated['password'], $user->password)) {
            RateLimiter::hit($key);
            Log::warning('Invalid password attempt for email: ' . $validated['email']);
            throw new AuthException('Invalid password.', 401);
        }

        RateLimiter::clear($key);

        $token = $user->createToken('auth_token')->plainTextToken;
        $cookie = cookie('authToken', $token, 60, '/', request()->getHost(), true, true, false, 'lax');

        return response()->json([
            'success' => true,
            'message' => 'Login successful',
            'user' => $user,
            'token' => $token,
            'date' => now()->toDateTimeString(),
        ])->withCookie($cookie);
    }
    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();
        return response()->json([
            'success' => true,
            'message' => 'Successfully logged out'
        ]);
    }

    public function user(Request $request)
    {
        /* return response()->json(); */
        return response()->json([
            'success' => true,
            'message' => 'User retrieved successfully',
            'user' => $request->user(),
        ]);
    }
}
