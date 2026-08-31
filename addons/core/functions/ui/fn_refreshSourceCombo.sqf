#include "..\..\script_component.hpp"
params [["_display", displayNull, [displayNull]]];
if (isNull _display) exitWith {};
private _catalog = uiNamespace getVariable ["RACA_itemCatalog", []];
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
    lbClear _combo;
    private _all = _combo lbAdd format ["%1 (%2)", _allLabel, count _catalog];
    _combo lbSetData [_all, ""];
    private _selected = 0;
    {
        private _index = _combo lbAdd format ["%1 (%2)", _x, _counts get _x];
        _combo lbSetData [_index, _x];
        _combo lbSetTooltip [_index, _x];
        if (_x isEqualTo _previous) then {_selected = _index};
    } forEach _keys;
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
