#include "..\..\script_component.hpp"
/* Synchronizes engine keyboard selection with stable class identities. */
disableSerialization;
params [["_list", controlNull, [controlNull]]];
if (isNull _list) exitWith {false};
private _display = ctrlParent _list;
if (isNull _display ||
    {_display getVariable ["RACA_rendering", false]} ||
    {_display getVariable ["RACA_mouseSelecting", false]}) exitWith {true};

private _highlighted = _display getVariable ["RACA_highlighted", createHashMap];
private _native = createHashMapFromArray ((lbSelection _list) apply {
    [_list lnbData [_x, 0], true]
});
for "_row" from 0 to (((lnbSize _list) select 0) - 1) do {
    private _className = _list lnbData [_row, 0];
    if (_className isNotEqualTo "") then {
        if (_native getOrDefault [_className, false]) then {
            _highlighted set [_className, true]
        } else {
            _highlighted deleteAt _className
        };
    };
};
private _currentRow = lnbCurSelRow _list;
if (_currentRow >= 0) then {
    private _currentClass = _list lnbData [_currentRow, 0];
    _display setVariable ["RACA_focusedClass", _currentClass];
    if ((count _native) <= 1) then {
        _display setVariable ["RACA_selectionAnchor", _currentClass]
    };
};
_display setVariable ["RACA_highlighted", _highlighted];
(_display displayCtrl RACA_IDC_PAGE_LABEL) ctrlSetText format [
    "Page %1 | %2 highlighted",
    (_display getVariable ["RACA_page", 0]) + 1,
    count _highlighted
];
true
