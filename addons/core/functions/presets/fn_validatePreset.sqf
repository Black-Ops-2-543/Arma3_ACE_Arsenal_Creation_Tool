/* Returns [validatedPreset, warnings]. Invalid presets return an empty preset. */
params [["_preset", [], [[]]]];

private _warnings = [];
([_preset] call RACA_fnc_migratePreset) params ["_migrated", "_migrationNotices", "_futureUntouched"];
_warnings append _migrationNotices;
if (_futureUntouched) exitWith {[[], _warnings]};
if (_migrated isEqualTo []) exitWith {[[], _warnings]};
_preset = _migrated;
if ((count _preset) < 4) exitWith {[[], _warnings + ["Preset data is incomplete."]]};

private _name = _preset param [2, "Embedded preset", [""]];
if (_name isEqualTo "") then {_name = "Embedded preset"};

private _sourceBuckets = _preset param [3, [], [[]]];
if ((count _sourceBuckets) isNotEqualTo 4) exitWith {[[], ["Preset cargo buckets are malformed."]]};

private _cleanBuckets = [[], [], [], []];

{
    private _classes = _x;
    private _sourceBucketIndex = _forEachIndex;
    if !(_classes isEqualType []) then {
        _warnings pushBack format ["Bucket %1 was not an array and was ignored.", _forEachIndex];
    } else {
        {
            if (_x isEqualType "") then {
                private _className = _x;
                if ([_className] call RACA_fnc_isSafeClassName) then {
                    ([_className] call RACA_fnc_classifyClass) params ["_actualBucket"];

                    if (_actualBucket < 0) then {
                        _warnings pushBackUnique format ["Missing item: %1", _className];
                        (_cleanBuckets select _sourceBucketIndex) pushBackUnique _className;
                    } else {
                        (_cleanBuckets select _actualBucket) pushBackUnique _className;
                    };
                } else {
                    _warnings pushBackUnique "An unsafe class name was rejected.";
                };
            } else {
                _warnings pushBackUnique "A non-text class entry was ignored.";
            };
        } forEach _classes;
    };
} forEach _sourceBuckets;

{_x sort true} forEach _cleanBuckets;
private _validatedPreset = ["RACA_PRESET", 1, _name, _cleanBuckets];
private _hasInheritance = false;
private _hasRuntime = false;

for "_metadataIndex" from 4 to ((count _preset) - 1) do {
    private _candidate = _preset param [_metadataIndex, [], [[]]];
    private _tag = _candidate param [0, "", [""]];

    if (_tag in ["RACA_INHERITANCE", "RACA_ADOPTION", "RACA_COMPOSITION"]) then {
        private _rawComposition = _candidate;
        private _validComposition =
            !_hasInheritance &&
            {(count _rawComposition) >= 6} &&
            {(_rawComposition param [1, -1, [0]]) isEqualTo 1};

        if (!_validComposition) then {
            _warnings pushBack "Malformed or duplicate inheritance metadata was ignored.";
        } else {
        private _parentName = _rawComposition param [2, "", [""]];
        private _parentFingerprint = _rawComposition param [3, "", [""]];
        private _rawAdditions = _rawComposition param [4, [], [[]]];
        private _rawRemovals = _rawComposition param [5, [], [[]]];
        private _parentNameValid =
            _parentName isNotEqualTo "" &&
            {(count _parentName) <= 128} &&
            {({_x < 32 || {_x isEqualTo 127}} count toArray _parentName) isEqualTo 0};

        if (!_parentNameValid || {!(_rawRemovals isEqualType [])}) then {
            _warnings pushBack "Unsafe inheritance metadata was ignored.";
        } else {
            ([["RACA_PRESET", 1, "Composition additions", _rawAdditions]] call RACA_fnc_validatePreset) params ["_additionPreset", "_additionWarnings"];
            _warnings append _additionWarnings;

            if (_additionPreset isEqualTo []) then {
                _warnings pushBack "Malformed inheritance additions were ignored with the source link.";
            } else {
                private _cleanRemovals = [];
                {
                    if (_x isEqualType "" && {[_x] call RACA_fnc_isSafeClassName}) then {
                        _cleanRemovals pushBackUnique _x;
                    } else {
                        _warnings pushBackUnique "An unsafe inheritance removal was rejected.";
                    };
                } forEach _rawRemovals;
                _cleanRemovals sort true;

                _validatedPreset pushBack [
                    "RACA_INHERITANCE",
                    1,
                    _parentName,
                    _parentFingerprint,
                    _additionPreset select 3,
                    _cleanRemovals
                ];
                _hasInheritance = true;
            };
        };
        };
    } else {
        if (_tag isEqualTo "RACA_RUNTIME") then {
            if (_hasRuntime || {(_candidate param [1, -1, [0]]) isNotEqualTo 1}) then {
                _warnings pushBack "Malformed or duplicate runtime metadata was ignored.";
            } else {
                _validatedPreset pushBack [
                    "RACA_RUNTIME",
                    1,
                    [_candidate param [2, [], [[]]]] call RACA_fnc_normalizeLimits,
                    _candidate param [3, "", [""]],
                    (_candidate param [4, 0, [0]]) max 0,
                    _candidate param [5, "", [""]],
                    _candidate param [6, [], [[]]],
                    _candidate param [7, [], [[]]]
                ];
                _hasRuntime = true;
            };
        } else {
            if (_tag find "RACA_" isEqualTo 0 && {(count _tag) <= 64}) then {
                _validatedPreset pushBack _candidate;
                _warnings pushBackUnique format ["Unknown metadata '%1' was preserved without interpretation.", _tag];
            } else {
                _warnings pushBackUnique "Unknown unsafe preset metadata was ignored.";
            };
        };
    };
};

[_validatedPreset, _warnings]
