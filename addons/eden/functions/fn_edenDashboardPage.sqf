#include "..\script_component.hpp"
params [["_display",displayNull,[displayNull]],["_delta",0,[0]]];
if (isNull _display) exitWith {false};
private _matches=_display getVariable ["RACA_dashboardMatches",[]];
private _pages=(ceil (count _matches / 200)) max 1;
private _page=((_display getVariable ["RACA_dashboardPage",0])+_delta) max 0 min (_pages-1);
_display setVariable ["RACA_dashboardPage",_page];
[_display] call RACA_fnc_edenDashboardRenderPage
