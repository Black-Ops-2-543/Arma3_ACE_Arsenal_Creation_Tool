#include "..\..\script_component.hpp"
disableSerialization;
params [["_display", displayNull, [displayNull]]];
if (isNull _display) exitWith {false};
private _list = _display displayCtrl RACA_IDC_SAVED_VIEW_LIST;
private _row = lnbCurSelRow _list;
if (_row < 0) exitWith {false};
private _name = _list lnbData [_row, 0];
[_display, _name] spawn {
    disableSerialization;
    params ["_display", "_name"];
    private _confirmed = [format ["Delete saved filters '%1'?%2Arsenal contents and presets are unaffected.", _name, toString [10]], "RACA Saved Filters", true, true, _display] call BIS_fnc_guiMessage;
    if (!_confirmed) exitWith {};
    private _views = call RACA_fnc_getSavedCatalogViews;
    _views = _views select {toLowerANSI (_x select 2) isNotEqualTo toLowerANSI _name};
    profileNamespace setVariable ["RACA_savedCatalogViews_v1", _views];
    saveProfileNamespace;
    (_display displayCtrl RACA_IDC_SAVED_VIEW_NAME) ctrlSetText "";
    [_display] call RACA_fnc_savedCatalogViewRefresh;
};
true
