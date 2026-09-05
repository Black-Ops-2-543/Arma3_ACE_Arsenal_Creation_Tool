/* Immutable indices for this loaded catalogue generation. */
params [["_catalog", [], [[]]]];
private _old = uiNamespace getVariable ["RACA_catalogIndex", createHashMap];
private _generation = uiNamespace getVariable ["RACA_catalogGeneration", 0];
if ((_old getOrDefault ["generation", -1]) isEqualTo _generation && {(_old getOrDefault ["count", -1]) isEqualTo count _catalog}) exitWith {_old};
private _started = diag_tickTime;
private _byClass = createHashMap;
private _categories = createHashMap;
private _sources = createHashMap;
private _addons = createHashMap;
private _authors = createHashMap;
private _search = [];
private _all = [];
{
    private _i = _forEachIndex;
    _all pushBack _i;
    _byClass set [toLowerANSI (_x select 1), _i];
    _search pushBack toLowerANSI (_x param [7, ""]);
    {
        _x params ["_map","_key"];
        private _values = _map getOrDefault [_key, []];
        _values pushBack _i;
        _map set [_key, _values];
    } forEach [[_categories,_x select 2],[_sources,_x select 4],[_addons,_x param [8,""]],[_authors,_x select 5]];
} forEach _catalog;
private _index = createHashMapFromArray [["generation",_generation],["count",count _catalog],["class",_byClass],["category",_categories],["source",_sources],["addon",_addons],["author",_authors],["search",_search],["all",_all],["sorts",createHashMap]];
uiNamespace setVariable ["RACA_catalogIndex", _index];
uiNamespace setVariable ["RACA_magazineCache", createHashMap];
diag_log format ["[RACA][PERF] catalogue index records=%1 seconds=%2", count _catalog, diag_tickTime - _started];
_index
