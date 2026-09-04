#include "..\script_component.hpp"
/* Converts one reusable mission configuration into a self-contained object value. */
params [["_configuration", [], [[]]]];
if ((_configuration param [0, "", [""]]) isEqualTo "") exitWith {[]};

private _id = _configuration select 0;
if !([_id] call RACA_fnc_edenIsSafeConfigurationId) exitWith {[]};
private _name = trim (_configuration param [1, "Restricted Arsenal", [""]]);
private _preset = [_configuration param [2, [], [[]]]] call RACA_fnc_flattenPreset;
if (_preset isEqualTo []) exitWith {[]};
if (_name isEqualTo "") then {_name = _preset select 2};
private _icon = trim (_configuration param [3, "", [""]]);
// Keep the authored access envelope intact until the shared assignment
// preflight has inspected it.  Normalising here would silently turn malformed
// legacy data into a valid-looking default before the safety gate sees it.
private _access = _configuration param [4, []];
private _limits = ([_preset] call RACA_fnc_getRuntimePolicy) select 2;

[
    "RACA_OBJECT_CONFIG",
    1,
    [[_id, _name, _preset, true, _access, _limits, _icon, false]],
    [
        ["auditLevel", "standard"],
        ["persistence", "mission"],
        ["configurationId", _id],
        ["configurationName", _name]
    ]
]
