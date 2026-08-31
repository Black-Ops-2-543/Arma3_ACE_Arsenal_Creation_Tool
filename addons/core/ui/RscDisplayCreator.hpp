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
        };

        class SavePreset: RscButton {
            idc = RACA_IDC_SAVE_PRESET;
            text = "SAVE / OVERWRITE";
            tooltip = "Save the current assigned items to your Arma profile";
            x = "safeZoneX + 0.07 * safeZoneW";
            y = "safeZoneY + 0.43 * safeZoneH";
            w = "0.19 * safeZoneW";
            h = "0.04 * safeZoneH";
            onButtonClick = "ctrlParent (_this select 0) call RACA_fnc_saveCurrentPreset";
        };

        class LoadPreset: SavePreset {
            idc = RACA_IDC_LOAD_PRESET;
            text = "LOAD";
            tooltip = "Load the selected saved preset into the creator";
            x = "safeZoneX + 0.27 * safeZoneW";
            onButtonClick = "ctrlParent (_this select 0) call RACA_fnc_loadSelectedPreset";
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
            h = "0.30 * safeZoneH";
            colorBackground[] = {0, 0, 0, 0.25};
        };

        class SearchLabel: RscText {
            idc = RACA_IDC_SEARCH_LABEL;
            text = "Search";
            x = "safeZoneX + 0.055 * safeZoneW";
            y = "safeZoneY + 0.17 * safeZoneH";
            w = "0.065 * safeZoneW";
            h = "0.035 * safeZoneH";
        };

        class Search: RscEdit {
            idc = RACA_IDC_SEARCH;
            tooltip = "Search display name, class name, category, mod, owning add-on, or author";
            x = "safeZoneX + 0.12 * safeZoneW";
            y = "safeZoneY + 0.17 * safeZoneH";
            w = "0.46 * safeZoneW";
            h = "0.035 * safeZoneH";
            onKeyUp = "ctrlParent (_this select 0) call RACA_fnc_queueRefresh";
        };

        class CategoryLabel: SearchLabel {
            idc = RACA_IDC_CATEGORY_LABEL;
            text = "Category";
            x = "safeZoneX + 0.60 * safeZoneW";
            w = "0.07 * safeZoneW";
        };

        class Category: RscCombo {
            idc = RACA_IDC_CATEGORY;
            x = "safeZoneX + 0.67 * safeZoneW";
            y = "safeZoneY + 0.17 * safeZoneH";
            w = "0.265 * safeZoneW";
            h = "0.035 * safeZoneH";
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
            h = "0.53 * safeZoneH";
            columns[] = {0.015, 0.10, 0.41, 0.67, 0.83};
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
            y = "safeZoneY + 0.80 * safeZoneH";
            w = "0.18 * safeZoneW";
            h = "0.04 * safeZoneH";
            onButtonClick = "[ctrlParent (_this select 0), true] call RACA_fnc_setVisibleSelection";
        };

        class ExcludeVisible: IncludeVisible {
            idc = RACA_IDC_EXCLUDE_VISIBLE;
            text = "EXCLUDE VISIBLE";
            x = "safeZoneX + 0.245 * safeZoneW";
            onButtonClick = "[ctrlParent (_this select 0), false] call RACA_fnc_setVisibleSelection";
        };

        class ClearAll: IncludeVisible {
            idc = RACA_IDC_CLEAR_ALL;
            text = "CLEAR ALL";
            x = "safeZoneX + 0.435 * safeZoneW";
            onButtonClick = "ctrlParent (_this select 0) call RACA_fnc_clearSelection";
        };

        class Summary: RscText {
            idc = RACA_IDC_SUMMARY;
            text = "0 items included";
            style = 16;
            x = "safeZoneX + 0.625 * safeZoneW";
            y = "safeZoneY + 0.79 * safeZoneH";
            w = "0.31 * safeZoneW";
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
            onButtonClick = "ctrlParent (_this select 0) closeDisplay 2";
        };
    };
};
