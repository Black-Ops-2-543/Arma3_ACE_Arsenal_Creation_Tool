#include "..\..\script_component.hpp"
disableSerialization;
params [["_display", displayNull, [displayNull]]];
if (isNull _display) exitWith {false};
private _parent = _display getVariable ["RACA_savedViewsParentDisplay", displayNull];
if (isNull _parent) exitWith {false};
private _list = _display displayCtrl RACA_IDC_SAVED_VIEW_LIST;
private _row = lnbCurSelRow _list;
if (_row < 0) exitWith {false};
private _name = _list lnbData [_row, 0];
private _views = call RACA_fnc_getSavedCatalogViews;
private _index = _views findIf {toLowerANSI (_x select 2) isEqualTo toLowerANSI _name};
if (_index < 0) exitWith {false};
(_views select _index) params ["", "", "", "_search", "_category", "_source", "_addon", "_author", "_tag", "_sortField", "_ascending"];
private _selectData = {
    params ["_control", "_data"];
    private _match = 0;
    for "_i" from 0 to ((lbSize _control) - 1) do {
        if ((_control lbData _i) isEqualTo _data) exitWith {_match = _i};
    };
    _control lbSetCurSel _match;
};
(_parent displayCtrl RACA_IDC_SEARCH) ctrlSetText _search;
[_parent displayCtrl RACA_IDC_CATEGORY, _category] call _selectData;
[_parent displayCtrl RACA_IDC_SOURCE_FILTER, _source] call _selectData;
[_parent displayCtrl RACA_IDC_ADDON_FILTER, _addon] call _selectData;
[_parent displayCtrl RACA_IDC_AUTHOR_FILTER, _author] call _selectData;
[_parent displayCtrl RACA_IDC_TAG_FILTER, _tag] call _selectData;
uiNamespace setVariable ["RACA_catalogSort", [_sortField, _ascending]];
profileNamespace setVariable ["RACA_catalogSort_v1", [_sortField, _ascending]];
saveProfileNamespace;
[_parent, "ASSIGNMENT"] call RACA_fnc_switchCreatorTab;
[_parent] call RACA_fnc_refreshItemList;
_display closeDisplay 1;
[_parent, format ["Applied saved catalogue view '%1' without changing the draft selection.", _name]] call RACA_fnc_setStatus;
true
