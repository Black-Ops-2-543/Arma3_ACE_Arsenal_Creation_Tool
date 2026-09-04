#include "..\..\script_component.hpp"
params [["_display",displayNull,[displayNull]],["_state",[],[[]]]];
if (isNull _display || {_state isEqualTo []}) exitWith {false};
_display setVariable ["RACA_refreshSuppressed",true];
(_display displayCtrl RACA_IDC_SEARCH) ctrlSetText (_state select 0);
private _unresolved = [];
{
    _x params ["_idc","_value"];
    private _c = _display displayCtrl _idc;
    private _match = -1;
    for "_i" from 0 to (lbSize _c - 1) do {if ((_c lbData _i) isEqualTo _value) exitWith {_match=_i}};
    if (_match<0 && {_value isNotEqualTo ""}) then {
        _match=_c lbAdd ("Missing: "+_value); _c lbSetData [_match,_value];
        _unresolved pushBack [_idc,_value];
    };
    _c lbSetCurSel (_match max 0);
} forEach (_state select 2);
uiNamespace setVariable ["RACA_catalogSort",+(_state select 3)];
_display setVariable ["RACA_highlighted",createHashMapFromArray ((_state select 4) apply {[_x,true]})];
_display setVariable ["RACA_selectionAnchor",_state select 5];
_display setVariable ["RACA_focusedClass",_state select 6];
_display setVariable ["RACA_navigationClasses",+(_state select 8)];
_display setVariable ["RACA_unresolvedFilters",_unresolved];
uiNamespace setVariable ["RACA_magazineFilterContext",+(_state select 10)];
[_display,_state select 1,false] call RACA_fnc_setSearchMode;
_display setVariable ["RACA_refreshSuppressed",false];
[_display,_state select 7] spawn {
    params ["_display","_page"];
    [_display] call RACA_fnc_refreshItemList;
    if (!isNull _display) then {
        _display setVariable ["RACA_page",_page min ((ceil ((count (uiNamespace getVariable ["RACA_visibleClasses",[]]))/200)-1) max 0)];
        [_display] call RACA_fnc_refreshItemList;
        private _diagnosticPrior = _display getVariable ["RACA_diagnosticNavigationPrior", []];
        if (_diagnosticPrior isNotEqualTo []) then {
            (_display displayCtrl RACA_IDC_CLEAR_MAGAZINES) ctrlSetText "Return To Previous View";
            (_display displayCtrl RACA_IDC_CLEAR_MAGAZINES) ctrlShow true;
        };
        ctrlSetFocus (_display displayCtrl RACA_IDC_ITEM_LIST);
    };
};
true
