#include "..\..\script_component.hpp"
params [["_display", displayNull, [displayNull]]];
if (isNull _display) exitWith {};
private _wasSuppressed = _display getVariable ["RACA_refreshSuppressed", false];
_display setVariable ["RACA_refreshSuppressed", true];
private _catalog = uiNamespace getVariable ["RACA_itemCatalog", []];
private _availableByControl = createHashMap;
private _populate = {
    params ["_combo", "_values", "_allLabel"];
    if (isNull _combo) exitWith {};
    private _previousIndex = lbCurSel _combo;
    private _previous = if (_previousIndex < 0) then {""} else {_combo lbData _previousIndex};
    private _counts = createHashMap;
    {
        if (_x isEqualType "" && {_x isNotEqualTo ""}) then {
            _counts set [_x, (_counts getOrDefault [_x, 0]) + 1];
        };
    } forEach _values;
    private _keys = keys _counts;
    _keys sort true;
    _availableByControl set [str ctrlIDC _combo, createHashMapFromArray (_keys apply {[_x, true]})];
    lbClear _combo;
    private _all = _combo lbAdd format ["%1 (%2)", _allLabel, count _catalog];
    _combo lbSetData [_all, ""];
    private _selected = 0;
    {
        private _index = _combo lbAdd format ["%1 (%2)", _x, _counts get _x];
        _combo lbSetData [_index, _x];
        if (_x isEqualTo _previous) then {_selected = _index};
    } forEach _keys;
    if (_previous isNotEqualTo "" && {_selected isEqualTo 0}) then {
        _selected = _combo lbAdd ("Missing: " + _previous);
        _combo lbSetData [_selected, _previous];
    };
    _combo lbSetCurSel _selected;
};

[
    _display displayCtrl RACA_IDC_SOURCE_FILTER,
    _catalog apply {_x param [4, "", [""]]},
    "All source mods"
] call _populate;
[
    _display displayCtrl RACA_IDC_ADDON_FILTER,
    _catalog apply {_x param [8, "", [""]]},
    "All owning add-ons"
] call _populate;
[
    _display displayCtrl RACA_IDC_AUTHOR_FILTER,
    _catalog apply {_x param [5, "", [""]]},
    "All authors"
] call _populate;

private _tagIndex = uiNamespace getVariable ["RACA_catalogTagIndex", createHashMap];
private _tagValues = [];
{
    {
        _tagValues pushBack _x;
    } forEach (_tagIndex getOrDefault [toLowerANSI (_x param [1, "", [""]]), []]);
} forEach _catalog;
[
    _display displayCtrl RACA_IDC_TAG_FILTER,
    _tagValues,
    "All tags"
] call _populate;
private _remainingUnresolved = [];
{
    _x params ["_idc", "_value"];
    private _available = _availableByControl getOrDefault [str _idc, createHashMap];
    if !(_available getOrDefault [_value, false]) then {_remainingUnresolved pushBack _x};
} forEach (_display getVariable ["RACA_unresolvedFilters", []]);
_display setVariable ["RACA_unresolvedFilters", _remainingUnresolved];
_display setVariable ["RACA_refreshSuppressed", _wasSuppressed];
