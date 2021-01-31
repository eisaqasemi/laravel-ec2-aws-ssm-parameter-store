<?php

use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
|
| Here is where you can register web routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| contains the "web" middleware group. Now create something great!
|
*/

Route::get('/', function () {
    return view('welcome');
});

Route::get('env-check', function () {
    return var_dump($_ENV);
});

Route::get('check2', function () {
    return '2222';
});

Route::get('check2', function () {
    return config('custom.myVar1');
});

