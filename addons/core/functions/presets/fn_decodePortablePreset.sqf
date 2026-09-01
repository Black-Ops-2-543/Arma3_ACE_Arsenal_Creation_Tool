/*
 * Parses portable JSON without compile/call. Returns
 * [availablePreset, metadata, warnings]. Invalid input returns an empty preset.
 */
params [["_text", "", [""]]];

private _warnings = [];
if (_text isEqualTo "") exitWith {[[], [], ["The clipboard is empty."]]};
if ((count _text) > 2000000) exitWith {
    [[], [], ["The JSON exceeds the 2,000,000-character import safety limit."]]
};

private _decoded = fromJSON _text;
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
if ((count _rawPreset) > 68) exitWith {
    [[], [], _warnings + ["Preset data exceeds the 64-record metadata safety limit."]]
};
if ((count _metadata) > 256) exitWith {
    [[], [], _warnings + ["Portable metadata exceeds the 256-record safety limit."]]
};

private _rawBuckets = _rawPreset param [3, [], [[]]];
if ((count _rawBuckets) isNotEqualTo 4) exitWith {
    [[], [], _warnings + ["Preset cargo buckets are malformed."]]
};
private _referenceCount = 0;
{
    if (_x isEqualType []) then {_referenceCount = _referenceCount + count _x};
} forEach _rawBuckets;
for "_metadataIndex" from 4 to ((count _rawPreset) - 1) do {
    private _candidate = _rawPreset param [_metadataIndex, [], [[]]];
    private _tag = _candidate param [0, "", [""]];
    if (_tag in ["RACA_INHERITANCE", "RACA_ADOPTION", "RACA_COMPOSITION"]) then {
        private _additions = _candidate param [4, [], [[]]];
        {
            if (_x isEqualType []) then {_referenceCount = _referenceCount + count _x};
        } forEach _additions;
        private _removals = _candidate param [5, [], [[]]];
        _referenceCount = _referenceCount + count _removals;
    };
    if (_tag isEqualTo "RACA_RUNTIME") then {
        _referenceCount = _referenceCount + count (_candidate param [2, [], [[]]]);
    };
};
if (_referenceCount > 20000) exitWith {
    [[], [], _warnings + ["Preset data exceeds the 20,000-reference safety limit."]]
};

private _rawName = _rawPreset select 2;
if !(_rawName isEqualType "") exitWith {[[], [], _warnings + ["Preset name must be text."]]};
if (_rawName isEqualTo "" || {(count _rawName) > 128}) exitWith {
    [[], [], _warnings + ["Preset name must contain 1 to 128 characters."]]
};
if (({_x < 32 || {_x isEqualTo 127}} count toArray _rawName) > 0) exitWith {
    [[], [], _warnings + ["Preset name contains unsupported control characters."]]
};

([_rawPreset] call RACA_fnc_validatePreset) params ["_validated", "_validationWarnings"];
_warnings append _validationWarnings;
if (_validated isEqualTo []) exitWith {[[], [], _warnings]};

private _availableBuckets = [[], [], [], []];
{
    {
        private _className = _x;
        if ([_className] call RACA_fnc_isSafeClassName) then {
            ([_className] call RACA_fnc_classifyClass) params ["_bucket"];
            if (_bucket >= 0) then {
                (_availableBuckets select _bucket) pushBackUnique _className;
            } else {
                _warnings pushBackUnique format ["Missing item: %1", _className];
            };
        } else {
            _warnings pushBackUnique "An unsafe class name was rejected.";
        };
    } forEach _x;
} forEach (_validated select 3);

{_x sort true} forEach _availableBuckets;
private _availableCount = 0;
{_availableCount = _availableCount + count _x} forEach _availableBuckets;
if (_availableCount isEqualTo 0) exitWith {
    [[], [], _warnings + ["The import contains no available arsenal items."]]
};

private _availablePreset = ["RACA_PRESET", 1, _validated select 2, _availableBuckets];
private _composition = [_validated] call RACA_fnc_getComposition;
if (_composition isNotEqualTo []) then {
    _availablePreset pushBack _composition;
};

[_availablePreset, _metadata, _warnings]
