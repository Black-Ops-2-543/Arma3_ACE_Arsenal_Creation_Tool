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
if ((_catalog findIf {toLowerANSI (_x select 1) isEqualTo toLowerANSI _className}) < 0) exitWith {
    (_display displayCtrl RACA_IDC_PREFLIGHT_SUMMARY) ctrlSetText format ["'%1' is unavailable in the loaded catalogue. Load its source mod, reopen the creator, and run preflight again.", _className];
    false
};

private _parent = _display getVariable ["RACA_preflightParentDisplay",displayNull];
if (isNull _parent) exitWith {false};
private _prior=[_parent] call RACA_fnc_captureCatalogView;
_display closeDisplay 1;
[_parent,_className,_prior] spawn {
    disableSerialization;
    params ["_parent","_className","_prior"];
    uiSleep 0.1;
    if (isNull _parent) exitWith {};
    [_parent,"ASSIGNMENT"] call RACA_fnc_switchCreatorTab;
    _parent setVariable ["RACA_navigationClasses",[_className]];
    _parent setVariable ["RACA_diagnosticNavigationPrior",_prior];
    (_parent displayCtrl RACA_IDC_CLEAR_MAGAZINES) ctrlSetText "Return To Previous View";
    (_parent displayCtrl RACA_IDC_CLEAR_MAGAZINES) ctrlShow true;
    [_parent] call RACA_fnc_refreshItemList;
    _parent setVariable ["RACA_highlighted",createHashMapFromArray [[_className,true]]];
    _parent setVariable ["RACA_focusedClass",_className];
    [_parent] call RACA_fnc_refreshItemList;
    ctrlSetFocus (_parent displayCtrl RACA_IDC_ITEM_LIST);
    [_parent,format ["Showing diagnostic class '%1'. Return restores every previous filter and selection.",_className]] call RACA_fnc_setStatus;
};
true
