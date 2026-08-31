#include "..\..\script_component.hpp"
params [["_display", displayNull, [displayNull]]];

if (isNull _display) exitWith {};

private _list = _display displayCtrl RACA_IDC_ITEM_LIST;
private _search = toLowerANSI ctrlText (_display displayCtrl RACA_IDC_SEARCH);
private _terms = (_search splitString " ") select {_x isNotEqualTo ""};
private _categoryControl = _display displayCtrl RACA_IDC_CATEGORY;
private _categoryIndex = lbCurSel _categoryControl;
private _category = if (_categoryIndex < 0) then {"All"} else {_categoryControl lbData _categoryIndex};
private _catalog = uiNamespace getVariable ["RACA_itemCatalog", []];
private _selected = uiNamespace getVariable ["RACA_builderSelected", createHashMap];
private _inherited = uiNamespace getVariable ["RACA_builderInherited", createHashMap];
private _visibleClasses = [];

lnbClear _list;
{
    _x params ["_displayName", "_className", "_itemCategory", "", "_modName", "_author", "_picture", "_searchBlob"];
    private _matchesCategory =
        _category isEqualTo "All" ||
        {_category isEqualTo "Included" && {_selected getOrDefault [_className, false]}} ||
        {_category isEqualTo "Inherited" && {_inherited getOrDefault [_className, false]}} ||
        {_itemCategory isEqualTo _category};
    private _matchesSearch = ({(_searchBlob find _x) >= 0} count _terms) isEqualTo count _terms;

    if (_matchesCategory && _matchesSearch) then {
        private _row = _list lnbAddRow ["", _displayName, _className, _modName, _author];
        _list lnbSetData [[_row, 0], _className];
        _list lnbSetPicture [
            [_row, 0],
            [RACA_TEXTURE_UNCHECKED, RACA_TEXTURE_CHECKED] select (_selected getOrDefault [_className, false])
        ];
        if (_picture isNotEqualTo "") then {
            _list lnbSetPicture [[_row, 1], _picture];
        };
        if (_inherited getOrDefault [_className, false]) then {
            {
                _list lnbSetColor [[_row, _x], [0.55, 0.82, 1, 1]];
            } forEach [1, 2, 3, 4];
            _list lnbSetPictureColor [[_row, 0], [0.55, 0.82, 1, 1]];
            _list lnbSetPictureColorSelected [[_row, 0], [0.7, 0.9, 1, 1]];
        };
        _visibleClasses pushBack _className;
    };
} forEach _catalog;

uiNamespace setVariable ["RACA_visibleClasses", _visibleClasses];
[_display] call RACA_fnc_updateSummary;
