#include "..\..\script_component.hpp"
disableSerialization;
params [["_display", displayNull, [displayNull]], ["_expectedGeneration", -1, [0]]];
if (isNull _display) exitWith {false};
if (_expectedGeneration >= 0 && {(_display getVariable ["RACA_generation", -1]) isNotEqualTo _expectedGeneration}) exitWith {false};
if (_display getVariable ["RACA_itemDetailsOpening", false]) exitWith {false};
private _existing = uiNamespace getVariable ["RACA_itemDetailsDisplay", displayNull];
if (!isNull _existing) exitWith {false};

private _list = _display displayCtrl RACA_IDC_ITEM_LIST;
private _row = lnbCurSelRow _list;
if (_row < 0) exitWith {
    [_display, "Select a catalogue row before opening item details."] call RACA_fnc_setStatus;
    false
};
private _classes = [_display] call RACA_fnc_resolveCreatorSelection;
private _className = _display getVariable ["RACA_focusedClass", _classes param [0, ""]];
if (_className isEqualTo "") exitWith {false};

uiNamespace setVariable ["RACA_itemDetailsParent", _display];
uiNamespace setVariable ["RACA_itemDetailsClass", _className];
_display setVariable ["RACA_itemDetailsOpening", true];
private _detailsDisplay = _display createDisplay "RACA_RscDisplayItemDetails";
if (isNull _detailsDisplay) exitWith {
    _display setVariable ["RACA_itemDetailsOpening", false];
    [_display, "Item details could not be opened."] call RACA_fnc_setStatus;
    false
};
uiNamespace setVariable ["RACA_itemDetailsDisplay", _detailsDisplay];
true
