#include "..\..\script_component.hpp"
params [["_display", displayNull, [displayNull]]];

if (isNull _display) exitWith {};

private _selected = uiNamespace getVariable ["RACA_builderSelected", createHashMap];
private _catalog = uiNamespace getVariable ["RACA_itemCatalog", []];
private _visible = uiNamespace getVariable ["RACA_visibleClasses", []];

(_display displayCtrl RACA_IDC_SUMMARY) ctrlSetText format [
    "%1 included | %2 visible / %3 available",
    count _selected,
    count _visible,
    count _catalog
];
