params [
    ["_group", controlNull, [controlNull]],
    ["_currentValue", [], [[]]]
];

if (isNull _group) exitWith {};
private _standaloneValue = +_currentValue;
if ((_standaloneValue param [0, "", [""]]) isEqualTo "RACA_PRESET") then {
    _standaloneValue = [_standaloneValue] call RACA_fnc_flattenPreset;
} else {
    if ((_standaloneValue param [0, "", [""]]) isEqualTo "RACA_OBJECT_CONFIG") then {
        private _slots = +(_standaloneValue param [2, []]);
        {
            if (_x isEqualType [] && {(count _x) >= 3}) then {
                _x set [2, [_x select 2] call RACA_fnc_flattenPreset];
            };
        } forEach _slots;
        _standaloneValue set [2, _slots];
    };
};
private _config = if (_standaloneValue isEqualTo []) then {[]} else {[_standaloneValue] call RACA_fnc_normalizeObjectConfig};
_group setVariable ["RACA_edenObjectConfig", _config];
[_group] call RACA_fnc_edenUpdateSummary;
