<?php

return [

    /*
    |--------------------------------------------------------------------------
    | Titik Lokasi Kantor OPD (Geofencing)
    |--------------------------------------------------------------------------
    |
    | Koordinat pusat area kantor OPD tempat peserta magang ditempatkan,
    | beserta radius maksimum (dalam meter) yang dianggap valid untuk
    | melakukan presensi datang/pulang.
    |
    | TODO: jika setiap peserta bisa ditempatkan di OPD berbeda-beda,
    | pindahkan office_latitude/office_longitude/radius_meters ini
    | menjadi kolom pada tabel penempatan/peserta, lalu ambil nilainya
    | dari relasi user->peserta->opd pada PresensiController.
    |
    */

    'office_latitude' => (float) env('PRESENSI_OFFICE_LAT', -5.438512),
    'office_longitude' => (float) env('PRESENSI_OFFICE_LNG', 105.258793),
    'radius_meters' => (int) env('PRESENSI_RADIUS_METERS', 250),

    /*
    |--------------------------------------------------------------------------
    | Jam Kerja
    |--------------------------------------------------------------------------
    */

    'jam_masuk' => env('PRESENSI_JAM_MASUK', '07:30'),
    'jam_pulang' => env('PRESENSI_JAM_PULANG', '16:00'),

];
