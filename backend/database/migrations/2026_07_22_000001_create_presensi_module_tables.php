<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (! Schema::hasTable('offices')) {
            Schema::create('offices', function (Blueprint $table) {
                $table->id();
                $table->string('name');
                $table->string('address');
                $table->decimal('latitude', 10, 7);
                $table->decimal('longitude', 10, 7);
                $table->unsignedInteger('attendance_radius_meters')->default(250);
                $table->boolean('is_active')->default(true);
                $table->timestamps();
            });
        }

        if (! Schema::hasTable('attendance_settings')) {
            Schema::create('attendance_settings', function (Blueprint $table) {
                $table->id();
                $table->time('check_in_time')->default('07:30:00');
                $table->time('check_out_time')->default('16:00:00');
                $table->string('timezone', 64)->default('Asia/Jakarta');
                $table->boolean('applies_every_day')->default(true);
                $table->timestamps();
            });
        }

        if (! Schema::hasTable('presensis')) {
            Schema::create('presensis', function (Blueprint $table) {
                $table->id();
                $table->foreignId('user_id')->constrained()->cascadeOnDelete();
                $table->foreignId('office_id')->nullable()->constrained('offices')->nullOnDelete();
                $table->enum('status', ['hadir', 'izin', 'tanpa_keterangan', 'libur']);
                $table->enum('type', ['datang', 'pulang', 'izin', 'tanpa_keterangan']);
                $table->date('presensi_date');
                $table->timestamp('checked_at')->nullable();
                $table->text('note')->nullable();
                $table->string('photo')->nullable();
                $table->string('proof_path')->nullable();
                $table->string('proof_mime_type', 100)->nullable();
                $table->unsignedInteger('proof_size_bytes')->nullable();
                $table->decimal('latitude', 10, 7)->nullable();
                $table->decimal('longitude', 10, 7)->nullable();
                $table->string('location_address')->nullable();
                $table->unsignedInteger('location_distance_meters')->nullable();
                $table->unsignedInteger('location_accuracy')->nullable();
                $table->boolean('location_valid')->nullable();
                $table->timestamp('absence_finalized_at')->nullable();
                $table->timestamps();
                $table->unique(['user_id', 'presensi_date', 'type']);
                $table->index(['user_id', 'presensi_date', 'status']);
            });
        } else {
            Schema::table('presensis', function (Blueprint $table) {
                $table->foreignId('office_id')->nullable()->after('user_id')->constrained('offices')->nullOnDelete();
                $table->string('status', 24)->default('hadir')->after('office_id');
                $table->string('type', 24)->default('datang')->after('status');
                $table->timestamp('checked_at')->nullable()->after('presensi_date');
                $table->text('note')->nullable()->after('checked_at');
                $table->string('photo')->nullable()->after('note');
                $table->string('proof_path')->nullable()->after('photo');
                $table->string('proof_mime_type', 100)->nullable()->after('proof_path');
                $table->unsignedInteger('proof_size_bytes')->nullable()->after('proof_mime_type');
                $table->decimal('latitude', 10, 7)->nullable()->after('proof_size_bytes');
                $table->decimal('longitude', 10, 7)->nullable()->after('latitude');
                $table->string('location_address')->nullable()->after('longitude');
                $table->unsignedInteger('location_distance_meters')->nullable()->after('location_address');
                $table->unsignedInteger('location_accuracy')->nullable()->after('location_distance_meters');
                $table->boolean('location_valid')->nullable()->after('location_accuracy');
                $table->timestamp('absence_finalized_at')->nullable()->after('location_valid');
                $table->unique(['user_id', 'presensi_date', 'type']);
                $table->index(['user_id', 'presensi_date', 'status']);
            });
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('presensis');
        Schema::dropIfExists('attendance_settings');
        Schema::dropIfExists('offices');
    }
};
