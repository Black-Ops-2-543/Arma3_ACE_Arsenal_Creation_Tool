#include "..\..\script_component.hpp"
params [["_display", displayNull, [displayNull]]];

if (isNull _display) exitWith {};

private _list = _display displayCtrl RACA_IDC_ITEM_LIST;
private _search = toLowerANSI ctrlText (_display displayCtrl RACA_IDC_SEARCH);
private _terms = (_search splitString " ") select {_x isNotEqualTo ""};
private _categoryControl = _display displayCtrl RACA_IDC_CATEGORY;
private _categoryIndex = lbCurSel _categoryControl;
private _category = if (_categoryIndex < 0) then {"All"} else {_categoryControl lbData _categoryIndex};
private _sourceControl = _display displayCtrl RACA_IDC_SOURCE_FILTER;
private _sourceIndex = lbCurSel _sourceControl;
private _source = if (_sourceIndex < 0) then {""} else {_sourceControl lbData _sourceIndex};
private _addonControl = _display displayCtrl RACA_IDC_ADDON_FILTER;
private _addonIndex = lbCurSel _addonControl;
private _addon = if (_addonIndex < 0) then {""} else {_addonControl lbData _addonIndex};
private _authorControl = _display displayCtrl RACA_IDC_AUTHOR_FILTER;
private _authorIndex = lbCurSel _authorControl;
private _authorFilter = if (_authorIndex < 0) then {""} else {_authorControl lbData _authorIndex};
private _tagControl = _display displayCtrl RACA_IDC_TAG_FILTER;
private _tagIndex = lbCurSel _tagControl;
private _tagFilter = if (_tagIndex < 0) then {""} else {_tagControl lbData _tagIndex};
if ((uiNamespace getVariable ["RACA_catalogSearchMode", "BASIC"]) isEqualTo "BASIC") then {
    _source = "";
    _addon = "";
    _authorFilter = "";
    _tagFilter = "";
};
private _catalog = uiNamespace getVariable ["RACA_itemCatalog", []];
private _selected = uiNamespace getVariable ["RACA_builderSelected", createHashMap];
private _inherited = uiNamespace getVariable ["RACA_builderInherited", createHashMap];
private _favorites = uiNamespace getVariable ["RACA_catalogFavorites", createHashMap];
private _tagsByClass = uiNamespace getVariable ["RACA_catalogTagIndex", createHashMap];
private _limits = uiNamespace getVariable ["RACA_builderLimits", createHashMap];
private _visibleClasses = [];
private _previousRow = lnbCurSelRow _list;
private _previousClass = if (_previousRow < 0) then {""} else {_list lnbData [_previousRow, 0]};
private _sortMode = uiNamespace getVariable ["RACA_catalogSort", ["item", true]];
private _sortField = _sortMode param [0, "item", [""]];
private _ascending = _sortMode param [1, true, [true]];
private _filtered = [];

{
    _x params ["_displayName", "_className", "_itemCategory", "", "_modName", "_author", "_picture", "_searchBlob", ["_sourceAddon", ""]];
    private _classTags = _tagsByClass getOrDefault [_className, []];
    private _matchesCategory =
        _category isEqualTo "All" ||
        {_category isEqualTo "Included" && {_selected getOrDefault [_className, false]}} ||
        {_category isEqualTo "Favorites" && {_favorites getOrDefault [_className, false]}} ||
        {_category isEqualTo "Inherited" && {_inherited getOrDefault [_className, false]}} ||
        {_itemCategory isEqualTo _category};
    private _tagSearchBlob = toLowerANSI (_classTags joinString " ");
    private _matchesSearch = ({((_searchBlob + " " + _tagSearchBlob) find _x) >= 0} count _terms) isEqualTo count _terms;
    private _matchesSource = _source isEqualTo "" || {_modName isEqualTo _source};
    private _matchesAddon = _addon isEqualTo "" || {_sourceAddon isEqualTo _addon};
    private _matchesAuthor = _authorFilter isEqualTo "" || {_author isEqualTo _authorFilter};
    private _matchesTag = _tagFilter isEqualTo "" || {_tagFilter in _classTags};

    if (_matchesCategory && _matchesSearch && _matchesSource && _matchesAddon && _matchesAuthor && _matchesTag) then {
        _filtered pushBack _x;
    };
} forEach _catalog;

private _decorated = _filtered apply {
    private _displayName = toLowerANSI (_x select 0);
    private _className = toLowerANSI (_x select 1);
    private _key = switch (_sortField) do {
        case "included": {
            private _included = _selected getOrDefault [_x select 1, false];
            private _rank = if (_ascending) then {[1, 0] select _included} else {[0, 1] select _included};
            format ["%1|%2|%3", _rank, _displayName, _className]
        };
        case "class": {_className};
        case "mod": {toLowerANSI (_x select 4)};
        case "author": {toLowerANSI (_x select 5)};
        default {_displayName};
    };
    [_key, _displayName, _className, _x]
};
_decorated sort (if (_sortField isEqualTo "included") then {true} else {_ascending});

lnbClear _list;
private _restoreRow = -1;
{
    private _item = _x select 3;
    _item params ["_displayName", "_className", "_itemCategory", "", "_modName", "_author", "_picture", ""];
    private _row = _list lnbAddRow ["", _displayName, _className, _modName, _author];
    _list lnbSetData [[_row, 0], _className];
    _list lnbSetPicture [
        [_row, 0],
        [RACA_TEXTURE_UNCHECKED, RACA_TEXTURE_CHECKED] select (_selected getOrDefault [_className, false])
    ];
    if (_picture isNotEqualTo "") then {
        _list lnbSetPicture [[_row, 1], _picture];
    };
    private _limit = _limits getOrDefault [_className, []];
    private _categoryLimit = _limits getOrDefault [format ["category:%1", _itemCategory], []];
    private _limitText = if (_limit isNotEqualTo []) then {format ["Exact limit: %1 (%2)", _limit select 1, _limit select 2]} else {
        if (_categoryLimit isNotEqualTo []) then {format ["Category limit: %1 (%2)", _categoryLimit select 1, _categoryLimit select 2]} else {"No quantity limit"}
    };
    private _tooltipLines = [
        _displayName,
        format ["Class: %1", _className],
        format ["Category: %1", _itemCategory],
        format ["Source: %1", _modName],
        format ["Author: %1", _author],
        _limitText
    ];
    private _classTags = _tagsByClass getOrDefault [_className, []];
    if (_classTags isNotEqualTo []) then {_tooltipLines pushBack format ["Tags: %1", _classTags joinString ", "]};
    if (_favorites getOrDefault [_className, false]) then {_tooltipLines pushBack "Favorite"};
    private _tooltip = _tooltipLines joinString (toString [10]);
    {_list lnbSetTooltip [[_row, _x], _tooltip]} forEach [0, 1, 2, 3, 4];
    if (_inherited getOrDefault [_className, false]) then {
        {
            _list lnbSetColor [[_row, _x], [0.55, 0.82, 1, 1]];
        } forEach [1, 2, 3, 4];
        _list lnbSetPictureColor [[_row, 0], [0.55, 0.82, 1, 1]];
        _list lnbSetPictureColorSelected [[_row, 0], [0.7, 0.9, 1, 1]];
    };
    if (_favorites getOrDefault [_className, false] && {!(_inherited getOrDefault [_className, false])}) then {
        _list lnbSetColor [[_row, 1], [1, 0.82, 0.35, 1]];
    };
    if (_className isEqualTo _previousClass) then {_restoreRow = _row};
    _visibleClasses pushBack _className;
} forEach _decorated;

if (_restoreRow >= 0) then {_list lnbSetCurSelRow _restoreRow};

private _headerLabels = [
    [RACA_IDC_INCLUDED_HEADER, "Included", "included"],
    [RACA_IDC_ITEM_HEADER, "Item", "item"],
    [RACA_IDC_CLASS_HEADER, "Class Name", "class"],
    [RACA_IDC_MOD_HEADER, "Mod", "mod"],
    [RACA_IDC_AUTHOR_HEADER, "Author", "author"]
];
{
    _x params ["_idc", "_label", "_field"];
    private _suffix = "";
    if (_field isEqualTo _sortField) then {
        _suffix = if (_field isEqualTo "included") then {
            [" — excluded first", " — included first"] select _ascending
        } else {
            [" — Z-A", " — A-Z"] select _ascending
        };
    };
    (_display displayCtrl _idc) ctrlSetText (_label + _suffix);
} forEach _headerLabels;

uiNamespace setVariable ["RACA_visibleClasses", _visibleClasses];
[_display] call RACA_fnc_updateSummary;
