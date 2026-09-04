params [
    ["_name", "Preset", [""]],
    ["_entries", [], [[]]],
    ["_summary", [0, 0, 0], [[]]]
];

_summary params [["_errors", 0, [0]], ["_warnings", 0, [0]], ["_info", 0, [0]]];
private _headerName = if (_name isEqualTo "") then {"Preset"} else {_name};
private _lines = [
    format ["Compatibility report: %1", _headerName],
    format ["%1 (E: %2, W: %3, I: %4)", _headerName, _errors, _warnings, _info],
    "",
    "Severity | Code | Message | Class | Source"
];
if (_entries isEqualTo []) then {
    _lines = [
        format ["Compatibility report: %1", _headerName],
        format ["%1 (E: %2, W: %3, I: %4)", _headerName, _errors, _warnings, _info],
        "",
        "No diagnostic findings were returned."
    ];
} else {
    {
        _x params ["_severity", "_code", "_message", ["_className", ""], ["_modName", ""], ["_sourceAddon", ""]];
        private _normalizedSeverity = toUpperANSI str _severity;
        private _source = if (_modName isEqualTo "") then {
            _sourceAddon
        } else {
            if (_sourceAddon isEqualTo "") then {_modName} else {_modName + " / " + _sourceAddon}
        };
        if (_source isEqualTo "") then {_source = "Unknown"};
        _lines pushBack format [
            "%1 | %2 | %3 | %4 | %5",
            _normalizedSeverity,
            _code,
            _message,
            _className,
            _source
        ];
    } forEach _entries;
};

_lines joinString toString [13, 10]
