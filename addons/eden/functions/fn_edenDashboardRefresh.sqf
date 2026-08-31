#include "..\script_component.hpp"
params [["_display", displayNull, [displayNull]]];
if (isNull _display || {!is3DEN}) exitWith {false};
private _list = _display displayCtrl RACA_EDEN_IDC_DASHBOARD_LIST;
private _objects = [];
lbClear _list;
{
    private _raw = (_x get3DENAttribute "RACA_RestrictedArsenalPreset") param [0, []];
    private _config = if (_raw isEqualTo []) then {[]} else {[_raw] call RACA_fnc_normalizeObjectConfig};
    if (_config isNotEqualTo []) then {
        private _variableName = (_x get3DENAttribute "Name") param [0, ""];
        if (_variableName isEqualTo "") then {_variableName = format ["%1 #%2", typeOf _x, get3DENEntityID _x]};
        private _slotNames = (_config select 2) apply {_x select 1};
        _list lbAdd format ["%1 | %2 slot(s): %3", _variableName, count _slotNames, _slotNames joinString ", "];
        _objects pushBack _x;
    };
} forEach (all3DENEntities select 0);
_display setVariable ["RACA_dashboardObjects", _objects];
if (_objects isNotEqualTo []) then {_list lbSetCurSel 0};
(_display displayCtrl RACA_EDEN_IDC_EDITOR_STATUS) ctrlSetText format ["Mission dashboard: %1 configured object(s); %2 object(s) currently selected in Eden.", count _objects, count (get3DENSelected "object")];
true
