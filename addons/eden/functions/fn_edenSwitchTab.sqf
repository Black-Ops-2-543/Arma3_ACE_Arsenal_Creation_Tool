#include "..\script_component.hpp"
params [
    ["_display", displayNull, [displayNull]],
    ["_tab", "DASHBOARD", [""]]
];
if (isNull _display) exitWith {false};

private _next = toUpperANSI _tab;
if !(_next in ["DASHBOARD", "CONFIGURE"]) then {_next = "DASHBOARD"};
private _previous = _display getVariable ["RACA_edenActiveTab", ""];
private _canSwitch = true;
if (_previous isEqualTo "CONFIGURE" && {_next isNotEqualTo "CONFIGURE"}) then {
    _canSwitch = [_display, -1, false] call RACA_fnc_edenEditorCommitSlot;
    if (_canSwitch) then {
        private _working = _display getVariable ["RACA_workingConfigurations", []];
        if (_working isNotEqualTo (call RACA_fnc_edenGetConfigurations)) then {
            _canSwitch = [_display, _working, "Save Arsenal Configuration changes"] call RACA_fnc_edenStoreConfigurations;
        };
    };
};
if (!_canSwitch) exitWith {false};

private _showDashboard = _next isEqualTo "DASHBOARD";
(_display displayCtrl RACA_EDEN_IDC_DASHBOARD_GROUP) ctrlShow _showDashboard;
(_display displayCtrl RACA_EDEN_IDC_CONFIGURE_GROUP) ctrlShow (!_showDashboard);
(_display displayCtrl RACA_EDEN_IDC_TAB_DASHBOARD) ctrlSetBackgroundColor (if (_showDashboard) then {
    [
        profileNamespace getVariable ["GUI_BCG_RGB_R", 0.13],
        profileNamespace getVariable ["GUI_BCG_RGB_G", 0.41],
        profileNamespace getVariable ["GUI_BCG_RGB_B", 0.67],
        0.95
    ]
} else {[0.13, 0.14, 0.16, 0.95]});
(_display displayCtrl RACA_EDEN_IDC_TAB_CONFIGURE) ctrlSetBackgroundColor (if (!_showDashboard) then {
    [
        profileNamespace getVariable ["GUI_BCG_RGB_R", 0.13],
        profileNamespace getVariable ["GUI_BCG_RGB_G", 0.41],
        profileNamespace getVariable ["GUI_BCG_RGB_B", 0.67],
        0.95
    ]
} else {[0.13, 0.14, 0.16, 0.95]});
_display setVariable ["RACA_edenActiveTab", _next];
if (_showDashboard) then {[_display] call RACA_fnc_edenDashboardRefresh};
true
