<?php

use Illuminate\Foundation\Inspiring;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\Schedule;

Artisan::command('inspire', function () {
    $this->comment(Inspiring::quote());
})->purpose('Display an inspiring quote');

// Dijalankan tiap menit; service hanya melakukan perubahan setelah jam pulang.
Schedule::command('presensi:finalize-absence')->everyMinute()->withoutOverlapping();
