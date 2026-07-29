<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Opd extends Model
{
    protected $table = 'opds';

    protected $fillable = [
        'name', 'nama_opd', 'code', 'alamat', 'kontak', 'logo_path', 'banner_path',
        'short_description', 'profile_description', 'field', 'category',
        'internship_status', 'kuota', 'internship_tasks', 'divisions', 'skills',
        'documentation_images', 'location', 'work_hours', 'contact_email',
        'contact_phone', 'website', 'additional_info', 'address',
        'attendance_latitude', 'attendance_longitude', 'attendance_radius_meters', 'kriteria',
    ];

    protected $casts = [
        'documentation_images' => 'array',
        'attendance_latitude'  => 'float',
        'attendance_longitude' => 'float',
        'kuota'                => 'integer',
    ];

    public function pendaftarans()
    {
        return $this->hasMany(Pendaftaran::class, 'opd_id');
    }

    public function bidangs()
    {
        return $this->hasMany(OpdBidang::class, 'opd_id');
    }

    public function testimonies()
    {
        return $this->hasMany(Testimony::class, 'opd_id');
    }

    public function mentors()
    {
        return $this->hasMany(Mentor::class, 'opd_id');
    }

    public function getTotalPesertaAktifAttribute(): int
    {
        return $this->pendaftarans()
            ->whereIn('status', ['accepted', 'aktif'])
            ->count();
    }

    public function getSisaSlotAttribute(): int
    {
        return max(0, ($this->kuota ?? 0) - $this->total_peserta_aktif);
    }

    public function getLogoUrlAttribute(): ?string
    {
        return $this->logo_path
            ? asset('storage/' . $this->logo_path)
            : null;
    }

    public function getBannerUrlAttribute(): ?string
    {
        return $this->banner_path
            ? asset('storage/' . $this->banner_path)
            : null;
    }

    public function getInternshipStatusLabelAttribute(): string
    {
        return match ($this->internship_status) {
            'terbuka' => 'Terbuka',
            'tutup'   => 'Tutup',
            'penuh'   => 'Penuh',
            default   => ucfirst($this->internship_status ?? ''),
        };
    }
}
