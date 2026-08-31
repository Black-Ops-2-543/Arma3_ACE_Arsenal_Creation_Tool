#include "..\..\script_component.hpp"
params [
    ["_display", displayNull, [displayNull]],
    ["_key", -1, [0]],
    ["_shift", false, [true]],
    ["_control", false, [true]],
    ["_alt", false, [true]]
];

if (isNull _display) exitWith {false};

if (_key isEqualTo 1) exitWith {
    [_display] spawn RACA_fnc_requestCreatorClose;
    true
};

if (_control && {_key isEqualTo 44}) exitWith {[_display, "UNDO"] call RACA_fnc_restoreCreatorHistory; true};
if (_control && {_key isEqualTo 21}) exitWith {[_display, "REDO"] call RACA_fnc_restoreCreatorHistory; true};

false
