#include "..\..\script_component.hpp"
params [["_display", displayNull, [displayNull]]];

if (isNull _display) exitWith {[]};

private _name = ctrlText (_display displayCtrl RACA_IDC_PRESET_NAME);
private _selected = uiNamespace getVariable ["RACA_builderSelected", createHashMap];
private _raw = +(uiNamespace getVariable ["RACA_builderRawPreset", []]);
private _bucketByClass = createHashMap;
{
    private _bucket = _forEachIndex;
    {_bucketByClass set [toLowerANSI _x, _bucket]} forEach _x;
} forEach (_raw param [3, [[], [], [], []], [[]]]);
private _buckets = [[], [], [], []];
{
    if (_selected getOrDefault [_x, false]) then {
        private _bucket = _bucketByClass getOrDefault [toLowerANSI _x, -1];
        if (_bucket < 0) then {_bucket = ([_x] call RACA_fnc_classifyCached) select 0};
        if (_bucket >= 0) then {(_buckets select _bucket) pushBack _x};
    };
} forEach keys _selected;

{_x sort true} forEach _buckets;
private _limitsMap = uiNamespace getVariable ["RACA_builderLimits", createHashMap];
private _limits = [];
private _limitKeys = keys _limitsMap;
_limitKeys sort true;
{
    if ((toLowerANSI _x find "category:") isEqualTo 0 || {_selected getOrDefault [_x, false]}) then {
        _limits pushBack (_limitsMap get _x);
    };
} forEach _limitKeys;
_limits = [_limits] call RACA_fnc_normalizeLimits;
private _runtime = [_raw] call RACA_fnc_getRuntimePolicy;
_runtime set [2, _limits];
private _result = ["RACA_PRESET", 1, _name, _buckets, _runtime];
for "_i" from 4 to ((count _raw) - 1) do {
    private _record = _raw select _i;
    if !((_record param [0, ""]) in ["RACA_RUNTIME", "RACA_INHERITANCE", "RACA_ADOPTION", "RACA_COMPOSITION"]) then {
        _result pushBack +_record;
    };
};
private _composition = +(uiNamespace getVariable ["RACA_builderComposition", []]);
if (_composition isNotEqualTo []) then {_result pushBack _composition};
_result
