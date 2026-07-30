<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Logbook extends Model
{
    use HasFactory;

    protected $fillable = ['user_id', 'activity', 'logbook_date'];

    protected function casts(): array
    {
        return ['logbook_date' => 'date'];
    }
}
