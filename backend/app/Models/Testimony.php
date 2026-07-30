<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Testimony extends Model
{
    protected $table = 'testimonies';
    protected $fillable = ['peserta_id', 'opd_id', 'rating', 'message'];

    public function opd()    { return $this->belongsTo(Opd::class, 'opd_id'); }
    public function peserta(){ return $this->belongsTo(Participant::class, 'peserta_id'); }
}
