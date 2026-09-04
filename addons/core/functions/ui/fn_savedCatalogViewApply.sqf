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
private _view = _views select _index;
_view params ["","","","_search","_category","_source","_addon","_author","_tag","_sortField","_ascending",["_mode","ADVANCED"]];
private _state = [_search,_mode,[[RACA_IDC_CATEGORY,_category],[RACA_IDC_SOURCE_FILTER,_source],[RACA_IDC_ADDON_FILTER,_addon],[RACA_IDC_AUTHOR_FILTER,_author],[RACA_IDC_TAG_FILTER,_tag]],[_sortField,_ascending],[],"","",0,[],[],[]];
_parent setVariable ["RACA_refreshSuppressed",true];
[_parent,"ASSIGNMENT"] call RACA_fnc_switchCreatorTab;
[_parent,_state] call RACA_fnc_restoreCatalogView;
_display closeDisplay 1;
[_parent,format ["Applied '%1' in %2 mode. Missing constraints remain visible and fail closed; arsenal contents were not changed.",_name,_mode]] call RACA_fnc_setStatus;
true
