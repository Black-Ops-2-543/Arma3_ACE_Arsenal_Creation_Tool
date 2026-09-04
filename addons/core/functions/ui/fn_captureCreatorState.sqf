#include "..\..\script_component.hpp"
/* v2 retains the first four legacy fields; identity and raw metadata are atomic. */
params [["_display", displayNull, [displayNull]]];
if (isNull _display) exitWith {[]};
private _selected = keys (uiNamespace getVariable ["RACA_builderSelected", createHashMap]);
private _inherited = keys (uiNamespace getVariable ["RACA_builderInherited", createHashMap]);
private _limitsMap = uiNamespace getVariable ["RACA_builderLimits", createHashMap];
private _limits = (keys _limitsMap) apply {+(_limitsMap get _x)};
_selected sort true;
_inherited sort true;
_limits sort true;
[
    _selected, _limits, +(uiNamespace getVariable ["RACA_builderComposition", []]), _inherited,
    "RACA_CREATOR_STATE", 2, ctrlText (_display displayCtrl RACA_IDC_PRESET_NAME),
    +(uiNamespace getVariable ["RACA_builderRawPreset", []]),
    uiNamespace getVariable ["RACA_builderOrigin", ""],
    uiNamespace getVariable ["RACA_creatorDirty", false]
]
