/*
 * Emits payload-free, ordered import telemetry.
 * Details must be aggregate scalar values from trusted call sites only.
 */
params [
    ["_operation", [], [[]]],
    ["_phase", "", [""]],
    ["_started", -1, [0]],
    ["_details", [], [[]]],
    ["_terminal", false, [false]]
];
if (_operation isEqualTo [] || {_phase isEqualTo ""}) exitWith {};
_operation params ["_owner", "_generation", "_dialog", "_id", ["_state", createHashMap, [createHashMap]]];

private _sequence = (_state getOrDefault ["sequence", 0]) + 1;
_state set ["sequence", _sequence];
private _elapsed = if (_started < 0) then {0} else {(diag_tickTime - _started) max 0};
private _safeDetails = [];
{
    _x params [["_key", "", [""]], ["_value", 0, [0, false, ""]]];
    if (_key in ["format", "characters", "candidates", "available", "unavailable", "warnings", "committed", "result"]) then {
        if (_value isEqualType "") then {
            if (_value in ["JSON", "SQF_LIST", "SUCCESS", "CANCELLED", "FAILED", "YES", "NO"]) then {
                _safeDetails pushBack format ["%1=%2", _key, _value];
            };
        } else {
            _safeDetails pushBack format ["%1=%2", _key, _value];
        };
    };
} forEach _details;

diag_log format [
    "[RACA][IMPORT:%1][%2:%3] phase=%4 seconds=%5 %6",
    _id,
    ["PHASE", "TERMINAL"] select _terminal,
    _sequence,
    _phase,
    _elapsed,
    _safeDetails joinString " "
];
