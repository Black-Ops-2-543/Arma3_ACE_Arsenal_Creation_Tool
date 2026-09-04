#include "..\script_component.hpp"
disableSerialization;
params [["_display", displayNull, [displayNull]]];
if (isNull _display || {!is3DEN}) exitWith {false};
if (!canSuspend) exitWith {
    [_display] spawn RACA_fnc_edenDashboardRefresh;
    true
};

private _request = (_display getVariable ["RACA_dashboardModelRequest", 0]) + 1;
_display setVariable ["RACA_dashboardModelRequest", _request];
private _started = diag_tickTime;
(_display displayCtrl RACA_EDEN_IDC_EDITOR_STATUS) ctrlSetText "Refreshing Mission Dashboard...";

private _readFilter = {
    params ["_idc", "_allowed", "_default"];
    private _control = _display displayCtrl _idc;
    private _value = _control lbData (lbCurSel _control);
    if (_value in _allowed) then {_value} else {_default}
};
private _variableMode = [
    RACA_EDEN_IDC_VARIABLE_FILTER,
    ["all", "none", "only"],
    "all"
] call _readFilter;
private _objectMode = [
    RACA_EDEN_IDC_OBJECT_FILTER,
    ["all", "unit", "module", "object"],
    "object"
] call _readFilter;
private _search = toLowerANSI trim ctrlText (
    _display displayCtrl RACA_EDEN_IDC_DASHBOARD_SEARCH
);

private _state = call RACA_fnc_edenGetConfigurationState;
private _configurations = _state select 2;
private _libraryRevision = str (_state select 3);
private _catalogRevision = uiNamespace getVariable ["RACA_catalogGeneration", 0];
private _cache = uiNamespace getVariable ["RACA_edenDashboardCache", createHashMap];
private _seen = createHashMap;
private _matches = [];
private _stale = false;
private _totalObjects = 0;

{
    if ((_forEachIndex mod 96) isEqualTo 0) then {
        uiSleep 0.001;
        _stale = isNull _display || {
            (_display getVariable ["RACA_dashboardModelRequest", -1]) isNotEqualTo _request
        };
    };
    if (_stale) exitWith {};

    private _object = _x;
    private _entityId = get3DENEntityID _object;
    if (_entityId >= 0) then {
        _totalObjects = _totalObjects + 1;
        private _idKey = str _entityId;
        _seen set [_idKey, true];

        private _className = typeOf _object;
        private _itemName = getText (
            configFile >> "CfgVehicles" >> _className >> "displayName"
        );
        if (_itemName isEqualTo "") then {_itemName = _className};
        private _variableName = (
            _object get3DENAttribute "Name"
        ) param [0, "", [""]];
        private _kind = if (_object isKindOf "Module_F") then {
            "module"
        } else {
            if (_object isKindOf "CAManBase") then {"unit"} else {"object"}
        };
        private _raw = (
            _object get3DENAttribute "RACA_RestrictedArsenalPreset"
        ) param [0, []];
        private _fingerprint = str [
            _className,
            _variableName,
            _raw,
            _libraryRevision,
            _catalogRevision
        ];
        private _cached = _cache getOrDefault [_idKey, []];
        private _model = [];

        if (_cached isNotEqualTo [] && {
            (_cached select 0) isEqualTo _fingerprint
        }) then {
            _model = +(_cached select 1);
            _model set [1, _object];
        } else {
            private _linkedId = "";
            private _linkedName = "";
            {
                if (_x isEqualType [] && {count _x >= 2}) then {
                    private _key = toLowerANSI (_x param [0, "", [""]]);
                    if (_key isEqualTo "configurationid") then {
                        _linkedId = _x param [1, "", [""]]
                    };
                    if (_key isEqualTo "configurationname") then {
                        _linkedName = _x param [1, "", [""]]
                    };
                };
            } forEach (_raw param [3, [], [[]]]);

            private _configurationName = "<No configuration>";
            if (_linkedId isNotEqualTo "") then {
                private _match = _configurations findIf {
                    toLowerANSI (_x select 0) isEqualTo toLowerANSI _linkedId
                };
                _configurationName = if (_match >= 0) then {
                    (_configurations select _match) select 1
                } else {
                    format [
                        "<Missing: %1>",
                        if (_linkedName isEqualTo "") then {_linkedId} else {_linkedName}
                    ]
                };
            } else {
                if (_raw isNotEqualTo []) then {
                    _configurationName = "<Legacy embedded configuration>"
                };
            };

            private _entries = [];
            private _summary = [0, 0, 0];
            if (_raw isNotEqualTo []) then {
                ([_raw, []] call RACA_fnc_preflightObjectConfig) params [
                    "",
                    "",
                    "_entries",
                    "_summary"
                ];
            };
            _model = [
                _entityId,
                _object,
                _itemName,
                _className,
                _variableName,
                _configurationName,
                _entries,
                _summary,
                +_raw,
                _kind
            ];
            _cache set [_idKey, [_fingerprint, +_model]];
        };

        private _variableMatch = switch _variableMode do {
            case "none": {_variableName isEqualTo ""};
            case "only": {_variableName isNotEqualTo ""};
            default {true};
        };
        private _objectMatch = _objectMode isEqualTo "all" || {
            _kind isEqualTo _objectMode
        };
        private _searchBlob = toLowerANSI format [
            "%1 %2 %3 %4",
            _itemName,
            _className,
            _variableName,
            _configurationName
        ];
        private _searchMatch = _search isEqualTo "" || {
            _searchBlob find _search >= 0
        };
        if (_variableMatch && {_objectMatch} && {_searchMatch}) then {
            _matches pushBack _model
        };
    };
} forEach (all3DENEntities select 0);

if (_stale) exitWith {false};
{
    if !(_seen getOrDefault [_x, false]) then {_cache deleteAt _x}
} forEach keys _cache;
uiNamespace setVariable ["RACA_edenDashboardCache", _cache];

private _configured = 0;
private _errors = 0;
private _warnings = 0;
private _information = 0;
private _report = [
    "RACA MISSION DASHBOARD REPORT",
    format ["Generated (UTC): %1", systemTimeUTC],
    format [
        "Filters: variable=%1, object=%2, search='%3'",
        _variableMode,
        _objectMode,
        _search
    ]
];
{
    _x params [
        "",
        "",
        "_itemName",
        "_className",
        "_variableName",
        "_configurationName",
        "_entries",
        "_summary",
        "_raw"
    ];
    if (_raw isNotEqualTo []) then {
        _configured = _configured + 1;
        _errors = _errors + (_summary select 0);
        _warnings = _warnings + (_summary select 1);
        _information = _information + (_summary select 2);
    };
    _report pushBack "";
    _report pushBack format [
        "%1 | %2 | %3 | variable=%4",
        _configurationName,
        _itemName,
        _className,
        if (_variableName isEqualTo "") then {"<blank>"} else {_variableName}
    ];
    if (_raw isNotEqualTo []) then {
        _report pushBack (
            [_itemName, _entries, _summary] call RACA_fnc_formatDiagnosticReport
        )
    };
} forEach _matches;
_report insert [3, [format [
    "Mission objects: %1 | Matching: %2 | Configured matching: %3 | Errors: %4 | Warnings: %5 | Information: %6",
    _totalObjects,
    count _matches,
    _configured,
    _errors,
    _warnings,
    _information
]]];

_display setVariable ["RACA_dashboardMatches", _matches];
_display setVariable [
    "RACA_dashboardMissionReport",
    _report joinString toString [13, 10]
];
_display setVariable [
    "RACA_dashboardSummary",
    [_totalObjects, count _matches, _configured, _errors, _warnings, _information]
];
_display setVariable ["RACA_dashboardPage", 0];
[_display] call RACA_fnc_edenDashboardRenderPage;
(_display displayCtrl RACA_EDEN_IDC_EDITOR_STATUS) ctrlSetText format [
    "Dashboard shows %1 of %2 mission object(s); %3 matching object(s) have an Arsenal Configuration. Cached refresh: %4 ms.",
    count _matches,
    _totalObjects,
    _configured,
    round ((diag_tickTime - _started) * 1000)
];
diag_log format [
    "[RACA][PERF] Eden dashboard objects=%1 matches=%2 cache=%3 seconds=%4",
    _totalObjects,
    count _matches,
    count _cache,
    diag_tickTime - _started
];
true
