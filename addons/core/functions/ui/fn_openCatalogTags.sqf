#include "..\..\script_component.hpp"
disableSerialization;
params [["_display", displayNull, [displayNull]]];
if (isNull _display) exitWith {false};

private _list = _display displayCtrl RACA_IDC_ITEM_LIST;
private _rows = lbSelection _list;
private _row = lnbCurSelRow _list;
if (_row >= 0 && {!(_row in _rows)}) then {_rows = [_row]};
private _classes = [];
{
    private _className = _list lnbData [_x, 0];
    if (_className isNotEqualTo "") then {_classes pushBackUnique _className};
} forEach _rows;

uiNamespace setVariable ["RACA_catalogTagsParent", _display];
uiNamespace setVariable ["RACA_catalogTagsSelection", _classes];
private _tagsDisplay = _display createDisplay "RACA_RscDisplayCatalogTags";
if (isNull _tagsDisplay) exitWith {
    [_display, "The catalogue tag manager could not be opened."] call RACA_fnc_setStatus;
    false
};
true
