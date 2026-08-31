class RACA_RscDisplayCreator {
    idd = RACA_IDD_CREATOR;
    movingEnable = 0;
    enableSimulation = 1;
    onLoad = "(_this select 0) call RACA_fnc_creatorOnLoad";
    onUnload = "(_this select 0) call RACA_fnc_creatorOnUnload";
    onKeyDown = "_this call RACA_fnc_creatorKeyDown";

    class controlsBackground {
        class Background: RscText {
            idc = -1;
            x = "safeZoneX + 0.035 * safeZoneW";
            y = "safeZoneY + 0.035 * safeZoneH";
            w = "0.93 * safeZoneW";
            h = "0.93 * safeZoneH";
            colorBackground[] = {0.02, 0.025, 0.03, 0.96};
        };

        class Frame: RscFrame {
            idc = -1;
            x = "safeZoneX + 0.035 * safeZoneW";
            y = "safeZoneY + 0.035 * safeZoneH";
            w = "0.93 * safeZoneW";
            h = "0.93 * safeZoneH";
            colorText[] = {0.85, 0.85, 0.85, 1};
        };

        class TitleBar: RscText {
            idc = -1;
            text = "";
            x = "safeZoneX + 0.05 * safeZoneW";
            y = "safeZoneY + 0.052 * safeZoneH";
            w = "0.88 * safeZoneW";
            h = "0.045 * safeZoneH";
            colorBackground[] = {0.19, 0.42, 0.19, 0.9};
        };
    };

    class controls {
        class CreatorTitle: RscText {
            idc = RACA_IDC_TITLE;
            text = "ARSENAL CREATION ASSISTANT";
            style = 2;
            x = "safeZoneX + 0.05 * safeZoneW";
            y = "safeZoneY + 0.052 * safeZoneH";
            w = "0.88 * safeZoneW";
            h = "0.045 * safeZoneH";
            colorBackground[] = {0, 0, 0, 0};
        };

        class PresetTab: RscButton {
            idc = RACA_IDC_TAB_PRESETS;
            text = "PRESET MANAGEMENT";
            tooltip = "Save, load, import, export, and adopt presets";
            x = "safeZoneX + 0.70 * safeZoneW";
            y = "safeZoneY + 0.108 * safeZoneH";
            w = "0.115 * safeZoneW";
            h = "0.04 * safeZoneH";
            onButtonClick = "[ctrlParent (_this select 0), 'PRESETS'] call RACA_fnc_switchCreatorTab";
        };

        class AssignmentTab: PresetTab {
            idc = RACA_IDC_TAB_ASSIGNMENT;
            text = "ASSIGNMENT";
            tooltip = "Search the complete catalogue and include or exclude items";
            x = "safeZoneX + 0.82 * safeZoneW";
            onButtonClick = "[ctrlParent (_this select 0), 'ASSIGNMENT'] call RACA_fnc_switchCreatorTab";
        };

        class QuickStart: PresetTab {
            idc = RACA_IDC_QUICK_START;
            text = "QUICK START";
            tooltip = "Create a guided blank or role-based draft";
            x = "safeZoneX + 0.055 * safeZoneW";
            w = "0.115 * safeZoneW";
            onButtonClick = "ctrlParent (_this select 0) call RACA_fnc_openQuickStart";
        };

        class History: QuickStart {
            idc = RACA_IDC_HISTORY;
            text = "REVISION HISTORY";
            tooltip = "Compare and restore automatically archived preset revisions";
            x = "safeZoneX + 0.18 * safeZoneW";
            w = "0.125 * safeZoneW";
            onButtonClick = "ctrlParent (_this select 0) call RACA_fnc_openPresetHistory";
        };

        class Undo: QuickStart {
            idc = RACA_IDC_UNDO;
            text = "UNDO";
            tooltip = "Undo the last creator selection or policy change (Ctrl+Z)";
            x = "safeZoneX + 0.315 * safeZoneW";
            w = "0.07 * safeZoneW";
            onButtonClick = "[ctrlParent (_this select 0), 'UNDO'] call RACA_fnc_restoreCreatorHistory";
        };

        class Redo: Undo {
            idc = RACA_IDC_REDO;
            text = "REDO";
            tooltip = "Redo the last undone change (Ctrl+Y)";
            x = "safeZoneX + 0.395 * safeZoneW";
            onButtonClick = "[ctrlParent (_this select 0), 'REDO'] call RACA_fnc_restoreCreatorHistory";
        };

        class CompareDraft: Undo {
            idc = RACA_IDC_COMPARE_DRAFT;
            text = "COMPARE DRAFT";
            tooltip = "Copy a class and quantity-policy diff between the current draft and selected saved preset";
            x = "safeZoneX + 0.475 * safeZoneW";
            w = "0.12 * safeZoneW";
            onButtonClick = "ctrlParent (_this select 0) call RACA_fnc_compareSelectedPreset";
        };

        class SavedViews: Undo {
            idc = RACA_IDC_SAVED_VIEWS;
            text = "SAVED VIEWS";
            tooltip = "Capture or restore reusable catalogue searches, filters, and sort order";
            x = "safeZoneX + 0.605 * safeZoneW";
            w = "0.085 * safeZoneW";
            onButtonClick = "ctrlParent (_this select 0) call RACA_fnc_openSavedCatalogViews";
        };

        class PresetPanel: RscText {
            idc = RACA_IDC_PRESET_PANEL;
            x = "safeZoneX + 0.055 * safeZoneW";
            y = "safeZoneY + 0.17 * safeZoneH";
            w = "0.42 * safeZoneW";
            h = "0.68 * safeZoneH";
            colorBackground[] = {0, 0, 0, 0.38};
        };

        class PresetFilesHeading: RscText {
            idc = RACA_IDC_PRESET_FILES_HEADING;
            text = "PRESET FILES";
            x = "safeZoneX + 0.07 * safeZoneW";
            y = "safeZoneY + 0.19 * safeZoneH";
            w = "0.39 * safeZoneW";
            h = "0.04 * safeZoneH";
            colorBackground[] = {0.19, 0.42, 0.19, 0.75};
        };

        class PresetNameLabel: RscText {
            idc = RACA_IDC_PRESET_NAME_LABEL;
            text = "Preset name";
            x = "safeZoneX + 0.07 * safeZoneW";
            y = "safeZoneY + 0.25 * safeZoneH";
            w = "0.39 * safeZoneW";
            h = "0.03 * safeZoneH";
        };

        class PresetName: RscEdit {
            idc = RACA_IDC_PRESET_NAME;
            x = "safeZoneX + 0.07 * safeZoneW";
            y = "safeZoneY + 0.283 * safeZoneH";
            w = "0.39 * safeZoneW";
            h = "0.037 * safeZoneH";
        };

        class SavedPresetLabel: PresetNameLabel {
            idc = RACA_IDC_SAVED_PRESET_LABEL;
            text = "Saved presets";
            y = "safeZoneY + 0.34 * safeZoneH";
        };

        class SavedPresets: RscCombo {
            idc = RACA_IDC_PRESET_LIST;
            x = "safeZoneX + 0.07 * safeZoneW";
            y = "safeZoneY + 0.373 * safeZoneH";
            w = "0.39 * safeZoneW";
            h = "0.037 * safeZoneH";
            onLBSelChanged = "ctrlParent (_this select 0) call RACA_fnc_refreshHistoryButtons";
        };

        class SavePreset: RscButton {
            idc = RACA_IDC_SAVE_PRESET;
            text = "SAVE / OVERWRITE";
            tooltip = "Save the current assigned items to your Arma profile";
            x = "safeZoneX + 0.07 * safeZoneW";
            y = "safeZoneY + 0.43 * safeZoneH";
            w = "0.12 * safeZoneW";
            h = "0.04 * safeZoneH";
            onButtonClick = "ctrlParent (_this select 0) call RACA_fnc_saveCurrentPreset";
        };

        class LoadPreset: SavePreset {
            idc = RACA_IDC_LOAD_PRESET;
            text = "LOAD";
            tooltip = "Load the selected saved preset into the creator";
            x = "safeZoneX + 0.20 * safeZoneW";
            onButtonClick = "ctrlParent (_this select 0) call RACA_fnc_loadSelectedPreset";
        };

        class DeletePreset: SavePreset {
            idc = RACA_IDC_DELETE_PRESET;
            text = "DELETE";
            tooltip = "Delete the selected profile preset after confirmation; embedded mission copies are unaffected";
            x = "safeZoneX + 0.33 * safeZoneW";
            colorBackground[] = {0.45, 0.12, 0.12, 0.9};
            onButtonClick = "ctrlParent (_this select 0) spawn RACA_fnc_deletePreset";
        };

        class ExportFormatLabel: PresetNameLabel {
            idc = RACA_IDC_EXPORT_FORMAT_LABEL;
            text = "Export format";
            y = "safeZoneY + 0.495 * safeZoneH";
        };

        class ExportFormat: RscCombo {
            idc = RACA_IDC_EXPORT_FORMAT;
            x = "safeZoneX + 0.07 * safeZoneW";
            y = "safeZoneY + 0.528 * safeZoneH";
            w = "0.39 * safeZoneW";
            h = "0.037 * safeZoneH";
        };

        class ExportPreset: SavePreset {
            idc = RACA_IDC_EXPORT_PRESET;
            text = "EXPORT TO CLIPBOARD";
            tooltip = "Export as JSON, reusable SQF, or a simple class list";
            y = "safeZoneY + 0.585 * safeZoneH";
            onButtonClick = "ctrlParent (_this select 0) call RACA_fnc_exportPreset";
        };

        class ImportPreset: ExportPreset {
            idc = RACA_IDC_IMPORT_PRESET;
            text = "IMPORT AUTO";
            tooltip = "Import a JSON preset, existing SQF arsenal, or class list from the clipboard";
            x = "safeZoneX + 0.27 * safeZoneW";
            onButtonClick = "ctrlParent (_this select 0) spawn RACA_fnc_importPreset";
        };

        class PresetHelp: RscText {
            idc = RACA_IDC_PRESET_HELP;
            text = "JSON guarantees a lossless round trip. Reusable SQF can be shared by multiple mission objects. Auto import safely reads JSON, SQF, and class lists without executing them.";
            style = 16;
            x = "safeZoneX + 0.07 * safeZoneW";
            y = "safeZoneY + 0.655 * safeZoneH";
            w = "0.39 * safeZoneW";
            h = "0.16 * safeZoneH";
            colorBackground[] = {0, 0, 0, 0};
        };

        class AdoptionPanel: PresetPanel {
            idc = RACA_IDC_ADOPTION_PANEL;
            x = "safeZoneX + 0.50 * safeZoneW";
            w = "0.435 * safeZoneW";
        };

        class AdoptionHeading: PresetFilesHeading {
            idc = RACA_IDC_ADOPTION_HEADING;
            text = "PRESET ADOPTION";
            x = "safeZoneX + 0.515 * safeZoneW";
            w = "0.405 * safeZoneW";
        };

        class BasePresetLabel: PresetNameLabel {
            idc = RACA_IDC_BASE_PRESET_LABEL;
            text = "Adopted source preset";
            x = "safeZoneX + 0.515 * safeZoneW";
            y = "safeZoneY + 0.25 * safeZoneH";
            w = "0.405 * safeZoneW";
        };

        class BasePreset: RscCombo {
            idc = RACA_IDC_BASE_PRESET;
            x = "safeZoneX + 0.515 * safeZoneW";
            y = "safeZoneY + 0.283 * safeZoneH";
            w = "0.405 * safeZoneW";
            h = "0.037 * safeZoneH";
        };

        class ApplyBase: SavePreset {
            idc = RACA_IDC_APPLY_BASE;
            text = "ADOPT / REFRESH";
            tooltip = "Adopt the selected source, or refresh this preset from its current source";
            x = "safeZoneX + 0.515 * safeZoneW";
            y = "safeZoneY + 0.34 * safeZoneH";
            w = "0.1975 * safeZoneW";
            onButtonClick = "ctrlParent (_this select 0) call RACA_fnc_applyBasePreset";
        };

        class FlattenPreset: ApplyBase {
            idc = RACA_IDC_FLATTEN_PRESET;
            text = "MAKE STANDALONE";
            tooltip = "Keep the complete current item set and remove its adoption link";
            x = "safeZoneX + 0.7225 * safeZoneW";
            onButtonClick = "ctrlParent (_this select 0) call RACA_fnc_flattenCurrentPreset";
        };

        class AdoptionHelp: RscText {
            idc = RACA_IDC_ADOPTION_HELP;
            text = "Adopt a saved preset to use its entire item set as a source. Every source item is shown in light blue on Assignment, whether currently included or excluded. Your child preset stores a complete usable snapshot plus additions and removals. Source changes are never applied silently: use ADOPT / REFRESH when you want them. MAKE STANDALONE removes the link without changing the current items.";
            style = 16;
            x = "safeZoneX + 0.515 * safeZoneW";
            y = "safeZoneY + 0.42 * safeZoneH";
            w = "0.405 * safeZoneW";
            h = "0.13 * safeZoneH";
            colorBackground[] = {0, 0, 0, 0.25};
        };

        class DiagnosticsHeading: AdoptionHeading {
            idc = RACA_IDC_DIAGNOSTICS_HEADING;
            text = "COMPATIBILITY & ROLE STARTERS";
            y = "safeZoneY + 0.565 * safeZoneH";
        };

        class Diagnostics: AdoptionHelp {
            idc = RACA_IDC_DIAGNOSTICS;
            text = "Run preflight to inspect missing classes, source add-ons, duplicate data, and compatibility errors.";
            y = "safeZoneY + 0.61 * safeZoneH";
            h = "0.09 * safeZoneH";
        };

        class RunDiagnostics: ApplyBase {
            idc = RACA_IDC_RUN_DIAGNOSTICS;
            text = "RUN PREFLIGHT";
            tooltip = "Run the same blocking compatibility checks used at runtime";
            y = "safeZoneY + 0.71 * safeZoneH";
            w = "0.125 * safeZoneW";
            onButtonClick = "ctrlParent (_this select 0) call RACA_fnc_runCreatorDiagnostics";
        };

        class OpenDiagnostics: RunDiagnostics {
            idc = RACA_IDC_OPEN_DIAGNOSTICS;
            text = "VIEW DETAILS";
            tooltip = "Open the filterable visual compatibility report";
            x = "safeZoneX + 0.655 * safeZoneW";
            onButtonClick = "ctrlParent (_this select 0) call RACA_fnc_openCreatorDiagnostics";
        };

        class CopyDiagnostics: OpenDiagnostics {
            idc = RACA_IDC_COPY_DIAGNOSTICS;
            text = "COPY REPORT";
            x = "safeZoneX + 0.795 * safeZoneW";
            onButtonClick = "ctrlParent (_this select 0) call RACA_fnc_copyCreatorDiagnostics";
        };

        class RoleTemplateLabel: BasePresetLabel {
            idc = RACA_IDC_ROLE_TEMPLATE_LABEL;
            text = "Role starter";
            y = "safeZoneY + 0.765 * safeZoneH";
            w = "0.09 * safeZoneW";
        };

        class RoleTemplate: BasePreset {
            idc = RACA_IDC_ROLE_TEMPLATE;
            x = "safeZoneX + 0.605 * safeZoneW";
            y = "safeZoneY + 0.765 * safeZoneH";
            w = "0.145 * safeZoneW";
        };

        class ApplyTemplate: RunDiagnostics {
            idc = RACA_IDC_APPLY_TEMPLATE;
            text = "APPLY STARTER";
            x = "safeZoneX + 0.755 * safeZoneW";
            y = "safeZoneY + 0.765 * safeZoneH";
            w = "0.095 * safeZoneW";
            onButtonClick = "ctrlParent (_this select 0) call RACA_fnc_applySelectedRoleTemplate";
        };

        class RolePacks: ApplyTemplate {
            idc = RACA_IDC_ROLE_PACKS_BUTTON;
            text = "PACKS";
            tooltip = "Capture, merge, replace, or delete profile-wide custom unit role packs";
            x = "safeZoneX + 0.855 * safeZoneW";
            w = "0.065 * safeZoneW";
            onButtonClick = "ctrlParent (_this select 0) call RACA_fnc_openRolePacks";
        };

        class SearchLabel: RscText {
            idc = RACA_IDC_SEARCH_LABEL;
            text = "Search";
            x = "safeZoneX + 0.055 * safeZoneW";
            y = "safeZoneY + 0.17 * safeZoneH";
            w = "0.05 * safeZoneW";
            h = "0.035 * safeZoneH";
        };

        class Search: RscEdit {
            idc = RACA_IDC_SEARCH;
            tooltip = "Search display name, class name, category, mod, owning add-on, or author";
            x = "safeZoneX + 0.11 * safeZoneW";
            y = "safeZoneY + 0.17 * safeZoneH";
            w = "0.295 * safeZoneW";
            h = "0.035 * safeZoneH";
            onKeyUp = "ctrlParent (_this select 0) call RACA_fnc_queueRefresh";
        };

        class CategoryLabel: SearchLabel {
            idc = RACA_IDC_CATEGORY_LABEL;
            text = "Category";
            x = "safeZoneX + 0.415 * safeZoneW";
            w = "0.06 * safeZoneW";
        };

        class Category: RscCombo {
            idc = RACA_IDC_CATEGORY;
            x = "safeZoneX + 0.48 * safeZoneW";
            y = "safeZoneY + 0.17 * safeZoneH";
            w = "0.17 * safeZoneW";
            h = "0.035 * safeZoneH";
            onLBSelChanged = "ctrlParent (_this select 0) call RACA_fnc_refreshItemList";
        };

        class SourceFilterLabel: SearchLabel {
            idc = RACA_IDC_SOURCE_FILTER_LABEL;
            text = "Mod";
            x = "safeZoneX + 0.66 * safeZoneW";
            w = "0.055 * safeZoneW";
        };

        class SourceFilter: Category {
            idc = RACA_IDC_SOURCE_FILTER;
            x = "safeZoneX + 0.72 * safeZoneW";
            w = "0.215 * safeZoneW";
            tooltip = "Filter the catalogue to one loaded source mod";
            onLBSelChanged = "ctrlParent (_this select 0) call RACA_fnc_refreshItemList";
        };

        class AddonFilterLabel: SearchLabel {
            idc = RACA_IDC_ADDON_FILTER_LABEL;
            text = "Add-on";
            x = "safeZoneX + 0.055 * safeZoneW";
            y = "safeZoneY + 0.212 * safeZoneH";
            w = "0.06 * safeZoneW";
        };

        class AddonFilter: Category {
            idc = RACA_IDC_ADDON_FILTER;
            x = "safeZoneX + 0.12 * safeZoneW";
            y = "safeZoneY + 0.212 * safeZoneH";
            w = "0.37 * safeZoneW";
            tooltip = "Filter by the owning CfgPatches add-on; counts reflect the active Arma session";
            onLBSelChanged = "ctrlParent (_this select 0) call RACA_fnc_refreshItemList";
        };

        class AuthorFilterLabel: AddonFilterLabel {
            idc = RACA_IDC_AUTHOR_FILTER_LABEL;
            text = "Author";
            x = "safeZoneX + 0.505 * safeZoneW";
            w = "0.06 * safeZoneW";
        };

        class AuthorFilter: AddonFilter {
            idc = RACA_IDC_AUTHOR_FILTER;
            x = "safeZoneX + 0.57 * safeZoneW";
            w = "0.365 * safeZoneW";
            tooltip = "Filter by the item config author; counts reflect the active Arma session";
        };

        class ColumnHeaderBackground: RscText {
            idc = RACA_IDC_COLUMN_BACKGROUND;
            text = "";
            x = "safeZoneX + 0.055 * safeZoneW";
            y = "safeZoneY + 0.257 * safeZoneH";
            w = "0.88 * safeZoneW";
            h = "0.03 * safeZoneH";
            colorBackground[] = {0, 0, 0, 0.55};
        };

        class IncludedHeader: RscButton {
            idc = RACA_IDC_INCLUDED_HEADER;
            text = "INCLUDED";
            tooltip = "Sort by inclusion state";
            x = "safeZoneX + 0.055 * safeZoneW";
            y = "safeZoneY + 0.257 * safeZoneH";
            w = "0.088 * safeZoneW";
            h = "0.03 * safeZoneH";
            style = 2;
            colorBackground[] = {0, 0, 0, 0};
            onButtonClick = "[ctrlParent (_this select 0), 'included'] call RACA_fnc_setSortMode";
        };

        class ItemHeader: IncludedHeader {
            idc = RACA_IDC_ITEM_HEADER;
            text = "ITEM";
            tooltip = "Sort by display name";
            x = "safeZoneX + 0.143 * safeZoneW";
            w = "0.272 * safeZoneW";
            onButtonClick = "[ctrlParent (_this select 0), 'item'] call RACA_fnc_setSortMode";
        };

        class ClassHeader: IncludedHeader {
            idc = RACA_IDC_CLASS_HEADER;
            text = "CLASS NAME";
            tooltip = "Sort by class name";
            x = "safeZoneX + 0.415 * safeZoneW";
            w = "0.228 * safeZoneW";
            onButtonClick = "[ctrlParent (_this select 0), 'class'] call RACA_fnc_setSortMode";
        };

        class ModHeader: IncludedHeader {
            idc = RACA_IDC_MOD_HEADER;
            text = "MOD";
            tooltip = "Sort by source mod";
            x = "safeZoneX + 0.643 * safeZoneW";
            w = "0.14 * safeZoneW";
            onButtonClick = "[ctrlParent (_this select 0), 'mod'] call RACA_fnc_setSortMode";
        };

        class AuthorHeader: IncludedHeader {
            idc = RACA_IDC_AUTHOR_HEADER;
            text = "AUTHOR";
            tooltip = "Sort by author";
            x = "safeZoneX + 0.783 * safeZoneW";
            w = "0.152 * safeZoneW";
            onButtonClick = "[ctrlParent (_this select 0), 'author'] call RACA_fnc_setSortMode";
        };

        class ItemList: RscListNBox {
            idc = RACA_IDC_ITEM_LIST;
            x = "safeZoneX + 0.055 * safeZoneW";
            y = "safeZoneY + 0.289 * safeZoneH";
            w = "0.88 * safeZoneW";
            h = "0.413 * safeZoneH";
            columns[] = {0.015, 0.10, 0.36, 0.55, 0.67, 0.82};
            multiSelect = 1;
            drawSideArrows = 0;
            disableOverflow = 1;
            colorBackground[] = {0, 0, 0, 0.45};
            tooltip = "Click to toggle one row. Ctrl-click selects separate rows; Shift-click selects a range. Press Space, Favorite, or Limit Item to apply an action to the complete selection.";
            onMouseButtonUp = "_this spawn {uiSleep 0.01; _this call RACA_fnc_toggleRow}";
            onKeyDown = "if ((_this select 1) isEqualTo 57) then {[_this select 0, 0] call RACA_fnc_toggleRow; true} else {if ((_this select 1) isEqualTo 28) then {ctrlParent (_this select 0) call RACA_fnc_openItemDetails; true} else {false}}";
        };

        class IncludeVisible: RscButton {
            idc = RACA_IDC_INCLUDE_VISIBLE;
            text = "INCLUDE VISIBLE";
            x = "safeZoneX + 0.055 * safeZoneW";
            y = "safeZoneY + 0.725 * safeZoneH";
            w = "0.12 * safeZoneW";
            h = "0.04 * safeZoneH";
            onButtonClick = "[ctrlParent (_this select 0), true] call RACA_fnc_setVisibleSelection";
        };

        class ExcludeVisible: IncludeVisible {
            idc = RACA_IDC_EXCLUDE_VISIBLE;
            text = "EXCLUDE VISIBLE";
            x = "safeZoneX + 0.18 * safeZoneW";
            onButtonClick = "[ctrlParent (_this select 0), false] call RACA_fnc_setVisibleSelection";
        };

        class ClearAll: IncludeVisible {
            idc = RACA_IDC_CLEAR_ALL;
            text = "CLEAR ALL";
            x = "safeZoneX + 0.305 * safeZoneW";
            w = "0.075 * safeZoneW";
            onButtonClick = "ctrlParent (_this select 0) call RACA_fnc_clearSelection";
        };

        class LimitScope: RscCombo {
            idc = RACA_IDC_LIMIT_SCOPE;
            x = "safeZoneX + 0.385 * safeZoneW";
            y = "safeZoneY + 0.725 * safeZoneH";
            w = "0.09 * safeZoneW";
            h = "0.04 * safeZoneH";
            tooltip = "Quantity scope: interaction, player, life, mission, or shared arsenal";
        };

        class LimitValue: RscEdit {
            idc = RACA_IDC_LIMIT_VALUE;
            x = "safeZoneX + 0.48 * safeZoneW";
            y = "safeZoneY + 0.725 * safeZoneH";
            w = "0.05 * safeZoneW";
            h = "0.04 * safeZoneH";
            text = "-1";
            tooltip = "Maximum quantity; -1 means unlimited";
        };

        class SetLimit: ClearAll {
            idc = RACA_IDC_SET_LIMIT;
            text = "LIMIT ITEM";
            x = "safeZoneX + 0.535 * safeZoneW";
            w = "0.075 * safeZoneW";
            onButtonClick = "ctrlParent (_this select 0) call RACA_fnc_setItemLimit";
        };

        class SetCategoryLimit: SetLimit {
            idc = RACA_IDC_SET_CATEGORY_LIMIT;
            text = "LIMIT CATEGORY";
            x = "safeZoneX + 0.615 * safeZoneW";
            w = "0.10 * safeZoneW";
            tooltip = "Apply the quantity and scope to the active equipment category";
            onButtonClick = "ctrlParent (_this select 0) call RACA_fnc_setCategoryLimit";
        };

        class Favorite: SetLimit {
            idc = RACA_IDC_FAVORITE;
            text = "FAVORITE";
            x = "safeZoneX + 0.72 * safeZoneW";
            w = "0.08 * safeZoneW";
            tooltip = "Add or remove the selected class from profile favorites";
            onButtonClick = "ctrlParent (_this select 0) call RACA_fnc_toggleFavorite";
        };

        class ViewMode: SetLimit {
            idc = RACA_IDC_VIEW_MODE;
            text = "ICONS";
            x = "safeZoneX + 0.805 * safeZoneW";
            w = "0.065 * safeZoneW";
            onButtonClick = "ctrlParent (_this select 0) call RACA_fnc_setCatalogView";
        };

        class ItemDetails: SetLimit {
            idc = RACA_IDC_ITEM_DETAILS_BUTTON;
            text = "DETAILS";
            x = "safeZoneX + 0.875 * safeZoneW";
            w = "0.06 * safeZoneW";
            tooltip = "Inspect the selected item's config, source, compatibility metadata, draft state, and effective quantity policy";
            onButtonClick = "ctrlParent (_this select 0) call RACA_fnc_openItemDetails";
        };

        class Summary: RscText {
            idc = RACA_IDC_SUMMARY;
            text = "0 items included";
            style = 16;
            x = "safeZoneX + 0.055 * safeZoneW";
            y = "safeZoneY + 0.785 * safeZoneH";
            w = "0.88 * safeZoneW";
            h = "0.06 * safeZoneH";
            colorBackground[] = {0, 0, 0, 0.4};
        };

        class Status: RscText {
            idc = RACA_IDC_STATUS;
            text = "Preparing item catalogue...";
            x = "safeZoneX + 0.055 * safeZoneW";
            y = "safeZoneY + 0.88 * safeZoneH";
            w = "0.75 * safeZoneW";
            h = "0.045 * safeZoneH";
            colorBackground[] = {0, 0, 0, 0.5};
        };

        class Close: RscButton {
            idc = 2;
            text = "CLOSE";
            x = "safeZoneX + 0.825 * safeZoneW";
            y = "safeZoneY + 0.88 * safeZoneH";
            w = "0.12 * safeZoneW";
            h = "0.045 * safeZoneH";
            onButtonClick = "ctrlParent (_this select 0) spawn RACA_fnc_requestCreatorClose";
        };
    };
};

class RACA_RscDisplayQuickStart {
    idd = RACA_IDD_QUICK_START;
    movingEnable = 0;
    enableSimulation = 1;
    onLoad = "(_this select 0) call RACA_fnc_quickStartOnLoad";
    class controlsBackground {
        class Background: RscText {
            idc = -1;
            x = "safeZoneX + 0.12 * safeZoneW";
            y = "safeZoneY + 0.05 * safeZoneH";
            w = "0.76 * safeZoneW";
            h = "0.90 * safeZoneH";
            colorBackground[] = {0.02, 0.025, 0.03, 0.98};
        };
        class Title: RscText {
            idc = -1;
            text = "RACA PARAMETERIZED QUICK START";
            style = 2;
            x = "safeZoneX + 0.14 * safeZoneW";
            y = "safeZoneY + 0.07 * safeZoneH";
            w = "0.72 * safeZoneW";
            h = "0.05 * safeZoneH";
            colorBackground[] = {0.19, 0.42, 0.19, 0.95};
        };
    };
    class controls {
        class Help: RscText {
            idc = RACA_IDC_QUICK_HELP;
            text = "Choose a built-in role or custom unit pack, constrain it to a loaded source mod, then apply optic, suppressor, night-vision, and medical policies. The result is always an unsaved review draft.";
            style = 16;
            x = "safeZoneX + 0.15 * safeZoneW";
            y = "safeZoneY + 0.14 * safeZoneH";
            w = "0.70 * safeZoneW";
            h = "0.09 * safeZoneH";
            colorBackground[] = {0, 0, 0, 0.25};
        };
        class NameLabel: RscText {
            idc = -1;
            text = "Draft preset name";
            x = "safeZoneX + 0.16 * safeZoneW";
            y = "safeZoneY + 0.26 * safeZoneH";
            w = "0.32 * safeZoneW";
            h = "0.03 * safeZoneH";
        };
        class Name: RscEdit {
            idc = RACA_IDC_QUICK_NAME;
            x = "safeZoneX + 0.16 * safeZoneW";
            y = "safeZoneY + 0.295 * safeZoneH";
            w = "0.32 * safeZoneW";
            h = "0.04 * safeZoneH";
        };
        class RoleLabel: NameLabel {
            text = "Starting role or custom pack";
            y = "safeZoneY + 0.355 * safeZoneH";
        };
        class Role: RscCombo {
            idc = RACA_IDC_QUICK_ROLE;
            x = "safeZoneX + 0.16 * safeZoneW";
            y = "safeZoneY + 0.39 * safeZoneH";
            w = "0.32 * safeZoneW";
            h = "0.04 * safeZoneH";
        };
        class SourceLabel: NameLabel {
            text = "Optional source-mod boundary";
            y = "safeZoneY + 0.45 * safeZoneH";
        };
        class Source: Role {
            idc = RACA_IDC_QUICK_SOURCE;
            y = "safeZoneY + 0.485 * safeZoneH";
            tooltip = "Limit role-starter suggestions to one loaded content source";
        };
        class ParameterHelp: Help {
            idc = -1;
            text = "Policies modify the generated set after the starter or pack is applied. Add uses matching classes from the source boundary; Exclude removes matching classes. Review broad matches before saving.";
            x = "safeZoneX + 0.16 * safeZoneW";
            y = "safeZoneY + 0.55 * safeZoneH";
            w = "0.32 * safeZoneW";
            h = "0.17 * safeZoneH";
        };
        class OpticsLabel: NameLabel {
            text = "Optic policy";
            x = "safeZoneX + 0.52 * safeZoneW";
        };
        class Optics: Role {
            idc = RACA_IDC_QUICK_OPTICS;
            x = "safeZoneX + 0.52 * safeZoneW";
            y = "safeZoneY + 0.295 * safeZoneH";
        };
        class SuppressorLabel: OpticsLabel {
            text = "Suppressor policy";
            y = "safeZoneY + 0.355 * safeZoneH";
        };
        class Suppressors: Optics {
            idc = RACA_IDC_QUICK_SUPPRESSORS;
            y = "safeZoneY + 0.39 * safeZoneH";
        };
        class NvgLabel: OpticsLabel {
            text = "Night-vision policy";
            y = "safeZoneY + 0.45 * safeZoneH";
        };
        class Nvg: Optics {
            idc = RACA_IDC_QUICK_NVG;
            y = "safeZoneY + 0.485 * safeZoneH";
        };
        class MedicalLabel: OpticsLabel {
            text = "Medical policy";
            y = "safeZoneY + 0.545 * safeZoneH";
        };
        class Medical: Optics {
            idc = RACA_IDC_QUICK_MEDICAL;
            y = "safeZoneY + 0.58 * safeZoneH";
        };
        class GeneratorNote: ParameterHelp {
            text = "Your last role, source, and policy choices are restored the next time Quick Start opens.";
            x = "safeZoneX + 0.52 * safeZoneW";
            y = "safeZoneY + 0.64 * safeZoneH";
            w = "0.32 * safeZoneW";
            h = "0.08 * safeZoneH";
        };
        class Create: RscButton {
            idc = RACA_IDC_QUICK_CREATE;
            text = "GENERATE REVIEW DRAFT";
            x = "safeZoneX + 0.16 * safeZoneW";
            y = "safeZoneY + 0.83 * safeZoneH";
            w = "0.32 * safeZoneW";
            h = "0.05 * safeZoneH";
            colorBackground[] = {0.19, 0.42, 0.19, 0.95};
            onButtonClick = "ctrlParent (_this select 0) call RACA_fnc_quickStartApply";
        };
        class Cancel: Create {
            idc = 2;
            text = "CANCEL";
            x = "safeZoneX + 0.52 * safeZoneW";
            w = "0.32 * safeZoneW";
            colorBackground[] = {0.12, 0.13, 0.14, 0.95};
            onButtonClick = "ctrlParent (_this select 0) closeDisplay 2";
        };
    };
};

class RACA_RscDisplayHistory {
    idd = RACA_IDD_HISTORY;
    movingEnable = 0;
    enableSimulation = 1;
    onLoad = "(_this select 0) call RACA_fnc_historyOnLoad";
    class controlsBackground {
        class Background: RscText {
            idc = -1;
            x = "safeZoneX + 0.12 * safeZoneW";
            y = "safeZoneY + 0.10 * safeZoneH";
            w = "0.76 * safeZoneW";
            h = "0.78 * safeZoneH";
            colorBackground[] = {0.02, 0.025, 0.03, 0.98};
        };
        class Title: RscText {
            idc = -1;
            text = "PRESET REVISION HISTORY";
            style = 2;
            x = "safeZoneX + 0.14 * safeZoneW";
            y = "safeZoneY + 0.12 * safeZoneH";
            w = "0.72 * safeZoneW";
            h = "0.05 * safeZoneH";
            colorBackground[] = {0.19, 0.42, 0.19, 0.95};
        };
    };
    class controls {
        class HistoryList: RscListNBox {
            idc = RACA_IDC_HISTORY_LIST;
            x = "safeZoneX + 0.14 * safeZoneW";
            y = "safeZoneY + 0.19 * safeZoneH";
            w = "0.72 * safeZoneW";
            h = "0.43 * safeZoneH";
            columns[] = {0.02, 0.12, 0.36, 0.54, 0.88};
            colorBackground[] = {0, 0, 0, 0.45};
            onLBSelChanged = "ctrlParent (_this select 0) call RACA_fnc_historySelect";
        };
        class Details: RscText {
            idc = RACA_IDC_HISTORY_DETAILS;
            text = "Select an archived revision.";
            style = 16;
            x = "safeZoneX + 0.14 * safeZoneW";
            y = "safeZoneY + 0.64 * safeZoneH";
            w = "0.72 * safeZoneW";
            h = "0.11 * safeZoneH";
            colorBackground[] = {0, 0, 0, 0.35};
        };
        class Restore: RscButton {
            idc = RACA_IDC_HISTORY_RESTORE;
            text = "RESTORE AS NEW REVISION";
            x = "safeZoneX + 0.14 * safeZoneW";
            y = "safeZoneY + 0.78 * safeZoneH";
            w = "0.30 * safeZoneW";
            h = "0.05 * safeZoneH";
            colorBackground[] = {0.19, 0.42, 0.19, 0.95};
            onButtonClick = "ctrlParent (_this select 0) spawn RACA_fnc_restorePresetRevision";
        };
        class Close: Restore {
            idc = 2;
            text = "CLOSE";
            x = "safeZoneX + 0.71 * safeZoneW";
            w = "0.15 * safeZoneW";
            colorBackground[] = {0.12, 0.13, 0.14, 0.95};
            onButtonClick = "ctrlParent (_this select 0) closeDisplay 2";
        };
    };
};

class RACA_RscDisplayAdmin {
    idd = RACA_IDD_ADMIN;
    movingEnable = 0;
    enableSimulation = 1;
    onLoad = "(_this select 0) call RACA_fnc_adminOnLoad";
    class controlsBackground {
        class Background: RscText {
            idc = -1;
            x = "safeZoneX + 0.03 * safeZoneW";
            y = "safeZoneY + 0.035 * safeZoneH";
            w = "0.94 * safeZoneW";
            h = "0.93 * safeZoneH";
            colorBackground[] = {0.02, 0.025, 0.03, 0.98};
        };
        class Title: RscText {
            idc = -1;
            text = "RACA RUNTIME ADMINISTRATION";
            style = 2;
            x = "safeZoneX + 0.05 * safeZoneW";
            y = "safeZoneY + 0.055 * safeZoneH";
            w = "0.90 * safeZoneW";
            h = "0.05 * safeZoneH";
            colorBackground[] = {0.19, 0.42, 0.19, 0.95};
        };
    };
    class controls {
        class ObjectHeading: RscText {
            idc = -1;
            text = "CONFIGURED OBJECTS — NAME | TYPE | SLOTS | QUOTAS | SESSIONS";
            x = "safeZoneX + 0.05 * safeZoneW";
            y = "safeZoneY + 0.12 * safeZoneH";
            w = "0.90 * safeZoneW";
            h = "0.035 * safeZoneH";
            colorBackground[] = {0.12, 0.13, 0.14, 0.95};
        };
        class Objects: RscListNBox {
            idc = RACA_IDC_ADMIN_OBJECTS;
            x = "safeZoneX + 0.05 * safeZoneW";
            y = "safeZoneY + 0.16 * safeZoneH";
            w = "0.90 * safeZoneW";
            h = "0.27 * safeZoneH";
            columns[] = {0.01, 0.18, 0.37, 0.82, 0.91};
            colorBackground[] = {0, 0, 0, 0.45};
        };
        class AuditHeading: ObjectHeading {
            text = "RECENT SERVER AUDIT — TIME | EVENT | PLAYER | UID | OBJECT | SLOT | DETAILS";
            y = "safeZoneY + 0.45 * safeZoneH";
        };
        class Audit: Objects {
            idc = RACA_IDC_ADMIN_AUDIT;
            y = "safeZoneY + 0.49 * safeZoneH";
            h = "0.27 * safeZoneH";
            columns[] = {0.01, 0.17, 0.29, 0.43, 0.57, 0.69, 0.79};
        };
        class Refresh: RscButton {
            idc = RACA_IDC_ADMIN_REFRESH;
            text = "REFRESH";
            x = "safeZoneX + 0.05 * safeZoneW";
            y = "safeZoneY + 0.785 * safeZoneH";
            w = "0.10 * safeZoneW";
            h = "0.045 * safeZoneH";
            onButtonClick = "[ctrlParent (_this select 0), 'refresh'] spawn RACA_fnc_adminExecute";
        };
        class ResetAll: Refresh {
            idc = RACA_IDC_ADMIN_RESET_ALL;
            text = "RESET ALL QUOTAS";
            x = "safeZoneX + 0.16 * safeZoneW";
            w = "0.14 * safeZoneW";
            onButtonClick = "[ctrlParent (_this select 0), 'resetquotas'] spawn RACA_fnc_adminExecute";
        };
        class ResetObject: Refresh {
            idc = RACA_IDC_ADMIN_RESET_OBJECT;
            text = "RESET OBJECT";
            x = "safeZoneX + 0.31 * safeZoneW";
            w = "0.12 * safeZoneW";
            onButtonClick = "[ctrlParent (_this select 0), 'resetobject'] spawn RACA_fnc_adminExecute";
        };
        class Enable: Refresh {
            idc = RACA_IDC_ADMIN_ENABLE;
            text = "ENABLE";
            x = "safeZoneX + 0.44 * safeZoneW";
            w = "0.09 * safeZoneW";
            onButtonClick = "[ctrlParent (_this select 0), 'enable'] spawn RACA_fnc_adminExecute";
        };
        class Disable: Enable {
            idc = RACA_IDC_ADMIN_DISABLE;
            text = "DISABLE";
            x = "safeZoneX + 0.54 * safeZoneW";
            onButtonClick = "[ctrlParent (_this select 0), 'disable'] spawn RACA_fnc_adminExecute";
        };
        class Clear: Enable {
            idc = RACA_IDC_ADMIN_CLEAR;
            text = "CLEAR";
            x = "safeZoneX + 0.64 * safeZoneW";
            colorBackground[] = {0.45, 0.12, 0.12, 0.9};
            onButtonClick = "[ctrlParent (_this select 0), 'clear'] spawn RACA_fnc_adminExecute";
        };
        class CopyAudit: Refresh {
            idc = RACA_IDC_ADMIN_COPY_AUDIT;
            text = "COPY AUDIT";
            x = "safeZoneX + 0.74 * safeZoneW";
            w = "0.10 * safeZoneW";
            onButtonClick = "ctrlParent (_this select 0) call RACA_fnc_adminCopyAudit";
        };
        class Close: Refresh {
            idc = 2;
            text = "CLOSE";
            x = "safeZoneX + 0.85 * safeZoneW";
            onButtonClick = "ctrlParent (_this select 0) closeDisplay 2";
        };
        class Status: RscText {
            idc = RACA_IDC_ADMIN_STATUS;
            text = "Requesting server state...";
            x = "safeZoneX + 0.20 * safeZoneW";
            y = "safeZoneY + 0.85 * safeZoneH";
            w = "0.75 * safeZoneW";
            h = "0.06 * safeZoneH";
            style = 16;
            colorBackground[] = {0, 0, 0, 0.45};
        };
        class Rehearsal: Refresh {
            idc = RACA_IDC_ADMIN_REHEARSAL;
            text = "MP REHEARSAL";
            tooltip = "Open the guided host, client, and join-in-progress synchronization rehearsal";
            x = "safeZoneX + 0.05 * safeZoneW";
            y = "safeZoneY + 0.85 * safeZoneH";
            w = "0.14 * safeZoneW";
            h = "0.06 * safeZoneH";
            colorBackground[] = {0.19, 0.42, 0.19, 0.95};
            onButtonClick = "ctrlParent (_this select 0) call RACA_fnc_openRehearsal";
        };
    };
};

class RACA_RscDisplayPreflight {
    idd = RACA_IDD_PREFLIGHT;
    movingEnable = 0;
    enableSimulation = 1;
    onLoad = "(_this select 0) call RACA_fnc_preflightOnLoad";
    onUnload = "uiNamespace setVariable ['RACA_preflightParent', displayNull]";

    class controlsBackground {
        class Background: RscText {
            idc = -1;
            x = "safeZoneX + 0.07 * safeZoneW";
            y = "safeZoneY + 0.07 * safeZoneH";
            w = "0.86 * safeZoneW";
            h = "0.86 * safeZoneH";
            colorBackground[] = {0.02, 0.025, 0.03, 0.99};
        };
        class Header: RscText {
            idc = -1;
            text = "RACA COMPATIBILITY PREFLIGHT";
            style = 2;
            x = "safeZoneX + 0.09 * safeZoneW";
            y = "safeZoneY + 0.09 * safeZoneH";
            w = "0.82 * safeZoneW";
            h = "0.05 * safeZoneH";
            colorBackground[] = {0.19, 0.42, 0.19, 0.95};
        };
    };

    class controls {
        class Summary: RscText {
            idc = RACA_IDC_PREFLIGHT_SUMMARY;
            text = "Loading compatibility results...";
            style = 16;
            x = "safeZoneX + 0.09 * safeZoneW";
            y = "safeZoneY + 0.155 * safeZoneH";
            w = "0.82 * safeZoneW";
            h = "0.08 * safeZoneH";
            colorBackground[] = {0, 0, 0, 0.45};
        };
        class FilterLabel: RscText {
            idc = -1;
            text = "Severity";
            x = "safeZoneX + 0.09 * safeZoneW";
            y = "safeZoneY + 0.25 * safeZoneH";
            w = "0.07 * safeZoneW";
            h = "0.035 * safeZoneH";
        };
        class Filter: RscCombo {
            idc = RACA_IDC_PREFLIGHT_FILTER;
            x = "safeZoneX + 0.16 * safeZoneW";
            y = "safeZoneY + 0.25 * safeZoneH";
            w = "0.20 * safeZoneW";
            h = "0.035 * safeZoneH";
            onLBSelChanged = "ctrlParent (_this select 0) call RACA_fnc_preflightRefresh";
        };
        class ListHeading: RscText {
            idc = -1;
            text = "SEVERITY            CODE                         MESSAGE                                                      CLASS                                      SOURCE";
            x = "safeZoneX + 0.09 * safeZoneW";
            y = "safeZoneY + 0.30 * safeZoneH";
            w = "0.82 * safeZoneW";
            h = "0.035 * safeZoneH";
            colorBackground[] = {0.12, 0.13, 0.14, 0.95};
        };
        class Entries: RscListNBox {
            idc = RACA_IDC_PREFLIGHT_LIST;
            x = "safeZoneX + 0.09 * safeZoneW";
            y = "safeZoneY + 0.34 * safeZoneH";
            w = "0.82 * safeZoneW";
            h = "0.43 * safeZoneH";
            columns[] = {0.01, 0.12, 0.26, 0.65, 0.80};
            colorBackground[] = {0, 0, 0, 0.45};
            onLBDblClick = "ctrlParent (_this select 0) call RACA_fnc_preflightSelect";
        };
        class ShowItem: RscButton {
            idc = RACA_IDC_PREFLIGHT_SHOW_ITEM;
            text = "SHOW AVAILABLE ITEM";
            tooltip = "Switch to Assignment and select the affected class when it exists in the loaded catalogue";
            x = "safeZoneX + 0.09 * safeZoneW";
            y = "safeZoneY + 0.80 * safeZoneH";
            w = "0.18 * safeZoneW";
            h = "0.05 * safeZoneH";
            onButtonClick = "ctrlParent (_this select 0) call RACA_fnc_preflightSelect";
        };
        class Rerun: ShowItem {
            idc = RACA_IDC_PREFLIGHT_RERUN;
            text = "RERUN PREFLIGHT";
            tooltip = "Repeat compatibility analysis for the current draft";
            x = "safeZoneX + 0.28 * safeZoneW";
            w = "0.15 * safeZoneW";
            onButtonClick = "ctrlParent (_this select 0) call RACA_fnc_preflightRerun";
        };
        class Copy: Rerun {
            idc = RACA_IDC_PREFLIGHT_COPY;
            text = "COPY REPORT";
            tooltip = "Copy the complete compatibility report to the clipboard";
            x = "safeZoneX + 0.44 * safeZoneW";
            onButtonClick = "ctrlParent (_this select 0) call RACA_fnc_preflightCopy";
        };
        class Close: Rerun {
            idc = 2;
            text = "CLOSE";
            tooltip = "Close the compatibility report";
            x = "safeZoneX + 0.76 * safeZoneW";
            colorBackground[] = {0.12, 0.13, 0.14, 0.95};
            onButtonClick = "ctrlParent (_this select 0) closeDisplay 2";
        };
    };
};

class RACA_RscDisplaySavedViews {
    idd = RACA_IDD_SAVED_VIEWS;
    movingEnable = 0;
    enableSimulation = 1;
    onLoad = "(_this select 0) call RACA_fnc_savedCatalogViewOnLoad";
    onUnload = "uiNamespace setVariable ['RACA_savedViewsParent', displayNull]";

    class controlsBackground {
        class Background: RscText {
            idc = -1;
            x = "safeZoneX + 0.07 * safeZoneW";
            y = "safeZoneY + 0.07 * safeZoneH";
            w = "0.86 * safeZoneW";
            h = "0.86 * safeZoneH";
            colorBackground[] = {0.02, 0.025, 0.03, 0.99};
        };
        class Header: RscText {
            idc = -1;
            text = "SAVED CATALOGUE VIEWS";
            style = 2;
            x = "safeZoneX + 0.09 * safeZoneW";
            y = "safeZoneY + 0.09 * safeZoneH";
            w = "0.82 * safeZoneW";
            h = "0.05 * safeZoneH";
            colorBackground[] = {0.19, 0.42, 0.19, 0.95};
        };
    };

    class controls {
        class Help: RscText {
            idc = -1;
            text = "Save a reusable catalogue workspace. Views store text, category, mod, add-on, author, and sort order; they never include or exclude arsenal items.";
            style = 16;
            x = "safeZoneX + 0.09 * safeZoneW";
            y = "safeZoneY + 0.15 * safeZoneH";
            w = "0.82 * safeZoneW";
            h = "0.065 * safeZoneH";
            colorBackground[] = {0, 0, 0, 0.35};
        };
        class NameLabel: RscText {
            idc = -1;
            text = "View name";
            x = "safeZoneX + 0.09 * safeZoneW";
            y = "safeZoneY + 0.23 * safeZoneH";
            w = "0.08 * safeZoneW";
            h = "0.04 * safeZoneH";
        };
        class Name: RscEdit {
            idc = RACA_IDC_SAVED_VIEW_NAME;
            x = "safeZoneX + 0.17 * safeZoneW";
            y = "safeZoneY + 0.23 * safeZoneH";
            w = "0.49 * safeZoneW";
            h = "0.04 * safeZoneH";
            maxChars = 64;
        };
        class Capture: RscButton {
            idc = RACA_IDC_SAVED_VIEW_CAPTURE;
            text = "CAPTURE CURRENT VIEW";
            tooltip = "Save the creator's current search, filters, and sort order under this name";
            x = "safeZoneX + 0.68 * safeZoneW";
            y = "safeZoneY + 0.23 * safeZoneH";
            w = "0.23 * safeZoneW";
            h = "0.04 * safeZoneH";
            colorBackground[] = {0.19, 0.42, 0.19, 0.95};
            onButtonClick = "ctrlParent (_this select 0) call RACA_fnc_savedCatalogViewCapture";
        };
        class ListHeading: RscText {
            idc = -1;
            text = "NAME                         SEARCH                    CATEGORY          MOD              ADD-ON           AUTHOR           SORT";
            x = "safeZoneX + 0.09 * safeZoneW";
            y = "safeZoneY + 0.29 * safeZoneH";
            w = "0.82 * safeZoneW";
            h = "0.035 * safeZoneH";
            colorBackground[] = {0.12, 0.13, 0.14, 0.95};
        };
        class Views: RscListNBox {
            idc = RACA_IDC_SAVED_VIEW_LIST;
            x = "safeZoneX + 0.09 * safeZoneW";
            y = "safeZoneY + 0.33 * safeZoneH";
            w = "0.82 * safeZoneW";
            h = "0.41 * safeZoneH";
            columns[] = {0.01, 0.20, 0.36, 0.49, 0.61, 0.73, 0.85};
            colorBackground[] = {0, 0, 0, 0.45};
            onLBSelChanged = "(_this select 0) call RACA_fnc_savedCatalogViewSelect";
            onLBDblClick = "ctrlParent (_this select 0) call RACA_fnc_savedCatalogViewApply";
        };
        class Details: RscText {
            idc = RACA_IDC_SAVED_VIEW_DETAILS;
            text = "No saved catalogue views yet.";
            style = 16;
            x = "safeZoneX + 0.09 * safeZoneW";
            y = "safeZoneY + 0.755 * safeZoneH";
            w = "0.82 * safeZoneW";
            h = "0.075 * safeZoneH";
            colorBackground[] = {0, 0, 0, 0.35};
        };
        class Apply: RscButton {
            idc = RACA_IDC_SAVED_VIEW_APPLY;
            text = "APPLY SELECTED VIEW";
            tooltip = "Restore the selected catalogue workspace without changing the draft selection";
            x = "safeZoneX + 0.09 * safeZoneW";
            y = "safeZoneY + 0.85 * safeZoneH";
            w = "0.20 * safeZoneW";
            h = "0.05 * safeZoneH";
            colorBackground[] = {0.19, 0.42, 0.19, 0.95};
            onButtonClick = "ctrlParent (_this select 0) call RACA_fnc_savedCatalogViewApply";
        };
        class Delete: Apply {
            idc = RACA_IDC_SAVED_VIEW_DELETE;
            text = "DELETE VIEW";
            tooltip = "Delete only the selected catalogue view after confirmation";
            x = "safeZoneX + 0.31 * safeZoneW";
            w = "0.15 * safeZoneW";
            colorBackground[] = {0.45, 0.12, 0.12, 0.9};
            onButtonClick = "ctrlParent (_this select 0) call RACA_fnc_savedCatalogViewDelete";
        };
        class Close: Apply {
            idc = 2;
            text = "CLOSE";
            x = "safeZoneX + 0.76 * safeZoneW";
            w = "0.15 * safeZoneW";
            colorBackground[] = {0.12, 0.13, 0.14, 0.95};
            onButtonClick = "ctrlParent (_this select 0) closeDisplay 2";
        };
    };
};

class RACA_RscDisplayItemDetails {
    idd = RACA_IDD_ITEM_DETAILS;
    movingEnable = 0;
    enableSimulation = 1;
    onLoad = "(_this select 0) call RACA_fnc_itemDetailsOnLoad";
    onUnload = "uiNamespace setVariable ['RACA_itemDetailsParent', displayNull]; uiNamespace setVariable ['RACA_itemDetailsClass', '']";

    class controlsBackground {
        class Background: RscText {
            idc = -1;
            x = "safeZoneX + 0.18 * safeZoneW";
            y = "safeZoneY + 0.10 * safeZoneH";
            w = "0.64 * safeZoneW";
            h = "0.80 * safeZoneH";
            colorBackground[] = {0.02, 0.025, 0.03, 0.99};
        };
        class Header: RscText {
            idc = RACA_IDC_ITEM_DETAILS_TITLE;
            text = "ITEM DETAILS";
            style = 2;
            x = "safeZoneX + 0.20 * safeZoneW";
            y = "safeZoneY + 0.12 * safeZoneH";
            w = "0.60 * safeZoneW";
            h = "0.05 * safeZoneH";
            colorBackground[] = {0.19, 0.42, 0.19, 0.95};
        };
    };

    class controls {
        class Picture: RscPicture {
            idc = RACA_IDC_ITEM_DETAILS_PICTURE;
            text = "";
            x = "safeZoneX + 0.21 * safeZoneW";
            y = "safeZoneY + 0.20 * safeZoneH";
            w = "0.16 * safeZoneW";
            h = "0.20 * safeZoneH";
        };
        class PictureHelp: RscText {
            idc = -1;
            text = "The image and metadata come from the class currently exposed by ACE Arsenal.";
            style = 16;
            x = "safeZoneX + 0.21 * safeZoneW";
            y = "safeZoneY + 0.42 * safeZoneH";
            w = "0.16 * safeZoneW";
            h = "0.15 * safeZoneH";
            colorBackground[] = {0, 0, 0, 0.25};
        };
        class Details: RscText {
            idc = RACA_IDC_ITEM_DETAILS_TEXT;
            text = "Loading item metadata...";
            style = 16;
            x = "safeZoneX + 0.39 * safeZoneW";
            y = "safeZoneY + 0.19 * safeZoneH";
            w = "0.40 * safeZoneW";
            h = "0.46 * safeZoneH";
            colorBackground[] = {0, 0, 0, 0.40};
        };
        class Status: RscText {
            idc = RACA_IDC_ITEM_DETAILS_STATUS;
            text = "";
            style = 16;
            x = "safeZoneX + 0.21 * safeZoneW";
            y = "safeZoneY + 0.68 * safeZoneH";
            w = "0.58 * safeZoneW";
            h = "0.07 * safeZoneH";
            colorBackground[] = {0, 0, 0, 0.35};
        };
        class Include: RscButton {
            idc = RACA_IDC_ITEM_DETAILS_INCLUDE;
            text = "INCLUDE ITEM";
            x = "safeZoneX + 0.21 * safeZoneW";
            y = "safeZoneY + 0.78 * safeZoneH";
            w = "0.14 * safeZoneW";
            h = "0.05 * safeZoneH";
            colorBackground[] = {0.19, 0.42, 0.19, 0.95};
            onButtonClick = "ctrlParent (_this select 0) call RACA_fnc_itemDetailsToggleIncluded";
        };
        class Favorite: Include {
            idc = RACA_IDC_ITEM_DETAILS_FAVORITE;
            text = "ADD FAVORITE";
            x = "safeZoneX + 0.36 * safeZoneW";
            colorBackground[] = {0.34, 0.29, 0.08, 0.95};
            onButtonClick = "ctrlParent (_this select 0) call RACA_fnc_itemDetailsToggleFavorite";
        };
        class Copy: Include {
            idc = RACA_IDC_ITEM_DETAILS_COPY;
            text = "COPY DETAILS";
            x = "safeZoneX + 0.51 * safeZoneW";
            colorBackground[] = {0.12, 0.13, 0.14, 0.95};
            onButtonClick = "ctrlParent (_this select 0) call RACA_fnc_itemDetailsCopy";
        };
        class Close: Include {
            idc = 2;
            text = "CLOSE";
            x = "safeZoneX + 0.66 * safeZoneW";
            w = "0.13 * safeZoneW";
            colorBackground[] = {0.12, 0.13, 0.14, 0.95};
            onButtonClick = "ctrlParent (_this select 0) closeDisplay 2";
        };
    };
};

class RACA_RscDisplayRolePacks {
    idd = RACA_IDD_ROLE_PACKS;
    movingEnable = 0;
    enableSimulation = 1;
    onLoad = "(_this select 0) call RACA_fnc_rolePackOnLoad";
    onUnload = "uiNamespace setVariable ['RACA_rolePacksParent', displayNull]";

    class controlsBackground {
        class Background: RscText {
            idc = -1;
            x = "safeZoneX + 0.10 * safeZoneW";
            y = "safeZoneY + 0.08 * safeZoneH";
            w = "0.80 * safeZoneW";
            h = "0.84 * safeZoneH";
            colorBackground[] = {0.02, 0.025, 0.03, 0.99};
        };
        class Header: RscText {
            idc = -1;
            text = "CUSTOM UNIT ROLE PACKS";
            style = 2;
            x = "safeZoneX + 0.12 * safeZoneW";
            y = "safeZoneY + 0.10 * safeZoneH";
            w = "0.76 * safeZoneW";
            h = "0.05 * safeZoneH";
            colorBackground[] = {0.19, 0.42, 0.19, 0.95};
        };
    };

    class controls {
        class Help: RscText {
            idc = -1;
            text = "Capture the current included classes as an additive or replaceable unit convention. Custom packs are profile-wide starters, appear in Quick Start, and remain separate from saved arsenal presets.";
            style = 16;
            x = "safeZoneX + 0.12 * safeZoneW";
            y = "safeZoneY + 0.17 * safeZoneH";
            w = "0.76 * safeZoneW";
            h = "0.065 * safeZoneH";
            colorBackground[] = {0, 0, 0, 0.35};
        };
        class NameLabel: RscText {
            idc = -1;
            text = "Pack name";
            x = "safeZoneX + 0.12 * safeZoneW";
            y = "safeZoneY + 0.25 * safeZoneH";
            w = "0.10 * safeZoneW";
            h = "0.04 * safeZoneH";
        };
        class Name: RscEdit {
            idc = RACA_IDC_ROLE_PACK_NAME;
            x = "safeZoneX + 0.22 * safeZoneW";
            y = "safeZoneY + 0.25 * safeZoneH";
            w = "0.42 * safeZoneW";
            h = "0.04 * safeZoneH";
            maxChars = 64;
        };
        class Capture: RscButton {
            idc = RACA_IDC_ROLE_PACK_CAPTURE;
            text = "CAPTURE CURRENT DRAFT";
            tooltip = "Store all currently included classes under this role-pack name";
            x = "safeZoneX + 0.66 * safeZoneW";
            y = "safeZoneY + 0.25 * safeZoneH";
            w = "0.22 * safeZoneW";
            h = "0.04 * safeZoneH";
            colorBackground[] = {0.19, 0.42, 0.19, 0.95};
            onButtonClick = "ctrlParent (_this select 0) call RACA_fnc_rolePackCapture";
        };
        class DescriptionLabel: NameLabel {
            text = "Description";
            y = "safeZoneY + 0.305 * safeZoneH";
        };
        class Description: Name {
            idc = RACA_IDC_ROLE_PACK_DESCRIPTION;
            x = "safeZoneX + 0.22 * safeZoneW";
            y = "safeZoneY + 0.305 * safeZoneH";
            w = "0.66 * safeZoneW";
            maxChars = 180;
        };
        class ListHeading: RscText {
            idc = -1;
            text = "NAME                                      ITEMS       DESCRIPTION";
            x = "safeZoneX + 0.12 * safeZoneW";
            y = "safeZoneY + 0.365 * safeZoneH";
            w = "0.76 * safeZoneW";
            h = "0.035 * safeZoneH";
            colorBackground[] = {0.12, 0.13, 0.14, 0.95};
        };
        class Packs: RscListNBox {
            idc = RACA_IDC_ROLE_PACK_LIST;
            x = "safeZoneX + 0.12 * safeZoneW";
            y = "safeZoneY + 0.405 * safeZoneH";
            w = "0.76 * safeZoneW";
            h = "0.30 * safeZoneH";
            columns[] = {0.01, 0.28, 0.38};
            colorBackground[] = {0, 0, 0, 0.45};
            onLBSelChanged = "(_this select 0) call RACA_fnc_rolePackSelect";
        };
        class Details: RscText {
            idc = RACA_IDC_ROLE_PACK_DETAILS;
            text = "No custom role packs yet.";
            style = 16;
            x = "safeZoneX + 0.12 * safeZoneW";
            y = "safeZoneY + 0.725 * safeZoneH";
            w = "0.76 * safeZoneW";
            h = "0.07 * safeZoneH";
            colorBackground[] = {0, 0, 0, 0.35};
        };
        class Merge: RscButton {
            idc = RACA_IDC_ROLE_PACK_MERGE;
            text = "MERGE INTO DRAFT";
            tooltip = "Add available classes from the selected pack without removing current draft classes";
            x = "safeZoneX + 0.12 * safeZoneW";
            y = "safeZoneY + 0.82 * safeZoneH";
            w = "0.16 * safeZoneW";
            h = "0.05 * safeZoneH";
            colorBackground[] = {0.19, 0.42, 0.19, 0.95};
            onButtonClick = "[ctrlParent (_this select 0), 'MERGE'] call RACA_fnc_rolePackApply";
        };
        class Replace: Merge {
            idc = RACA_IDC_ROLE_PACK_REPLACE;
            text = "REPLACE DRAFT";
            tooltip = "Replace current draft inclusion with the selected pack's available classes";
            x = "safeZoneX + 0.29 * safeZoneW";
            w = "0.18 * safeZoneW";
            onButtonClick = "[ctrlParent (_this select 0), 'REPLACE'] call RACA_fnc_rolePackApply";
        };
        class Delete: Merge {
            idc = RACA_IDC_ROLE_PACK_DELETE;
            text = "DELETE PACK";
            tooltip = "Delete only this custom role pack after confirmation";
            x = "safeZoneX + 0.48 * safeZoneW";
            w = "0.14 * safeZoneW";
            colorBackground[] = {0.45, 0.12, 0.12, 0.9};
            onButtonClick = "ctrlParent (_this select 0) call RACA_fnc_rolePackDelete";
        };
        class Close: Merge {
            idc = 2;
            text = "CLOSE";
            x = "safeZoneX + 0.73 * safeZoneW";
            w = "0.15 * safeZoneW";
            colorBackground[] = {0.12, 0.13, 0.14, 0.95};
            onButtonClick = "ctrlParent (_this select 0) closeDisplay 2";
        };
    };
};

class RACA_RscDisplayRehearsal {
    idd = RACA_IDD_REHEARSAL;
    movingEnable = 0;
    enableSimulation = 1;
    onLoad = "(_this select 0) call RACA_fnc_rehearsalOnLoad";

    class controlsBackground {
        class Background: RscText {
            idc = -1;
            x = "safeZoneX + 0.05 * safeZoneW";
            y = "safeZoneY + 0.05 * safeZoneH";
            w = "0.90 * safeZoneW";
            h = "0.90 * safeZoneH";
            colorBackground[] = {0.02, 0.025, 0.03, 0.99};
        };
        class Header: RscText {
            idc = -1;
            text = "RACA MULTIPLAYER REHEARSAL";
            style = 2;
            x = "safeZoneX + 0.07 * safeZoneW";
            y = "safeZoneY + 0.07 * safeZoneH";
            w = "0.86 * safeZoneW";
            h = "0.05 * safeZoneH";
            colorBackground[] = {0.19, 0.42, 0.19, 0.95};
        };
    };

    class controls {
        class Summary: RscText {
            idc = RACA_IDC_REHEARSAL_SUMMARY;
            text = "Requesting rehearsal state...";
            style = 16;
            x = "safeZoneX + 0.07 * safeZoneW";
            y = "safeZoneY + 0.14 * safeZoneH";
            w = "0.86 * safeZoneW";
            h = "0.09 * safeZoneH";
            colorBackground[] = {0.42, 0.34, 0.08, 0.95};
        };
        class ListHeading: RscText {
            idc = -1;
            text = "ROLE       NAME                    UID                         OWNER    DEPS      OBJECTS   SLOTS     RESULT    ISSUES";
            x = "safeZoneX + 0.07 * safeZoneW";
            y = "safeZoneY + 0.25 * safeZoneH";
            w = "0.86 * safeZoneW";
            h = "0.035 * safeZoneH";
            colorBackground[] = {0.12, 0.13, 0.14, 0.95};
        };
        class Participants: RscListNBox {
            idc = RACA_IDC_REHEARSAL_LIST;
            x = "safeZoneX + 0.07 * safeZoneW";
            y = "safeZoneY + 0.29 * safeZoneH";
            w = "0.86 * safeZoneW";
            h = "0.37 * safeZoneH";
            columns[] = {0.01, 0.09, 0.22, 0.39, 0.46, 0.54, 0.62, 0.70, 0.78};
            colorBackground[] = {0, 0, 0, 0.45};
        };
        class Status: RscText {
            idc = RACA_IDC_REHEARSAL_STATUS;
            text = "Start with an initial client connected, then join another client after START.";
            style = 16;
            x = "safeZoneX + 0.07 * safeZoneW";
            y = "safeZoneY + 0.68 * safeZoneH";
            w = "0.86 * safeZoneW";
            h = "0.10 * safeZoneH";
            colorBackground[] = {0, 0, 0, 0.35};
        };
        class Start: RscButton {
            idc = RACA_IDC_REHEARSAL_START;
            text = "START NEW";
            tooltip = "Start a new server-authoritative rehearsal and probe every currently connected interface client";
            x = "safeZoneX + 0.07 * safeZoneW";
            y = "safeZoneY + 0.82 * safeZoneH";
            w = "0.15 * safeZoneW";
            h = "0.05 * safeZoneH";
            colorBackground[] = {0.19, 0.42, 0.19, 0.95};
            onButtonClick = "[ctrlParent (_this select 0), 'START'] call RACA_fnc_rehearsalExecute";
        };
        class Refresh: Start {
            idc = RACA_IDC_REHEARSAL_REFRESH;
            text = "REFRESH PROBES";
            tooltip = "Ask every connected interface client to re-check dependencies and local action registration";
            x = "safeZoneX + 0.23 * safeZoneW";
            w = "0.17 * safeZoneW";
            onButtonClick = "[ctrlParent (_this select 0), 'REFRESH'] call RACA_fnc_rehearsalExecute";
        };
        class Finish: Start {
            idc = RACA_IDC_REHEARSAL_FINISH;
            text = "FINALIZE";
            tooltip = "Stop accepting JIP probes and freeze the current rehearsal outcome";
            x = "safeZoneX + 0.41 * safeZoneW";
            w = "0.14 * safeZoneW";
            onButtonClick = "[ctrlParent (_this select 0), 'FINISH'] call RACA_fnc_rehearsalExecute";
        };
        class Copy: Start {
            idc = RACA_IDC_REHEARSAL_COPY;
            text = "COPY REPORT";
            tooltip = "Copy gate and participant evidence as a shareable text report";
            x = "safeZoneX + 0.56 * safeZoneW";
            w = "0.16 * safeZoneW";
            colorBackground[] = {0.12, 0.13, 0.14, 0.95};
            onButtonClick = "ctrlParent (_this select 0) call RACA_fnc_rehearsalCopy";
        };
        class Close: Start {
            idc = 2;
            text = "CLOSE";
            x = "safeZoneX + 0.78 * safeZoneW";
            w = "0.15 * safeZoneW";
            colorBackground[] = {0.12, 0.13, 0.14, 0.95};
            onButtonClick = "ctrlParent (_this select 0) closeDisplay 2";
        };
    };
};
