/* Returns normalized profile-wide custom role packs sorted by name. */
private _raw = profileNamespace getVariable ["RACA_rolePacks_v1", []];
if !(_raw isEqualType []) exitWith {[]};

private _packs = [];
private _seenNames = [];
{
    if (
        _x isEqualType [] &&
        {(count _x) >= 5} &&
        {(_x param [0, "", [""]]) isEqualTo "RACA_ROLE_PACK"} &&
        {(_x param [1, -1, [0]]) isEqualTo 1}
    ) then {
        private _name = _x param [2, "", [""]];
        private _description = _x param [3, "", [""]];
        private _rawClasses = _x param [4, [], [[]]];
        private _classes = [];
        {
            if (_x isEqualType "" && {[_x] call RACA_fnc_isSafeClassName}) then {
                _classes pushBackUnique _x;
            };
        } forEach (_rawClasses select [0, 5000]);
        _classes sort true;
        private _nameKey = toLowerANSI _name;
        if (
            _name isNotEqualTo "" &&
            {(count _name) <= 64} &&
            {(count _description) <= 180} &&
            {_classes isNotEqualTo []} &&
            {!(_nameKey in _seenNames)} &&
            {(count _packs) < 50}
        ) then {
            _seenNames pushBack _nameKey;
            _packs pushBack ["RACA_ROLE_PACK", 1, _name, _description, _classes];
        };
    };
} forEach _raw;

private _decorated = _packs apply {[toLowerANSI (_x select 2), _x]};
_decorated sort true;
_decorated apply {_x select 1}
