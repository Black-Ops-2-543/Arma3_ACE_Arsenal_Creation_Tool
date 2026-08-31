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
private _catalog = uiNamespace getVariable ["RACA_itemCatalog", []];
private _selected = uiNamespace getVariable ["RACA_builderSelected", createHashMap];
private _inherited = uiNamespace getVariable ["RACA_builderInherited", createHashMap];
private _favorites = uiNamespace getVariable ["RACA_catalogFavorites", createHashMap];
private _limits = uiNamespace getVariable ["RACA_builderLimits", createHashMap];
private _showIcons = uiNamespace getVariable ["RACA_catalogShowIcons", true];
private _visibleClasses = [];

lnbClear _list;
{
    _x params ["_displayName", "_className", "_itemCategory", "", "_modName", "_author", "_picture", "_searchBlob"];
    private _matchesCategory =
        _category isEqualTo "All" ||
        {_category isEqualTo "Included" && {_selected getOrDefault [_className, false]}} ||
        {_category isEqualTo "Favorites" && {_favorites getOrDefault [_className, false]}} ||
        {_category isEqualTo "Inherited" && {_inherited getOrDefault [_className, false]}} ||
        {_itemCategory isEqualTo _category};
    private _matchesSearch = ({(_searchBlob find _x) >= 0} count _terms) isEqualTo count _terms;
    private _matchesSource = _source isEqualTo "" || {_modName isEqualTo _source};

    if (_matchesCategory && _matchesSearch && _matchesSource) then {
        private _row = _list lnbAddRow ["", _displayName, _className, _modName, _author];
        _list lnbSetData [[_row, 0], _className];
        _list lnbSetPicture [
            [_row, 0],
            [RACA_TEXTURE_UNCHECKED, RACA_TEXTURE_CHECKED] select (_selected getOrDefault [_className, false])
        ];
        if (_showIcons && {_picture isNotEqualTo ""}) then {
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
        _visibleClasses pushBack _className;
    };
} forEach _catalog;

uiNamespace setVariable ["RACA_visibleClasses", _visibleClasses];
[_display] call RACA_fnc_updateSummary;
