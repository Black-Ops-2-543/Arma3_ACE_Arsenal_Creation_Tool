#include "..\..\script_component.hpp"
params [
    ["_list", controlNull, [controlNull]],
    ["_button", 0, [0]]
];

if (isNull _list || {_button isNotEqualTo 0}) exitWith {};

private _row = lnbCurSelRow _list;
if (_row < 0) exitWith {};

private _className = _list lnbData [_row, 0];
if (_className isEqualTo "") exitWith {};

private _selected = uiNamespace getVariable ["RACA_builderSelected", createHashMap];
private _include = !(_selected getOrDefault [_className, false]);

if (_include) then {
    _selected set [_className, true];
} else {
    _selected deleteAt _className;
};

_list lnbSetPicture [[_row, 0], [RACA_TEXTURE_UNCHECKED, RACA_TEXTURE_CHECKED] select _include];
uiNamespace setVariable ["RACA_builderSelected", _selected];
[ctrlParent _list] call RACA_fnc_updateSummary;
