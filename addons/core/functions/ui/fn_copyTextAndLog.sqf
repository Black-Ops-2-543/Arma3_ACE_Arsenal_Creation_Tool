/*
 * Clipboard and local RPT use the SAME immutable string.
 * CODEPOINTS chunks are ASCII JSON arrays: preserve Unicode, quotes, CRLF/LF,
 * and blank lines without relying on RPT's string quoting or line wrapping.
 * 96 codepoints bound encoded lines, not the total export size.
 */
params [["_text", "", [""]], ["_context", "RACA export", [""]]];
forceUnicode 1;
copyToClipboard _text;
private _id = (uiNamespace getVariable ["RACA_copySerial", 0]) + 1;
uiNamespace setVariable ["RACA_copySerial", _id];
private _queue = uiNamespace getVariable ["RACA_copyQueue", []];
_queue pushBack [_id, _context, _text];
uiNamespace setVariable ["RACA_copyQueue", _queue];
if !(uiNamespace getVariable ["RACA_copyWorker", false]) then {
    uiNamespace setVariable ["RACA_copyWorker", true];
    [] spawn {
        forceUnicode 1;
        while {(uiNamespace getVariable ["RACA_copyQueue", []]) isNotEqualTo []} do {
            private _queue = uiNamespace getVariable ["RACA_copyQueue", []];
            (_queue deleteAt 0) params ["_id","_context","_text"];
            uiNamespace setVariable ["RACA_copyQueue", _queue];
            private _codes = toArray _text;
            private _chunks = ceil ((count _codes) / 96);
            private _checksum = 0;
            { _checksum = (_checksum + _x) mod 16777213 } forEach _codes;
            diag_log format ["[RACA][COPY:%1] BEGIN context=%2 units=%3 chunks=%4 encoding=CODEPOINTS checksum=%5", _id, toJSON _context, count _codes, _chunks, _checksum];
            for "_i" from 0 to (_chunks - 1) do {
                diag_log format ["[RACA][COPY:%1] CHUNK %2/%3 %4", _id, _i+1, _chunks, toJSON (_codes select [_i*96,96])];
                if ((_i mod 32) isEqualTo 0) then {uiSleep 0.001};
            };
            diag_log format ["[RACA][COPY:%1] END units=%2 chunks=%3 checksum=%4", _id, count _codes, _chunks, _checksum];
            uiNamespace setVariable ["RACA_copyCompleted", _id];
            if (hasInterface) then {systemChat format ["RACA: export %1 has finished writing to the local RPT.", _id]};
        };
        uiNamespace setVariable ["RACA_copyWorker", false];
    };
};
_id
