#include "..\..\script_component.hpp"
params [["_display",displayNull,[displayNull]]];
if (isNull _display) exitWith {};
_display setVariable ["RACA_refreshSuppressed",true];
{(_display displayCtrl (_x select 0)) lbSetCurSel 0} forEach (_display getVariable ["RACA_unresolvedFilters",[]]);
_display setVariable ["RACA_unresolvedFilters",[]];
_display setVariable ["RACA_refreshSuppressed",false];
[_display] call RACA_fnc_refreshItemList;
[_display,"Missing constraints explicitly cleared. Saved filters remain unchanged."] call RACA_fnc_setStatus;
