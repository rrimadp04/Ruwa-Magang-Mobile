<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Pendaftaran extends Model
{
    protected $table = 'pendaftarans';

    protected $fillable = [
        'user_id', 'opd_id', 'bidang_id', 'bidang',
        'university', 'prodi', 'status',
        'cv_path', 'transkrip_path', 'surat_path',
        'start_date', 'end_date',
        'catatan_penolakan', 'admin_note', 'note',
    ];

    protected $casts = [
        'start_date' => 'date',
        'end_date'   => 'date',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function opd()
    {
        return $this->belongsTo(Opd::class, 'opd_id');
    }

    public function bidangRelasi()
    {
        return $this->belongsTo(Bidang::class, 'bidang_id');
    }

    public function getCvUrlAttribute(): ?string
    {
        return $this->cv_path ? asset('storage/' . $this->cv_path) : null;
    }

    public function getTranskripUrlAttribute(): ?string
    {
        return $this->transkrip_path ? asset('storage/' . $this->transkrip_path) : null;
    }

    public function getSuratUrlAttribute(): ?string
    {
        return $this->surat_path ? asset('storage/' . $this->surat_path) : null;
    }
}
