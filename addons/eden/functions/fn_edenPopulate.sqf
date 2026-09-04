#include "..\script_component.hpp"
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

private _combo = _group controlsGroupCtrl RACA_EDEN_IDC_PRESET;
lbClear _combo;
private _none = _combo lbAdd "<No Arsenal Configuration>";
_combo lbSetData [_none, ""];
private _selected = 0;
private _linkedId = "";
if (_config isNotEqualTo []) then {
    {
        if (_x isEqualType [] && {(count _x) >= 2} && {toLowerANSI (_x param [0, "", [""]]) isEqualTo "configurationid"}) exitWith {
            _linkedId = _x param [1, "", [""]];
        };
    } forEach (_config param [3, [], [[]]]);
};

private _configurations = call RACA_fnc_edenGetConfigurations;
{
    private _row = _combo lbAdd (_x select 1);
    _combo lbSetData [_row, _x select 0];
    _combo lbSetTooltip [_row, format ["Assign '%1' using preset '%2'.", _x select 1, (_x select 2) select 2]];
    if (_linkedId isNotEqualTo "" && {toLowerANSI (_x select 0) isEqualTo toLowerANSI _linkedId}) then {_selected = _row};
    if (_linkedId isEqualTo "" && {_config isNotEqualTo []} && {([_x] call RACA_fnc_edenConfigurationToObjectConfig) isEqualTo _config}) then {_selected = _row};
} forEach _configurations;

if (_config isNotEqualTo [] && {_selected isEqualTo 0}) then {
    private _legacy = _combo lbAdd "<Legacy embedded configuration - unchanged>";
    _combo lbSetData [_legacy, "__PRESERVE__"];
    _combo lbSetTooltip [_legacy, "This object contains older embedded RACA data. Choose a named configuration to replace it, or leave this selected to preserve it."];
    _selected = _legacy;
};
_combo lbSetCurSel _selected;
[_group] call RACA_fnc_edenUpdateSummary;
