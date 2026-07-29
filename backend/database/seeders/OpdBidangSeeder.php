<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class OpdBidangSeeder extends Seeder
{
    // 15 bidang dari sistem_magang
    private array $bidangs = [
        'BIDANG LAYANAN, TEKNOLOGI INFORMASI DAN KOMUNIKASI, PELESTARIAN, DAN KERJASAMA',
        'BIDANG AKUNTANSI',
        'BIDANG KESEHATAN MASYARAKAT',
        'BIDANG ENERGI',
        'BIDANG HUKUM',
        'BIDANG PENGELOLAAN DAN LAYANAN INFORMASI PUBLIK',
        'BIDANG PENGELOLAAN DAERAH ALIRAN SUNGAI (DAS) DAN REHABILITASI HUTAN DAN LAHAN (RHL)',
        'BIDANG PERENCANAAN DAN PEMANFAATAN HUTAN',
        'BIDANG PERLINDUNGAN DAN KONSERVASI HUTAN',
        'BIDANG PERSANDIAN DAN STATISTIK',
        'BIDANG PENYULUHAN, PEMBERDAYAAN MASYARAKAT DAN USAHA KEHUTANAN',
        'BIDANG PENGADAAN, PEMBERHENTIAN DAN INFORMASI KEPEGAWAIAN',
        'BIDANG TEKNOLOGI INFORMASI DAN KOMUNIKASI',
        'BIDANG BINA KONSTRUKSI',
        'SEKRETARIAT',
    ];

    // OPD utama (instansi pemerintah provinsi)
    private array $opds = [
        ['name' => 'BIRO PENGADAAN BARANG DAN JASA', 'code' => '1004110000', 'category' => 'Biro', 'field' => 'Administrasi Pemerintahan'],
        ['name' => 'BIRO ADMINISTRASI PIMPINAN', 'code' => '1004120000', 'category' => 'Biro', 'field' => 'Administrasi Pemerintahan'],
        ['name' => 'SEKRETARIAT DAERAH PROVINSI', 'code' => '1004010000', 'category' => 'Sekretariat', 'field' => 'Administrasi Pemerintahan'],
        ['name' => 'ASISTEN PEMERINTAHAN DAN KESEJAHTERAAN RAKYAT', 'code' => '1004020000', 'category' => 'Asisten', 'field' => 'Administrasi Pemerintahan'],
        ['name' => 'ASISTEN PEREKONOMIAN, DAN PEMBANGUNAN', 'code' => '1004030000', 'category' => 'Asisten', 'field' => 'Perencanaan dan Pembangunan'],
        ['name' => 'ASISTEN ADMINISTRASI UMUM', 'code' => '1004040000', 'category' => 'Asisten', 'field' => 'Administrasi Pemerintahan'],
        ['name' => 'BIRO PEMERINTAHAN DAN OTONOMI DAERAH', 'code' => '1004050000', 'category' => 'Biro', 'field' => 'Administrasi Pemerintahan'],
        ['name' => 'BIRO HUKUM', 'code' => '1004060000', 'category' => 'Biro', 'field' => 'Hukum'],
        ['name' => 'BIRO KESEJAHTERAAN RAKYAT', 'code' => '1004070000', 'category' => 'Biro', 'field' => 'Sosial dan Pemberdayaan'],
        ['name' => 'BIRO PEREKONOMIAN', 'code' => '1004080000', 'category' => 'Biro', 'field' => 'Ekonomi dan Pembangunan'],
        ['name' => 'BIRO ORGANISASI', 'code' => '1004130000', 'category' => 'Biro', 'field' => 'Administrasi Pemerintahan'],
        ['name' => 'STAF AHLI GUBERNUR BIDANG PEMERINTAHAN, HUKUM DAN POLITIK', 'code' => '1004140000', 'category' => 'Unit Pelaksana', 'field' => 'Administrasi Pemerintahan'],
        ['name' => 'STAF AHLI GUBERNUR BIDANG EKONOMI, KEUANGAN DAN PEMBANGUNAN', 'code' => '1004150000', 'category' => 'Unit Pelaksana', 'field' => 'Keuangan dan Aset'],
        ['name' => 'STAF AHLI GUBERNUR BIDANG KEMASYARAKATAN DAN SUMBER DAYA MANUSIA', 'code' => '1004160000', 'category' => 'Unit Pelaksana', 'field' => 'Sosial dan Pemberdayaan'],
        ['name' => 'SEKRETARIAT DPRD', 'code' => '1004170000', 'category' => 'Sekretariat', 'field' => 'Administrasi Pemerintahan'],
        ['name' => 'INSPEKTORAT PROVINSI', 'code' => '1004180000', 'category' => 'Inspektorat', 'field' => 'Administrasi Pemerintahan'],
        ['name' => 'DINAS PENDIDIKAN DAN KEBUDAYAAN', 'code' => '1005010000', 'category' => 'Dinas', 'field' => 'Pendidikan'],
        ['name' => 'DINAS KESEHATAN', 'code' => '1005020000', 'category' => 'Dinas', 'field' => 'Kesehatan'],
        ['name' => 'DINAS BINA MARGA DAN BINA KONSTRUKSI', 'code' => '1005030000', 'category' => 'Dinas', 'field' => 'Infrastruktur dan Tata Ruang'],
        ['name' => 'DINAS PENGELOLAAN SUMBER DAYA AIR', 'code' => '1005040000', 'category' => 'Dinas', 'field' => 'Infrastruktur dan Tata Ruang'],
        ['name' => 'SATUAN POLISI PAMONG PRAJA', 'code' => '1005050000', 'category' => 'Satuan', 'field' => 'Ketenteraman dan Kebencanaan'],
        ['name' => 'DINAS SOSIAL', 'code' => '1005060000', 'category' => 'Dinas', 'field' => 'Sosial dan Pemberdayaan'],
        ['name' => 'DINAS TENAGA KERJA', 'code' => '1005070000', 'category' => 'Dinas', 'field' => 'Sosial dan Pemberdayaan'],
        ['name' => 'DINAS PEMBERDAYAAN PEREMPUAN DAN PERLINDUNGAN ANAK', 'code' => '1005080000', 'category' => 'Dinas', 'field' => 'Sosial dan Pemberdayaan'],
        ['name' => 'DINAS PETERNAKAN DAN KESEHATAN HEWAN', 'code' => '1005090000', 'category' => 'Dinas', 'field' => 'Pertanian dan Ketahanan Pangan'],
        ['name' => 'DINAS KEPENDUDUKAN DAN PENCATATAN SIPIL', 'code' => '1005110000', 'category' => 'Dinas', 'field' => 'Administrasi Pemerintahan'],
        ['name' => 'DINAS PEMBERDAYAAN MASYARAKAT, DESA DAN TRANSMIGRASI', 'code' => '1005120000', 'category' => 'Dinas', 'field' => 'Sosial dan Pemberdayaan'],
        ['name' => 'DINAS PERHUBUNGAN', 'code' => '1005130000', 'category' => 'Dinas', 'field' => 'Perhubungan'],
        ['name' => 'DINAS KOMUNIKASI, INFORMATIKA DAN STATISTIK', 'code' => '1005140000', 'category' => 'Dinas', 'field' => 'Komunikasi dan Informatika'],
        ['name' => 'DINAS KOPERASI, USAHA KECIL DAN MENENGAH', 'code' => '1005150000', 'category' => 'Dinas', 'field' => 'Ekonomi dan Pembangunan'],
        ['name' => 'DINAS PENANAMAN MODAL DAN PELAYANAN TERPADU SATU PINTU', 'code' => '1005160000', 'category' => 'Dinas', 'field' => 'Ekonomi dan Pembangunan'],
        ['name' => 'DINAS PEMUDA DAN OLAHRAGA', 'code' => '1005170000', 'category' => 'Dinas', 'field' => 'Olahraga dan Kepemudaan'],
        ['name' => 'DINAS PERPUSTAKAAN DAN KEARSIPAN', 'code' => '1005180000', 'category' => 'Dinas', 'field' => 'Arsip dan Perpustakaan'],
        ['name' => 'DINAS KELAUTAN DAN PERIKANAN', 'code' => '1005190000', 'category' => 'Dinas', 'field' => 'Kelautan dan Perikanan'],
        ['name' => 'DINAS KETAHANAN PANGAN, TANAMAN PANGAN, DAN HORTIKULTURA', 'code' => '1005210000', 'category' => 'Dinas', 'field' => 'Pertanian dan Ketahanan Pangan'],
        ['name' => 'DINAS PERKEBUNAN', 'code' => '1005220000', 'category' => 'Dinas', 'field' => 'Pertanian dan Ketahanan Pangan'],
        ['name' => 'DINAS KEHUTANAN', 'code' => '1005230000', 'category' => 'Dinas', 'field' => 'Lingkungan Hidup'],
        ['name' => 'DINAS ENERGI DAN SUMBER DAYA MINERAL', 'code' => '1005240000', 'category' => 'Dinas', 'field' => 'Energi dan Sumber Daya'],
        ['name' => 'DINAS PERINDUSTRIAN DAN PERDAGANGAN', 'code' => '1005250000', 'category' => 'Dinas', 'field' => 'Perindustrian dan Perdagangan'],
        ['name' => 'DINAS PERUMAHAN, KAWASAN PERMUKIMAN DAN CIPTA KARYA', 'code' => '1005270000', 'category' => 'Dinas', 'field' => 'Infrastruktur dan Tata Ruang'],
        ['name' => 'BADAN PERENCANAAN PEMBANGUNAN DAERAH', 'code' => '1006010000', 'category' => 'Badan', 'field' => 'Perencanaan dan Pembangunan'],
        ['name' => 'BADAN PENGELOLAAN KEUANGAN DAN ASET DAERAH', 'code' => '1006020000', 'category' => 'Badan', 'field' => 'Keuangan dan Aset'],
        ['name' => 'BADAN PENDAPATAN DAERAH', 'code' => '1006030000', 'category' => 'Badan', 'field' => 'Keuangan dan Aset'],
        ['name' => 'BADAN KEPEGAWAIAN DAERAH', 'code' => '1006040000', 'category' => 'Badan', 'field' => 'Administrasi Pemerintahan'],
        ['name' => 'BADAN PENGEMBANGAN SUMBER DAYA MANUSIA DAERAH', 'code' => '1006050000', 'category' => 'Badan', 'field' => 'Administrasi Pemerintahan'],
        ['name' => 'BADAN PENELITIAN DAN PENGEMBANGAN DAERAH', 'code' => '1006060000', 'category' => 'Badan', 'field' => 'Perencanaan dan Pembangunan'],
        ['name' => 'BADAN PENGHUBUNG', 'code' => '1006070000', 'category' => 'Badan', 'field' => 'Administrasi Pemerintahan'],
        ['name' => 'BADAN PENANGGULANGAN BENCANA DAERAH', 'code' => '1006080000', 'category' => 'Badan', 'field' => 'Ketenteraman dan Kebencanaan'],
        ['name' => 'BADAN KESATUAN BANGSA DAN POLITIK DAERAH', 'code' => '1007010000', 'category' => 'Badan', 'field' => 'Administrasi Pemerintahan'],
        ['name' => 'RUMAH SAKIT UMUM DAERAH DR. Hi. ABDUL MOELOEK', 'code' => '1007030000', 'category' => 'Rumah Sakit', 'field' => 'Kesehatan'],
        ['name' => 'RUMAH SAKIT JIWA DAERAH', 'code' => '1007040000', 'category' => 'Rumah Sakit', 'field' => 'Kesehatan'],
        ['name' => 'RUMAH SAKIT UMUM DAERAH BANDAR NEGARA HUSADA', 'code' => '1007050000', 'category' => 'Rumah Sakit', 'field' => 'Kesehatan'],
        ['name' => 'BIRO ADMINISTRASI PEMBANGUNAN', 'code' => '1004090000', 'category' => 'Biro', 'field' => 'Perencanaan dan Pembangunan'],
        ['name' => 'SEKRETARIAT KOMISI PEMILIHAN UMUM (KPU)', 'code' => '1013010000', 'category' => 'Sekretariat', 'field' => 'Administrasi Pemerintahan'],
        ['name' => 'SEKRETARIAT BADAN NARKOTIKA NASIONAL', 'code' => '1014010000', 'category' => 'Sekretariat', 'field' => 'Ketenteraman dan Kebencanaan'],
    ];

    public function run(): void
    {
        $now = now();

        // Seed bidangs
        foreach ($this->bidangs as $name) {
            DB::table('bidangs')->updateOrInsert(
                ['name' => $name],
                ['created_at' => $now, 'updated_at' => $now]
            );
        }

        $bidangIds = DB::table('bidangs')->pluck('id', 'name');

        // Seed opds
        foreach ($this->opds as $opd) {
            $exists = DB::table('opds')->where('code', $opd['code'])->first();
            if (!$exists) {
                DB::table('opds')->insert([
                    'name'             => $opd['name'],
                    'nama_opd'         => $opd['name'],
                    'code'             => $opd['code'],
                    'field'            => $opd['field'],
                    'category'         => $opd['category'],
                    'internship_status'=> 'terbuka',
                    'kuota'            => 75,
                    'created_at'       => $now,
                    'updated_at'       => $now,
                ]);
            }
        }

        // Seed opd_bidangs — setiap OPD mendapat semua 15 bidang, kuota 5 per bidang
        $opdIds = DB::table('opds')->pluck('id');
        foreach ($opdIds as $opdId) {
            foreach ($bidangIds as $bidangId) {
                $exists = DB::table('opd_bidangs')
                    ->where('opd_id', $opdId)
                    ->where('bidang_id', $bidangId)
                    ->exists();
                if (!$exists) {
                    DB::table('opd_bidangs')->insert([
                        'opd_id'     => $opdId,
                        'bidang_id'  => $bidangId,
                        'kuota'      => 5,
                        'created_at' => $now,
                        'updated_at' => $now,
                    ]);
                }
            }
        }
    }
}
