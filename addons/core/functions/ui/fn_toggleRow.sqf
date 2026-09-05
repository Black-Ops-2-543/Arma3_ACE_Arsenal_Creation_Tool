#include "..\..\script_component.hpp"
params [["_list",controlNull,[controlNull]],["_button",0,[0]],["_mouseX",0,[0]],["_mouseY",0,[0]],["_shift",false,[true]],["_ctrl",false,[true]],["_alt",false,[true]],["_keyboard",false,[true]]];
if (isNull _list) exitWith {};
private _display = ctrlParent _list;
_display setVariable ["RACA_mouseSelecting", false];
if (_button isNotEqualTo 0) exitWith {};
if (_display getVariable ["RACA_rendering",false]) exitWith {};
private _row = lnbCurSelRow _list;
private _class = if (_row < 0) then {""} else {_list lnbData [_row,0]};
if (_class isEqualTo "") exitWith {};
private _highlights = _display getVariable ["RACA_highlighted",createHashMap];
if (!_keyboard) then {
    if (_shift) then {
        private _visible = uiNamespace getVariable ["RACA_visibleClasses",[]];
        private _anchor = _display getVariable ["RACA_selectionAnchor",_class];
        private _a = _visible find _anchor;
        private _b = _visible find _class;
        if (_a < 0) then {_a = _b; _display setVariable ["RACA_selectionAnchor",_class]};
        if (!_ctrl) then {_highlights = createHashMap};
        if (_a >= 0 && {_b >= 0}) then {
            for "_i" from (_a min _b) to (_a max _b) do {_highlights set [_visible select _i,true]};
        };
    } else {
        if (_ctrl) then {
            if (_highlights getOrDefault [_class,false]) then {_highlights deleteAt _class} else {_highlights set [_class,true]};
        } else {_highlights = createHashMapFromArray [[_class,true]]};
        _display setVariable ["RACA_selectionAnchor",_class];
    };
    _display setVariable ["RACA_highlighted",_highlights];
    _display setVariable ["RACA_focusedClass",_class];
};
private _checkbox = _mouseX <= ((ctrlPosition _list select 0) + (ctrlPosition _list select 2)*0.095);
if (_keyboard || {_checkbox && {!_ctrl} && {!_shift}}) then {
    private _classes = [_display] call RACA_fnc_resolveCreatorSelection;
    private _selected = uiNamespace getVariable ["RACA_builderSelected",createHashMap];
    // Mixed selection: include all unless all are already included.
    private _include = (_classes findIf {!(_selected getOrDefault [_x,false])}) >= 0;
    private _changed = _classes select {(_selected getOrDefault [_x,false]) isNotEqualTo _include};
    if (_changed isNotEqualTo []) then {
        [_display] call RACA_fnc_pushCreatorHistory;
        {if (_include) then {_selected set [_x,true]} else {_selected deleteAt _x}} forEach _changed;
        uiNamespace setVariable ["RACA_builderSelected",_selected];
        [_display,format ["%1 %2 item(s).",["Excluded","Included"] select _include,count _changed]] call RACA_fnc_setStatus;
    };
};
[_display] call RACA_fnc_refreshItemList;
if (!_keyboard && {!_shift} && {!_ctrl} && {!_alt} &&
    {["RACA_openItemDetailsOnSelection"] call RACA_fnc_getSetting}) then {
    [_display, _display getVariable ["RACA_generation", -1]] call RACA_fnc_openItemDetails;
};
