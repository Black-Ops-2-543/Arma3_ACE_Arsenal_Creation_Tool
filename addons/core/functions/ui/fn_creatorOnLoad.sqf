#include "..\..\script_component.hpp"
params [["_display", displayNull, [displayNull]]];

if (isNull _display) exitWith {};

uiNamespace setVariable ["RACA_builderDisplay", _display];
uiNamespace setVariable ["RACA_builderSelected", createHashMap];
uiNamespace setVariable ["RACA_builderComposition", []];
uiNamespace setVariable ["RACA_builderInherited", createHashMap];
uiNamespace setVariable ["RACA_builderLimits", createHashMap];
uiNamespace setVariable ["RACA_catalogShowIcons", true];
uiNamespace setVariable ["RACA_catalogDensity", "comfortable"];
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
call RACA_fnc_refreshCatalogTagIndex;

[_display] call RACA_fnc_refreshCategoryCombo;

private _exportFormat = _display displayCtrl RACA_IDC_EXPORT_FORMAT;
lbClear _exportFormat;
{
    _x params ["_label", "_data"];
    private _index = _exportFormat lbAdd _label;
    _exportFormat lbSetData [_index, _data];
} forEach [
    ["JSON preset", "JSON"],
    ["Reusable SQF", "SQF"],
    ["Class list", "LIST"],
    ["Required-mod manifest", "MANIFEST"],
    ["Support bundle", "SUPPORT"]
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
_list ctrlEnable false;

[_display, _list] spawn {
    params ["_display", "_list"];
    private _catalog = uiNamespace getVariable ["RACA_itemCatalog", []];

    if (_catalog isEqualTo []) then {
        [_display, "Reading all ACE Arsenal-compatible items from loaded mods..."] call RACA_fnc_setStatus;
        _catalog = [_display] call RACA_fnc_scanItems;
        uiNamespace setVariable ["RACA_itemCatalog", _catalog];
    };

    if (isNull _display) exitWith {};
    _list ctrlEnable true;
    [_display] call RACA_fnc_refreshSourceCombo;
    [_display] call RACA_fnc_refreshItemList;
    [_display, format ["Ready. %1 loaded arsenal items are searchable.", count _catalog]] call RACA_fnc_setStatus;
    private _recoveryHandled = [_display] call RACA_fnc_offerDraftRecovery;
    if (!_recoveryHandled &&
        {(call RACA_fnc_getPresetLibrary) isEqualTo []} &&
        {!(profileNamespace getVariable ["RACA_onboardingSeen_v1", false])}) then {
        uiSleep 0.1;
        if (!isNull _display) then {[_display] call RACA_fnc_openQuickStart};
    };
};
