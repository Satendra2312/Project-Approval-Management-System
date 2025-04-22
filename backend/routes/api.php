<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\ProjectController;
use Illuminate\Support\Facades\Route;

Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/user', [AuthController::class, 'user']);

    Route::get('/projects', [ProjectController::class, 'index']);
    Route::post('/projects', [ProjectController::class, 'store']);
    Route::get('/projects/{project}', [ProjectController::class, 'show']);
    Route::patch('/projects/{project}/approve', [ProjectController::class, 'approve']);
    Route::patch('/projects/{project}/reject', [ProjectController::class, 'reject']);
});


Route::prefix('test')->group(function () {
    Route::get('/get-test', function () {
        return response()->json([
            'message' => 'This is a GET request for /test/get-test.',
            'data' => [
                'name' => 'Satendra Kumar',
                'age' => 25,
                'location' => 'Lucknow',
                'portfolio' => 'satendra.inceptionspark.com',
            ]
        ]);
    });

    Route::post('/post-test', function () {
        $data = request()->all();
        return response()->json([
            'message' => 'This is a POST request for /test/post-test.',
            'received_data' => $data,
        ]);
    });
    Route::get('/test-cookie', function () {
        $cookie = cookie('testCookie', 'testValue', 60, '/', request()->getHost(), true, true, false, 'lax');
        return response()->json(['message' => 'Cookie set'])->withCookie($cookie);
    });
});
