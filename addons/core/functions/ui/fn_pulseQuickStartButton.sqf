#include "..\..\script_component.hpp"
params [
    ["_display", displayNull, [displayNull]]
];

if (isNull _display) exitWith {};

if (uiNamespace getVariable ["RACA_quickStartPulseSeen_v2", false]) exitWith {};

private _button = _display displayCtrl RACA_IDC_QUICK_START;
if (isNull _button) exitWith {};

private _accent = [
    ((profileNamespace getVariable ['GUI_BCG_RGB_R', 0.19]) max 0.24),
    ((profileNamespace getVariable ['GUI_BCG_RGB_G', 0.42]) max 0.24),
    ((profileNamespace getVariable ['GUI_BCG_RGB_B', 0.19]) max 0.24),
    0.95
];
private _dimFactor = 0.75;
private _dimFloor = 0.40;
private _dim = (_accent select [0, 3]) apply {(_x * _dimFactor) max _dimFloor};
private _base = [(_dim # 0), (_dim # 1), (_dim # 2), 0.92];

uiNamespace setVariable ["RACA_quickStartPulseSeen_v2", true];

for "_i" from 1 to 3 do {
    _button ctrlSetBackgroundColor _accent;
    uiSleep 0.12;
    _button ctrlSetBackgroundColor _base;
    uiSleep 0.12;
};
