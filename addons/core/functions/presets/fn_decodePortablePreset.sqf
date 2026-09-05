/*
 * Parses portable JSON without compile/call. Returns
 * [authoredPreset, metadata, warnings]. Invalid input returns an empty preset.
 */
params [["_text", "", [""]], ["_operation", [], [[]]]];

private _warnings = [];
if (_text isEqualTo "") exitWith {[[], [], ["The clipboard is empty."]]};

private _parseStarted = diag_tickTime;
private _decoded = fromJSON _text;
[_operation, "lexical_scan", _parseStarted, []] call RACA_fnc_importTelemetry;
if !([_operation, "Validating JSON", 0, 1] call RACA_fnc_importCheckpoint) exitWith {[[], [], ["Import cancelled."]]};
if (isNil "_decoded") exitWith {[[], [], ["The clipboard does not contain valid JSON."]]};
if !(_decoded isEqualType []) exitWith {[[], [], ["The JSON root must be an array."]]};

private _rawPreset = [];
private _metadata = [];
private _signature = _decoded param [0, "", [""]];
if (_signature isEqualTo "RACA_PORTABLE_PRESET" && {(count _decoded) > 4}) exitWith {
    [[], [], ["The portable envelope contains too many top-level fields."]]
};

if (_signature isEqualTo "RACA_PORTABLE_PRESET") then {
    private _formatVersion = _decoded param [1, -1, [0]];
    if (_formatVersion in [1, 2]) then {
        _rawPreset = _decoded param [2, [], [[]]];
        _metadata = _decoded param [3, [], [[]]];
        if (_formatVersion isEqualTo 1) then {
            _warnings pushBack "Migrated portable format 1 to format 2.";
        };
    } else {
        if (_formatVersion isEqualTo 0) then {
            // Supported legacy transport: [signature, 0, name, buckets].
            _rawPreset = [
                "RACA_PRESET",
                1,
                _decoded param [2, "", [""]],
                _decoded param [3, [], [[]]]
            ];
            _warnings pushBack "Migrated legacy portable format 0 to format 1.";
        } else {
            _warnings pushBack format ["Portable format version %1 is not supported.", _formatVersion];
        };
    };
} else {
    if (_signature isEqualTo "RACA_PRESET") then {
        // Pre-portable profile/mission arrays are accepted and wrapped safely.
        _rawPreset = _decoded;
        _warnings pushBack "Migrated a legacy raw preset into the portable format.";
    } else {
        _warnings pushBack "The import signature is not recognized.";
    };
};

if (_rawPreset isEqualTo []) exitWith {[[], [], _warnings]};
if ((count _rawPreset) < 4) exitWith {[[], [], _warnings + ["Preset data is incomplete."]]};
private _rawName = _rawPreset select 2;
if !(_rawName isEqualType "") exitWith {[[], [], _warnings + ["Preset name must be text."]]};
if (_rawName isEqualTo "" || {(count _rawName) > 128}) exitWith {
    [[], [], _warnings + ["Preset name must contain 1 to 128 characters."]]
};
if (({_x < 32 || {_x isEqualTo 127}} count toArray _rawName) > 0) exitWith {
    [[], [], _warnings + ["Preset name contains unsupported control characters."]]
};

private _validationStarted = diag_tickTime;
([_rawPreset, _operation] call RACA_fnc_validatePreset) params ["_validated", "_validationWarnings"];
_warnings append _validationWarnings;
private _available = 0;
if (_validated isNotEqualTo []) then {{_available = _available + count _x} forEach (_validated select 3)};
private _unavailable = {_x find "Missing item:" isEqualTo 0} count _validationWarnings;
[_operation, "preset_validation", _validationStarted, [["available", _available], ["unavailable", _unavailable], ["warnings", count _warnings]]] call RACA_fnc_importTelemetry;
if (_validated isEqualTo []) exitWith {[[], [], _warnings]};
if ((_warnings findIf {_x find "unsafe class" >= 0 || {_x find "non-text class" >= 0}}) >= 0) exitWith {[[], [], _warnings + ["Unsafe or non-text cargo was rejected; no preset was imported."]]};

// Validation preserves authored unavailable entries and all supported metadata.
// Decoding never stamps a local revision or mutates the profile library.
[_validated, _metadata, _warnings]
