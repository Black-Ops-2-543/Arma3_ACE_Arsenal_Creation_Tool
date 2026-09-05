#include "..\..\script_component.hpp"
params [["_display", displayNull, [displayNull]]];

if (isNull _display) exitWith {};

uiNamespace setVariable ["RACA_builderDisplay", _display];
_display setVariable ["RACA_generation", (uiNamespace getVariable ["RACA_creatorGeneration", 0]) + 1];
uiNamespace setVariable ["RACA_creatorGeneration", _display getVariable "RACA_generation"];
uiNamespace setVariable ["RACA_builderRawPreset", []];
uiNamespace setVariable ["RACA_builderOrigin", ""];
uiNamespace setVariable ["RACA_magazineFilterContext", []];
uiNamespace setVariable ["RACA_builderSelected", createHashMap];
uiNamespace setVariable ["RACA_selectionRevision",0];
uiNamespace setVariable ["RACA_builderComposition", []];
uiNamespace setVariable ["RACA_builderInherited", createHashMap];
uiNamespace setVariable ["RACA_inheritedRevision",0];
uiNamespace setVariable ["RACA_builderLimits", createHashMap];
uiNamespace setVariable ["RACA_catalogShowIcons", true];
uiNamespace setVariable ["RACA_catalogDensity", "comfortable"];
// Recovered/saved/navigation states are applied through restoreCatalogView.
// Until one exists, a new Creator session starts from the typed preference.
private _searchMode = ["RACA_defaultSearchMode"] call RACA_fnc_getSetting;
uiNamespace setVariable ["RACA_catalogSearchMode", _searchMode];
private _sortMode = profileNamespace getVariable ["RACA_catalogSort_v1", ["item", true]];
if !(_sortMode isEqualType [] && {(count _sortMode) >= 2}) then {_sortMode = ["item", true]};
private _sortField = toLowerANSI (_sortMode param [0, "item", [""]]);
if !(_sortField in ["included", "item", "class", "mod", "author"]) then {_sortField = "item"};
uiNamespace setVariable ["RACA_catalogSort", [_sortField, _sortMode param [1, true, [true]]]];
uiNamespace setVariable ["RACA_creatorDiagnostics", []];
uiNamespace setVariable ["RACA_visibleClasses", []];
uiNamespace setVariable ["RACA_creatorUndo", []];
uiNamespace setVariable ["RACA_creatorRedo", []];
uiNamespace setVariable ["RACA_creatorDirty", false];
uiNamespace setVariable ["RACA_creatorDiscarding", false];
uiNamespace setVariable [
    "RACA_draftRecoveryRevision",
    (uiNamespace getVariable ["RACA_draftRecoveryRevision", 0]) + 1
];
private _favoriteClasses = profileNamespace getVariable ["RACA_favoriteClasses_v1", []];
if !(_favoriteClasses isEqualType []) then {_favoriteClasses = []};
private _favorites = createHashMap;
{
    if (_x isEqualType "" && {[_x] call RACA_fnc_isSafeClassName}) then {_favorites set [_x, true]};
} forEach _favoriteClasses;
uiNamespace setVariable ["RACA_catalogFavorites", _favorites];
uiNamespace setVariable ["RACA_favoritesRevision",0];
call RACA_fnc_refreshCatalogTagIndex;

[_display] call RACA_fnc_refreshCategoryCombo;

private _exportFormat = _display displayCtrl RACA_IDC_EXPORT_FORMAT;
lbClear _exportFormat;
{
    _x params ["_label", "_data", "_tooltip"];
    private _index = _exportFormat lbAdd _label;
    _exportFormat lbSetData [_index, _data];
    _exportFormat lbSetTooltip [_index, _tooltip];
} forEach [
    ["JSON preset", "JSON", "Choose JSON to back up or share a complete RACA preset and guarantee a lossless RACA re-import."],
    ["Reusable SQF", "SQF", "Choose reusable SQF for a mission-folder script that multiple Eden objects can call and RACA can conservatively re-import."],
    ["Class list", "LIST", "Choose Class list when another script or setting only needs a quick comma-separated list of class names."],
    ["Required-mod manifest", "MANIFEST", "Choose Required-mod manifest to audit which mods and add-ons a preset depends on before mission deployment."],
    ["Support bundle", "SUPPORT", "Choose Support bundle when reporting a problem; it packages the preset with diagnostic context for troubleshooting."]
];
_exportFormat lbSetCurSel 0;

private _resetCombo = _display displayCtrl RACA_IDC_LIMIT_RESET;
lbClear _resetCombo;
{
    _x params ["_label", "_data"];
    private _index = _resetCombo lbAdd _label;
    _resetCombo lbSetData [_index, _data];
} forEach [
    ["Never", "never"],
    ["Every interaction", "interaction"],
    ["Player respawn", "respawn"],
    ["Admin: new round", "round"],
    ["Admin: new phase", "phase"]
];
_resetCombo lbSetCurSel 0;

private _scopeCombo = _display displayCtrl RACA_IDC_LIMIT_SCOPE;
lbClear _scopeCombo;
{private _index = _scopeCombo lbAdd _x; _scopeCombo lbSetData [_index, toLowerANSI _x]} forEach ["Interaction", "Player", "Life", "Mission", "Arsenal"];
_scopeCombo lbSetCurSel 4;
[_display] call RACA_fnc_syncLimitPolicy;

[_display] call RACA_fnc_refreshRoleTemplateCombo;

[_display] call RACA_fnc_refreshPresetCombo;
[_display] call RACA_fnc_updateSummary;
[_display, "PRESETS"] call RACA_fnc_switchCreatorTab;
[_display] call RACA_fnc_refreshHistoryButtons;

private _list = _display displayCtrl RACA_IDC_ITEM_LIST;
lnbClear _list;
private _loadingRow = _list lnbAddRow ["", "Loading the item catalogue...", "", "", ""];
_list lnbSetTooltip [[_loadingRow, 1], "You can continue using Preset Management while the item catalogue loads."];

[_display, _list] spawn {
    params ["_display", "_list"];
    private _catalog = uiNamespace getVariable ["RACA_itemCatalog", []];

    if (_catalog isEqualTo []) then {
        [_display, "Reading all ACE Arsenal-compatible items from loaded mods..."] call RACA_fnc_setStatus;
        _catalog = [_display] call RACA_fnc_scanItems;
        uiNamespace setVariable ["RACA_itemCatalog", _catalog];
        uiNamespace setVariable ["RACA_catalogGeneration", (uiNamespace getVariable ["RACA_catalogGeneration", 0]) + 1];
        uiNamespace setVariable ["RACA_catalogIndex", createHashMap];
    };

    if (isNull _display) exitWith {};
    [_display] call RACA_fnc_refreshSourceCombo;
    [_display] call RACA_fnc_refreshItemList;
    [_display, format ["Ready. %1 loaded arsenal items are searchable.", count _catalog]] call RACA_fnc_setStatus;
    private _recoveryHandled = [_display] call RACA_fnc_offerDraftRecovery;
    if (!_recoveryHandled &&
        {(call RACA_fnc_getPresetLibrary) isEqualTo []} &&
        {["RACA_showOnboardingGuidance"] call RACA_fnc_getSetting} &&
        {!(profileNamespace getVariable ["RACA_onboardingSeen_v1", false])}) then {
        uiSleep 0.1;
        if (!isNull _display) then {[_display] call RACA_fnc_openQuickStart};
    };
};
