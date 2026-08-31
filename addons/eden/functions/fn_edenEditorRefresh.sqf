#include "..\script_component.hpp"
params [["_display", displayNull, [displayNull]], ["_preferred", -1, [0]]];
if (isNull _display) exitWith {};
private _config = _display getVariable ["RACA_workingConfig", ["RACA_OBJECT_CONFIG", 1, [], []]];
private _slots = _config param [2, []];
private _list = _display displayCtrl RACA_EDEN_IDC_SLOT_LIST;
_display setVariable ["RACA_editorRefreshing", true];
lbClear _list;
{
    private _label = format ["[%1] %2 — %3", ["OFF", "ON"] select (_x select 3), _x select 1, (_x select 2) select 2];
    private _row = _list lbAdd _label;
    _list lbSetData [_row, _x select 0];
} forEach _slots;
if (_slots isEqualTo []) then {
    _display setVariable ["RACA_currentSlot", -1];
    (_display displayCtrl RACA_EDEN_IDC_EDITOR_STATUS) ctrlSetText "No slots configured. Add a slot to begin.";
} else {
    private _selection = if (_preferred < 0) then {0} else {_preferred min ((count _slots) - 1)};
    _list lbSetCurSel _selection;
    _display setVariable ["RACA_editorRefreshing", false];
    [_list, _selection] call RACA_fnc_edenEditorSelectSlot;
};
_display setVariable ["RACA_editorRefreshing", false];
