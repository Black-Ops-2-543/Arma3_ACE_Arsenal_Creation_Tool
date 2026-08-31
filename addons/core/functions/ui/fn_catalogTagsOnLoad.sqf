#include "..\..\script_component.hpp"
disableSerialization;
params [["_display", displayNull, [displayNull]]];
if (isNull _display) exitWith {};
_display setVariable ["RACA_catalogTagsParentDisplay", uiNamespace getVariable ["RACA_catalogTagsParent", displayNull]];
_display setVariable ["RACA_catalogTagsSelectedClasses", uiNamespace getVariable ["RACA_catalogTagsSelection", []]];
[_display] call RACA_fnc_catalogTagsRefresh;
