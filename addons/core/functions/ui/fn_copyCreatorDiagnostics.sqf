#include "..\..\script_component.hpp"
params [["_display", displayNull, [displayNull]]];
if (isNull _display) exitWith {};
if (isMultiplayer) exitWith {[_display, "Copy report is available from the single-player creator mission only."] call RACA_fnc_setStatus};
private _stored = uiNamespace getVariable ["RACA_creatorDiagnostics", []];
if (_stored isEqualTo []) then {_stored = [_display] call RACA_fnc_runCreatorDiagnostics; _stored = uiNamespace getVariable ["RACA_creatorDiagnostics", []]};
if (_stored isNotEqualTo []) then {copyToClipboard (_stored select 1); [_display, "Compatibility report copied to the clipboard."] call RACA_fnc_setStatus};
