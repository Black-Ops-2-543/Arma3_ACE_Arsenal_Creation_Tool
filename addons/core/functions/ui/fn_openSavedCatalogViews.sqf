#include "..\..\script_component.hpp"
disableSerialization;
params [["_display", displayNull, [displayNull]]];
if (isNull _display) exitWith {false};
uiNamespace setVariable ["RACA_savedViewsParent", _display];
private _viewsDisplay = _display createDisplay "RACA_RscDisplaySavedViews";
if (isNull _viewsDisplay) exitWith {
    [_display, "Saved Filters could not be opened."] call RACA_fnc_setStatus;
    false
};
true
