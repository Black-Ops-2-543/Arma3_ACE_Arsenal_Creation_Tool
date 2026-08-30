#include "..\script_component.hpp"
params [["_group", controlNull, [controlNull]]];

if (isNull _group) exitWith {[]};

private _combo = _group controlsGroupCtrl RACA_EDEN_IDC_PRESET;
private _options = _group getVariable ["RACA_edenPresetOptions", [[]]];
private _selection = lbCurSel _combo;
private _value = _options param [_selection, []];

if (_value isEqualType []) then {+_value} else {[]}
