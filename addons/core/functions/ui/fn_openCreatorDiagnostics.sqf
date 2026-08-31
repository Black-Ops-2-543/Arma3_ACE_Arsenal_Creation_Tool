#include "..\..\script_component.hpp"
disableSerialization;
params [["_display", displayNull, [displayNull]]];

if (isNull _display) exitWith {false};
private _stored = uiNamespace getVariable ["RACA_creatorDiagnostics", []];
if (_stored isEqualTo []) then {
    [_display] call RACA_fnc_runCreatorDiagnostics;
    _stored = uiNamespace getVariable ["RACA_creatorDiagnostics", []];
};
if (_stored isEqualTo []) exitWith {false};

uiNamespace setVariable ["RACA_preflightParent", _display];
private _preflightDisplay = _display createDisplay "RACA_RscDisplayPreflight";
if (isNull _preflightDisplay) exitWith {
    [_display, "The detailed compatibility report could not be opened."] call RACA_fnc_setStatus;
    false
};
true
