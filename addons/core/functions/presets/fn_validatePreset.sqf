/* Returns [validatedPreset, warnings]. Invalid presets return an empty preset. */
params [["_preset", [], [[]]]];

private _warnings = [];
if ((count _preset) < 4) exitWith {[[], ["Preset data is incomplete."]]};
if ((_preset param [0, "", [""]]) isNotEqualTo "RACA_PRESET") exitWith {[[], ["Preset signature is not recognized."]]};
if ((_preset param [1, -1, [0]]) isNotEqualTo 1) exitWith {[[], ["Preset schema version is not supported."]]};

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

if ((count _preset) > 4) then {
    private _rawComposition = _preset param [4, [], [[]]];
    private _validComposition =
        (count _rawComposition) >= 6 &&
        {(_rawComposition param [0, "", [""]]) in ["RACA_ADOPTION", "RACA_COMPOSITION"]} &&
        {(_rawComposition param [1, -1, [0]]) isEqualTo 1};

    if (!_validComposition) then {
        _warnings pushBack "Malformed adoption metadata was ignored.";
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
            _warnings pushBack "Unsafe adoption metadata was ignored.";
        } else {
            ([["RACA_PRESET", 1, "Composition additions", _rawAdditions]] call RACA_fnc_validatePreset) params ["_additionPreset", "_additionWarnings"];
            _warnings append _additionWarnings;

            if (_additionPreset isEqualTo []) then {
                _warnings pushBack "Malformed adoption additions were ignored with the source link.";
            } else {
                private _cleanRemovals = [];
                {
                    if (_x isEqualType "" && {[_x] call RACA_fnc_isSafeClassName}) then {
                        _cleanRemovals pushBackUnique _x;
                    } else {
                        _warnings pushBackUnique "An unsafe adoption removal was rejected.";
                    };
                } forEach _rawRemovals;
                _cleanRemovals sort true;

                _validatedPreset pushBack [
                    "RACA_ADOPTION",
                    1,
                    _parentName,
                    _parentFingerprint,
                    _additionPreset select 3,
                    _cleanRemovals
                ];
            };
        };
    };
};

[_validatedPreset, _warnings]
