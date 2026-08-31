#include "..\..\script_component.hpp"
params [
    ["_display", displayNull, [displayNull]],
    ["_field", "item", [""]]
];

if (isNull _display) exitWith {false};
_field = toLowerANSI _field;
if !(_field in ["included", "item", "class", "mod", "author"]) exitWith {false};

private _current = uiNamespace getVariable ["RACA_catalogSort", ["item", true]];
private _ascending = if ((_current param [0, ""]) isEqualTo _field) then {
    !(_current param [1, true])
} else {
    _field isNotEqualTo "included"
};
private _next = [_field, _ascending];
uiNamespace setVariable ["RACA_catalogSort", _next];
profileNamespace setVariable ["RACA_catalogSort_v1", _next];
saveProfileNamespace;

[_display] call RACA_fnc_refreshItemList;
private _label = switch (_field) do {
    case "included": {["excluded items first", "included items first"] select _ascending};
    case "class": {format ["class name (%1)", ["Z-A", "A-Z"] select _ascending]};
    case "mod": {format ["source mod (%1)", ["Z-A", "A-Z"] select _ascending]};
    case "author": {format ["author (%1)", ["Z-A", "A-Z"] select _ascending]};
    default {format ["item name (%1)", ["Z-A", "A-Z"] select _ascending]};
};
[_display, format ["Sorted catalogue by %1. Filters and inclusion state are unchanged.", _label]] call RACA_fnc_setStatus;
true
