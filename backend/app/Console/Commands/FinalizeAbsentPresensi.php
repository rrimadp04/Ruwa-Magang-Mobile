<?php

namespace App\Console\Commands;

use App\Services\PresensiAbsenceService;
use Illuminate\Console\Command;

class FinalizeAbsentPresensi extends Command
{
    protected $signature = 'presensi:finalize-absence {--date= : Tanggal YYYY-MM-DD, default hari ini}';

    protected $description = 'Menandai peserta yang belum lengkap presensi setelah jam pulang sebagai Tanpa Keterangan';

    public function handle(PresensiAbsenceService $absenceService): int
    {
        $date = $this->option('date') ?: now('Asia/Jakarta')->toDateString();
        $count = $absenceService->finalizeForDate(now('Asia/Jakarta')->parse($date));

        $this->info("{$count} data Tanpa Keterangan diproses untuk {$date}.");

        return self::SUCCESS;
    }
}
