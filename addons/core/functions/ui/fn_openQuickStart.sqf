#include "..\..\script_component.hpp"
params [["_display", displayNull, [displayNull]]];
if (isNull _display) exitWith {displayNull};
uiNamespace setVariable ["RACA_quickStartParent", _display];
profileNamespace setVariable ["RACA_onboardingSeen_v1", true];
saveProfileNamespace;
_display createDisplay "RACA_RscDisplayQuickStart"
