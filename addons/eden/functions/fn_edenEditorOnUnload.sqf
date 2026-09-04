#include "..\script_component.hpp"
disableSerialization;
params [["_display", displayNull, [displayNull]]];
if (isNull _display) exitWith {false};
{
    _x params ["_event", "_handler"];
    if (_handler >= 0) then {remove3DENEventHandler [_event, _handler]};
} forEach (_display getVariable ["RACA_edenHistoryHandlers", []]);
_display setVariable ["RACA_edenHistoryHandlers", []];
_display setVariable ["RACA_dashboardQueueRevision", (_display getVariable ["RACA_dashboardQueueRevision", 0]) + 1];
_display setVariable ["RACA_dashboardModelRequest", (_display getVariable ["RACA_dashboardModelRequest", 0]) + 1];
true
