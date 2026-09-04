/* Returns normalized profile-wide catalogue views sorted by name. */
private _raw = profileNamespace getVariable ["RACA_savedCatalogViews_v1", []];
if !(_raw isEqualType []) exitWith {[]};
private _views = [];
private _seenNames = [];
{
    if (_x isEqualType [] && {(count _x) >= 10} && {(_x param [0, "", [""]]) isEqualTo "RACA_CATALOG_VIEW"}) then {
        private _version = _x param [1, -1, [0]];
        private _shapeValid = (_version isEqualTo 1 && {(count _x) >= 10}) ||
            {_version isEqualTo 2 && {(count _x) >= 11}} ||
            {_version isEqualTo 3 && {(count _x) >= 12}};
        if (_version in [1, 2, 3] && {_shapeValid}) then {
            private _name = _x param [2, "", [""]];
            private _search = _x param [3, "", [""]];
            private _category = _x param [4, "All", [""]];
            private _source = _x param [5, "", [""]];
            private _addon = _x param [6, "", [""]];
            private _author = _x param [7, "", [""]];
            private _tag = if (_version >= 2) then {_x param [8, "", [""]]} else {""};
            private _sortField = toLowerANSI (_x param [[8, 9] select (_version >= 2), "item", [""]]);
            private _ascending = _x param [[9, 10] select (_version >= 2), true, [true]];
            if !(_sortField in ["included", "item", "class", "mod", "author"]) then {_sortField = "item"};
            private _nameKey = toLowerANSI _name;
            if (
                _name isNotEqualTo "" &&
                {(count _name) <= 64} &&
                {(count _search) <= 256} &&
                {(count _tag) <= 48} &&
                {!(_nameKey in _seenNames)} &&
                {(count _views) < 50}
            ) then {
                _seenNames pushBack _nameKey;
                _views pushBack ["RACA_CATALOG_VIEW", 3, _name, _search, _category, _source, _addon, _author, _tag, _sortField, _ascending, if (_version >= 3) then {_x param [11, "ADVANCED", [""]]} else {"ADVANCED"}];
            };
        };
    };
} forEach _raw;
private _decorated = _views apply {[toLowerANSI (_x select 2), _x]};
_decorated sort true;
_decorated apply {_x select 1}
