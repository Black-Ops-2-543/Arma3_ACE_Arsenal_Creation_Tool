#include "..\script_component.hpp"
params [["_group", controlNull, [controlNull]]];

if (isNull _group) exitWith {};

private _combo = _group controlsGroupCtrl RACA_EDEN_IDC_PRESET;
private _options = _group getVariable ["RACA_edenPresetOptions", [[]]];
private _current = _options param [lbCurSel _combo, []];
[_group, _current] call RACA_fnc_edenPopulate;
