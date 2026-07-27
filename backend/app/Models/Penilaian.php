<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Penilaian extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id', 'file_path', 'status', 'nilai_akhir', 'predikat', 'reviewer',
        'tanggal_review', 'komentar',
    ];

    protected function casts(): array
    {
        return ['tanggal_review' => 'date', 'nilai_akhir' => 'decimal:2'];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
