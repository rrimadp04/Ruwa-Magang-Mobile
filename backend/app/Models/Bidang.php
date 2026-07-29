<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Bidang extends Model
{
    protected $table = 'bidangs';

    protected $fillable = ['name'];

    public function opdBidangs()
    {
        return $this->hasMany(OpdBidang::class, 'bidang_id');
    }
}
