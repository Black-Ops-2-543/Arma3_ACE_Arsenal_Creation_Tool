#include "..\..\script_component.hpp"
params [["_display", displayNull, [displayNull]]];

if (isNull _display) exitWith {};

private _combo = _display displayCtrl RACA_IDC_PRESET_LIST;
private _analysisCombo = _display displayCtrl RACA_IDC_PRESET_TOOL;
private _library = call RACA_fnc_getPresetLibrary;
uiNamespace setVariable ["RACA_builderLibrary", _library];

lbClear _combo;
lbClear _analysisCombo;
private _none = _combo lbAdd "<Select a saved preset>";
_combo lbSetData [_none, ""];
private _analysisNone = _analysisCombo lbAdd "<Select a preset to analyze>";
_analysisCombo lbSetData [_analysisNone, ""];
{
    private _name = _x select 2;
    private _index = _combo lbAdd _name;
    _combo lbSetData [_index, _name];
    private _analysisIndex = _analysisCombo lbAdd _name;
    _analysisCombo lbSetData [_analysisIndex, _name];
} forEach _library;
_combo lbSetCurSel 0;
_analysisCombo lbSetCurSel 0;
[_display] call RACA_fnc_refreshBaseCombo;
[_display] call RACA_fnc_refreshHistoryButtons;
