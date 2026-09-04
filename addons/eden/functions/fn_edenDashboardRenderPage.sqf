#include "..\script_component.hpp"
disableSerialization;
params [["_display",displayNull,[displayNull]]];
if (isNull _display) exitWith {false};
private _matches=_display getVariable ["RACA_dashboardMatches",[]];
private _page=_display getVariable ["RACA_dashboardPage",0];
private _pages=(ceil (count _matches / 200)) max 1;
_page=_page max 0 min (_pages-1);
_display setVariable ["RACA_dashboardPage",_page];
private _slice=_matches select [_page*200,200];
private _list=_display displayCtrl RACA_EDEN_IDC_DASHBOARD_LIST;
private _previousObject=_display getVariable ["RACA_dashboardSelectedObject",objNull];
private _objects=[]; private _reports=[]; private _selectedRow=-1;
lnbClear _list;
{
    _x params ["","_object","_itemName","_className","_variableName","_configurationName","_entries","_summary","_raw"];
    private _row=_list lnbAddRow [_configurationName,_itemName,_className,_variableName];
    _list lnbSetTooltip [[_row,0],format ["Arsenal Configuration: %1",_configurationName]];
    _list lnbSetTooltip [[_row,1],_itemName];
    _list lnbSetTooltip [[_row,2],_className];
    _list lnbSetTooltip [[_row,3],if (_variableName isEqualTo "") then {"No variable name"} else {_variableName}];
    private _color=if (_raw isEqualTo []) then {[0.72,0.72,0.72,1]} else {if ((_summary select 0)>0) then {[1,0.38,0.35,1]} else {if ((_summary select 1)>0) then {[1,0.80,0.32,1]} else {[0.55,1,0.58,1]}}};
    _list lnbSetColor [[_row,0],_color];
    _objects pushBack _object; _reports pushBack [_object,_itemName,_className,_variableName,_configurationName,_entries,_summary];
    if (_object isEqualTo _previousObject) then {_selectedRow=_row};
} forEach _slice;
_display setVariable ["RACA_dashboardObjects",_objects];
_display setVariable ["RACA_dashboardReports",_reports];
if (_objects isNotEqualTo []) then {
    if (_selectedRow<0) then {_selectedRow=0};
    _list lnbSetCurSelRow _selectedRow;
    _display setVariable ["RACA_dashboardSelectedObject",_objects select _selectedRow];
    [_display,false] call RACA_fnc_edenDashboardSelect;
} else {
    _display setVariable ["RACA_dashboardSelectedObject",objNull];
    private _assignment=_display displayCtrl RACA_EDEN_IDC_DASHBOARD_ASSIGNMENT;
    lbClear _assignment; private _none=_assignment lbAdd "<No Arsenal Configuration>"; _assignment lbSetData [_none,""]; _assignment lbSetCurSel 0;
    (_display displayCtrl RACA_EDEN_IDC_DASHBOARD_APPLY) ctrlEnable false;
};
(_display displayCtrl RACA_EDEN_IDC_DASHBOARD_PAGE_LABEL) ctrlSetText format ["Page %1 / %2 | %3 matching object(s)",_page+1,_pages,count _matches];
(_display displayCtrl RACA_EDEN_IDC_DASHBOARD_PAGE_PREV) ctrlEnable (_page>0);
(_display displayCtrl RACA_EDEN_IDC_DASHBOARD_PAGE_NEXT) ctrlEnable (_page+1<_pages);
true
