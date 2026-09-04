#include "..\script_component.hpp"
disableSerialization;
params [["_display", displayNull, [displayNull]]];
if (isNull _display || {!is3DEN}) exitWith {false};
if !([_display, -1, false] call RACA_fnc_edenEditorCommitSlot) exitWith {false};

private _index = _display getVariable ["RACA_currentSlot", -1];
private _configurations = +(_display getVariable ["RACA_workingConfigurations", []]);
if (_index < 0 || {_index >= count _configurations}) exitWith {false};
private _configuration = _configurations select _index;
private _configurationId = toLowerANSI (_configuration select 0);
private _linkedCount = 0;
{
    private _raw = (_x get3DENAttribute "RACA_RestrictedArsenalPreset") param [0, []];
    private _linkedId = "";
    {
        if (_x isEqualType [] && {(count _x) >= 2} && {toLowerANSI (_x param [0, "", [""]]) isEqualTo "configurationid"}) exitWith {
            _linkedId = toLowerANSI (_x param [1, "", [""]]);
        };
    } forEach (_raw param [3, [], [[]]]);
    if (_linkedId isEqualTo _configurationId) then {_linkedCount = _linkedCount + 1};
} forEach (all3DENEntities select 0);

private _confirmed = [
    format ["Delete Arsenal Configuration '%1'?%2%2This also clears it from %3 linked mission object(s). The complete change can be undone once with Eden Undo.", _configuration select 1, toString [10], _linkedCount],
    "Delete Arsenal Configuration",
    "Delete",
    "Cancel",
    _display
] call BIS_fnc_guiMessage;
if (!_confirmed) exitWith {false};
private _activeDisplay = findDisplay RACA_EDEN_IDD_CONFIG;
if (isNull _activeDisplay) exitWith {false};
_display = _activeDisplay;

_configurations deleteAt _index;
_display setVariable ["RACA_currentSlot", -1];
if !([_display, _configurations, format ["Delete Arsenal Configuration '%1'", _configuration select 1]] call RACA_fnc_edenStoreConfigurations) exitWith {false};
[_display, (_index min ((count _configurations) - 1)) max 0] call RACA_fnc_edenEditorRefresh;
(_display displayCtrl RACA_EDEN_IDC_EDITOR_STATUS) ctrlSetText format ["Deleted '%1' and cleared %2 linked mission object(s).", _configuration select 1, _linkedCount];
true
