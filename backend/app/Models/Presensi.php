<?php

namespace App\Models;

<<<<<<< HEAD
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Presensi extends Model
{
    protected $fillable = [
        'user_id', 'office_id', 'status', 'type', 'presensi_date', 'checked_at', 'note',
        'photo', 'proof_path', 'proof_mime_type', 'proof_size_bytes', 'latitude',
        'longitude', 'location_address', 'location_distance_meters', 'location_accuracy',
        'location_valid', 'absence_finalized_at',
    ];

    protected function casts(): array
    {
        return [
            'presensi_date' => 'date', 'checked_at' => 'datetime',
            'absence_finalized_at' => 'datetime', 'latitude' => 'float', 'longitude' => 'float',
            'location_valid' => 'boolean',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function office(): BelongsTo
    {
        return $this->belongsTo(Office::class);
    }
=======
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Presensi extends Model
{
    use HasFactory;

    protected $table = 'presensis';
    protected $fillable = ['user_id', 'presensi_date'];
    protected $casts = ['presensi_date' => 'date'];
>>>>>>> origin/develop
}
