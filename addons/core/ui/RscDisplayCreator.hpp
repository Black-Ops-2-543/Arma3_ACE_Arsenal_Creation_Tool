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
            onButtonClick = "ctrlParent (_this select 0) call RACA_fnc_importPreset";
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
            onButtonClick = "ctrlParent (_this select 0) call RACA_fnc_runCreatorDiagnostics";
        };

        class CopyDiagnostics: RunDiagnostics {
            idc = RACA_IDC_COPY_DIAGNOSTICS;
            text = "COPY REPORT";
            x = "safeZoneX + 0.7225 * safeZoneW";
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
            w = "0.205 * safeZoneW";
        };

        class ApplyTemplate: RunDiagnostics {
            idc = RACA_IDC_APPLY_TEMPLATE;
            text = "APPLY STARTER";
            x = "safeZoneX + 0.815 * safeZoneW";
            y = "safeZoneY + 0.765 * safeZoneH";
            w = "0.105 * safeZoneW";
            onButtonClick = "ctrlParent (_this select 0) call RACA_fnc_applySelectedRoleTemplate";
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
            text = "Source";
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

        class ColumnHeaderBackground: RscText {
            idc = RACA_IDC_COLUMN_BACKGROUND;
            text = "";
            x = "safeZoneX + 0.055 * safeZoneW";
            y = "safeZoneY + 0.215 * safeZoneH";
            w = "0.88 * safeZoneW";
            h = "0.03 * safeZoneH";
            colorBackground[] = {0, 0, 0, 0.55};
        };

        class IncludedHeader: ColumnHeaderBackground {
            idc = RACA_IDC_INCLUDED_HEADER;
            text = "INCLUDED";
            w = "0.088 * safeZoneW";
            style = 2;
            colorBackground[] = {0, 0, 0, 0};
        };

        class ItemHeader: IncludedHeader {
            idc = RACA_IDC_ITEM_HEADER;
            text = "ITEM";
            x = "safeZoneX + 0.143 * safeZoneW";
            w = "0.272 * safeZoneW";
        };

        class ClassHeader: IncludedHeader {
            idc = RACA_IDC_CLASS_HEADER;
            text = "CLASS NAME";
            x = "safeZoneX + 0.415 * safeZoneW";
            w = "0.228 * safeZoneW";
        };

        class ModHeader: IncludedHeader {
            idc = RACA_IDC_MOD_HEADER;
            text = "MOD";
            x = "safeZoneX + 0.643 * safeZoneW";
            w = "0.14 * safeZoneW";
        };

        class AuthorHeader: IncludedHeader {
            idc = RACA_IDC_AUTHOR_HEADER;
            text = "AUTHOR";
            x = "safeZoneX + 0.783 * safeZoneW";
            w = "0.152 * safeZoneW";
        };

        class ItemList: RscListNBox {
            idc = RACA_IDC_ITEM_LIST;
            x = "safeZoneX + 0.055 * safeZoneW";
            y = "safeZoneY + 0.247 * safeZoneH";
            w = "0.88 * safeZoneW";
            h = "0.46 * safeZoneH";
            columns[] = {0.015, 0.10, 0.36, 0.55, 0.67, 0.82};
            multiSelect = 1;
            drawSideArrows = 0;
            disableOverflow = 1;
            colorBackground[] = {0, 0, 0, 0.45};
            onMouseButtonUp = "_this spawn {uiSleep 0.01; [_this select 0, _this select 1] call RACA_fnc_toggleRow}";
            onKeyDown = "if ((_this select 1) isEqualTo 57) then {[_this select 0, 0] call RACA_fnc_toggleRow; true} else {false}";
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
            x = "safeZoneX + 0.25 * safeZoneW";
            y = "safeZoneY + 0.16 * safeZoneH";
            w = "0.50 * safeZoneW";
            h = "0.68 * safeZoneH";
            colorBackground[] = {0.02, 0.025, 0.03, 0.98};
        };
        class Title: RscText {
            idc = -1;
            text = "RACA QUICK START";
            style = 2;
            x = "safeZoneX + 0.27 * safeZoneW";
            y = "safeZoneY + 0.22 * safeZoneH";
            w = "0.46 * safeZoneW";
            h = "0.05 * safeZoneH";
            colorBackground[] = {0.19, 0.42, 0.19, 0.95};
        };
    };
    class controls {
        class Help: RscText {
            idc = RACA_IDC_HISTORY_DETAILS;
            text = "1. Name the arsenal.  2. Start blank or choose a role starter.  3. Review every suggestion on Assignment.  4. Run preflight and save. Role starters are broad loaded-mod suggestions, never an authorization decision.";
            style = 16;
            x = "safeZoneX + 0.28 * safeZoneW";
            y = "safeZoneY + 0.29 * safeZoneH";
            w = "0.44 * safeZoneW";
            h = "0.14 * safeZoneH";
            colorBackground[] = {0, 0, 0, 0.25};
        };
        class NameLabel: RscText {
            idc = -1;
            text = "Draft preset name";
            x = "safeZoneX + 0.28 * safeZoneW";
            y = "safeZoneY + 0.45 * safeZoneH";
            w = "0.44 * safeZoneW";
            h = "0.03 * safeZoneH";
        };
        class Name: RscEdit {
            idc = RACA_IDC_QUICK_NAME;
            x = "safeZoneX + 0.28 * safeZoneW";
            y = "safeZoneY + 0.485 * safeZoneH";
            w = "0.44 * safeZoneW";
            h = "0.04 * safeZoneH";
        };
        class RoleLabel: NameLabel {
            text = "Starting point";
            y = "safeZoneY + 0.54 * safeZoneH";
        };
        class Role: RscCombo {
            idc = RACA_IDC_QUICK_ROLE;
            x = "safeZoneX + 0.28 * safeZoneW";
            y = "safeZoneY + 0.575 * safeZoneH";
            w = "0.44 * safeZoneW";
            h = "0.04 * safeZoneH";
        };
        class SourceLabel: NameLabel {
            text = "Optional source-mod boundary";
            y = "safeZoneY + 0.625 * safeZoneH";
        };
        class Source: Role {
            idc = RACA_IDC_QUICK_SOURCE;
            y = "safeZoneY + 0.66 * safeZoneH";
            tooltip = "Limit role-starter suggestions to one loaded content source";
        };
        class Create: RscButton {
            idc = RACA_IDC_QUICK_CREATE;
            text = "CREATE REVIEW DRAFT";
            x = "safeZoneX + 0.28 * safeZoneW";
            y = "safeZoneY + 0.74 * safeZoneH";
            w = "0.27 * safeZoneW";
            h = "0.05 * safeZoneH";
            colorBackground[] = {0.19, 0.42, 0.19, 0.95};
            onButtonClick = "ctrlParent (_this select 0) call RACA_fnc_quickStartApply";
        };
        class Cancel: Create {
            idc = 2;
            text = "CANCEL";
            x = "safeZoneX + 0.57 * safeZoneW";
            w = "0.15 * safeZoneW";
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
            x = "safeZoneX + 0.05 * safeZoneW";
            y = "safeZoneY + 0.85 * safeZoneH";
            w = "0.90 * safeZoneW";
            h = "0.06 * safeZoneH";
            style = 16;
            colorBackground[] = {0, 0, 0, 0.45};
        };
    };
};
