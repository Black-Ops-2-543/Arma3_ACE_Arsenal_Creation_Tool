#include "..\script_component.hpp"
disableSerialization;
params [["_display", displayNull, [displayNull]], ["_operation", "REPAIR", [""]]];
if (!is3DEN) exitWith {false};

private _state = call RACA_fnc_edenGetConfigurationState;
private _status = _state select 0;
if (_status isEqualTo "FUTURE") exitWith {false};
private _raw = _state select 3;
private _entries = _state select 4;
private _blocked = _entries select {(_x select 1) isEqualTo "BLOCKED"};
private _repairable = _entries select {(_x select 1) isEqualTo "REPAIRABLE"};
private _invalid = _entries select {(_x select 1) in ["BLOCKED", "REPAIRABLE"]};
private _validEnvelope = (
    _raw isEqualType [] &&
    {count _raw isEqualTo 3} &&
    {(_raw param [0, "", [""]]) isEqualTo "RACA_EDEN_CONFIGURATIONS"} &&
    {(_raw param [1, -1, [0]]) isEqualTo 1} &&
    {(_raw select 2) isEqualType []}
);
private _records = if (_validEnvelope) then {+(_raw select 2)} else {[]};
private _objects = all3DENEntities select 0;

private _refreshDisplay = {
    params ["_display", "_message"];
    if (isNull _display) exitWith {};
    private _nextState = call RACA_fnc_edenGetConfigurationState;
    _display setVariable ["RACA_configurationLibraryState", _nextState];
    _display setVariable ["RACA_workingConfigurations", +(_nextState select 2)];
    _display setVariable ["RACA_configurationsDirty", false];
    private _ready = (_nextState select 0) isEqualTo "READY";
    {
        (_display displayCtrl _x) ctrlEnable _ready;
    } forEach [
        RACA_EDEN_IDC_CONFIG_SAVE,
        RACA_EDEN_IDC_CONFIG_ADD,
        RACA_EDEN_IDC_CONFIG_DELETE,
        RACA_EDEN_IDC_DASHBOARD_APPLY,
        RACA_EDEN_IDC_SAVE_CLOSE
    ];
    (_display displayCtrl RACA_EDEN_IDC_REPAIR) ctrlShow false;
    (_display displayCtrl RACA_EDEN_IDC_REMOVE_BLOCKED) ctrlShow false;
    [_display, 0] call RACA_fnc_edenEditorRefresh;
    [_display, true] call RACA_fnc_edenDashboardQueueRefresh;
    (_display displayCtrl RACA_EDEN_IDC_EDITOR_STATUS) ctrlSetText _message;
};

if (toUpperANSI _operation isEqualTo "REMOVE") exitWith {
    if (_invalid isEqualTo []) then {false} else {
        private _rootInvalid = !_validEnvelope || {(_invalid findIf {(_x select 0) < 0}) >= 0};
        private _warning = if (_rootInvalid) then {
            "The library envelope itself is invalid, so this will remove the complete stored library and clear every linked RACA object snapshot."
        } else {
            "Only records explicitly classified as invalid will be removed; valid records are retained. Linked objects that reference a removed record will be cleared."
        };
        private _ok = [
            format [
                "Remove %1 invalid configuration record(s)? %2 Copy Report first if you need the exact raw recovery payload. This removal is one Eden Undo step.",
                count _invalid,
                _warning
            ],
            "Remove Invalid Records",
            "Remove",
            "Cancel",
            _display
        ] call BIS_fnc_guiMessage;
        if (!_ok) then {false} else {
            private _removeIndexes = createHashMap;
            {
                private _index = _x select 0;
                if (_index >= 0) then {_removeIndexes set [str _index, true]};
            } forEach _invalid;
            private _next = if (_rootInvalid) then {[]} else {
                _records select {!(_removeIndexes getOrDefault [str _forEachIndex, false])}
            };
            private _remainingIds = createHashMapFromArray (
                _next apply {[toLowerANSI (_x param [0, "", [""]]), true]}
            );
            private _stored = if (_next isEqualTo []) then {[]} else {
                ["RACA_EDEN_CONFIGURATIONS", 1, _next]
            };
            private _cleared = 0;
            [
                "Remove invalid RACA records",
                "RACA library recovery",
                "a3\3den\data\cfg3den\history\changeattributes_ca.paa"
            ] collect3DENHistory {
                "RACA_RestrictedArsenals" set3DENMissionAttribute ["RACA_ArsenalConfigurations", _stored];
                {
                    private _object = _x;
                    private _value = (_object get3DENAttribute "RACA_RestrictedArsenalPreset") param [0, []];
                    private _linkedId = "";
                    {
                        if (
                            _x isEqualType [] &&
                            {count _x >= 2} &&
                            {toLowerANSI (_x param [0, "", [""]]) isEqualTo "configurationid"}
                        ) exitWith {_linkedId = toLowerANSI (_x param [1, "", [""]])};
                    } forEach (_value param [3, [], [[]]]);
                    if (_linkedId isNotEqualTo "" && {!(_remainingIds getOrDefault [_linkedId, false])}) then {
                        _object set3DENAttribute ["RACA_RestrictedArsenalPreset", []];
                        _cleared = _cleared + 1;
                    };
                } forEach _objects;
            };
            private _message = format [
                "Removed %1 invalid record(s) and cleared %2 linked object(s) in one Eden Undo step.",
                count _invalid,
                _cleared
            ];
            diag_log format [
                "[RACA][EDEN_RECOVERY] operation=REMOVE invalid=%1 remaining=%2 clearedObjects=%3 rootInvalid=%4",
                count _invalid,
                count _next,
                _cleared,
                _rootInvalid
            ];
            [_display, _message] call _refreshDisplay;
            true
        }
    }
};

if (_blocked isNotEqualTo []) exitWith {
    if (!isNull _display) then {
        (_display displayCtrl RACA_EDEN_IDC_EDITOR_STATUS) ctrlSetText "Repair blocked: ambiguous or malformed records must be explicitly removed or preserved."
    };
    false
};
if (_repairable isEqualTo [] || {!_validEnvelope}) exitWith {false};

private _map = [];
private _existing = +(_state select 2);
{
    private _index = _x select 0;
    private _record = +(_records select _index);
    private _old = _record select 0;
    private _id = [_existing] call RACA_fnc_edenGenerateConfigurationId;
    _record set [0, _id];
    _records set [_index, _record];
    _existing pushBack _record;
    _map pushBack [_old, _id, _record select 1];
} forEach _repairable;

private _updated = 0;
[
    "Repair RACA configuration IDs",
    "RACA library recovery",
    "a3\3den\data\cfg3den\history\changeattributes_ca.paa"
] collect3DENHistory {
    "RACA_RestrictedArsenals" set3DENMissionAttribute [
        "RACA_ArsenalConfigurations",
        ["RACA_EDEN_CONFIGURATIONS", 1, _records]
    ];
    {
        private _object = _x;
        private _value = (_object get3DENAttribute "RACA_RestrictedArsenalPreset") param [0, []];
        private _options = +(_value param [3, [], [[]]]);
        private _changed = false;
        {
            if (toLowerANSI (_x param [0, "", [""]]) isEqualTo "configurationid") then {
                private _linked = toLowerANSI (_x param [1, "", [""]]);
                private _match = _map findIf {toLowerANSI (_x select 0) isEqualTo _linked};
                if (_match >= 0) then {
                    _x set [1, (_map select _match) select 1];
                    _changed = true
                };
            };
        } forEach _options;
        if (_changed) then {
            _value set [3, _options];
            _object set3DENAttribute ["RACA_RestrictedArsenalPreset", _value];
            _updated = _updated + 1
        };
    } forEach _objects;
};
private _message = format [
    "Repaired %1 opaque ID(s) and %2 linked object(s) in one Eden Undo step.",
    count _map,
    _updated
];
diag_log format [
    "[RACA][EDEN_RECOVERY] operation=REPAIR ids=%1 linkedObjects=%2",
    count _map,
    _updated
];
[_display, _message] call _refreshDisplay;
true
