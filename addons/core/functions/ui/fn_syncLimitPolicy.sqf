#include "..\..\script_component.hpp"
params [["_display", displayNull, [displayNull]]];
if (isNull _display) exitWith {false};

private _scopeCtrl = _display displayCtrl RACA_IDC_LIMIT_SCOPE;
private _resetCtrl = _display displayCtrl RACA_IDC_LIMIT_RESET;
private _scope = _scopeCtrl lbData (lbCurSel _scopeCtrl);
if (_scope isEqualTo "interaction") then {
    private _interactionIndex = -1;
    for "_index" from 0 to ((lbSize _resetCtrl) - 1) do {
        if ((_resetCtrl lbData _index) isEqualTo "interaction") exitWith {_interactionIndex = _index};
    };
    if (_interactionIndex >= 0) then {_resetCtrl lbSetCurSel _interactionIndex};
    _resetCtrl ctrlEnable false;
    _resetCtrl ctrlSetTooltip "Interaction allowances always start fresh whenever this arsenal is used.";
} else {
    _resetCtrl ctrlEnable true;
    _resetCtrl ctrlSetTooltip "When this allowance becomes available again. Round and phase resets are triggered by a runtime administrator.";
};
true
