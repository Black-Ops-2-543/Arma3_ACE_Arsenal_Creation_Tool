#include "..\..\script_component.hpp"
params [["_display", displayNull, [displayNull]]];

if (isNull _display) exitWith {};

private _combo = _display displayCtrl RACA_IDC_PRESET_LIST;
private _library = call RACA_fnc_getPresetLibrary;
uiNamespace setVariable ["RACA_builderLibrary", _library];

lbClear _combo;
_combo lbAdd "<Select a saved preset>";
{
    _combo lbAdd (_x select 2);
} forEach _library;
_combo lbSetCurSel 0;
