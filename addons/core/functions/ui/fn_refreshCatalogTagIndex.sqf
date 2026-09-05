/* Rebuilds the fast class-to-tags lookup used by search, filtering, and details. */
private _index = createHashMap;
private _byTag = createHashMap;
{
    _x params ["", "", "_name", "_classes"];
    {
        private _key = toLowerANSI _x;
        private _classTags = _index getOrDefault [_key, []];
        _classTags pushBackUnique _name;
        _index set [_key, _classTags];
        private _members = _byTag getOrDefault [_name, createHashMap];
        _members set [_key, true];
        _byTag set [_name, _members];
    } forEach _classes;
} forEach call RACA_fnc_getCatalogTags;
{
    private _classTags = _index get _x;
    _classTags sort true;
    _index set [_x, _classTags];
} forEach keys _index;
uiNamespace setVariable ["RACA_catalogTagIndex", _index];
uiNamespace setVariable ["RACA_catalogClassesByTag", _byTag];
private _tagSearch = createHashMap;
{_tagSearch set [_x, toLowerANSI ((_index get _x) joinString " ")]} forEach keys _index;
uiNamespace setVariable ["RACA_catalogTagSearch", _tagSearch];
uiNamespace setVariable ["RACA_tagRevision", (uiNamespace getVariable ["RACA_tagRevision",0])+1];
_index
