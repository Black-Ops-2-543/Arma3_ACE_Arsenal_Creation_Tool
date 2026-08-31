#include "..\..\script_component.hpp"
disableSerialization;
params [["_display", displayNull, [displayNull]]];

if (isNull _display) exitWith {false};
private _parent = _display getVariable ["RACA_preflightParentDisplay", displayNull];
if (isNull _parent) exitWith {
    (_display displayCtrl RACA_IDC_PREFLIGHT_SUMMARY) ctrlSetText "The creator is no longer available. Close this report and reopen the creator.";
    false
};
[_parent] call RACA_fnc_runCreatorDiagnostics;
[_display] call RACA_fnc_preflightRefresh;
true
