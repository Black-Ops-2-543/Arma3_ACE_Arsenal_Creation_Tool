#include "..\..\script_component.hpp"
params [["_display",displayNull,[displayNull]]];
private _values = [RACA_IDC_CATEGORY,RACA_IDC_SOURCE_FILTER,RACA_IDC_ADDON_FILTER,RACA_IDC_AUTHOR_FILTER,RACA_IDC_TAG_FILTER] apply {
    private _c=_display displayCtrl _x; private _i=lbCurSel _c;
    [_x,if (_i<0) then {""} else {_c lbData _i}]
};
[ctrlText (_display displayCtrl RACA_IDC_SEARCH),uiNamespace getVariable ["RACA_catalogSearchMode","BASIC"],_values,+(uiNamespace getVariable ["RACA_catalogSort",["item",true]]),keys (_display getVariable ["RACA_highlighted",createHashMap]),_display getVariable ["RACA_selectionAnchor",""],_display getVariable ["RACA_focusedClass",""],_display getVariable ["RACA_page",0],+(_display getVariable ["RACA_navigationClasses",[]]),+(_display getVariable ["RACA_unresolvedFilters",[]]),+(uiNamespace getVariable ["RACA_magazineFilterContext",[]])]
