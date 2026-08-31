#include "..\..\script_component.hpp"
params [["_display", displayNull, [displayNull]]];
if (isNull _display) exitWith {false};
if !(uiNamespace getVariable ["RACA_creatorDirty", false]) exitWith {_display closeDisplay 2; true};
private _confirmed = [
    "Close the creator and discard the current unsaved changes? Saved profile presets will not be changed.",
    "Unsaved RACA Changes",
    "DISCARD AND CLOSE",
    "KEEP EDITING",
    _display
] call BIS_fnc_guiMessage;
if (_confirmed && {!isNull _display}) then {_display closeDisplay 2};
_confirmed
