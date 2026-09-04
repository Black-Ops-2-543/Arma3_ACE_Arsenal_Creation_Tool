#include "..\script_component.hpp"
disableSerialization;
params [["_display",displayNull,[displayNull]],["_immediate",false,[true]]];
if (isNull _display) exitWith {false};
private _request=(_display getVariable ["RACA_dashboardQueueRevision",0])+1;
_display setVariable ["RACA_dashboardQueueRevision",_request];
[_display,_request,_immediate] spawn {
    disableSerialization;
    params ["_display","_request","_immediate"];
    if (!_immediate) then {uiSleep 0.18};
    if (isNull _display || {(_display getVariable ["RACA_dashboardQueueRevision",-1]) isNotEqualTo _request}) exitWith {};
    [_display] call RACA_fnc_edenDashboardRefresh;
};
true
