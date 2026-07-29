<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // ── bidangs ──────────────────────────────────────────────────────────
        if (!Schema::hasTable('bidangs')) {
            Schema::create('bidangs', function (Blueprint $table) {
                $table->id();
                $table->string('name')->unique();
                $table->timestamps();
            });
        }

        // ── opds ─────────────────────────────────────────────────────────────
        if (!Schema::hasTable('opds')) {
            Schema::create('opds', function (Blueprint $table) {
                $table->id();
                $table->string('name');
                $table->string('nama_opd')->nullable();
                $table->string('code')->nullable()->unique();
                $table->string('alamat')->nullable();
                $table->string('kontak')->nullable();
                $table->string('logo_path')->nullable();
                $table->string('banner_path')->nullable();
                $table->text('short_description')->nullable();
                $table->text('profile_description')->nullable();
                $table->string('field')->nullable();
                $table->string('category')->nullable();
                $table->string('internship_status')->default('terbuka');
                $table->integer('kuota')->default(10);
                $table->text('internship_tasks')->nullable();
                $table->text('divisions')->nullable();
                $table->text('skills')->nullable();
                $table->json('documentation_images')->nullable();
                $table->string('location')->nullable();
                $table->string('work_hours')->nullable();
                $table->string('contact_email')->nullable();
                $table->string('contact_phone')->nullable();
                $table->string('website')->nullable();
                $table->text('additional_info')->nullable();
                $table->string('address')->nullable();
                $table->decimal('attendance_latitude', 10, 7)->nullable();
                $table->decimal('attendance_longitude', 10, 7)->nullable();
                $table->integer('attendance_radius_meters')->nullable();
                $table->text('kriteria')->nullable();
                $table->timestamps();
            });
        }

        // ── opd_bidangs ───────────────────────────────────────────────────────
        if (!Schema::hasTable('opd_bidangs')) {
            Schema::create('opd_bidangs', function (Blueprint $table) {
                $table->id();
                $table->foreignId('opd_id')->constrained('opds')->cascadeOnDelete();
                $table->foreignId('bidang_id')->constrained('bidangs')->cascadeOnDelete();
                $table->integer('kuota')->default(5);
                $table->timestamps();
                $table->unique(['opd_id', 'bidang_id']);
            });
        }

        // ── pendaftarans ──────────────────────────────────────────────────────
        if (!Schema::hasTable('pendaftarans')) {
            Schema::create('pendaftarans', function (Blueprint $table) {
                $table->id();
                $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
                $table->foreignId('opd_id')->constrained('opds')->cascadeOnDelete();
                $table->foreignId('bidang_id')->nullable()->constrained('bidangs')->nullOnDelete();
                $table->string('bidang')->nullable();
                $table->string('university')->nullable();
                $table->string('prodi')->nullable();
                $table->string('status')->default('pending'); // pending|accepted|rejected
                $table->string('cv_path')->nullable();
                $table->string('transkrip_path')->nullable();
                $table->string('surat_path')->nullable();
                $table->date('start_date')->nullable();
                $table->date('end_date')->nullable();
                $table->text('catatan_penolakan')->nullable();
                $table->timestamps();
            });
        }

        // ── testimonies ───────────────────────────────────────────────────────
        if (!Schema::hasTable('testimonies')) {
            Schema::create('testimonies', function (Blueprint $table) {
                $table->id();
                $table->foreignId('peserta_id')->constrained('participants')->cascadeOnDelete();
                $table->foreignId('opd_id')->constrained('opds')->cascadeOnDelete();
                $table->tinyInteger('rating')->default(5);
                $table->text('message');
                $table->timestamps();
            });
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('testimonies');
        Schema::dropIfExists('pendaftarans');
        Schema::dropIfExists('opd_bidangs');
        Schema::dropIfExists('opds');
        Schema::dropIfExists('bidangs');
    }
};
