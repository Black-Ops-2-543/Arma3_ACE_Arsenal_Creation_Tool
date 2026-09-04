#include "..\..\script_component.hpp"
disableSerialization;
params [["_display", displayNull, [displayNull]]];
if (isNull _display) exitWith {false};
private _row = lnbCurSelRow (_display displayCtrl RACA_IDC_PREFLIGHT_LIST);
private _entry = (_display getVariable ["RACA_preflightRows", []]) param [_row, []];
private _className = _entry param [3, "", [""]];
private _parent = _display getVariable ["RACA_preflightParentDisplay", displayNull];
if (_className isEqualTo "" || {isNull _parent}) exitWith {false};
private _catalog = uiNamespace getVariable ["RACA_itemCatalog", []];
if ((_catalog findIf {toLowerANSI (_x select 1) isEqualTo toLowerANSI _className}) >= 0) exitWith {false};
private _selected = uiNamespace getVariable ["RACA_builderSelected", createHashMap];
private _selectedKeys = (keys _selected) select {
    toLowerANSI _x isEqualTo toLowerANSI _className &&
    {_selected getOrDefault [_x, false]}
};
if (_selectedKeys isEqualTo []) exitWith {false};
private _confirmed = [
    format ["Remove unavailable authored class '%1' from this draft? Its source mod does not need to be loaded, and the change can be undone.", _className],
    "Remove Unavailable Item",
    "Remove From Draft",
    "Cancel",
    _display
] call BIS_fnc_guiMessage;
if (!_confirmed || {isNull _parent} || {isNull _display}) exitWith {false};
[_parent] call RACA_fnc_pushCreatorHistory;
{_selected deleteAt _x} forEach _selectedKeys;
uiNamespace setVariable ["RACA_builderSelected", _selected];
[_parent] call RACA_fnc_refreshItemList;
[_parent] call RACA_fnc_runCreatorDiagnostics;
[_display] call RACA_fnc_preflightRefresh;
[_parent, format ["Removed unavailable authored class '%1' from the draft. Undo restores it.", _className]] call RACA_fnc_setStatus;
true
