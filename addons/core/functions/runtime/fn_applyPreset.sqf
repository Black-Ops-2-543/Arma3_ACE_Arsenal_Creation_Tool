/* Public runtime entry point. The Eden attribute calls this on the server. */
params [
    ["_object", objNull, [objNull]],
    ["_rawPreset", [], [[]]]
];

if (isNull _object) exitWith {false};

([_rawPreset] call RACA_fnc_validatePreset) params ["_preset", "_warnings"];
if (_preset isEqualTo []) exitWith {
    diag_log "[RACA] Refused to apply an invalid restricted arsenal preset.";
    false
};

private _classes = [];
{_classes append _x} forEach (_preset select 3);

[_object, true] call ace_arsenal_fnc_removeBox;
if (_classes isEqualTo []) exitWith {
    diag_log format ["[RACA] Preset '%1' contained no usable items; arsenal removed.", _preset select 2];
    false
};

[_object, _classes, true] call ace_arsenal_fnc_initBox;
_object setVariable ["RACA_appliedPreset", [1, _preset select 2, count _classes], true];

if (_warnings isNotEqualTo []) then {
    diag_log format ["[RACA] Applied preset '%1' with warnings: %2", _preset select 2, _warnings];
};

true
