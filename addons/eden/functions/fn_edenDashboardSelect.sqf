#include "..\script_component.hpp"
disableSerialization;
params [["_display", displayNull, [displayNull]], ["_focusInEden", false, [true]]];
if (isNull _display || {!is3DEN}) exitWith {false};
private _list = _display displayCtrl RACA_EDEN_IDC_DASHBOARD_LIST;
private _index = lnbCurSelRow _list;
private _object = (_display getVariable ["RACA_dashboardObjects", []]) param [_index, objNull];
if (isNull _object) exitWith {
    (_display displayCtrl RACA_EDEN_IDC_DASHBOARD_APPLY) ctrlEnable false;
    false
};
_display setVariable ["RACA_dashboardSelectedObject", _object];
(_display displayCtrl RACA_EDEN_IDC_DASHBOARD_APPLY) ctrlEnable true;

private _raw = (_object get3DENAttribute "RACA_RestrictedArsenalPreset") param [0, []];
private _linkedId = "";
{
    if (_x isEqualType [] && {(count _x) >= 2} && {toLowerANSI (_x param [0, "", [""]]) isEqualTo "configurationid"}) exitWith {
        _linkedId = _x param [1, "", [""]];
    };
} forEach (_raw param [3, [], [[]]]);

private _assignment = _display displayCtrl RACA_EDEN_IDC_DASHBOARD_ASSIGNMENT;
lbClear _assignment;
private _none = _assignment lbAdd "<No Arsenal Configuration>";
_assignment lbSetData [_none, ""];
private _selected = 0;
{
    private _row = _assignment lbAdd (_x select 1);
    _assignment lbSetData [_row, _x select 0];
    _assignment lbSetTooltip [_row, format ["Assign '%1' using preset '%2'.", _x select 1, (_x select 2) select 2]];
    if (_linkedId isNotEqualTo "" && {toLowerANSI (_x select 0) isEqualTo toLowerANSI _linkedId}) then {_selected = _row};
} forEach (call RACA_fnc_edenGetConfigurations);
_assignment lbSetCurSel _selected;

if (_focusInEden) then {set3DENSelected [_object]};
private _name = getText (configFile >> "CfgVehicles" >> typeOf _object >> "displayName");
if (_name isEqualTo "") then {_name = typeOf _object};
private _variableName = (_object get3DENAttribute "Name") param [0, "", [""]];
(_display displayCtrl RACA_EDEN_IDC_EDITOR_STATUS) ctrlSetText format [
    "%1Selected %2 (%3)%4. Choose an Arsenal Configuration, then Apply to Object.",
    ["", "Selected in Eden: "] select _focusInEden,
    _name,
    typeOf _object,
    if (_variableName isEqualTo "") then {""} else {format [", variable %1", _variableName]}
];
true
