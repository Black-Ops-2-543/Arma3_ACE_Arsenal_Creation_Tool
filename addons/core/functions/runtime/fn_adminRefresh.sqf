#include "..\..\script_component.hpp"
params [
    ["_display", displayNull, [displayNull]],
    ["_snapshot", [], [[]]]
];
if (isNull _display || {_snapshot isEqualTo []}) exitWith {false};
_display setVariable ["RACA_adminSnapshot", _snapshot];
_snapshot params ["_message", "_objects", "_audit"];
private _objectList = _display displayCtrl RACA_IDC_ADMIN_OBJECTS;
lnbClear _objectList;
{
    _x params ["", "_objectId", "_variableName", "_type", "", "_slots", "_quotaCount", "_sessionCount"];
    private _name = if (_variableName isEqualTo "") then {_objectId} else {_variableName};
    private _slotNames = _slots apply {format ["%1%2", _x select 1, [" (off)", ""] select (_x select 2)]};
    private _row = _objectList lnbAddRow [_name, _type, _slotNames joinString ", ", str _quotaCount, str _sessionCount];
    _objectList lnbSetData [[_row, 0], str _forEachIndex];
    _objectList lnbSetTooltip [[_row, 2], _slots apply {format ["%1: %2 conditions, %3 limits, %4 classes", _x select 1, _x select 4, _x select 5, _x select 6]} joinString toString [10]];
} forEach _objects;
if (_objects isNotEqualTo []) then {_objectList lnbSetCurSelRow 0};

private _auditList = _display displayCtrl RACA_IDC_ADMIN_AUDIT;
lnbClear _auditList;
{
    _x params ["_time", "_event", "_uid", "_name", "_objectId", "_slotId", "_details"];
    private _row = _auditList lnbAddRow [str _time, _event, _name, _uid, _objectId, _slotId, str _details];
    _auditList lnbSetData [[_row, 0], str _forEachIndex];
} forEach _audit;
(_display displayCtrl RACA_IDC_ADMIN_STATUS) ctrlSetText _message;
true
