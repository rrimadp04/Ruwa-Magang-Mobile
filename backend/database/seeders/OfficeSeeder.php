<?php

namespace Database\Seeders;

use App\Models\Office;
use Illuminate\Database\Seeder;

class OfficeSeeder extends Seeder
{
    public function run(): void
    {
        Office::query()->updateOrCreate(['name' => 'Dinas Komunikasi, Informatika dan Statistik Provinsi Lampung'], [
            'address' => 'Jl. R.W. Monginsidi No. 69, Telukbetung, Bandar Lampung, Lampung 35221',
            'latitude' => -5.4385120,
            'longitude' => 105.2587930,
            'attendance_radius_meters' => 250,
            'is_active' => true,
        ]);
    }
}
