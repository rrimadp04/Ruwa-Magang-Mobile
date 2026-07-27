<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class AttendanceSetting extends Model
{
    protected $fillable = ['check_in_time', 'check_out_time', 'timezone', 'applies_every_day'];

    protected function casts(): array
    {
        return ['applies_every_day' => 'boolean'];
    }
}
