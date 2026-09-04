#include "..\script_component.hpp"
disableSerialization;
params [["_display", displayNull, [displayNull]]];
if (isNull _display || {!is3DEN}) exitWith {false};
private _row = lnbCurSelRow (_display displayCtrl RACA_EDEN_IDC_DASHBOARD_LIST);
private _object = (_display getVariable ["RACA_dashboardObjects", []]) param [_row, objNull];
if (isNull _object) exitWith {
    (_display displayCtrl RACA_EDEN_IDC_EDITOR_STATUS) ctrlSetText "Select a Dashboard row before applying a configuration.";
    false
};
private _assignment = _display displayCtrl RACA_EDEN_IDC_DASHBOARD_ASSIGNMENT;
private _selection = lbCurSel _assignment;
private _configurationId = if (_selection < 0) then {""} else {_assignment lbData _selection};
private _value = [];
private _statusName = "No Arsenal Configuration";
private _canApply = true;

if (_configurationId isEqualTo "") then {
    private _raw = (_object get3DENAttribute "RACA_RestrictedArsenalPreset") param [0, []];
    if (_raw isEqualTo []) then {
        (_display displayCtrl RACA_EDEN_IDC_EDITOR_STATUS) ctrlSetText "This object already has no Arsenal Configuration.";
        _canApply = false;
    };
    if (_canApply) then {
        _canApply = [
            "Remove the RACA Arsenal Configuration from this object? This can be undone with Eden Undo.",
            "Remove Arsenal Configuration",
            "Remove",
            "Cancel",
            _display
        ] call BIS_fnc_guiMessage;
    };
} else {
    private _configurations = call RACA_fnc_edenGetConfigurations;
    private _match = _configurations findIf {toLowerANSI (_x select 0) isEqualTo toLowerANSI _configurationId};
    if (_match < 0) then {
        (_display displayCtrl RACA_EDEN_IDC_EDITOR_STATUS) ctrlSetText "That Arsenal Configuration no longer exists. Refresh the Dashboard and choose another.";
        _canApply = false;
    };
    if (_canApply) then {
        private _configuration = _configurations select _match;
        ([_configuration, uiNamespace getVariable ["RACA_itemCatalog", []]] call RACA_fnc_validateConfigurationForAssignment) params ["_valid", "_normalized", "_entries", "_summary"];
        if (!_valid) then {
            (_display displayCtrl RACA_EDEN_IDC_EDITOR_STATUS) ctrlSetText format ["Apply blocked by %1 preflight error(s): %2", _summary select 0, (_entries apply {_x select 2}) joinString "; "];
            _canApply = false;
        } else {
            _value = _normalized;
        };
        _statusName = _configuration select 1;
    };
};
if (!_canApply) exitWith {false};
private _activeTransaction = uiNamespace getVariable ["RACA_edenNativeTransaction", []];
if (_activeTransaction isNotEqualTo []) then {
    private _activeExpiry = _activeTransaction param [8, 0, [0]];
    if (_activeExpiry > diag_tickTime) exitWith {
        (_display displayCtrl RACA_EDEN_IDC_EDITOR_STATUS) ctrlSetText "Another native Attributes fallback is still active. Finish or cancel it before applying again.";
        _canApply = false;
    };
    uiNamespace setVariable ["RACA_edenNativeTransaction", nil];
};
if (!_canApply) exitWith {false};
private _activeDisplay = findDisplay RACA_EDEN_IDD_CONFIG;
if (isNull _activeDisplay) exitWith {false};
_display = _activeDisplay;

/*
 * Eden rejects custom-attribute writes while this child display owns the
 * workspace.  Preserve the Dashboard context, close the child display, make
 * the one-object history change from display 313, and then reopen the tool.
 */
private _variableFilter = _display displayCtrl RACA_EDEN_IDC_VARIABLE_FILTER;
private _variableMode = _variableFilter lbData (lbCurSel _variableFilter);
private _objectFilter = _display displayCtrl RACA_EDEN_IDC_OBJECT_FILTER;
private _objectMode = _objectFilter lbData (lbCurSel _objectFilter);
private _searchText = ctrlText (_display displayCtrl RACA_EDEN_IDC_DASHBOARD_SEARCH);
_display closeDisplay 1;
uiSleep 0.05;

/*
 * Prefer Eden's attribute scripting commands.  Some Arma builds reject this
 * custom array-valued control through those commands while still accepting it
 * through the native Attributes window.  In that case, hand the requested
 * selection to the control's native load/save lifecycle and verify the exact
 * value after Eden accepts the dialog.
 */
private _property = "RACA_RestrictedArsenalPreset";
private _before = (_object get3DENAttribute _property) param [0, []];
private _didSet = _before isEqualTo _value;
if (!_didSet) then {
    _didSet = set3DENAttributes [[[_object], _property, +_value]];
};
if (!_didSet) then {
    private _entityId = get3DENEntityID _object;
    if (_entityId >= 0) then {
        _didSet = set3DENAttributes [[[_entityId], _property, +_value]];
    };
};
if (!_didSet) then {
    private _entityId = get3DENEntityID _object;
    if (_entityId >= 0) then {
        private _libraryRevision = str ((call RACA_fnc_edenGetConfigurationState) select 3);
        private _requestId = format ["native_%1_%2", clientOwner, floor (diag_tickTime * 1000)];
        uiNamespace setVariable ["RACA_edenNativeTransaction", [
            "RACA_EDEN_NATIVE_TRANSACTION", 1, _requestId, _entityId, _configurationId,
            +_value, +_before, _libraryRevision, diag_tickTime + 5, "PENDING", displayNull
        ]];
        set3DENSelected [_object];
        do3DENAction "OpenAttributes";

        private _nativeDeadline = diag_tickTime + 5;
        waitUntil {
            uiSleep 0.02;
            private _candidate = (_object get3DENAttribute _property) param [0, []];
            private _transaction = uiNamespace getVariable ["RACA_edenNativeTransaction", []];
            private _state = _transaction param [9, "CLEARED", [""]];
            private _nativeDisplay = _transaction param [10, displayNull, [displayNull]];
            _candidate isEqualTo _value || {!is3DEN} || {_state find "REJECTED:" isEqualTo 0} ||
                {_state isEqualTo "LOADED" && {isNull _nativeDisplay}} || {diag_tickTime >= _nativeDeadline}
        };
        _didSet = ((_object get3DENAttribute _property) param [0, []]) isEqualTo _value;
        if (!_didSet) then {
            private _transaction = uiNamespace getVariable ["RACA_edenNativeTransaction", []];
            private _nativeDisplay = _transaction param [10, displayNull, [displayNull]];
            if (!isNull _nativeDisplay) then {
                ctrlActivate (_nativeDisplay displayCtrl 2);
                uiSleep 0.05;
            };
        };
        uiNamespace setVariable ["RACA_edenNativeTransaction", nil];
    };
};
uiSleep 0.05;
private _stored = (_object get3DENAttribute _property) param [0, []];
private _retained = _didSet && {_stored isEqualTo _value};

[] call RACA_fnc_edenOpenEditor;
private _deadline = diag_tickTime + 2;
private _reopenedDisplay = displayNull;
waitUntil {
    uiSleep 0.01;
    _reopenedDisplay = findDisplay RACA_EDEN_IDD_CONFIG;
    !isNull _reopenedDisplay || {!is3DEN} || {diag_tickTime >= _deadline}
};
if (isNull _reopenedDisplay) exitWith {_retained};

private _restoreCombo = {
    params ["_control", "_data"];
    private _match = -1;
    for "_index" from 0 to ((lbSize _control) - 1) do {
        if ((_control lbData _index) isEqualTo _data) exitWith {_match = _index};
    };
    if (_match >= 0) then {_control lbSetCurSel _match};
};
(_reopenedDisplay displayCtrl RACA_EDEN_IDC_DASHBOARD_SEARCH) ctrlSetText _searchText;
[_reopenedDisplay displayCtrl RACA_EDEN_IDC_VARIABLE_FILTER, _variableMode] call _restoreCombo;
[_reopenedDisplay displayCtrl RACA_EDEN_IDC_OBJECT_FILTER, _objectMode] call _restoreCombo;
_reopenedDisplay setVariable ["RACA_dashboardSelectedObject", _object];
[_reopenedDisplay] call RACA_fnc_edenDashboardRefresh;

private _status = _reopenedDisplay displayCtrl RACA_EDEN_IDC_EDITOR_STATUS;
if (!_didSet) exitWith {
    _status ctrlSetText "Eden rejected the Arsenal Configuration change; the object was not modified.";
    false
};
if (!_retained) exitWith {
    _status ctrlSetText "Eden did not retain the Arsenal Configuration change; the object was not reported as updated.";
    false
};
_status ctrlSetText format ["Applied '%1' to %2. Use Eden Undo to revert.", _statusName, typeOf _object];
true
