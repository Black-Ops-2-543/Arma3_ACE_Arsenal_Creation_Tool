#include "..\..\script_component.hpp"
disableSerialization;
params [["_display", displayNull, [displayNull]]];
if (isNull _display || {_display getVariable ["RACA_refreshSuppressed",false]}) exitWith {};
if (!canSuspend) exitWith {[_display] spawn RACA_fnc_refreshItemList};
private _request = (_display getVariable ["RACA_renderRequest",0])+1;
_display setVariable ["RACA_renderRequest",_request];
private _started = diag_tickTime;
private _pageSize = ["RACA_catalogPageSize"] call RACA_fnc_getSetting;
private _catalog = uiNamespace getVariable ["RACA_itemCatalog",[]];
private _index = [_catalog] call RACA_fnc_indexCatalog;
private _read = {params ["_idc","_default"]; private _c=_display displayCtrl _idc; private _r=lbCurSel _c; if (_r<0) then {_default} else {_c lbData _r}};
private _category = [RACA_IDC_CATEGORY,"All"] call _read;
private _source = [RACA_IDC_SOURCE_FILTER,""] call _read;
private _addon = [RACA_IDC_ADDON_FILTER,""] call _read;
private _author = [RACA_IDC_AUTHOR_FILTER,""] call _read;
private _tag = [RACA_IDC_TAG_FILTER,""] call _read;
private _searchMode = uiNamespace getVariable ["RACA_catalogSearchMode","BASIC"];
if (_searchMode isEqualTo "BASIC") then {_source=""; _addon=""; _author=""; _tag=""};
private _terms = (toLowerANSI ctrlText (_display displayCtrl RACA_IDC_SEARCH)) splitString " ";
private _sort = uiNamespace getVariable ["RACA_catalogSort",["item",true]];
_sort params ["_sortField","_ascending"];
private _selected = uiNamespace getVariable ["RACA_builderSelected",createHashMap];
private _favorites = uiNamespace getVariable ["RACA_catalogFavorites",createHashMap];
private _inherited = uiNamespace getVariable ["RACA_builderInherited",createHashMap];
private _tags = uiNamespace getVariable ["RACA_catalogTagIndex",createHashMap];
private _tagSearch = uiNamespace getVariable ["RACA_catalogTagSearch",createHashMap];
private _magContext = uiNamespace getVariable ["RACA_magazineFilterContext",[]];
private _override = _display getVariable ["RACA_navigationClasses",[]];
if (_magContext isNotEqualTo []) then {_override = _magContext select 2};
private _dynamic = if (_category in ["Included","Favorites","Inherited"] || {_sortField isEqualTo "included"}) then {
    [uiNamespace getVariable ["RACA_selectionRevision",0],uiNamespace getVariable ["RACA_favoritesRevision",0],uiNamespace getVariable ["RACA_inheritedRevision",0]]
} else {[]};
private _unresolved = _display getVariable ["RACA_unresolvedFilters",[]];
private _unresolvedEffective = _unresolved select {_searchMode isEqualTo "ADVANCED" || {(_x select 0) isEqualTo RACA_IDC_CATEGORY}};
private _key = str [uiNamespace getVariable ["RACA_catalogGeneration",0],_category,_source,_addon,_author,_tag,_terms,_sort,_dynamic,uiNamespace getVariable ["RACA_tagRevision",0],_override,_unresolvedEffective];
private _results = _display getVariable ["RACA_resultIndices",[]];
private _newFilter = _key isNotEqualTo (_display getVariable ["RACA_resultKey",""]);
private _stale = false;
if (_newFilter) then {
    [_display,"Filtering catalogue..."] call RACA_fnc_setStatus;
    private _candidates = _index get "all";
    {
        _x params ["_field","_value"];
        if (_value isNotEqualTo "" && {_value isNotEqualTo "All"} && {!(_value in ["Included","Favorites","Inherited"])}) then {
            private _set = (_index get _field) getOrDefault [_value,[]];
            if (count _set < count _candidates) then {
                private _allowed = createHashMapFromArray (_set apply {[str _x,true]});
                _candidates = _candidates select {_allowed getOrDefault [str _x,false]};
            } else {
                private _current = createHashMapFromArray (_candidates apply {[str _x,true]});
                _candidates = _set select {_current getOrDefault [str _x,false]};
            };
        };
    } forEach [["category",_category],["source",_source],["addon",_addon],["author",_author]];
    if (_override isNotEqualTo []) then {
        _candidates = _override apply {(_index get "class") getOrDefault [toLowerANSI _x,-1]};
        _candidates = _candidates select {_x>=0};
    };
    if (_tag isNotEqualTo "") then {
        private _tagMembers = (uiNamespace getVariable ["RACA_catalogClassesByTag",createHashMap]) getOrDefault [_tag,createHashMap];
        _candidates = _candidates select {_tagMembers getOrDefault [toLowerANSI ((_catalog select _x) select 1),false]};
    };
    _results = [];
    if (_unresolvedEffective isEqualTo [] || {_override isNotEqualTo []}) then {
        {
            if ((_forEachIndex mod 512) isEqualTo 0) then {
                uiSleep 0.001;
                _stale = isNull _display || {(_display getVariable ["RACA_renderRequest",-1]) isNotEqualTo _request};
            };
            if (_stale) exitWith {};
            private _r = _catalog select _x;
            _r params ["","_class","_cat","","_mod","_auth","","_blob",["_own",""]];
            private _classKey = toLowerANSI _class;
            private _classTags = _tags getOrDefault [_classKey,[]];
            private _matchCat = _category isEqualTo "All" || {_cat isEqualTo _category} || {_category isEqualTo "Included" && {_selected getOrDefault [_class,false]}} || {_category isEqualTo "Favorites" && {_favorites getOrDefault [_class,false]}} || {_category isEqualTo "Inherited" && {_inherited getOrDefault [_class,false]}};
            if (_override isNotEqualTo [] || {_matchCat && {_source isEqualTo "" || {_source isEqualTo _mod}} && {_addon isEqualTo "" || {_addon isEqualTo _own}} && {_author isEqualTo "" || {_author isEqualTo _auth}} && {_tag isEqualTo "" || {_tag in _classTags}} && {private _text = ((_index get "search") select _x) + " " + (_tagSearch getOrDefault [_classKey,""]); (_terms findIf {(_text find _x)<0})<0}}) then {_results pushBack _x};
        } forEach _candidates;
    };
    if (!_stale) then {
        private _sortKey = str [_sort,_dynamic];
        private _sorts = _index get "sorts";
        private _ranks = _sorts getOrDefault [_sortKey,createHashMap];
        if (count _ranks isEqualTo 0) then {
            private _decorated = (_index get "all") apply {
                private _r=_catalog select _x;
                private _class=_r select 1;
                private _value=switch (_sortField) do {
                    case "class": {toLowerANSI _class};
                    case "mod": {toLowerANSI (_r select 4)};
                    case "author": {toLowerANSI (_r select 5)};
                    case "included": {str ([1,0] select (_selected getOrDefault [_class,false]))};
                    default {toLowerANSI (_r select 0)};
                };
                [_value,toLowerANSI (_r select 0),toLowerANSI _class,_x]
            };
            _decorated sort _ascending;
            {_ranks set [str (_x select 3),_forEachIndex]} forEach _decorated;
            if (_sortField isNotEqualTo "included") then {_sorts set [_sortKey,_ranks]};
        };
        private _ordered = _results apply {[_ranks get str _x,_x]};
        _ordered sort true;
        _results = _ordered apply {_x select 1};
        _display setVariable ["RACA_resultIndices",_results];
        _display setVariable ["RACA_resultKey",_key];
        _display setVariable ["RACA_page",0];
        private _classes = _results apply {(_catalog select _x) select 1};
        uiNamespace setVariable ["RACA_visibleClasses",_classes];
        private _visibleSet = createHashMapFromArray (_classes apply {[_x,true]});
        private _h = _display getVariable ["RACA_highlighted",createHashMap];
        {if !(_visibleSet getOrDefault [_x,false]) then {_h deleteAt _x}} forEach keys _h;
        if !(_visibleSet getOrDefault [_display getVariable ["RACA_selectionAnchor",""],false]) then {_display setVariable ["RACA_selectionAnchor",""]};
        _display setVariable ["RACA_highlighted",_h];
    };
};
if (_stale || {isNull _display} || {(_display getVariable ["RACA_renderRequest",-1]) isNotEqualTo _request}) exitWith {};
private _page = _display getVariable ["RACA_page",0];
private _previousPageSize = _display getVariable ["RACA_pageSize", _pageSize];
if (_previousPageSize isNotEqualTo _pageSize) then {
    private _focusedKey = toLowerANSI (_display getVariable ["RACA_focusedClass", ""]);
    private _focusedResult = _results findIf {toLowerANSI ((_catalog select _x) select 1) isEqualTo _focusedKey};
    if (_focusedResult >= 0) then {_page = floor (_focusedResult / _pageSize)};
};
private _pageCount = (ceil (count _results / _pageSize)) max 1;
_page = _page min (_pageCount - 1);
_display setVariable ["RACA_page", _page];
_display setVariable ["RACA_pageSize", _pageSize];
private _slice = _results select [_page * _pageSize, _pageSize];
private _renderKey = str [_key,_page,_pageSize];
private _rebuild = _renderKey isNotEqualTo (_display getVariable ["RACA_renderKey",""]);
private _list = _display displayCtrl RACA_IDC_ITEM_LIST;
private _h = _display getVariable ["RACA_highlighted",createHashMap];
private _limits = uiNamespace getVariable ["RACA_builderLimits",createHashMap];
_display setVariable ["RACA_rendering",true];
if (_rebuild) then {lnbClear _list};
private _focus = _display getVariable ["RACA_focusedClass",""];
{
    private _r = _catalog select _x;
    _r params ["_name","_class","_cat","","_mod","_author","_picture"];
    private _row = _forEachIndex;
    if (_rebuild) then {
        _list lnbAddRow ["",_name,_class,_mod,_author];
        _list lnbSetData [[_row,0],_class];
        if (_picture isNotEqualTo "") then {_list lnbSetPicture [[_row,1],_picture]};
    };
    _list lnbSetPicture [[_row,0],[RACA_TEXTURE_UNCHECKED,RACA_TEXTURE_CHECKED] select (_selected getOrDefault [_class,false])];
    private _color = if (_inherited getOrDefault [_class,false]) then {[0.55,0.82,1,1]} else {if (_favorites getOrDefault [_class,false]) then {[1,0.82,0.35,1]} else {[1,1,1,1]}};
    { _list lnbSetColor [[_row,_x],_color] } forEach [1,2,3,4];
    private _policies = [];
    {if (_x isNotEqualTo []) then {_policies pushBack format ["%1: %2 (%3; reset %4)",_x select 0,_x select 1,_x select 2,_x select 3]}} forEach [_limits getOrDefault [_class,[]],_limits getOrDefault ["category:"+_cat,[]]];
    private _tooltip = ([_name,_class,_mod,"Tags: "+((_tags getOrDefault [toLowerANSI _class,[]]) joinString ", ")] + _policies) joinString toString [10];
    {_list lnbSetTooltip [[_row,_x],_tooltip]} forEach [0,1,2,3,4];
    if (_class isEqualTo _focus && {_rebuild}) then {_list lnbSetCurSelRow _row};
} forEach _slice;
{private _class=(_catalog select _x) select 1; _list lbSetSelected [_forEachIndex,_h getOrDefault [_class,false]]} forEach _slice;
_display setVariable ["RACA_renderKey",_renderKey];
_display setVariable ["RACA_rendering",false];
(_display displayCtrl RACA_IDC_PAGE_LABEL) ctrlSetText format ["Page %1 / %2 | %3 matches | %4 highlighted",_page+1,_pageCount,count _results,count _h];
(_display displayCtrl RACA_IDC_PAGE_PREV) ctrlEnable (_page>0);
(_display displayCtrl RACA_IDC_PAGE_NEXT) ctrlEnable ((_page+1)*_pageSize<count _results);
(_display displayCtrl RACA_IDC_CLEAR_MAGAZINES) ctrlShow (_magContext isNotEqualTo [] && {(uiNamespace getVariable ["RACA_creatorTab",""]) isEqualTo "ASSIGNMENT"});
(_display displayCtrl RACA_IDC_CLEAR_MISSING_FILTERS) ctrlShow (_unresolvedEffective isNotEqualTo []);
[_display] call RACA_fnc_updateSummary;
diag_log format ["[RACA][PERF] catalogue refresh records=%1 matches=%2 rows=%3 filter=%4 rebuild=%5 seconds=%6",count _catalog,count _results,count _slice,_newFilter,_rebuild,diag_tickTime - _started];
