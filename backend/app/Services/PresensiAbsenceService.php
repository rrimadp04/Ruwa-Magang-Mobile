<?php

namespace App\Services;

use App\Models\AttendanceSetting;
use App\Models\Presensi;
use App\Models\User;
use Carbon\CarbonInterface;
use Illuminate\Support\Carbon;

class PresensiAbsenceService
{
    /**
     * Finalkan Tanpa Keterangan untuk satu tanggal.
     *
     * Sabtu dan Minggu sengaja tidak diproses sebagai ketidakhadiran karena
     * ditampilkan sebagai Libur oleh modul rincian. Hari libur nasional dapat
     * ditambahkan kemudian melalui tabel kalender kerja.
     */
    public function finalizeForDate(CarbonInterface $date): int
    {
        $setting = AttendanceSetting::query()->first();
        $timezone = $setting?->timezone ?? 'Asia/Jakarta';
        $localDate = Carbon::parse($date, $timezone)->startOfDay();

        if ($localDate->isWeekend()) {
            return 0;
        }

        $deadline = $localDate->copy()->setTimeFromTimeString(
            $setting?->check_out_time ?? '16:00:00',
        );

        if (Carbon::now($timezone)->lt($deadline)) {
            return 0;
        }

        $createdOrUpdated = 0;

        User::query()->select('id')->orderBy('id')->chunkById(200, function ($users) use ($localDate, &$createdOrUpdated): void {
            foreach ($users as $user) {
                $records = Presensi::query()
                    ->where('user_id', $user->id)
                    ->whereDate('presensi_date', $localDate->toDateString())
                    ->get(['id', 'type', 'status']);

                if ($records->contains('type', 'izin')) {
                    continue;
                }

                if (! $records->contains('type', 'datang')) {
                    Presensi::query()->firstOrCreate([
                        'user_id' => $user->id,
                        'presensi_date' => $localDate->toDateString(),
                        'type' => 'tanpa_keterangan',
                    ], [
                        'status' => 'tanpa_keterangan',
                        'absence_finalized_at' => now($localDate->timezone),
                    ]);
                    $createdOrUpdated++;
                    continue;
                }

                $checkout = $records->firstWhere('type', 'pulang');
                if ($checkout === null) {
                    Presensi::query()->firstOrCreate([
                        'user_id' => $user->id,
                        'presensi_date' => $localDate->toDateString(),
                        'type' => 'pulang',
                    ], [
                        'status' => 'tanpa_keterangan',
                        'absence_finalized_at' => now($localDate->timezone),
                    ]);
                    $createdOrUpdated++;
                }
            }
        });

        return $createdOrUpdated;
    }
}
