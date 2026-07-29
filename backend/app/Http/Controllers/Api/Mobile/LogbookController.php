<?php

namespace App\Http\Controllers\Api\Mobile;

use App\Http\Controllers\Controller;
use App\Models\Logbook;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Schema;

class LogbookController extends Controller
{
    public function index(Request $request)
    {
        $this->ensureTable();

        return response()->json(['status' => 'success', 'data' => Logbook::where('user_id', $request->user()->id)
            ->latest('logbook_date')->latest()->get()->map(fn (Logbook $item) => $this->payload($item))]);
    }

    public function store(Request $request)
    {
        $this->ensureTable();
        $data = $request->validate(['activity' => ['required', 'string', 'max:2000'], 'logbook_date' => ['required', 'date']]);
        $item = Logbook::create(['user_id' => $request->user()->id, ...$data]);

        return response()->json(['status' => 'success', 'data' => $this->payload($item)], 201);
    }

    public function update(Request $request, Logbook $logbook)
    {
        $this->ensureOwner($request, $logbook);
        $data = $request->validate(['activity' => ['required', 'string', 'max:2000'], 'logbook_date' => ['required', 'date']]);
        $logbook->update($data);

        return response()->json(['status' => 'success', 'data' => $this->payload($logbook->fresh())]);
    }

    public function destroy(Request $request, Logbook $logbook)
    {
        $this->ensureOwner($request, $logbook);
        $logbook->delete();

        return response()->json(['status' => 'success']);
    }

    private function ensureTable(): void
    {
        abort_unless(Schema::hasTable('logbooks'), 503, 'Tabel logbook belum tersedia di database.');
    }

    private function ensureOwner(Request $request, Logbook $logbook): void
    {
        $this->ensureTable();
        abort_unless($logbook->user_id === $request->user()->id, 403);
    }

    private function payload(Logbook $item): array
    {
        return ['id' => $item->id, 'user_id' => $item->user_id, 'activity' => $item->activity, 'logbook_date' => $item->logbook_date?->toDateString(), 'status' => 'pending', 'created_at' => $item->created_at?->toISOString()];
    }
}
