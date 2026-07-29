<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class OpdBidang extends Model
{
    protected $table = 'opd_bidangs';

    protected $fillable = ['opd_id', 'bidang_id', 'kuota'];

    public function opd()
    {
        return $this->belongsTo(Opd::class, 'opd_id');
    }

    public function bidang()
    {
        return $this->belongsTo(Bidang::class, 'bidang_id');
    }

    public function getPesertaAktifAttribute(): int
    {
        return Pendaftaran::where('opd_id', $this->opd_id)
            ->where('bidang_id', $this->bidang_id)
            ->whereIn('status', ['accepted', 'aktif'])
            ->count();
    }

    public function getSisaAttribute(): int
    {
        return max(0, ($this->kuota ?? 5) - $this->peserta_aktif);
    }

    public function getIsFullAttribute(): bool
    {
        return $this->sisa <= 0;
    }

    public function getStatusAttribute(): string
    {
        return $this->is_full ? 'penuh' : 'tersedia';
    }
}
