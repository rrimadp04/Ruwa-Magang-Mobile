<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('participants', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->unique()->constrained()->cascadeOnDelete();
            $table->string('status', 20)->default('pending');
            $table->timestamps();
        });

        Schema::create('logbooks', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->date('logbook_date')->nullable();
            $table->text('activity')->nullable();
            $table->timestamps();
        });

        Schema::create('presensis', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->date('presensi_date');
            $table->timestamps();
            $table->index(['user_id', 'presensi_date']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('presensis');
        Schema::dropIfExists('logbooks');
        Schema::dropIfExists('participants');
    }
};
