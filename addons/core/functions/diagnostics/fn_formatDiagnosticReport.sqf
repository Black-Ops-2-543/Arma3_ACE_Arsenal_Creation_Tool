params [
    ["_name", "Preset", [""]],
    ["_entries", [], [[]]],
    ["_summary", [0, 0, 0], [[]]]
];

_summary params [["_errors", 0, [0]], ["_warnings", 0, [0]], ["_info", 0, [0]]];
private _lines = [
    format ["RACA compatibility report: %1", _name],
    format ["Errors: %1 | Warnings: %2 | Information: %3", _errors, _warnings, _info]
];
{
    _x params ["_severity", "_code", "_message", ["_className", ""], ["_modName", ""], ["_sourceAddon", ""]];
    private _source = if (_className isEqualTo "") then {""} else {
        format [" [class=%1; mod=%2; addon=%3]", _className, _modName, _sourceAddon]
    };
    _lines pushBack format ["[%1] %2: %3%4", _severity, _code, _message, _source];
} forEach _entries;

_lines joinString toString [13, 10]
