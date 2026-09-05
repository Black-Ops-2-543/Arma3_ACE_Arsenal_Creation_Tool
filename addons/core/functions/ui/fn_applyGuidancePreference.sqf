#include "..\..\script_component.hpp"
params [["_display", displayNull, [displayNull]]];
if (isNull _display) exitWith {};
private _show = ["RACA_showOnboardingGuidance"] call RACA_fnc_getSetting;
private _presetTab = (uiNamespace getVariable ["RACA_creatorTab", "PRESETS"]) isEqualTo "PRESETS";
{(_display displayCtrl _x) ctrlShow (_show && {_presetTab})} forEach [RACA_IDC_INHERITANCE_HELP, RACA_IDC_DIAGNOSTICS];
