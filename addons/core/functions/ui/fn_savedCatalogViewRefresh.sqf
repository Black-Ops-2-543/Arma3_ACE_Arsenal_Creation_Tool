#include "..\..\script_component.hpp"
disableSerialization;
params [["_display", displayNull, [displayNull]]];
if (isNull _display) exitWith {false};
private _views = call RACA_fnc_getSavedCatalogViews;
private _list = _display displayCtrl RACA_IDC_SAVED_VIEW_LIST;
private _previousRow = lnbCurSelRow _list;
private _previousName = if (_previousRow < 0) then {""} else {_list lnbData [_previousRow, 0]};
lnbClear _list;
private _restore = -1;
{
    _x params ["", "", "_name", "_search", "_category", "_source", "_addon", "_author", "_tag", "_sortField", "_ascending"];
    private _sort = format ["%1 %2", toUpperANSI _sortField, ["Z-A", "A-Z"] select _ascending];
    private _row = _list lnbAddRow [_name, _search, _category, _source, _addon, _author, _tag, _sort];
    _list lnbSetData [[_row, 0], _name];
    private _tooltip = format ["Search: %1%8Category: %2%8Mod: %3%8Add-on: %4%8Author: %5%8Tag: %6%8Sort: %7", _search, _category, _source, _addon, _author, _tag, _sort, toString [10]];
    {_list lnbSetTooltip [[_row, _x], _tooltip]} forEach [0, 1, 2, 3, 4, 5, 6, 7];
    if (toLowerANSI _name isEqualTo toLowerANSI _previousName) then {_restore = _row};
} forEach _views;
if (_restore < 0 && {_views isNotEqualTo []}) then {_restore = 0};
if (_restore >= 0) then {_list lnbSetCurSelRow _restore};
private _details = _display displayCtrl RACA_IDC_SAVED_VIEW_DETAILS;
if (_views isEqualTo []) then {
    (_display displayCtrl RACA_IDC_SAVED_VIEW_NAME) ctrlSetText "";
    _details ctrlSetText "No saved filters yet. Set up Arsenal Contents, enter a name, then choose Save Current Filters.";
} else {
    [_list] call RACA_fnc_savedCatalogViewSelect;
};
(_display displayCtrl RACA_IDC_SAVED_VIEW_APPLY) ctrlEnable (_views isNotEqualTo []);
(_display displayCtrl RACA_IDC_SAVED_VIEW_DELETE) ctrlEnable (_views isNotEqualTo []);
true
