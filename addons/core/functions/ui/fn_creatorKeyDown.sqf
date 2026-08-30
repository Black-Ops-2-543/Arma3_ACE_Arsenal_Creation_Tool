#include "..\..\script_component.hpp"
params [
    ["_display", displayNull, [displayNull]],
    ["_key", -1, [0]]
];

if (isNull _display) exitWith {false};

if (_key isEqualTo 1) exitWith {
    _display closeDisplay 2;
    true
};

false
