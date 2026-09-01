#include "..\..\script_component.hpp"
disableSerialization;
params [["_display", displayNull, [displayNull]]];
if (isNull _display) exitWith {};
_display setVariable ["RACA_rolePacksParentDisplay", uiNamespace getVariable ["RACA_rolePacksParent", displayNull]];
_display setVariable ["RACA_rolePacksReturnDisplay", uiNamespace getVariable ["RACA_rolePacksReturn", displayNull]];
[_display] call RACA_fnc_rolePackRefresh;
