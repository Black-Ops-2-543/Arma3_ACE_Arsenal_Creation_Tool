/* Engine resolution includes magazine wells and every muzzle. Loaded cargo only. */
params [["_class","",[""]]];
private _catalog=uiNamespace getVariable ["RACA_itemCatalog",[]];
private _index=[_catalog] call RACA_fnc_indexCatalog;
private _cache=uiNamespace getVariable ["RACA_magazineCache",createHashMap];
private _key=toLowerANSI _class;
if (_key in _cache) exitWith {_cache get _key};
private _i=(_index get "class") getOrDefault [_key,-1];
private _result=[];
if (_i>=0 && {((_catalog select _i) select 3) isEqualTo 1}) then {
    private _seen=createHashMap;
    {
        private _id=(_index get "class") getOrDefault [toLowerANSI _x,-1];
        if (_id>=0 && {((_catalog select _id) select 3) isEqualTo 2} && {!(_seen getOrDefault [toLowerANSI _x,false])}) then {
            _seen set [toLowerANSI _x,true];
            _result pushBack ((_catalog select _id) select 1);
        };
    } forEach compatibleMagazines _class;
};
_result sort true;
_cache set [_key,_result];
uiNamespace setVariable ["RACA_magazineCache",_cache];
_result
