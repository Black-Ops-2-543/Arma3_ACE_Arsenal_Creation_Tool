#include "..\..\script_component.hpp"
params [["_display", displayNull, [displayNull]]];
if (isNull _display) exitWith {displayNull};
if ((uiNamespace getVariable ["RACA_itemCatalog", []]) isEqualTo []) exitWith {
    [_display, "Finish loading the item catalogue before opening Quick Start."] call RACA_fnc_setStatus;
    displayNull
};
uiNamespace setVariable ["RACA_quickStartParent", _display];
profileNamespace setVariable ["RACA_onboardingSeen_v1", true];
saveProfileNamespace;
_display createDisplay "RACA_RscDisplayQuickStart"
