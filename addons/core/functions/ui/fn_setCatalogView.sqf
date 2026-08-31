#include "..\..\script_component.hpp"
params [["_display", displayNull, [displayNull]]];
if (isNull _display) exitWith {};
private _showIcons = !(uiNamespace getVariable ["RACA_catalogShowIcons", true]);
uiNamespace setVariable ["RACA_catalogShowIcons", _showIcons];
[_display] call RACA_fnc_refreshItemList;
[_display, format ["Catalogue icons %1. Search, filters, selections, and scroll position are preserved.", ["hidden", "shown"] select _showIcons]] call RACA_fnc_setStatus;
