#include "..\..\script_component.hpp"
disableSerialization;
params [["_display", displayNull, [displayNull]]];
if (isNull _display) exitWith {false};
private _creator = _display getVariable ["RACA_parentCreator", displayNull];
if (isNull _creator) then {_creator = _display};
uiNamespace setVariable ["RACA_rolePacksParent", _creator];
uiNamespace setVariable ["RACA_rolePacksReturn", _display];
private _manager = _display createDisplay "RACA_RscDisplayRolePacks";
if (isNull _manager) exitWith {
    if (!isNull _creator) then {[_creator, "Custom role packs could not be opened."] call RACA_fnc_setStatus};
    false
};
true
