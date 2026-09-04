#include "..\..\script_component.hpp"
params [["_display", displayNull, [displayNull]]];

if (isNull _display) exitWith {};

private _combo = _display displayCtrl RACA_IDC_CATEGORY;
private _previousIndex = lbCurSel _combo;
private _previous = if (_previousIndex < 0) then {"All"} else {_combo lbData _previousIndex};
private _categories = [
    "All",
    "Weapons",
    "Attachments",
    "Magazines",
    "Uniforms",
    "Vests",
    "Backpacks",
    "Headgear",
    "NVGs",
    "Facewear",
    "Equipment",
    "Included",
    "Favorites"
];

private _inherited = uiNamespace getVariable ["RACA_builderInherited", createHashMap];
if ((count _inherited) > 0) then {
    _categories pushBack "Inherited";
};

lbClear _combo;
private _selectedIndex = 0;
{
    private _index = _combo lbAdd _x;
    _combo lbSetData [_index, _x];
    if (_x isEqualTo _previous) then {_selectedIndex = _index};
} forEach _categories;

private _unresolved = _display getVariable ["RACA_unresolvedFilters", []];
private _constraintIndex = _unresolved findIf {
    (_x select 0) isEqualTo RACA_IDC_CATEGORY && {(_x select 1) isEqualTo _previous}
};
if (_selectedIndex isEqualTo 0 && {_previous isNotEqualTo "All"}) then {
    _selectedIndex = _combo lbAdd ("Missing: " + _previous);
    _combo lbSetData [_selectedIndex, _previous];
    if (_constraintIndex < 0) then {_unresolved pushBack [RACA_IDC_CATEGORY, _previous]};
} else {
    if (_constraintIndex >= 0) then {_unresolved deleteAt _constraintIndex};
};
_display setVariable ["RACA_unresolvedFilters", _unresolved];

_combo lbSetCurSel _selectedIndex;
