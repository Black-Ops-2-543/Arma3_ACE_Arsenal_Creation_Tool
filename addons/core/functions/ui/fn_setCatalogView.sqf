#include "..\..\script_component.hpp"
params [["_display", displayNull, [displayNull]]];
if (isNull _display) exitWith {};
uiNamespace setVariable ["RACA_catalogShowIcons", true];
[_display] call RACA_fnc_refreshItemList;
[_display, "Catalogue icons are always shown."] call RACA_fnc_setStatus;
