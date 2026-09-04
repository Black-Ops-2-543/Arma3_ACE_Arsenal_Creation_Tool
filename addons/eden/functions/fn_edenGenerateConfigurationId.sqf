params [["_existing",[],[[]]]];
private _seen=createHashMapFromArray (_existing apply {[toLowerANSI (_x select 0),true]});
private _number = 1;
private _id = format ["cfg_%1", _number];
while {_seen getOrDefault [_id,false]} do {
    _number = _number + 1;
    _id = format ["cfg_%1", _number];
};
_id
