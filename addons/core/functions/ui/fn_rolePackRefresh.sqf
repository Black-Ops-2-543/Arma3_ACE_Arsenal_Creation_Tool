#include "..\..\script_component.hpp"
disableSerialization;
params [["_display", displayNull, [displayNull]]];
if (isNull _display) exitWith {false};

private _packs = call RACA_fnc_getRolePacks;
private _list = _display displayCtrl RACA_IDC_ROLE_PACK_LIST;
private _previousRow = lnbCurSelRow _list;
private _previousName = if (_previousRow < 0) then {""} else {_list lnbData [_previousRow, 0]};
lnbClear _list;
private _restore = -1;
{
    _x params ["", "", "_name", "_description", "_classes"];
    private _row = _list lnbAddRow [_name, str count _classes, _description];
    _list lnbSetData [[_row, 0], _name];
    private _tooltip = format ["%1 class(es)%2%3", count _classes, toString [10], if (_description isEqualTo "") then {"No description"} else {_description}];
    {_list lnbSetTooltip [[_row, _x], _tooltip]} forEach [0, 1, 2];
    if (toLowerANSI _name isEqualTo toLowerANSI _previousName) then {_restore = _row};
} forEach _packs;
if (_restore < 0 && {_packs isNotEqualTo []}) then {_restore = 0};
if (_restore >= 0) then {
    _list lnbSetCurSelRow _restore;
    [_list] call RACA_fnc_rolePackSelect;
} else {
    (_display displayCtrl RACA_IDC_ROLE_PACK_NAME) ctrlSetText "";
    (_display displayCtrl RACA_IDC_ROLE_PACK_DESCRIPTION) ctrlSetText "";
    (_display displayCtrl RACA_IDC_ROLE_PACK_DETAILS) ctrlSetText "No custom role packs yet. Build a useful draft, name it, and capture its included classes.";
};
{
    (_display displayCtrl _x) ctrlEnable (_packs isNotEqualTo []);
} forEach [RACA_IDC_ROLE_PACK_MERGE, RACA_IDC_ROLE_PACK_REPLACE, RACA_IDC_ROLE_PACK_DELETE];
true
