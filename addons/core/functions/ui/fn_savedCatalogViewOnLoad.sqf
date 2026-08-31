#include "..\..\script_component.hpp"
disableSerialization;
params [["_display", displayNull, [displayNull]]];
if (isNull _display) exitWith {};
_display setVariable ["RACA_savedViewsParentDisplay", uiNamespace getVariable ["RACA_savedViewsParent", displayNull]];
[_display] call RACA_fnc_savedCatalogViewRefresh;
