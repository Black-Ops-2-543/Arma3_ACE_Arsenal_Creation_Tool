/* Applies a validated catalogue-tag delta to a copied normalized tag array. */
params ["_records","_delta",["_reverse",false,[true]]];
_delta params ["_kind","_tagName","_classes"];
private _index = _records findIf {toLowerANSI (_x select 2) isEqualTo toLowerANSI _tagName};
private _effective = _kind;
if (_reverse) then {
    private _inverse = createHashMapFromArray [["ADD","REMOVE"],["REMOVE","ADD"],["DELETE","RESTORE"]];
    _effective = _inverse getOrDefault [_kind,_kind];
};
if (_effective isEqualTo "DELETE") exitWith {if (_index >= 0) then {_records deleteAt _index}; _records};
if (_effective isEqualTo "RESTORE") exitWith {_records pushBack ["RACA_CATALOG_TAG",1,_tagName,+_classes]; _records};
if (_index < 0) then {
    _records pushBack ["RACA_CATALOG_TAG",1,_tagName,[]];
    _index=(count _records)-1;
};
private _members = +((_records select _index) select 3);
private _set = createHashMapFromArray (_members apply {[toLowerANSI _x,true]});
if (_effective isEqualTo "ADD") then {
    {if !(_set getOrDefault [toLowerANSI _x,false]) then {_members pushBack _x; _set set [toLowerANSI _x,true]}} forEach _classes;
} else {
    private _remove=createHashMapFromArray (_classes apply {[toLowerANSI _x,true]});
    _members=_members select {!(_remove getOrDefault [toLowerANSI _x,false])};
};
_members sort true;
_records set [_index,["RACA_CATALOG_TAG",1,(_records select _index) select 2,_members]];
_records
