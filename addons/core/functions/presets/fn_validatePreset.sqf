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
                ([_className] call RACA_fnc_classifyClass) params ["_actualBucket"];

                if (_actualBucket < 0) then {
                    _warnings pushBackUnique format ["Missing item: %1", _className];
                    (_cleanBuckets select _sourceBucketIndex) pushBackUnique _className;
                } else {
                    (_cleanBuckets select _actualBucket) pushBackUnique _className;
                };
            };
        } forEach _classes;
    };
} forEach _sourceBuckets;

{_x sort true} forEach _cleanBuckets;
[["RACA_PRESET", 1, _name, _cleanBuckets], _warnings]
