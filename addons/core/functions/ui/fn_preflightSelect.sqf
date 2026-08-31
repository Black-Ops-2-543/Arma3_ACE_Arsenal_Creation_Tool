#include "..\..\script_component.hpp"
disableSerialization;
params [["_display", displayNull, [displayNull]]];

if (isNull _display) exitWith {false};
private _row = lnbCurSelRow (_display displayCtrl RACA_IDC_PREFLIGHT_LIST);
private _entry = (_display getVariable ["RACA_preflightRows", []]) param [_row, []];
private _className = _entry param [3, "", [""]];
if (_className isEqualTo "") exitWith {
    (_display displayCtrl RACA_IDC_PREFLIGHT_SUMMARY) ctrlSetText "The selected diagnostic is not tied to one catalogue class.";
    false
};
private _catalog = uiNamespace getVariable ["RACA_itemCatalog", []];
if ((_catalog findIf {(_x select 1) isEqualTo _className}) < 0) exitWith {
    (_display displayCtrl RACA_IDC_PREFLIGHT_SUMMARY) ctrlSetText format ["'%1' is unavailable in the loaded catalogue. Load its source mod, reopen the creator, and run preflight again.", _className];
    false
};

_display closeDisplay 1;
[_className] spawn {
    disableSerialization;
    params ["_className"];
    uiSleep 0.1;
    private _parent = findDisplay RACA_IDD_CREATOR;
    if (isNull _parent) exitWith {};
    [_parent, "ASSIGNMENT"] call RACA_fnc_switchCreatorTab;
    (_parent displayCtrl RACA_IDC_SEARCH) ctrlSetText "";
    (_parent displayCtrl RACA_IDC_CATEGORY) lbSetCurSel 0;
    (_parent displayCtrl RACA_IDC_SOURCE_FILTER) lbSetCurSel 0;
    [_parent] call RACA_fnc_refreshItemList;
    private _list = _parent displayCtrl RACA_IDC_ITEM_LIST;
    private _targetRow = -1;
    for "_index" from 0 to ((lnbSize _list select 0) - 1) do {
        if ((_list lnbData [_index, 0]) isEqualTo _className) exitWith {_targetRow = _index};
    };
    if (_targetRow >= 0) then {
        _list lnbSetCurSelRow _targetRow;
        ctrlSetFocus _list;
        [_parent, format ["Selected preflight item '%1'.", _className]] call RACA_fnc_setStatus;
    };
};
true
