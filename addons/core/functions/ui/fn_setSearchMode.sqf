#include "..\..\script_component.hpp"
params [
    ["_display", displayNull, [displayNull]],
    ["_requested", "", [""]]
];
if (isNull _display) exitWith {};

private _mode = toUpperANSI _requested;
if !(_mode in ["BASIC", "ADVANCED"]) then {
    _mode = ["ADVANCED", "BASIC"] select ((uiNamespace getVariable ["RACA_catalogSearchMode", "BASIC"]) isEqualTo "ADVANCED");
};
uiNamespace setVariable ["RACA_catalogSearchMode", _mode];
profileNamespace setVariable ["RACA_catalogSearchMode_v1", _mode];
saveProfileNamespace;

private _assignmentOpen = (uiNamespace getVariable ["RACA_creatorTab", "PRESETS"]) isEqualTo "ASSIGNMENT";
private _showAdvanced = _assignmentOpen && {_mode isEqualTo "ADVANCED"};
{
    (_display displayCtrl _x) ctrlShow _showAdvanced;
} forEach [
    RACA_IDC_SOURCE_FILTER_LABEL,
    RACA_IDC_SOURCE_FILTER,
    RACA_IDC_ADDON_FILTER_LABEL,
    RACA_IDC_ADDON_FILTER,
    RACA_IDC_AUTHOR_FILTER_LABEL,
    RACA_IDC_AUTHOR_FILTER,
    RACA_IDC_TAG_FILTER_LABEL,
    RACA_IDC_TAG_FILTER
];

private _button = _display displayCtrl RACA_IDC_SEARCH_MODE;
_button ctrlSetText (["Advanced Search", "Basic Search"] select (_mode isEqualTo "ADVANCED"));
_button ctrlSetTooltip ([
    "Show mod, add-on, author, and tag filters",
    "Hide extra filters and keep only Search and Category"
] select (_mode isEqualTo "ADVANCED"));
_button ctrlCommit 0;
[_display] call RACA_fnc_refreshItemList;
