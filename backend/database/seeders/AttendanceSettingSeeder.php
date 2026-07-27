<?php

namespace Database\Seeders;

use App\Models\AttendanceSetting;
use Illuminate\Database\Seeder;

class AttendanceSettingSeeder extends Seeder
{
    public function run(): void
    {
        AttendanceSetting::query()->updateOrCreate(['id' => 1], [
            'check_in_time' => '07:30:00',
            'check_out_time' => '16:00:00',
            'timezone' => 'Asia/Jakarta',
            'applies_every_day' => true,
        ]);
    }
}
