/* Returns normalized profile-wide catalogue tags sorted by name. */
private _raw = profileNamespace getVariable ["RACA_catalogTags_v1", []];
if !(_raw isEqualType []) exitWith {[]};

private _tags = [];
private _seenNames = [];
{
    if (
        _x isEqualType [] &&
        {(count _x) >= 4} &&
        {(_x param [0, "", [""]]) isEqualTo "RACA_CATALOG_TAG"} &&
        {(_x param [1, -1, [0]]) isEqualTo 1}
    ) then {
        private _name = ((_x param [2, "", [""]]) splitString (toString [9, 10, 13, 32])) joinString " ";
        private _nameKey = toLowerANSI _name;
        private _classes = [];
        {
            if (_x isEqualType "" && {[_x] call RACA_fnc_isSafeClassName}) then {
                _classes pushBackUnique _x;
            };
        } forEach ((_x param [3, [], [[]]]) select [0, 5000]);
        _classes sort true;
        if (
            _name isNotEqualTo "" &&
            {(count _name) <= 48} &&
            {!(_nameKey in _seenNames)} &&
            {(count _tags) < 100}
        ) then {
            _seenNames pushBack _nameKey;
            _tags pushBack ["RACA_CATALOG_TAG", 1, _name, _classes];
        };
    };
} forEach _raw;

private _decorated = _tags apply {[toLowerANSI (_x select 2), _x]};
_decorated sort true;
_decorated apply {_x select 1}
