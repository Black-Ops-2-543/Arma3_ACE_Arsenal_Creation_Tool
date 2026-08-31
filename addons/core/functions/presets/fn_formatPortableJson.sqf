/* Pretty-prints the JSON-safe portable envelope with stable two-space indent. */
params [["_portable", [], [[]]]];
if (_portable isEqualTo []) exitWith {""};

private _newline = toString [13, 10];
private _formatValue = {
    params ["_value", "_depth", "_self", "_newline"];

    if (_value isEqualType []) exitWith {
        if (_value isEqualTo []) exitWith {"[]"};

        private _indent = "";
        private _childIndent = "";
        for "_index" from 1 to _depth do {_indent = _indent + "  "};
        for "_index" from 0 to _depth do {_childIndent = _childIndent + "  "};

        private _children = [];
        {
            _children pushBack ([_x, _depth + 1, _self, _newline] call _self);
        } forEach _value;

        "[" + _newline + _childIndent +
        (_children joinString ("," + _newline + _childIndent)) +
        _newline + _indent + "]"
    };

    toJSON _value
};

[_portable, 0, _formatValue, _newline] call _formatValue
