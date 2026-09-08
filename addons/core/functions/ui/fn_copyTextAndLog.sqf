/*
 * Clipboard and local RPT use the SAME immutable string.
 * CODEPOINTS chunks are ASCII JSON arrays: preserve Unicode, quotes, CRLF/LF,
 * and blank lines without relying on RPT's string quoting or line wrapping.
 * 96 codepoints bound encoded lines, not the total export size.
 */
params [["_text", "", [""]], ["_context", "RACA export", [""]]];
forceUnicode 1;
copyToClipboard _text;
// Keep the marker below Arma's scientific-notation formatting threshold so
// operators can paste the exact visible ID into the host reconstructor.
private _id = ((uiNamespace getVariable ["RACA_copySerial", floor (random 900000)]) mod 999999) + 1;
uiNamespace setVariable ["RACA_copySerial", _id];
private _states = uiNamespace getVariable ["RACA_copyStates",createHashMap];
private _estimatedBytes = (count toArray _text) * 4;
private _state = ["queued",_context,_estimatedBytes,diag_tickTime,""];
_states set [str _id,_state];
_states deleteAt str (_id - 64);
uiNamespace setVariable ["RACA_copyStates",_states];
private _queue = uiNamespace getVariable ["RACA_copyQueue", []];
private _queuedBytes = uiNamespace getVariable ["RACA_copyQueuedBytes",0];
private _capacity = 4;
private _byteBudget = 2097152;
if ((count _queue) >= _capacity || {_queuedBytes + _estimatedBytes > _byteBudget}) exitWith {
    _state set [0,"failed"];
    _state set [4,format ["RPT queue backpressure: capacity %1 copies / %2 bytes.",_capacity,_byteBudget]];
    _states set [str _id,_state];
    uiNamespace setVariable ["RACA_copyStates",_states];
    diag_log format ["[RACA][COPY:%1] FAILED state=backpressure bytes=%2 queuedBytes=%3 capacity=%4 budget=%5 clipboard=complete",_id,_estimatedBytes,_queuedBytes,_capacity,_byteBudget];
    if (hasInterface) then {systemChat format ["RACA: clipboard copy %1 succeeded; RPT recovery was not queued because its bounded queue is full.",_id]};
    _id
};
_queue pushBack [_id, _context, _text,_estimatedBytes];
uiNamespace setVariable ["RACA_copyQueue", _queue];
uiNamespace setVariable ["RACA_copyQueuedBytes",_queuedBytes + _estimatedBytes];
if (hasInterface) then {systemChat format ["RACA: clipboard copy %1 succeeded; RPT recovery is queued.",_id]};
if !(uiNamespace getVariable ["RACA_copyWorker", false]) then {
    uiNamespace setVariable ["RACA_copyWorker", true];
    [] spawn {
        forceUnicode 1;
        while {(uiNamespace getVariable ["RACA_copyQueue", []]) isNotEqualTo []} do {
            private _queue = uiNamespace getVariable ["RACA_copyQueue", []];
            (_queue deleteAt 0) params ["_id","_context","_text","_estimatedBytes"];
            uiNamespace setVariable ["RACA_copyQueue", _queue];
            uiNamespace setVariable ["RACA_copyQueuedBytes",((uiNamespace getVariable ["RACA_copyQueuedBytes",0]) - _estimatedBytes) max 0];
            private _states = uiNamespace getVariable ["RACA_copyStates",createHashMap];
            private _state = _states getOrDefault [str _id,["queued",_context,_estimatedBytes,diag_tickTime,""]];
            _state set [0,"writing"];
            _states set [str _id,_state];
            uiNamespace setVariable ["RACA_copyStates",_states];
            private _codes = toArray _text;
            private _chunks = ceil ((count _codes) / 96);
            private _digestA = 104729;
            private _digestB = 130363;
            {
                // Each multiplication remains below 2^24, Arma's exact
                // integer range. Apply the modulus before subsequent additions
                // so the host can reproduce the digest without float drift.
                _digestA = (_digestA * 2) mod 8388593;
                _digestA = (_digestA + _x) mod 8388593;
                _digestA = (_digestA + (_forEachIndex mod 4093)) mod 8388593;
                _digestB = (_digestB * 3) mod 5592403;
                _digestB = (_digestB + _x) mod 5592403;
                _digestB = (_digestB + ((_forEachIndex mod 4093) * 3)) mod 5592403;
            } forEach _codes;
            private _decimalString = {
                params ["_number"];
                private _remaining = floor _number;
                if (_remaining isEqualTo 0) exitWith {"0"};
                private _digits = [];
                while {_remaining > 0} do {
                    _digits pushBack (toString [48 + (_remaining mod 10)]);
                    _remaining = floor (_remaining / 10);
                };
                reverse _digits;
                _digits joinString ""
            };
            private _digest = format ["P23X2-%1-%2",[_digestA] call _decimalString,[_digestB] call _decimalString];
            diag_log format ["[RACA][COPY:%1] BEGIN version=3 context=%2 units=%3 chunks=%4 encoding=CODEPOINTS digest=%5", _id, toJSON _context, count _codes, _chunks, _digest];
            for "_i" from 0 to (_chunks - 1) do {
                diag_log format ["[RACA][COPY:%1] CHUNK %2/%3 %4", _id, _i+1, _chunks, toJSON (_codes select [_i*96,96])];
                if ((_i mod 32) isEqualTo 0) then {uiSleep 0.001};
            };
            diag_log format ["[RACA][COPY:%1] END version=3 units=%2 chunks=%3 digest=%4", _id, count _codes, _chunks, _digest];
            _state set [0,"complete"];
            _state set [4,""];
            _states set [str _id,_state];
            uiNamespace setVariable ["RACA_copyStates",_states];
            uiNamespace setVariable ["RACA_copyCompleted", _id];
            if (hasInterface) then {systemChat format ["RACA: export %1 has finished writing to the local RPT.", _id]};
        };
        uiNamespace setVariable ["RACA_copyWorker", false];
    };
};
_id
