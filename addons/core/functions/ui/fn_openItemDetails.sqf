#include "..\..\script_component.hpp"
disableSerialization;
params [["_display", displayNull, [displayNull]]];
if (isNull _display) exitWith {false};

private _list = _display displayCtrl RACA_IDC_ITEM_LIST;
private _row = lnbCurSelRow _list;
if (_row < 0) exitWith {
    [_display, "Select a catalogue row before opening item details."] call RACA_fnc_setStatus;
    false
};
private _className = _list lnbData [_row, 0];
if (_className isEqualTo "") exitWith {false};

uiNamespace setVariable ["RACA_itemDetailsParent", _display];
uiNamespace setVariable ["RACA_itemDetailsClass", _className];
private _detailsDisplay = _display createDisplay "RACA_RscDisplayItemDetails";
if (isNull _detailsDisplay) exitWith {
    [_display, "Item details could not be opened."] call RACA_fnc_setStatus;
    false
};
true
