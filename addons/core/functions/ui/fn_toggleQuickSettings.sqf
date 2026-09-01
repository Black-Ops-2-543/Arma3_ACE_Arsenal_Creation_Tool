#include "..\..\script_component.hpp"
params [
    ["_display", displayNull, [displayNull]],
    ["_force", -1, [0]]
];
if (isNull _display) exitWith {};

private _open = _display getVariable ["RACA_quickSettingsOpen", false];
if (_force isEqualTo 0) then {_open = false} else {
    if (_force isEqualTo 1) then {_open = true} else {_open = !_open};
};
_display setVariable ["RACA_quickSettingsOpen", _open];
{
    (_display displayCtrl _x) ctrlShow _open;
} forEach [
    RACA_IDC_QUICK_ROLE_LABEL,
    RACA_IDC_QUICK_ROLE,
    RACA_IDC_QUICK_SOURCE_LABEL,
    RACA_IDC_QUICK_SOURCE,
    RACA_IDC_QUICK_PARAMETER_HELP,
    RACA_IDC_QUICK_OPTICS_LABEL,
    RACA_IDC_QUICK_OPTICS,
    RACA_IDC_QUICK_SUPPRESSORS_LABEL,
    RACA_IDC_QUICK_SUPPRESSORS,
    RACA_IDC_QUICK_NVG_LABEL,
    RACA_IDC_QUICK_NVG,
    RACA_IDC_QUICK_MEDICAL_LABEL,
    RACA_IDC_QUICK_MEDICAL,
    RACA_IDC_QUICK_GENERATOR_NOTE,
    RACA_IDC_ROLE_PACKS_BUTTON
];
private _button = _display displayCtrl RACA_IDC_QUICK_SETTINGS;
_button ctrlSetText (["Open Optional Settings", "Hide Optional Settings"] select _open);
_button ctrlSetTooltip ([
    "Choose a role starter, content source, and optional equipment policies",
    "Return to the simple Quick Start view; your settings remain selected"
] select _open);
_button ctrlCommit 0;
