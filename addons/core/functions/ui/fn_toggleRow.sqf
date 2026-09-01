#include "..\..\script_component.hpp"
params [
    ["_list", controlNull, [controlNull]],
    ["_button", 0, [0]],
    ["_mouseX", 0, [0]],
    ["_mouseY", 0, [0]],
    ["_shift", false, [true]],
    ["_ctrl", false, [true]],
    ["_alt", false, [true]],
    ["_keyboard", false, [true]]
];

if (isNull _list || {_button isNotEqualTo 0}) exitWith {};

private _rows = lbSelection _list;
if (_shift || _ctrl) exitWith {
    [
        ctrlParent _list,
        format [
            "%1 catalogue row(s) selected. Press Space to include/exclude them together, or use Favorite or Limit Item.",
            (count _rows) max 1
        ]
    ] call RACA_fnc_setStatus;
};
private _row = lnbCurSelRow _list;
if (_row < 0 && {_rows isNotEqualTo []}) then {_row = _rows select 0};
if (_row < 0) exitWith {};

/*
 * Mouse clicks select rows everywhere, but only the real checkbox hotspot
 * changes inclusion. Space passes _keyboard=true and acts on the full current
 * selection. Mouse coordinates are in screen space, as is ctrlPosition.
 */
if (!_keyboard && {_mouseX > ((ctrlPosition _list select 0) + ((ctrlPosition _list select 2) * 0.095))}) exitWith {
        [
            ctrlParent _list,
            "Row selected. Press Space or click its checkbox to include or exclude it."
        ] call RACA_fnc_setStatus;
};

if (_rows isEqualTo [] || {!(_row in _rows)}) then {_rows = [_row]};

private _className = _list lnbData [_row, 0];
if (_className isEqualTo "") exitWith {};
private _classes = [];
{
    private _candidate = _list lnbData [_x, 0];
    if (_candidate isNotEqualTo "") then {_classes pushBackUnique _candidate};
} forEach _rows;
if (_classes isEqualTo []) exitWith {};

private _selected = uiNamespace getVariable ["RACA_builderSelected", createHashMap];
private _include = !(_selected getOrDefault [_className, false]);

[ctrlParent _list] call RACA_fnc_pushCreatorHistory;

{
    if (_include) then {
        _selected set [_x, true];
    } else {
        _selected deleteAt _x;
    };
} forEach _classes;
uiNamespace setVariable ["RACA_builderSelected", _selected];
private _display = ctrlParent _list;
[_display] call RACA_fnc_refreshItemList;
[_display, format ["%1 %2 selected catalogue row(s).", ["Excluded", "Included"] select _include, count _classes]] call RACA_fnc_setStatus;
