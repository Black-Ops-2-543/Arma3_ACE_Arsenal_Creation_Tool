#include "..\..\script_component.hpp"
disableSerialization;
params [["_display", displayNull, [displayNull]]];
private _parent = if (isNull _display) then {displayNull} else {_display getVariable ["RACA_itemDetailsParentDisplay", displayNull]};
uiNamespace setVariable ["RACA_itemDetailsParent", displayNull];
uiNamespace setVariable ["RACA_itemDetailsClass", ""];
uiNamespace setVariable ["RACA_itemDetailsDisplay", displayNull];
if (!isNull _parent) then {
    _parent setVariable ["RACA_itemDetailsOpening", false];
    ctrlSetFocus (_parent displayCtrl RACA_IDC_ITEM_LIST);
};
