#include "..\..\script_component.hpp"
disableSerialization;
params [["_display", displayNull, [displayNull]]];
if (isNull _display) exitWith {false};
private _report = _display getVariable ["RACA_itemDetailsReport", ""];
if (_report isEqualTo "") exitWith {false};
copyToClipboard _report;
(_display displayCtrl RACA_IDC_ITEM_DETAILS_STATUS) ctrlSetText "Copied the complete item-detail report to the clipboard.";
true
