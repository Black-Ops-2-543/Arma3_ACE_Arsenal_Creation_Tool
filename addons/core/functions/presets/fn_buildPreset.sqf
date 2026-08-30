#include "..\..\script_component.hpp"
params [["_display", displayNull, [displayNull]]];

if (isNull _display) exitWith {[]};

private _name = ctrlText (_display displayCtrl RACA_IDC_PRESET_NAME);
private _selected = uiNamespace getVariable ["RACA_builderSelected", createHashMap];
private _catalog = uiNamespace getVariable ["RACA_itemCatalog", []];
private _buckets = [[], [], [], []];

{
    _x params ["", "_className", "", "_bucket"];
    if (_selected getOrDefault [_className, false]) then {
        (_buckets select _bucket) pushBackUnique _className;
    };
} forEach _catalog;

{_x sort true} forEach _buckets;
["RACA_PRESET", 1, _name, _buckets]
