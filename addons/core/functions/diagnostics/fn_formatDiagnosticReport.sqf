params [
    ["_name", "Preset", [""]],
    ["_entries", [], [[]]],
    ["_summary", [0, 0, 0], [[]]]
];

_summary params [["_errors", 0, [0]], ["_warnings", 0, [0]], ["_info", 0, [0]]];
private _lines = [
    format ["Compatibility report: %1", _name],
    format ["Errors: %1", _errors],
    format ["Warnings: %1", _warnings],
    format ["Information: %1", _info],
    "",
    "Diagnostic entries (Severity, Code, Message, Class, Mod, Source):"
];
if (_entries isEqualTo []) then {
    _lines = [
        format ["Compatibility report: %1", _name],
        format ["Errors: %1", _errors],
        format ["Warnings: %1", _warnings],
        format ["Information: %1", _info],
        "",
        "No diagnostic findings were returned."
    ];
} else {
    {
        _x params ["_severity", "_code", "_message", ["_className", ""], ["_modName", ""], ["_sourceAddon", ""]];
        private _source = if (_modName isEqualTo "") then {
            _sourceAddon
        } else {
            if (_sourceAddon isEqualTo "") then {_modName} else {_modName + " / " + _sourceAddon}
        };
        if (_source isEqualTo "") then {_source = "Unknown"};
        _lines pushBack format [
            "%1\t%2\t%3\t%4\t%5\t%6",
            _severity,
            _code,
            _message,
            _className,
            _modName,
            _source
        ];
    } forEach _entries;
};

_lines joinString toString [13, 10]
