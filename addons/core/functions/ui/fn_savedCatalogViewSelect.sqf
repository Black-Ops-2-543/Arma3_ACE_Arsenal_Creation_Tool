#include "..\..\script_component.hpp"
disableSerialization;
params [["_list", controlNull, [controlNull]]];
if (isNull _list) exitWith {false};
private _row = lnbCurSelRow _list;
if (_row < 0) exitWith {false};
private _name = _list lnbData [_row, 0];
private _display = ctrlParent _list;
(_display displayCtrl RACA_IDC_SAVED_VIEW_NAME) ctrlSetText _name;
private _views = call RACA_fnc_getSavedCatalogViews;
private _index = _views findIf {toLowerANSI (_x select 2) isEqualTo toLowerANSI _name};
if (_index >= 0) then {
    (_views select _index) params ["", "", "", "_search", "_category", "_source", "_addon", "_author", "_tag", "_sortField", "_ascending"];
    private _show = {
        params ["_value"];
        if (_value isEqualTo "") then {"All"} else {_value}
    };
    (_display displayCtrl RACA_IDC_SAVED_VIEW_DETAILS) ctrlSetText format [
        "Search: %1 | Category: %2 | Mod: %3 | Add-on: %4 | Author: %5 | Tag: %6 | Sort: %7 %8. Applying these filters will not change arsenal contents.",
        [_search] call _show,
        [_category] call _show,
        [_source] call _show,
        [_addon] call _show,
        [_author] call _show,
        [_tag] call _show,
        toUpperANSI _sortField,
        ["descending", "ascending"] select _ascending
    ];
};
true
