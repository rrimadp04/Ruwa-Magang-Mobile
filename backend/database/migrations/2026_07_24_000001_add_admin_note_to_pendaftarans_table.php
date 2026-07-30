<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('pendaftarans', function (Blueprint $table) {
            if (!Schema::hasColumn('pendaftarans', 'admin_note')) {
                $table->text('admin_note')->nullable()->after('catatan_penolakan');
            }
            if (!Schema::hasColumn('pendaftarans', 'note')) {
                $table->text('note')->nullable()->after('admin_note');
            }
        });
    }

    public function down(): void
    {
        Schema::table('pendaftarans', function (Blueprint $table) {
            $table->dropColumnIfExists('admin_note');
            $table->dropColumnIfExists('note');
        });
    }
};
