#include "..\..\script_component.hpp"
params [
    ["_display", displayNull, [displayNull]]
];

if (isNull _display) exitWith {};

if (
    (profileNamespace getVariable ["RACA_quickStartPulseSeen_v2", false]) ||
    (missionNamespace getVariable ["RACA_quickStartPulseSeenSession", false])
) exitWith {};

private _button = _display displayCtrl RACA_IDC_QUICK_START;
if (isNull _button) exitWith {};

private _accent = [
    ((profileNamespace getVariable ['GUI_BCG_RGB_R', 0.19]) max 0.24),
    ((profileNamespace getVariable ['GUI_BCG_RGB_G', 0.42]) max 0.24),
    ((profileNamespace getVariable ['GUI_BCG_RGB_B', 0.19]) max 0.24),
    0.95
];
private _base = (_accent select [0, 3]) apply {(_x * 0.72) + 0.25};
private _dimmed = [(_base # 0), (_base # 1), (_base # 2), 0.95];

profileNamespace setVariable ["RACA_quickStartPulseSeen_v2", true];
missionNamespace setVariable ["RACA_quickStartPulseSeenSession", true];
saveProfileNamespace;

for "_i" from 1 to 3 do {
    _button ctrlSetBackgroundColor _accent;
    uiSleep 0.12;
    _button ctrlSetBackgroundColor _dimmed;
    uiSleep 0.12;
};
