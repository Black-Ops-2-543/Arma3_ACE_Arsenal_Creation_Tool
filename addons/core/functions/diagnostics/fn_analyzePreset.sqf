/*
 * Returns [canApply, entries, summary]. Entry layout:
 * [severity, code, message, className, sourceMod, sourceAddon].
 */
params [
    ["_rawPreset", [], [[]]],
    ["_catalog", [], [[]]],
    ["_optionalClasses", [], [[]]]
];

private _entries = [];
private _sourceByClass = createHashMap;
{
    _x params ["", "_className", "", "", "_modName", "", "", "", ["_sourceAddon", ""]];
    _sourceByClass set [_className, [_modName, _sourceAddon]];
} forEach _catalog;

private _policy = [_rawPreset] call RACA_fnc_getRuntimePolicy;
private _requirements = _policy param [7, [], [[]]];
{
    _x params [["_className", "", [""]], ["_modName", "Unknown", [""]], ["_sourceAddon", "", [""]]];
    if (_className isNotEqualTo "" && {!(_className in _sourceByClass)}) then {
        _sourceByClass set [_className, [_modName, _sourceAddon]];
    };
} forEach _requirements;

if !(_rawPreset isEqualType []) exitWith {
    [false, [["ERROR", "INVALID_ROOT", "Preset data is not an array.", "", "", ""]], [1, 0, 0]]
};
if ((count _rawPreset) < 4) exitWith {
    [false, [["ERROR", "INCOMPLETE", "Preset data is incomplete.", "", "", ""]], [1, 0, 0]]
};

private _seen = createHashMap;
private _buckets = _rawPreset param [3, [], [[]]];
if ((count _buckets) isNotEqualTo 4) then {
    _entries pushBack ["ERROR", "BUCKET_SHAPE", "Preset cargo must contain four cargo buckets.", "", "", ""];
} else {
    {
        private _bucket = _x;
        private _sourceBucketIndex = _forEachIndex;
        if !(_bucket isEqualType []) then {
            _entries pushBack ["ERROR", "INVALID_BUCKET", format ["Cargo bucket %1 is not an array.", _forEachIndex], "", "", ""];
        } else {
            {
                private _className = _x;
                if !(_className isEqualType "") then {
                    _entries pushBack ["ERROR", "INVALID_CLASS_VALUE", "A cargo entry is not text.", "", "", ""];
                } else {
                    (_sourceByClass getOrDefault [_className, ["Unknown", ""]]) params ["_modName", "_sourceAddon"];
                    if (_seen getOrDefault [_className, false]) then {
                        _entries pushBack ["WARNING", "DUPLICATE_CLASS", format ["Duplicate class '%1' will be collapsed.", _className], _className, _modName, _sourceAddon];
                    } else {
                        _seen set [_className, true];
                    };

                    if !([_className] call RACA_fnc_isSafeClassName) then {
                        _entries pushBack ["ERROR", "UNSAFE_CLASS", format ["Unsafe class name '%1' was rejected.", _className], _className, _modName, _sourceAddon];
                    } else {
                        ([_className] call RACA_fnc_classifyClass) params ["_actualBucket"];
                        if (_actualBucket < 0) then {
                            private _optional = _className in _optionalClasses;
                            private _severity = ["ERROR", "WARNING"] select _optional;
                            private _requirement = ["required", "optional"] select _optional;
                            _entries pushBack [
                                _severity,
                                ["MISSING_REQUIRED", "MISSING_OPTIONAL"] select _optional,
                                format ["Unavailable %1 class '%2' (likely source: %3 / %4).", _requirement, _className, _modName, _sourceAddon],
                                _className,
                                _modName,
                                _sourceAddon
                            ];
                        } else {
                            if (_actualBucket isNotEqualTo _sourceBucketIndex) then {
                                _entries pushBack ["INFO", "BUCKET_REPAIRED", format ["'%1' will be moved to its correct ACE cargo bucket.", _className], _className, _modName, _sourceAddon];
                            };
                        };
                    };
                };
            } forEach _bucket;
        };
    } forEach _buckets;
};

private _errorCount = {(_x select 0) isEqualTo "ERROR"} count _entries;
private _warningCount = {(_x select 0) isEqualTo "WARNING"} count _entries;
private _infoCount = {(_x select 0) isEqualTo "INFO"} count _entries;
if (_entries isEqualTo []) then {
    _entries pushBack ["INFO", "READY", "Preset passed compatibility preflight.", "", "", ""];
    _infoCount = 1;
};

[_errorCount isEqualTo 0, _entries, [_errorCount, _warningCount, _infoCount]]
