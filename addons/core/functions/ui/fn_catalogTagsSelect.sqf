#include "..\..\script_component.hpp"
disableSerialization;
params [["_list", controlNull, [controlNull]]];
if (isNull _list) exitWith {false};
private _row = lnbCurSelRow _list;
if (_row < 0) exitWith {false};
private _name = _list lnbData [_row, 0];
private _display = ctrlParent _list;
_display setVariable ["RACA_memberPage",0];
_display setVariable ["RACA_tagMemberHighlights",createHashMap];
private _tags = call RACA_fnc_getCatalogTags;
private _index = _tags findIf {toLowerANSI (_x select 2) isEqualTo toLowerANSI _name};
if (_index < 0) exitWith {false};

(_display displayCtrl RACA_IDC_CATALOG_TAG_NAME) ctrlSetText _name;
private _classes = (_tags select _index) select 3;
private _selectedClasses = _display getVariable ["RACA_catalogTagsSelectedClasses", []];
private _capturedSet=createHashMapFromArray (_selectedClasses apply {[(toLowerANSI _x),true]});
private _selectedCount = {_capturedSet getOrDefault [toLowerANSI _x,false]} count _classes;
private _available = createHashMap;
{_available set [toLowerANSI (_x select 1), true]} forEach (uiNamespace getVariable ["RACA_itemCatalog", []]);
private _availableCount = {_available getOrDefault [toLowerANSI _x, false]} count _classes;
(_display displayCtrl RACA_IDC_CATALOG_TAG_DETAILS) ctrlSetText format [
    "Tag '%1' contains %2 class(es); %3 are available in this Arma session and %4 are in the current multi-row selection.%5Tags are profile-wide authoring metadata. They never alter a preset or mission object.",
    _name,
    count _classes,
    _availableCount,
    _selectedCount,
    toString [10]
];
[_display] call RACA_fnc_catalogTagMembersRefresh;
true
