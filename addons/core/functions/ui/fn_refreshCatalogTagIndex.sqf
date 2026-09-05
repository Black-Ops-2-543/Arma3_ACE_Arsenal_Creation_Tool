/* Rebuilds or incrementally patches the class-to-tags lookup. Delta: [operation, tag, classes]. */
params [["_delta",[],[[]]]];
if ((count _delta) isEqualTo 3) exitWith {
    _delta params ["_operation","_name","_classes"];
    private _index = uiNamespace getVariable ["RACA_catalogTagIndex",createHashMap];
    private _byTag = uiNamespace getVariable ["RACA_catalogClassesByTag",createHashMap];
    private _members = _byTag getOrDefault [_name,createHashMap];
    {
        private _key = toLowerANSI _x;
        private _classTags = _index getOrDefault [_key,[]];
        if (_operation isEqualTo "ADD") then {
            _classTags pushBackUnique _name;
            _classTags sort true;
            _members set [_key,true];
        } else {
            _classTags = _classTags - [_name];
            _members deleteAt _key;
        };
        if (_classTags isEqualTo []) then {_index deleteAt _key} else {_index set [_key,_classTags]};
    } forEach _classes;
    if (_operation isEqualTo "DELETE") then {_byTag deleteAt _name} else {_byTag set [_name,_members]};
    private _tagSearch = createHashMap;
    {_tagSearch set [_x,toLowerANSI ((_index get _x) joinString " ")]} forEach keys _index;
    uiNamespace setVariable ["RACA_catalogTagIndex",_index];
    uiNamespace setVariable ["RACA_catalogClassesByTag",_byTag];
    uiNamespace setVariable ["RACA_catalogTagSearch",_tagSearch];
    uiNamespace setVariable ["RACA_tagRevision",(uiNamespace getVariable ["RACA_tagRevision",0])+1];
    _index
};
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
