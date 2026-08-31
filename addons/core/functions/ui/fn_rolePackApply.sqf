#include "..\..\script_component.hpp"
disableSerialization;
params [
    ["_display", displayNull, [displayNull]],
    ["_mode", "MERGE", [""]]
];
if (isNull _display) exitWith {false};
private _parent = _display getVariable ["RACA_rolePacksParentDisplay", displayNull];
if (isNull _parent) exitWith {false};
private _list = _display displayCtrl RACA_IDC_ROLE_PACK_LIST;
private _row = lnbCurSelRow _list;
if (_row < 0) exitWith {false};
private _name = _list lnbData [_row, 0];

[_parent] call RACA_fnc_pushCreatorHistory;
private _replace = (toUpperANSI _mode) isEqualTo "REPLACE";
private _result = ["pack:" + toLowerANSI _name, uiNamespace getVariable ["RACA_itemCatalog", []], _replace] call RACA_fnc_applyRoleTemplate;
private _warnings = _result param [1, []];
[_parent] call RACA_fnc_refreshItemList;
_display closeDisplay 1;
[_parent, format [
    "%1 custom role pack '%2'; %3 class(es) are now included.%4",
    ["Merged", "Replaced the draft with"] select _replace,
    _name,
    count (uiNamespace getVariable ["RACA_builderSelected", createHashMap]),
    if (_warnings isEqualTo []) then {""} else {format [" %1 unavailable pack class(es) were skipped.", count _warnings]}
]] call RACA_fnc_setStatus;
true
