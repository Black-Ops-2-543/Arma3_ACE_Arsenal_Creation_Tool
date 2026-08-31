#include "..\..\script_component.hpp"
disableSerialization;
params [["_display", displayNull, [displayNull]]];
if (isNull _display) exitWith {false};
uiNamespace setVariable ["RACA_rolePacksParent", _display];
private _manager = _display createDisplay "RACA_RscDisplayRolePacks";
if (isNull _manager) exitWith {
    [_display, "Custom role packs could not be opened."] call RACA_fnc_setStatus;
    false
};
true
