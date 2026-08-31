#include "..\..\script_component.hpp"
params [["_display", displayNull, [displayNull]]];

if (isNull _display) exitWith {};

private _selected = uiNamespace getVariable ["RACA_builderSelected", createHashMap];
private _catalog = uiNamespace getVariable ["RACA_itemCatalog", []];
private _visible = uiNamespace getVariable ["RACA_visibleClasses", []];
private _sourceItems = uiNamespace getVariable ["RACA_builderInherited", createHashMap];
private _limits = uiNamespace getVariable ["RACA_builderLimits", createHashMap];
private _favorites = uiNamespace getVariable ["RACA_catalogFavorites", createHashMap];
private _summary = format ["%1 included | %2 visible / %3 available | %4 limits | %5 favorites", count _selected, count _visible, count _catalog, count _limits, count _favorites];

if ((count _sourceItems) > 0) then {
    private _sourceKeys = keys _sourceItems;
    private _selectedKeys = keys _selected;
    private _sourceIncludedCount = {_selected getOrDefault [_x, false]} count _sourceKeys;
    private _addedCount = {!(_sourceItems getOrDefault [_x, false])} count _selectedKeys;
    private _removedCount = (count _sourceKeys) - _sourceIncludedCount;
    _summary = format [
        "%1 total | %2 source included +%3 added -%4 removed | %5/%6 visible | %7 limits",
        count _selected,
        _sourceIncludedCount,
        _addedCount,
        _removedCount,
        count _visible,
        count _catalog,
        count _limits
    ];
};

_summary = _summary + ([" | SAVED", " | UNSAVED DRAFT"] select (uiNamespace getVariable ["RACA_creatorDirty", false]));

(_display displayCtrl RACA_IDC_SUMMARY) ctrlSetText _summary;
