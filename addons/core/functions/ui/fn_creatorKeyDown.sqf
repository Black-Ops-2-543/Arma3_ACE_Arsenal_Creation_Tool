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

if (_key isEqualTo 57) exitWith {
    private _list = _display displayCtrl RACA_IDC_ITEM_LIST;
    if ((lnbCurSelRow _list) >= 0) then {
        [_list, 0] call RACA_fnc_toggleRow;
        true
    } else {
        false
    }
};

false
