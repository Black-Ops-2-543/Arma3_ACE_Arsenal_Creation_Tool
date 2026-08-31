#include "..\script_component.hpp"
params [["_display", displayNull, [displayNull]], ["_operation", "ASSIGN", [""]]];
if (isNull _display || {!is3DEN}) exitWith {false};
private _objects = get3DENSelected "object";
if (_objects isEqualTo []) exitWith {
    (_display displayCtrl RACA_EDEN_IDC_EDITOR_STATUS) ctrlSetText "Select one or more Eden objects before using a bulk operation.";
    false
};
[_display, -1, false] call RACA_fnc_edenEditorCommitSlot;
private _working = _display getVariable ["RACA_workingConfig", []];
private _config = if ((_working param [2, []]) isEqualTo []) then {[]} else {[_working] call RACA_fnc_normalizeObjectConfig};
if (toUpperANSI _operation isEqualTo "ASSIGN" && {_config isEqualTo []}) exitWith {
    (_display displayCtrl RACA_EDEN_IDC_EDITOR_STATUS) ctrlSetText "Add and save at least one valid slot before bulk assignment.";
    false
};
private _slotCount = if (_config isEqualTo []) then {0} else {count (_config select 2)};
private _confirmed = [
    format ["%1 %2 selected Eden object(s)%3?\n\nThis creates one undoable Eden history step and changes no unselected objects.", toUpperANSI _operation, count _objects, if (_operation isEqualTo "ASSIGN") then {format [" with %1 slot(s)", _slotCount]} else {""}],
    "RACA Mission-Wide Update", "APPLY", "CANCEL", _display
] call BIS_fnc_guiMessage;
if (!_confirmed || {isNull _display}) exitWith {false};
private _value = if (toUpperANSI _operation isEqualTo "CLEAR") then {[]} else {_config};
[format ["RACA %1", toUpperANSI _operation], "Restricted Arsenal bulk update", "a3\3den\data\cfg3den\history\changeattributes_ca.paa"] collect3DENHistory {
    {_x set3DENAttribute ["RACA_RestrictedArsenalPreset", _value]} forEach _objects;
};
[_display] call RACA_fnc_edenDashboardRefresh;
(_display displayCtrl RACA_EDEN_IDC_EDITOR_STATUS) ctrlSetText format ["%1 completed for %2 selected object(s). Use Eden Undo to revert.", toUpperANSI _operation, count _objects];
true
