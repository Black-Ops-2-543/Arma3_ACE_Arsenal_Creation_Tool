#include "..\..\script_component.hpp"
params [
    ["_display", displayNull, [displayNull]]
];

if (isNull _display) exitWith {};

if ((profileNamespace getVariable ["RACA_quickStartPulseSeen_v1", false])) exitWith {};

private _button = _display displayCtrl RACA_IDC_QUICK_START;
if (isNull _button) exitWith {};

private _accent = [
    ((profileNamespace getVariable ['GUI_BCG_RGB_R', 0.19]) max 0.24),
    ((profileNamespace getVariable ['GUI_BCG_RGB_G', 0.42]) max 0.24),
    ((profileNamespace getVariable ['GUI_BCG_RGB_B', 0.19]) max 0.24),
    0.95
];
private _dim = _accent apply {(_x * 0.74) max 0.14};
private _base = _dim + [0.98];

profileNamespace setVariable ["RACA_quickStartPulseSeen_v1", true];
saveProfileNamespace;

for "_i" from 1 to 4 do {
    _button ctrlSetBackgroundColor _accent;
    uiSleep 0.12;
    _button ctrlSetBackgroundColor _base;
    uiSleep 0.12;
};
