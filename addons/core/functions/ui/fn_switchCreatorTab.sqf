#include "..\..\script_component.hpp"
params [
    ["_display", displayNull, [displayNull]],
    ["_tab", "PRESETS", [""]]
];

if (isNull _display) exitWith {};

private _presetControls = [
    RACA_IDC_PRESET_PANEL,
    RACA_IDC_ADOPTION_PANEL,
    RACA_IDC_PRESET_FILES_HEADING,
    RACA_IDC_PRESET_NAME_LABEL,
    RACA_IDC_PRESET_NAME,
    RACA_IDC_SAVED_PRESET_LABEL,
    RACA_IDC_PRESET_LIST,
    RACA_IDC_SAVE_PRESET,
    RACA_IDC_LOAD_PRESET,
    RACA_IDC_DELETE_PRESET,
    RACA_IDC_EXPORT_FORMAT_LABEL,
    RACA_IDC_EXPORT_FORMAT,
    RACA_IDC_EXPORT_PRESET,
    RACA_IDC_IMPORT_PRESET,
    RACA_IDC_PRESET_HELP,
    RACA_IDC_ADOPTION_HEADING,
    RACA_IDC_BASE_PRESET_LABEL,
    RACA_IDC_BASE_PRESET,
    RACA_IDC_APPLY_BASE,
    RACA_IDC_FLATTEN_PRESET,
    RACA_IDC_ADOPTION_HELP,
    RACA_IDC_DIAGNOSTICS_HEADING,
    RACA_IDC_DIAGNOSTICS,
    RACA_IDC_RUN_DIAGNOSTICS,
    RACA_IDC_COPY_DIAGNOSTICS,
    RACA_IDC_ROLE_TEMPLATE_LABEL,
    RACA_IDC_ROLE_TEMPLATE,
    RACA_IDC_APPLY_TEMPLATE
];
private _assignmentControls = [
    RACA_IDC_SEARCH_LABEL,
    RACA_IDC_SEARCH,
    RACA_IDC_CATEGORY_LABEL,
    RACA_IDC_CATEGORY,
    RACA_IDC_SOURCE_FILTER_LABEL,
    RACA_IDC_SOURCE_FILTER,
    RACA_IDC_COLUMN_BACKGROUND,
    RACA_IDC_INCLUDED_HEADER,
    RACA_IDC_ITEM_HEADER,
    RACA_IDC_CLASS_HEADER,
    RACA_IDC_MOD_HEADER,
    RACA_IDC_AUTHOR_HEADER,
    RACA_IDC_ITEM_LIST,
    RACA_IDC_INCLUDE_VISIBLE,
    RACA_IDC_EXCLUDE_VISIBLE,
    RACA_IDC_CLEAR_ALL,
    RACA_IDC_LIMIT_SCOPE,
    RACA_IDC_LIMIT_VALUE,
    RACA_IDC_SET_LIMIT,
    RACA_IDC_SET_CATEGORY_LIMIT,
    RACA_IDC_FAVORITE,
    RACA_IDC_VIEW_MODE,
    RACA_IDC_SUMMARY
];

private _showPresets = (toUpperANSI _tab) isEqualTo "PRESETS";
{(_display displayCtrl _x) ctrlShow _showPresets} forEach _presetControls;
{(_display displayCtrl _x) ctrlShow !_showPresets} forEach _assignmentControls;

private _activeColor = [0.19, 0.42, 0.19, 0.95];
private _inactiveColor = [0.08, 0.09, 0.10, 0.95];
(_display displayCtrl RACA_IDC_TAB_PRESETS) ctrlSetBackgroundColor ([_inactiveColor, _activeColor] select _showPresets);
(_display displayCtrl RACA_IDC_TAB_ASSIGNMENT) ctrlSetBackgroundColor ([_activeColor, _inactiveColor] select _showPresets);

uiNamespace setVariable ["RACA_creatorTab", ["ASSIGNMENT", "PRESETS"] select _showPresets];
if (!_showPresets) then {
    [_display] call RACA_fnc_refreshCategoryCombo;
    [_display] call RACA_fnc_refreshItemList;
};
