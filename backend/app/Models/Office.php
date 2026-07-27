<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Office extends Model
{
    protected $fillable = ['name', 'address', 'latitude', 'longitude', 'attendance_radius_meters', 'is_active'];

    protected function casts(): array
    {
        return ['latitude' => 'float', 'longitude' => 'float', 'is_active' => 'boolean'];
    }

    public function presensis(): HasMany
    {
        return $this->hasMany(Presensi::class);
    }
}
