<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Sertifikat extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id', 'nama_sertifikat', 'nomor_sertifikat', 'status',
        'tanggal_terbit', 'penerbit', 'file_path',
    ];

    protected function casts(): array
    {
        return ['tanggal_terbit' => 'date'];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
