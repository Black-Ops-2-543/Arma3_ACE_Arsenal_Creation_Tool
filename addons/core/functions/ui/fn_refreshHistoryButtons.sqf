#include "..\..\script_component.hpp"
params [["_display", displayNull, [displayNull]]];
if (isNull _display) exitWith {};
/* Keep both actions available; an empty stack produces a clear explanation. */
(_display displayCtrl RACA_IDC_UNDO) ctrlEnable true;
(_display displayCtrl RACA_IDC_REDO) ctrlEnable true;
[_display] call RACA_fnc_updateSummary;
