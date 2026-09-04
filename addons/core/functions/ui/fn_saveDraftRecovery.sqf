#include "..\..\script_component.hpp"
disableSerialization;
params [["_display", displayNull, [displayNull]]];

if (isNull _display) then {
    _display = uiNamespace getVariable ["RACA_builderDisplay", displayNull];
};
if (isNull _display || {!(uiNamespace getVariable ["RACA_creatorDirty", false])}) exitWith {false};

private _rawName = ctrlText (_display displayCtrl RACA_IDC_PRESET_NAME);
private _nameCharacters = (toArray _rawName) select {_x >= 32 && {_x isNotEqualTo 127}};
private _safeName = toString (_nameCharacters select [0, 128]);
private _preset = [_display] call RACA_fnc_buildPreset;
_preset set [2, if (_safeName isEqualTo "") then {"Recovered unsaved draft"} else {_safeName}];

profileNamespace setVariable [
    "RACA_creatorDraftRecovery_v1",
    [
        "RACA_DRAFT_RECOVERY",
        1,
        _safeName,
        _preset,
        +(uiNamespace getVariable ["RACA_builderComposition", []]),
        systemTimeUTC,
        uiNamespace getVariable ["RACA_builderOrigin", ""]
    ]
];
saveProfileNamespace;
true
