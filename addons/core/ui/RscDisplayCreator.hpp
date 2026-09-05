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
            colorBackground[] = {0.055, 0.06, 0.07, 0.98};
            colorBackground2[] = {0.055, 0.06, 0.07, 0.98};
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
            colorBackground[] = {"(profileNamespace getVariable ['GUI_BCG_RGB_R',0.19])", "(profileNamespace getVariable ['GUI_BCG_RGB_G',0.42])", "(profileNamespace getVariable ['GUI_BCG_RGB_B',0.19])", 0.92};
            colorBackground2[] = {"(profileNamespace getVariable ['GUI_BCG_RGB_R',0.19])", "(profileNamespace getVariable ['GUI_BCG_RGB_G',0.42])", "(profileNamespace getVariable ['GUI_BCG_RGB_B',0.19])", 0.92};
        };
    };

    class controls {
        class CreatorTitle: RscText {
            idc = RACA_IDC_TITLE;
            text = "Arsenal Creation Assistant";
            style = 2;
            font = "PuristaSemibold";
            sizeEx = "0.036 * safeZoneH";
            x = "safeZoneX + 0.05 * safeZoneW";
            y = "safeZoneY + 0.052 * safeZoneH";
            w = "0.88 * safeZoneW";
            h = "0.045 * safeZoneH";
            colorBackground[] = {0, 0, 0, 0};
            colorBackground2[] = {0, 0, 0, 0};
        };

        class PresetTab: RACA_Button {
            idc = RACA_IDC_TAB_PRESETS;
            text = "Preset Management";
            tooltip = "Save, load, import, export, and inherit from presets";
            x = "safeZoneX + 0.70 * safeZoneW";
            y = "safeZoneY + 0.108 * safeZoneH";
            w = "0.115 * safeZoneW";
            h = "0.04 * safeZoneH";
            colorBackground[] = {0.16, 0.17, 0.19, 0.98};
            colorBackground2[] = {0.16, 0.17, 0.19, 0.98};
            colorBackgroundActive[] = {"(profileNamespace getVariable ['GUI_BCG_RGB_R',0.19])", "(profileNamespace getVariable ['GUI_BCG_RGB_G',0.42])", "(profileNamespace getVariable ['GUI_BCG_RGB_B',0.19])", 0.95};
            colorBackgroundActive2[] = {"(profileNamespace getVariable ['GUI_BCG_RGB_R',0.19])", "(profileNamespace getVariable ['GUI_BCG_RGB_G',0.42])", "(profileNamespace getVariable ['GUI_BCG_RGB_B',0.19])", 0.95};
            colorBackgroundDisabled[] = {"(profileNamespace getVariable ['GUI_BCG_RGB_R',0.19])", "(profileNamespace getVariable ['GUI_BCG_RGB_G',0.42])", "(profileNamespace getVariable ['GUI_BCG_RGB_B',0.19])", 0.95};
            colorFocused[] = {"(profileNamespace getVariable ['GUI_BCG_RGB_R',0.19])", "(profileNamespace getVariable ['GUI_BCG_RGB_G',0.42])", "(profileNamespace getVariable ['GUI_BCG_RGB_B',0.19])", 0.95};
            colorFocused2[] = {"(profileNamespace getVariable ['GUI_BCG_RGB_R',0.19])", "(profileNamespace getVariable ['GUI_BCG_RGB_G',0.42])", "(profileNamespace getVariable ['GUI_BCG_RGB_B',0.19])", 0.95};
            colorDisabled[] = {1, 1, 1, 1};
            periodFocus = 0;
            periodOver = 0;
            onButtonClick = "[ctrlParent (_this select 0), 'PRESETS'] call RACA_fnc_switchCreatorTab";
        };

        class AssignmentTab: PresetTab {
            idc = RACA_IDC_TAB_ASSIGNMENT;
            text = "Arsenal Contents";
            tooltip = "Search the complete catalogue and include or exclude items";
            x = "safeZoneX + 0.82 * safeZoneW";
            onButtonClick = "[ctrlParent (_this select 0), 'ASSIGNMENT'] call RACA_fnc_switchCreatorTab";
        };

        class PresetTabIndicator: RscText {
            idc = RACA_IDC_TAB_PRESETS_INDICATOR;
            text = "";
            x = "safeZoneX + 0.70 * safeZoneW";
            y = "safeZoneY + 0.144 * safeZoneH";
            w = "0.115 * safeZoneW";
            h = "0.004 * safeZoneH";
            enable = 0;
            colorBackground[] = {"(profileNamespace getVariable ['GUI_BCG_RGB_R',0.19])", "(profileNamespace getVariable ['GUI_BCG_RGB_G',0.42])", "(profileNamespace getVariable ['GUI_BCG_RGB_B',0.19])", 1};
            colorBackground2[] = {"(profileNamespace getVariable ['GUI_BCG_RGB_R',0.19])", "(profileNamespace getVariable ['GUI_BCG_RGB_G',0.42])", "(profileNamespace getVariable ['GUI_BCG_RGB_B',0.19])", 1};
        };

        class AssignmentTabIndicator: PresetTabIndicator {
            idc = RACA_IDC_TAB_ASSIGNMENT_INDICATOR;
            x = "safeZoneX + 0.82 * safeZoneW";
        };

        class QuickStart: PresetTab {
            idc = RACA_IDC_QUICK_START;
            text = "Quick Start";
            tooltip = "Create a guided blank or role-based draft";
            canFocus = 1;
            x = "safeZoneX + 0.135 * safeZoneW";
            w = "0.115 * safeZoneW";
            colorBackground[] = {0.16, 0.17, 0.19, 0.98};
            colorBackground2[] = {0.16, 0.17, 0.19, 0.98};
            colorBackgroundActive[] = {"((profileNamespace getVariable ['GUI_BCG_RGB_R',0.19]) max 0.24)", "((profileNamespace getVariable ['GUI_BCG_RGB_G',0.42]) max 0.24)", "((profileNamespace getVariable ['GUI_BCG_RGB_B',0.19]) max 0.24)", 0.95};
            colorBackgroundActive2[] = {"((profileNamespace getVariable ['GUI_BCG_RGB_R',0.19]) max 0.24)", "((profileNamespace getVariable ['GUI_BCG_RGB_G',0.42]) max 0.24)", "((profileNamespace getVariable ['GUI_BCG_RGB_B',0.19]) max 0.24)", 0.95};
            colorBackgroundDisabled[] = {0.16, 0.17, 0.19, 0.98};
            colorFocused[] = {"((profileNamespace getVariable ['GUI_BCG_RGB_R',0.19]) max 0.24)", "((profileNamespace getVariable ['GUI_BCG_RGB_G',0.42]) max 0.24)", "((profileNamespace getVariable ['GUI_BCG_RGB_B',0.19]) max 0.24)", 0.95};
            colorFocused2[] = {"((profileNamespace getVariable ['GUI_BCG_RGB_R',0.19]) max 0.24)", "((profileNamespace getVariable ['GUI_BCG_RGB_G',0.42]) max 0.24)", "((profileNamespace getVariable ['GUI_BCG_RGB_B',0.19]) max 0.24)", 0.95};
            colorDisabled[] = {0.7, 0.7, 0.7, 0.9};
            periodFocus = 0;
            periodOver = 0;
            onButtonClick = "ctrlParent (_this select 0) call RACA_fnc_openQuickStart";
        };

        class Undo: QuickStart {
            idc = RACA_IDC_UNDO;
            text = "Undo";
            tooltip = "Undo the last creator selection or policy change (Ctrl+Z)";
            x = "safeZoneX + 0.055 * safeZoneW";
            y = "safeZoneY + 0.108 * safeZoneH";
            w = "0.07 * safeZoneW";
            h = "0.019 * safeZoneH";
            onButtonClick = "[ctrlParent (_this select 0), 'UNDO'] call RACA_fnc_restoreCreatorHistory";
        };

        class Redo: Undo {
            idc = RACA_IDC_REDO;
            text = "Redo";
            tooltip = "Redo the last undone change (Ctrl+Y)";
            x = "safeZoneX + 0.055 * safeZoneW";
            y = "safeZoneY + 0.129 * safeZoneH";
            onButtonClick = "[ctrlParent (_this select 0), 'REDO'] call RACA_fnc_restoreCreatorHistory";
        };

        class SavedViews: Undo {
            idc = RACA_IDC_SAVED_VIEWS;
            text = "Saved Filters";
            tooltip = "Save or restore a search and filter setup; this never changes arsenal contents";
            x = "safeZoneX + 0.50 * safeZoneW";
            y = "safeZoneY + 0.108 * safeZoneH";
            w = "0.10 * safeZoneW";
            h = "0.04 * safeZoneH";
            onButtonClick = "ctrlParent (_this select 0) call RACA_fnc_openSavedCatalogViews";
        };

        class CatalogTags: SavedViews {
            idc = RACA_IDC_CATALOG_TAGS_BUTTON;
            text = "Edit Tags";
            x = "safeZoneX + 0.61 * safeZoneW";
            w = "0.08 * safeZoneW";
            tooltip = "Create tags or apply them to selected catalogue rows";
            onButtonClick = "ctrlParent (_this select 0) call RACA_fnc_openCatalogTags";
        };

        class PresetPanel: RscText {
            idc = RACA_IDC_PRESET_PANEL;
            x = "safeZoneX + 0.055 * safeZoneW";
            y = "safeZoneY + 0.17 * safeZoneH";
            w = "0.42 * safeZoneW";
            h = "0.68 * safeZoneH";
            colorBackground[] = {0.12, 0.13, 0.15, 0.98};
            colorBackground2[] = {0.12, 0.13, 0.15, 0.98};
        };

        class PresetFilesHeading: RscText {
            idc = RACA_IDC_PRESET_FILES_HEADING;
            text = "Preset Files";
            font = "PuristaSemibold";
            sizeEx = "0.026 * safeZoneH";
            x = "safeZoneX + 0.07 * safeZoneW";
            y = "safeZoneY + 0.19 * safeZoneH";
            w = "0.39 * safeZoneW";
            h = "0.04 * safeZoneH";
            colorBackground[] = {"(profileNamespace getVariable ['GUI_BCG_RGB_R',0.19])", "(profileNamespace getVariable ['GUI_BCG_RGB_G',0.42])", "(profileNamespace getVariable ['GUI_BCG_RGB_B',0.19])", 0.78};
            colorBackground2[] = {"(profileNamespace getVariable ['GUI_BCG_RGB_R',0.19])", "(profileNamespace getVariable ['GUI_BCG_RGB_G',0.42])", "(profileNamespace getVariable ['GUI_BCG_RGB_B',0.19])", 0.78};
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
            onKeyUp = "ctrlParent (_this select 0) call RACA_fnc_queueDraftRecovery";
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
            tooltip = "";
            onLBSelChanged = "ctrlParent (_this select 0) call RACA_fnc_refreshHistoryButtons";
        };

        class SavePreset: RACA_Button {
            idc = RACA_IDC_SAVE_PRESET;
            text = "Save / Overwrite";
            tooltip = "Save the current assigned items to your Arma profile";
            x = "safeZoneX + 0.07 * safeZoneW";
            y = "safeZoneY + 0.43 * safeZoneH";
            w = "0.12 * safeZoneW";
            h = "0.04 * safeZoneH";
            colorBackground[] = {0.19, 0.20, 0.23, 0.98};
            colorBackground2[] = {0.19, 0.20, 0.23, 0.98};
            onButtonClick = "ctrlParent (_this select 0) call RACA_fnc_saveCurrentPreset";
        };

        class LoadPreset: SavePreset {
            idc = RACA_IDC_LOAD_PRESET;
            text = "Load";
            tooltip = "Load the selected saved preset into the creator";
            x = "safeZoneX + 0.20 * safeZoneW";
            onButtonClick = "ctrlParent (_this select 0) call RACA_fnc_loadSelectedPreset";
        };

        class DeletePreset: SavePreset {
            idc = RACA_IDC_DELETE_PRESET;
            text = "Delete";
            tooltip = "Delete the selected profile preset after confirmation; embedded mission copies are unaffected";
            x = "safeZoneX + 0.33 * safeZoneW";
            colorBackground[] = {0.45, 0.12, 0.12, 0.9};
            colorBackground2[] = {0.45, 0.12, 0.12, 0.9};
            onButtonClick = "ctrlParent (_this select 0) call RACA_fnc_deletePreset";
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
            tooltip = "Open the list and hover an export format to see when to choose it";
        };

        class ExportPreset: SavePreset {
            idc = RACA_IDC_EXPORT_PRESET;
            text = "Export to Clipboard";
            tooltip = "Export as JSON, reusable SQF, or a simple class list";
            y = "safeZoneY + 0.575 * safeZoneH";
            onButtonClick = "ctrlParent (_this select 0) call RACA_fnc_exportPreset";
        };

        class ImportPreset: ExportPreset {
            idc = RACA_IDC_IMPORT_PRESET;
            text = "Import Automatically";
            tooltip = "Import a JSON preset, existing SQF arsenal, or class list from the clipboard";
            x = "safeZoneX + 0.27 * safeZoneW";
            onButtonClick = "ctrlParent (_this select 0) spawn RACA_fnc_importPreset";
        };

        class PresetAnalysisHeading: PresetFilesHeading {
            idc = RACA_IDC_PRESET_ANALYSIS_HEADING;
            text = "Preset Analysis";
            y = "safeZoneY + 0.635 * safeZoneH";
        };

        class PresetTool: ExportFormat {
            idc = RACA_IDC_PRESET_TOOL;
            y = "safeZoneY + 0.69 * safeZoneH";
            w = "0.39 * safeZoneW";
            tooltip = "Choose a preset from Preset Analysis for history and draft comparison.";
            onLBSelChanged = "ctrlParent (_this select 0) call RACA_fnc_refreshHistoryButtons";
        };

        class SeeHistory: SavePreset {
            idc = RACA_IDC_HISTORY;
            text = "See History";
            tooltip = "Open revision history for the selected Preset Analysis preset";
            y = "safeZoneY + 0.745 * safeZoneH";
            w = "0.19 * safeZoneW";
            onButtonClick = "[ctrlParent (_this select 0), RACA_IDC_PRESET_TOOL] call RACA_fnc_openPresetHistory";
        };

        class CompareAnalysis: SeeHistory {
            idc = RACA_IDC_COMPARE_DRAFT;
            text = "Compare With Draft";
            tooltip = "Compare the selected Preset Analysis preset with the current draft and copy a diff";
            x = "safeZoneX + 0.27 * safeZoneW";
            onButtonClick = "[ctrlParent (_this select 0), RACA_IDC_PRESET_TOOL] call RACA_fnc_compareSelectedPreset";
        };

        class InheritancePanel: PresetPanel {
            idc = RACA_IDC_INHERITANCE_PANEL;
            x = "safeZoneX + 0.50 * safeZoneW";
            w = "0.435 * safeZoneW";
        };

        class InheritanceHeading: PresetFilesHeading {
            idc = RACA_IDC_INHERITANCE_HEADING;
            text = "Preset Inheritance";
            x = "safeZoneX + 0.515 * safeZoneW";
            w = "0.405 * safeZoneW";
        };

        class BasePresetLabel: PresetNameLabel {
            idc = RACA_IDC_BASE_PRESET_LABEL;
            text = "Inherited source preset";
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
            tooltip = "";
        };

        class ApplyBase: SavePreset {
            idc = RACA_IDC_APPLY_BASE;
            text = "Inherit / Refresh";
            tooltip = "Inherit from the selected source, or refresh this preset from its current source";
            x = "safeZoneX + 0.515 * safeZoneW";
            y = "safeZoneY + 0.34 * safeZoneH";
            w = "0.1975 * safeZoneW";
            onButtonClick = "ctrlParent (_this select 0) call RACA_fnc_applyBasePreset";
        };

        class FlattenPreset: ApplyBase {
            idc = RACA_IDC_FLATTEN_PRESET;
            text = "Make Standalone";
            tooltip = "Keep the complete current item set and remove its inheritance link";
            x = "safeZoneX + 0.7225 * safeZoneW";
            onButtonClick = "ctrlParent (_this select 0) call RACA_fnc_flattenCurrentPreset";
        };

        class InheritanceHelp: RscText {
            idc = RACA_IDC_INHERITANCE_HELP;
            text = "Inherit from a saved preset to use its item set as a source. Every inherited item is light blue in Arsenal Contents, whether included or excluded. The child stores a complete usable snapshot plus its additions and removals. Source changes are never applied silently: use Inherit / Refresh when you want them. Make Standalone removes the link without changing items.";
            style = 16;
            x = "safeZoneX + 0.515 * safeZoneW";
            y = "safeZoneY + 0.42 * safeZoneH";
            w = "0.405 * safeZoneW";
            h = "0.13 * safeZoneH";
            colorBackground[] = {0, 0, 0, 0.25};
            colorBackground2[] = {0, 0, 0, 0.25};
        };

        class DiagnosticsHeading: InheritanceHeading {
            idc = RACA_IDC_DIAGNOSTICS_HEADING;
            text = "Compatibility";
            y = "safeZoneY + 0.585 * safeZoneH";
        };

        class Diagnostics: InheritanceHelp {
            idc = RACA_IDC_DIAGNOSTICS;
            text = "Check this draft for missing classes, unavailable source add-ons, duplicate data, and other problems before exporting or using it in a mission.";
            y = "safeZoneY + 0.63 * safeZoneH";
            h = "0.105 * safeZoneH";
        };

        class RunDiagnostics: ApplyBase {
            idc = RACA_IDC_RUN_DIAGNOSTICS;
            text = "Check Compatibility";
            tooltip = "Run the same compatibility checks used when a mission starts";
            y = "safeZoneY + 0.755 * safeZoneH";
            w = "0.125 * safeZoneW";
            onButtonClick = "ctrlParent (_this select 0) call RACA_fnc_runCreatorDiagnostics";
        };

        class OpenDiagnostics: RunDiagnostics {
            idc = RACA_IDC_OPEN_DIAGNOSTICS;
            text = "View Details";
            tooltip = "Open the filterable visual compatibility report";
            x = "safeZoneX + 0.655 * safeZoneW";
            onButtonClick = "ctrlParent (_this select 0) call RACA_fnc_openCreatorDiagnostics";
        };

        class CopyDiagnostics: OpenDiagnostics {
            idc = RACA_IDC_COPY_DIAGNOSTICS;
            text = "Copy Report";
            x = "safeZoneX + 0.795 * safeZoneW";
            onButtonClick = "ctrlParent (_this select 0) call RACA_fnc_copyCreatorDiagnostics";
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
            tooltip = "Search item names and class names";
            x = "safeZoneX + 0.11 * safeZoneW";
            y = "safeZoneY + 0.17 * safeZoneH";
            w = "0.30 * safeZoneW";
            h = "0.035 * safeZoneH";
            onKeyUp = "ctrlParent (_this select 0) call RACA_fnc_queueRefresh";
        };

        class CategoryLabel: SearchLabel {
            idc = RACA_IDC_CATEGORY_LABEL;
            text = "Category";
            x = "safeZoneX + 0.42 * safeZoneW";
            w = "0.06 * safeZoneW";
        };

        class Category: RscCombo {
            idc = RACA_IDC_CATEGORY;
            x = "safeZoneX + 0.485 * safeZoneW";
            y = "safeZoneY + 0.17 * safeZoneH";
            w = "0.19 * safeZoneW";
            h = "0.035 * safeZoneH";
            onLBSelChanged = "ctrlParent (_this select 0) call RACA_fnc_refreshItemList";
        };

        class SearchMode: RACA_Button {
            idc = RACA_IDC_SEARCH_MODE;
            text = "Advanced Search";
            x = "safeZoneX + 0.805 * safeZoneW";
            y = "safeZoneY + 0.17 * safeZoneH";
            w = "0.13 * safeZoneW";
            h = "0.035 * safeZoneH";
            colorBackground[] = {0.19, 0.20, 0.23, 0.98};
            colorBackground2[] = {0.19, 0.20, 0.23, 0.98};
            onButtonClick = "ctrlParent (_this select 0) call RACA_fnc_setSearchMode";
        };

        class SourceFilterLabel: SearchLabel {
            idc = RACA_IDC_SOURCE_FILTER_LABEL;
            text = "Mod";
            x = "safeZoneX + 0.055 * safeZoneW";
            y = "safeZoneY + 0.212 * safeZoneH";
            w = "0.04 * safeZoneW";
        };

        class SourceFilter: Category {
            idc = RACA_IDC_SOURCE_FILTER;
            x = "safeZoneX + 0.095 * safeZoneW";
            y = "safeZoneY + 0.212 * safeZoneH";
            w = "0.17 * safeZoneW";
            tooltip = "";
            onLBSelChanged = "ctrlParent (_this select 0) call RACA_fnc_refreshItemList";
        };

        class AddonFilterLabel: SearchLabel {
            idc = RACA_IDC_ADDON_FILTER_LABEL;
            text = "Add-on";
            x = "safeZoneX + 0.275 * safeZoneW";
            y = "safeZoneY + 0.212 * safeZoneH";
            w = "0.06 * safeZoneW";
        };

        class AddonFilter: Category {
            idc = RACA_IDC_ADDON_FILTER;
            x = "safeZoneX + 0.335 * safeZoneW";
            y = "safeZoneY + 0.212 * safeZoneH";
            w = "0.20 * safeZoneW";
            tooltip = "";
            onLBSelChanged = "ctrlParent (_this select 0) call RACA_fnc_refreshItemList";
        };

        class AuthorFilterLabel: AddonFilterLabel {
            idc = RACA_IDC_AUTHOR_FILTER_LABEL;
            text = "Author";
            x = "safeZoneX + 0.545 * safeZoneW";
            w = "0.05 * safeZoneW";
        };

        class AuthorFilter: AddonFilter {
            idc = RACA_IDC_AUTHOR_FILTER;
            x = "safeZoneX + 0.60 * safeZoneW";
            w = "0.14 * safeZoneW";
            tooltip = "";
        };

        class TagFilterLabel: AddonFilterLabel {
            idc = RACA_IDC_TAG_FILTER_LABEL;
            text = "Tag";
            x = "safeZoneX + 0.75 * safeZoneW";
            w = "0.035 * safeZoneW";
        };

        class TagFilter: AddonFilter {
            idc = RACA_IDC_TAG_FILTER;
            x = "safeZoneX + 0.79 * safeZoneW";
            w = "0.145 * safeZoneW";
            tooltip = "";
        };

        class ColumnHeaderBackground: RscText {
            idc = RACA_IDC_COLUMN_BACKGROUND;
            text = "";
            x = "safeZoneX + 0.055 * safeZoneW";
            y = "safeZoneY + 0.257 * safeZoneH";
            w = "0.88 * safeZoneW";
            h = "0.03 * safeZoneH";
            colorBackground[] = {0.17, 0.18, 0.21, 0.98};
            colorBackground2[] = {0.17, 0.18, 0.21, 0.98};
        };

        class IncludedHeader: RACA_Button {
            idc = RACA_IDC_INCLUDED_HEADER;
            text = "Included";
            tooltip = "Sort by inclusion state";
            x = "safeZoneX + 0.055 * safeZoneW";
            y = "safeZoneY + 0.257 * safeZoneH";
            w = "0.088 * safeZoneW";
            h = "0.03 * safeZoneH";
            style = 2;
            colorBackground[] = {0, 0, 0, 0};
            colorBackground2[] = {0, 0, 0, 0};
            onButtonClick = "[ctrlParent (_this select 0), 'included'] call RACA_fnc_setSortMode";
        };

        class ItemHeader: IncludedHeader {
            idc = RACA_IDC_ITEM_HEADER;
            text = "Item";
            tooltip = "Sort by display name";
            x = "safeZoneX + 0.143 * safeZoneW";
            w = "0.2288 * safeZoneW";
            onButtonClick = "[ctrlParent (_this select 0), 'item'] call RACA_fnc_setSortMode";
        };

        class ClassHeader: IncludedHeader {
            idc = RACA_IDC_CLASS_HEADER;
            text = "Class Name";
            tooltip = "Sort by class name";
            x = "safeZoneX + 0.3718 * safeZoneW";
            w = "0.1672 * safeZoneW";
            onButtonClick = "[ctrlParent (_this select 0), 'class'] call RACA_fnc_setSortMode";
        };

        class ModHeader: IncludedHeader {
            idc = RACA_IDC_MOD_HEADER;
            text = "Mod";
            tooltip = "Sort by source mod";
            x = "safeZoneX + 0.539 * safeZoneW";
            w = "0.132 * safeZoneW";
            onButtonClick = "[ctrlParent (_this select 0), 'mod'] call RACA_fnc_setSortMode";
        };

        class AuthorHeader: IncludedHeader {
            idc = RACA_IDC_AUTHOR_HEADER;
            text = "Author";
            tooltip = "Sort by author";
            x = "safeZoneX + 0.671 * safeZoneW";
            w = "0.264 * safeZoneW";
            onButtonClick = "[ctrlParent (_this select 0), 'author'] call RACA_fnc_setSortMode";
        };

        class ItemList: RscListNBox {
            idc = RACA_IDC_ITEM_LIST;
            x = "safeZoneX + 0.055 * safeZoneW";
            y = "safeZoneY + 0.289 * safeZoneH";
            w = "0.88 * safeZoneW";
            h = "0.370 * safeZoneH";
            // The first column occupies 10% of the list. Offset its square
            // checkbox so the icon is visually centered beneath the header.
            columns[] = {0.038, 0.10, 0.36, 0.55, 0.70};
            style = 32;
            multiSelect = 1;
            drawSideArrows = 0;
            disableOverflow = 1;
            colorBackground[] = {0.035, 0.04, 0.05, 0.98};
            colorBackground2[] = {0.035, 0.04, 0.05, 0.98};
            tooltip = "Click a row to select it. Only Space or the checkbox changes inclusion. Ctrl-click selects separate rows; Shift-click selects a range.";
            onMouseButtonDown = "ctrlParent (_this select 0) setVariable ['RACA_mouseSelecting', true]";
            onMouseButtonUp = "_this call RACA_fnc_toggleRow";
            onLBSelChanged = "(_this select 0) call RACA_fnc_itemListSelectionChanged";
            onKeyDown = "if ((_this select 1) isEqualTo 57) then {[_this select 0, 0, 0, 0, false, false, false, true] call RACA_fnc_toggleRow; true} else {if ((_this select 1) isEqualTo 28) then {ctrlParent (_this select 0) call RACA_fnc_openItemDetails; true} else {false}}";
        };

        class PreviousPage: RACA_Button {
            idc = RACA_IDC_PAGE_PREV;
            text = "Previous Page";
            x = "safeZoneX + 0.055 * safeZoneW";
            y = "safeZoneY + 0.665 * safeZoneH";
            w = "0.12 * safeZoneW";
            h = "0.032 * safeZoneH";
            onButtonClick = "[ctrlParent (_this select 0), -1] call RACA_fnc_catalogPage";
        };
        class NextPage: PreviousPage {
            idc = RACA_IDC_PAGE_NEXT;
            text = "Next Page";
            x = "safeZoneX + 0.815 * safeZoneW";
            onButtonClick = "[ctrlParent (_this select 0), 1] call RACA_fnc_catalogPage";
        };
        class PageLabel: RscText {
            idc = RACA_IDC_PAGE_LABEL;
            style = 2;
            font = "PuristaMedium";
            sizeEx = "0.022 * safeZoneH";
            x = "safeZoneX + 0.185 * safeZoneW";
            y = "safeZoneY + 0.665 * safeZoneH";
            w = "0.62 * safeZoneW";
            h = "0.032 * safeZoneH";
        };
        class ClearMagazineFilter: RACA_ComplementButton {
            idc = RACA_IDC_CLEAR_MAGAZINES;
            text = "Clear Magazine Filter";
            x = "safeZoneX + 0.51 * safeZoneW";
            y = "safeZoneY + 0.20 * safeZoneH";
            w = "0.19 * safeZoneW";
            h = "0.03 * safeZoneH";
            onButtonClick = "ctrlParent (_this select 0) call RACA_fnc_clearMagazineFilter";
        };
        class ClearMissingFilters: RACA_DestructiveButton {
            idc = RACA_IDC_CLEAR_MISSING_FILTERS;
            text = "Clear Missing Filters";
            x = "safeZoneX + 0.51 * safeZoneW";
            y = "safeZoneY + 0.17 * safeZoneH";
            w = "0.19 * safeZoneW";
            h = "0.028 * safeZoneH";
            onButtonClick = "ctrlParent (_this select 0) call RACA_fnc_clearMissingFilters";
        };

        class SelectionGroup: RscText {
            idc = RACA_IDC_SELECTION_GROUP;
            x = "safeZoneX + 0.055 * safeZoneW";
            y = "safeZoneY + 0.708 * safeZoneH";
            w = "0.32 * safeZoneW";
            h = "0.097 * safeZoneH";
            colorBackground[] = {0.115, 0.125, 0.145, 0.98};
            colorBackground2[] = {0.115, 0.125, 0.145, 0.98};
        };

        class SelectionHeading: RscText {
            idc = RACA_IDC_SELECTION_HEADING;
            text = "Change Arsenal Contents";
            font = "PuristaSemibold";
            x = "safeZoneX + 0.065 * safeZoneW";
            y = "safeZoneY + 0.712 * safeZoneH";
            w = "0.30 * safeZoneW";
            h = "0.026 * safeZoneH";
        };

        class ItemActionGroup: SelectionGroup {
            idc = RACA_IDC_ITEM_ACTION_GROUP;
            x = "safeZoneX + 0.385 * safeZoneW";
            w = "0.14 * safeZoneW";
        };

        class ItemActionHeading: SelectionHeading {
            idc = RACA_IDC_ITEM_ACTION_HEADING;
            text = "Selected Rows";
            x = "safeZoneX + 0.395 * safeZoneW";
            w = "0.12 * safeZoneW";
        };

        class LimitGroup: SelectionGroup {
            idc = RACA_IDC_LIMIT_GROUP;
            x = "safeZoneX + 0.535 * safeZoneW";
            w = "0.40 * safeZoneW";
        };

        class LimitHeading: SelectionHeading {
            idc = RACA_IDC_LIMIT_HEADING;
            text = "Optional Quantity Limits";
            x = "safeZoneX + 0.545 * safeZoneW";
            w = "0.38 * safeZoneW";
        };

        class IncludeVisible: RACA_Button {
            idc = RACA_IDC_INCLUDE_VISIBLE;
            text = "Include Matches";
            x = "safeZoneX + 0.065 * safeZoneW";
            y = "safeZoneY + 0.75 * safeZoneH";
            w = "0.105 * safeZoneW";
            h = "0.038 * safeZoneH";
            colorBackground[] = {0.19, 0.20, 0.23, 0.98};
            colorBackground2[] = {0.19, 0.20, 0.23, 0.98};
            onButtonClick = "[ctrlParent (_this select 0), true] call RACA_fnc_setVisibleSelection";
        };

        class ExcludeVisible: IncludeVisible {
            idc = RACA_IDC_EXCLUDE_VISIBLE;
            text = "Exclude Matches";
            x = "safeZoneX + 0.175 * safeZoneW";
            onButtonClick = "[ctrlParent (_this select 0), false] call RACA_fnc_setVisibleSelection";
        };

        class ClearAll: IncludeVisible {
            idc = RACA_IDC_CLEAR_ALL;
            text = "Clear All";
            x = "safeZoneX + 0.285 * safeZoneW";
            w = "0.08 * safeZoneW";
            onButtonClick = "ctrlParent (_this select 0) call RACA_fnc_clearSelection";
        };

        class LimitScope: RscCombo {
            idc = RACA_IDC_LIMIT_SCOPE;
            x = "safeZoneX + 0.545 * safeZoneW";
            y = "safeZoneY + 0.757 * safeZoneH";
            w = "0.095 * safeZoneW";
            h = "0.031 * safeZoneH";
            tooltip = "";
            onLBSelChanged = "ctrlParent (_this select 0) call RACA_fnc_syncLimitPolicy";
        };

        class QuantityLabel: RscText {
            idc = RACA_IDC_QUANTITY_LABEL;
            text = "Scope";
            x = "safeZoneX + 0.545 * safeZoneW";
            y = "safeZoneY + 0.738 * safeZoneH";
            w = "0.095 * safeZoneW";
            h = "0.018 * safeZoneH";
            sizeEx = "0.016 * safeZoneH";
        };

        class LimitResetLabel: QuantityLabel {
            idc = RACA_IDC_LIMIT_RESET_LABEL;
            text = "Reset";
            x = "safeZoneX + 0.645 * safeZoneW";
        };

        class LimitReset: LimitScope {
            idc = RACA_IDC_LIMIT_RESET;
            x = "safeZoneX + 0.645 * safeZoneW";
            w = "0.10 * safeZoneW";
            tooltip = "";
            onLBSelChanged = "";
        };

        class LimitValueLabel: QuantityLabel {
            idc = RACA_IDC_LIMIT_VALUE_LABEL;
            text = "Max";
            x = "safeZoneX + 0.75 * safeZoneW";
            w = "0.045 * safeZoneW";
        };

        class LimitValue: RscEdit {
            idc = RACA_IDC_LIMIT_VALUE;
            x = "safeZoneX + 0.75 * safeZoneW";
            y = "safeZoneY + 0.757 * safeZoneH";
            w = "0.045 * safeZoneW";
            h = "0.031 * safeZoneH";
            text = "-1";
            tooltip = "Maximum quantity; -1 means unlimited";
        };

        class LimitHint: QuantityLabel {
            idc = RACA_IDC_LIMIT_HINT;
            text = "Optional: -1 means unlimited";
            x = "safeZoneX + 0.545 * safeZoneW";
            y = "safeZoneY + 0.789 * safeZoneH";
            w = "0.25 * safeZoneW";
            h = "0.014 * safeZoneH";
            sizeEx = "0.014 * safeZoneH";
        };

        class SetLimit: ClearAll {
            idc = RACA_IDC_SET_LIMIT;
            text = "Limit Selection";
            x = "safeZoneX + 0.805 * safeZoneW";
            y = "safeZoneY + 0.738 * safeZoneH";
            w = "0.12 * safeZoneW";
            h = "0.029 * safeZoneH";
            tooltip = "Apply this quantity, scope, and reset policy to every selected row";
            onButtonClick = "ctrlParent (_this select 0) call RACA_fnc_setItemLimit";
        };

        class SetCategoryLimit: SetLimit {
            idc = RACA_IDC_SET_CATEGORY_LIMIT;
            text = "Limit Category";
            x = "safeZoneX + 0.805 * safeZoneW";
            y = "safeZoneY + 0.772 * safeZoneH";
            w = "0.12 * safeZoneW";
            tooltip = "Apply the quantity and scope to the active equipment category";
            onButtonClick = "ctrlParent (_this select 0) call RACA_fnc_setCategoryLimit";
        };

        class Favorite: SetLimit {
            idc = RACA_IDC_FAVORITE;
            text = "Favorite";
            x = "safeZoneX + 0.395 * safeZoneW";
            y = "safeZoneY + 0.742 * safeZoneH";
            w = "0.12 * safeZoneW";
            h = "0.026 * safeZoneH";
            tooltip = "Add or remove every selected class from profile favorites";
            onButtonClick = "ctrlParent (_this select 0) call RACA_fnc_toggleFavorite";
        };

        class ItemDetails: SetLimit {
            idc = RACA_IDC_ITEM_DETAILS_BUTTON;
            text = "Details";
            x = "safeZoneX + 0.395 * safeZoneW";
            y = "safeZoneY + 0.772 * safeZoneH";
            w = "0.12 * safeZoneW";
            h = "0.026 * safeZoneH";
            tooltip = "Inspect the selected item's config, source, compatibility metadata, draft state, and effective quantity policy";
            onButtonClick = "ctrlParent (_this select 0) call RACA_fnc_openItemDetails";
        };

        class Summary: RscText {
            idc = RACA_IDC_SUMMARY;
            text = "0 items included";
            style = 16;
            x = "safeZoneX + 0.055 * safeZoneW";
            y = "safeZoneY + 0.815 * safeZoneH";
            w = "0.88 * safeZoneW";
            h = "0.045 * safeZoneH";
            colorBackground[] = {0.13, 0.14, 0.16, 0.98};
            colorBackground2[] = {0.13, 0.14, 0.16, 0.98};
        };

        class Status: RscText {
            idc = RACA_IDC_STATUS;
            text = "Preparing item catalogue...";
            x = "safeZoneX + 0.055 * safeZoneW";
            y = "safeZoneY + 0.88 * safeZoneH";
            w = "0.75 * safeZoneW";
            h = "0.045 * safeZoneH";
            colorBackground[] = {0.10, 0.11, 0.13, 0.98};
            colorBackground2[] = {0.10, 0.11, 0.13, 0.98};
        };

        class Close: RACA_Button {
            idc = 2;
            text = "Close";
            colorBackground[] = {0.19, 0.20, 0.23, 0.98};
            colorBackground2[] = {0.19, 0.20, 0.23, 0.98};
            x = "safeZoneX + 0.825 * safeZoneW";
            y = "safeZoneY + 0.88 * safeZoneH";
            w = "0.12 * safeZoneW";
            h = "0.045 * safeZoneH";
            onButtonClick = "ctrlParent (_this select 0) spawn RACA_fnc_requestCreatorClose";
        };
    };
};

class RACA_RscDisplayPresetDeletion {
    idd = RACA_IDD_PRESET_DELETION;
    movingEnable = 0;
    enableSimulation = 1;
    onLoad = "(_this select 0) call RACA_fnc_presetDeletionOnLoad";
    onUnload = "uiNamespace setVariable ['RACA_deletePresetPending', nil]";

    class controlsBackground {
        class Background: RscText {
            idc = -1;
            x = "safeZoneX + 0.30 * safeZoneW";
            y = "safeZoneY + 0.355 * safeZoneH";
            w = "0.40 * safeZoneW";
            h = "0.29 * safeZoneH";
            colorBackground[] = {0.055, 0.06, 0.07, 0.99};
            colorBackground2[] = {0.055, 0.06, 0.07, 0.99};
        };
        class Frame: RscFrame {
            idc = -1;
            x = "safeZoneX + 0.30 * safeZoneW";
            y = "safeZoneY + 0.355 * safeZoneH";
            w = "0.40 * safeZoneW";
            h = "0.29 * safeZoneH";
            colorText[] = {0.85, 0.85, 0.85, 1};
        };
        class TitleBar: RscText {
            idc = -1;
            text = "";
            x = "safeZoneX + 0.315 * safeZoneW";
            y = "safeZoneY + 0.375 * safeZoneH";
            w = "0.37 * safeZoneW";
            h = "0.05 * safeZoneH";
            colorBackground[] = {"(profileNamespace getVariable ['GUI_BCG_RGB_R',0.19])", "(profileNamespace getVariable ['GUI_BCG_RGB_G',0.42])", "(profileNamespace getVariable ['GUI_BCG_RGB_B',0.19])", 0.95};
            colorBackground2[] = {"(profileNamespace getVariable ['GUI_BCG_RGB_R',0.19])", "(profileNamespace getVariable ['GUI_BCG_RGB_G',0.42])", "(profileNamespace getVariable ['GUI_BCG_RGB_B',0.19])", 0.95};
        };
    };

    class controls {
        class Title: RscText {
            idc = -1;
            text = "Preset Deletion";
            style = 2;
            font = "PuristaSemibold";
            sizeEx = "0.034 * safeZoneH";
            x = "safeZoneX + 0.315 * safeZoneW";
            y = "safeZoneY + 0.375 * safeZoneH";
            w = "0.37 * safeZoneW";
            h = "0.05 * safeZoneH";
            colorBackground[] = {0, 0, 0, 0};
            colorBackground2[] = {0, 0, 0, 0};
        };
        class Message: RscText {
            idc = RACA_IDC_PRESET_DELETION_MESSAGE;
            text = "Are you sure you want to delete this preset?";
            style = 18;
            x = "safeZoneX + 0.33 * safeZoneW";
            y = "safeZoneY + 0.45 * safeZoneH";
            w = "0.34 * safeZoneW";
            h = "0.075 * safeZoneH";
            colorBackground[] = {0, 0, 0, 0.25};
            colorBackground2[] = {0, 0, 0, 0.25};
        };
        class Delete: RACA_Button {
            idc = RACA_IDC_PRESET_DELETION_DELETE;
            text = "Delete";
            tooltip = "Permanently remove this preset from the profile library after archiving its current revision";
            x = "safeZoneX + 0.33 * safeZoneW";
            y = "safeZoneY + 0.555 * safeZoneH";
            w = "0.16 * safeZoneW";
            h = "0.05 * safeZoneH";
            colorBackground[] = {0.45, 0.12, 0.12, 0.95};
            colorBackground2[] = {0.45, 0.12, 0.12, 0.95};
            onButtonClick = "ctrlParent (_this select 0) call RACA_fnc_confirmPresetDeletion";
        };
        class Cancel: Delete {
            idc = 2;
            text = "Cancel";
            tooltip = "Keep the preset";
            x = "safeZoneX + 0.51 * safeZoneW";
            colorBackground[] = {0.12, 0.13, 0.14, 0.95};
            colorBackground2[] = {0.12, 0.13, 0.14, 0.95};
            onButtonClick = "ctrlParent (_this select 0) closeDisplay 2";
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
            colorBackground[] = {0.055, 0.06, 0.07, 0.99};
            colorBackground2[] = {0.055, 0.06, 0.07, 0.99};
        };
        class Title: RscText {
            idc = -1;
            text = "Quick Start";
            style = 2;
            font = "PuristaSemibold";
            sizeEx = "0.038 * safeZoneH";
            x = "safeZoneX + 0.14 * safeZoneW";
            y = "safeZoneY + 0.07 * safeZoneH";
            w = "0.72 * safeZoneW";
            h = "0.05 * safeZoneH";
            colorBackground[] = {"(profileNamespace getVariable ['GUI_BCG_RGB_R',0.19])", "(profileNamespace getVariable ['GUI_BCG_RGB_G',0.42])", "(profileNamespace getVariable ['GUI_BCG_RGB_B',0.19])", 0.95};
            colorBackground2[] = {"(profileNamespace getVariable ['GUI_BCG_RGB_R',0.19])", "(profileNamespace getVariable ['GUI_BCG_RGB_G',0.42])", "(profileNamespace getVariable ['GUI_BCG_RGB_B',0.19])", 0.95};
        };
    };
    class controls {
        class Help: RscText {
            idc = RACA_IDC_QUICK_HELP;
            text = "1. Name your arsenal.  2. Select Generate Draft.  3. Review Arsenal Contents, then save or export it. With Optional Settings closed, you start with a blank arsenal.";
            style = 16;
            x = "safeZoneX + 0.15 * safeZoneW";
            y = "safeZoneY + 0.14 * safeZoneH";
            w = "0.70 * safeZoneW";
            h = "0.09 * safeZoneH";
            colorBackground[] = {0, 0, 0, 0.25};
            colorBackground2[] = {0, 0, 0, 0.25};
        };
        class NameLabel: RscText {
            idc = -1;
            text = "1. Name this arsenal draft";
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
        class Settings: RACA_Button {
            idc = RACA_IDC_QUICK_SETTINGS;
            text = "Open Optional Settings";
            x = "safeZoneX + 0.16 * safeZoneW";
            y = "safeZoneY + 0.355 * safeZoneH";
            w = "0.32 * safeZoneW";
            h = "0.04 * safeZoneH";
            colorBackground[] = {0.19, 0.20, 0.23, 0.98};
            colorBackground2[] = {0.19, 0.20, 0.23, 0.98};
            onButtonClick = "ctrlParent (_this select 0) call RACA_fnc_toggleQuickSettings";
        };

        class RoleLabel: NameLabel {
            idc = RACA_IDC_QUICK_ROLE_LABEL;
            text = "Optional role starter or custom pack";
            y = "safeZoneY + 0.415 * safeZoneH";
        };
        class Role: RscCombo {
            idc = RACA_IDC_QUICK_ROLE;
            x = "safeZoneX + 0.16 * safeZoneW";
            y = "safeZoneY + 0.45 * safeZoneH";
            w = "0.25 * safeZoneW";
            h = "0.04 * safeZoneH";
        };
        class SourceLabel: NameLabel {
            idc = RACA_IDC_QUICK_SOURCE_LABEL;
            text = "Optional source-mod boundary";
            y = "safeZoneY + 0.51 * safeZoneH";
        };
        class Source: Role {
            idc = RACA_IDC_QUICK_SOURCE;
            y = "safeZoneY + 0.545 * safeZoneH";
            w = "0.32 * safeZoneW";
            tooltip = "";
        };
        class ParameterHelp: Help {
            idc = RACA_IDC_QUICK_PARAMETER_HELP;
            text = "Settings are optional. A role provides a useful starting point; policies then add or remove common item types. You will always review the result before saving.";
            x = "safeZoneX + 0.16 * safeZoneW";
            y = "safeZoneY + 0.605 * safeZoneH";
            w = "0.32 * safeZoneW";
            h = "0.12 * safeZoneH";
        };
        class OpticsLabel: NameLabel {
            idc = RACA_IDC_QUICK_OPTICS_LABEL;
            text = "Optic policy";
            x = "safeZoneX + 0.52 * safeZoneW";
            y = "safeZoneY + 0.415 * safeZoneH";
        };
        class Optics: Role {
            idc = RACA_IDC_QUICK_OPTICS;
            x = "safeZoneX + 0.52 * safeZoneW";
            y = "safeZoneY + 0.45 * safeZoneH";
        };
        class SuppressorLabel: OpticsLabel {
            idc = RACA_IDC_QUICK_SUPPRESSORS_LABEL;
            text = "Suppressor policy";
            y = "safeZoneY + 0.51 * safeZoneH";
        };
        class Suppressors: Optics {
            idc = RACA_IDC_QUICK_SUPPRESSORS;
            y = "safeZoneY + 0.545 * safeZoneH";
        };
        class NvgLabel: OpticsLabel {
            idc = RACA_IDC_QUICK_NVG_LABEL;
            text = "Night-vision policy";
            y = "safeZoneY + 0.605 * safeZoneH";
        };
        class Nvg: Optics {
            idc = RACA_IDC_QUICK_NVG;
            y = "safeZoneY + 0.64 * safeZoneH";
        };
        class MedicalLabel: OpticsLabel {
            idc = RACA_IDC_QUICK_MEDICAL_LABEL;
            text = "Medical policy";
            y = "safeZoneY + 0.70 * safeZoneH";
        };
        class Medical: Optics {
            idc = RACA_IDC_QUICK_MEDICAL;
            y = "safeZoneY + 0.735 * safeZoneH";
        };
        class GeneratorNote: ParameterHelp {
            idc = RACA_IDC_QUICK_GENERATOR_NOTE;
            text = "Your settings are remembered next time.";
            x = "safeZoneX + 0.52 * safeZoneW";
            y = "safeZoneY + 0.785 * safeZoneH";
            w = "0.32 * safeZoneW";
            h = "0.03 * safeZoneH";
        };

        class RolePacks: RACA_Button {
            idc = RACA_IDC_ROLE_PACKS_BUTTON;
            text = "Packs";
            tooltip = "Create and manage custom role packs";
            x = "safeZoneX + 0.42 * safeZoneW";
            y = "safeZoneY + 0.45 * safeZoneH";
            w = "0.06 * safeZoneW";
            h = "0.04 * safeZoneH";
            colorBackground[] = {0.19, 0.20, 0.23, 0.98};
            colorBackground2[] = {0.19, 0.20, 0.23, 0.98};
            onButtonClick = "ctrlParent (_this select 0) call RACA_fnc_openRolePacks";
        };
        class Create: RACA_Button {
            idc = RACA_IDC_QUICK_CREATE;
            text = "2. Generate Draft";
            x = "safeZoneX + 0.16 * safeZoneW";
            y = "safeZoneY + 0.83 * safeZoneH";
            w = "0.32 * safeZoneW";
            h = "0.05 * safeZoneH";
            colorBackground[] = {"(profileNamespace getVariable ['GUI_BCG_RGB_R',0.19])", "(profileNamespace getVariable ['GUI_BCG_RGB_G',0.42])", "(profileNamespace getVariable ['GUI_BCG_RGB_B',0.19])", 0.95};
            colorBackground2[] = {"(profileNamespace getVariable ['GUI_BCG_RGB_R',0.19])", "(profileNamespace getVariable ['GUI_BCG_RGB_G',0.42])", "(profileNamespace getVariable ['GUI_BCG_RGB_B',0.19])", 0.95};
            onButtonClick = "ctrlParent (_this select 0) call RACA_fnc_quickStartApply";
        };
        class Cancel: Create {
            idc = 2;
            text = "Cancel";
            x = "safeZoneX + 0.52 * safeZoneW";
            w = "0.32 * safeZoneW";
            colorBackground[] = {0.12, 0.13, 0.14, 0.95};
            colorBackground2[] = {0.12, 0.13, 0.14, 0.95};
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
            colorBackground2[] = {0.02, 0.025, 0.03, 0.98};
        };
        class Title: RscText {
            idc = -1;
            text = "Preset Revision History";
            style = 2;
            x = "safeZoneX + 0.14 * safeZoneW";
            y = "safeZoneY + 0.12 * safeZoneH";
            w = "0.72 * safeZoneW";
            h = "0.05 * safeZoneH";
            colorBackground[] = {"(profileNamespace getVariable ['GUI_BCG_RGB_R',0.19])", "(profileNamespace getVariable ['GUI_BCG_RGB_G',0.42])", "(profileNamespace getVariable ['GUI_BCG_RGB_B',0.19])", 0.95};
            colorBackground2[] = {"(profileNamespace getVariable ['GUI_BCG_RGB_R',0.19])", "(profileNamespace getVariable ['GUI_BCG_RGB_G',0.42])", "(profileNamespace getVariable ['GUI_BCG_RGB_B',0.19])", 0.95};
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
            colorBackground2[] = {0, 0, 0, 0.45};
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
            colorBackground2[] = {0, 0, 0, 0.35};
        };
        class Restore: RACA_Button {
            idc = RACA_IDC_HISTORY_RESTORE;
            text = "Restore As New Revision";
            x = "safeZoneX + 0.14 * safeZoneW";
            y = "safeZoneY + 0.78 * safeZoneH";
            w = "0.30 * safeZoneW";
            h = "0.05 * safeZoneH";
            colorBackground[] = {"(profileNamespace getVariable ['GUI_BCG_RGB_R',0.19])", "(profileNamespace getVariable ['GUI_BCG_RGB_G',0.42])", "(profileNamespace getVariable ['GUI_BCG_RGB_B',0.19])", 0.95};
            colorBackground2[] = {"(profileNamespace getVariable ['GUI_BCG_RGB_R',0.19])", "(profileNamespace getVariable ['GUI_BCG_RGB_G',0.42])", "(profileNamespace getVariable ['GUI_BCG_RGB_B',0.19])", 0.95};
            onButtonClick = "ctrlParent (_this select 0) spawn RACA_fnc_restorePresetRevision";
        };
        class Close: Restore {
            idc = 2;
            text = "Close";
            x = "safeZoneX + 0.71 * safeZoneW";
            w = "0.15 * safeZoneW";
            colorBackground[] = {0.12, 0.13, 0.14, 0.95};
            colorBackground2[] = {0.12, 0.13, 0.14, 0.95};
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
            colorBackground2[] = {0.02, 0.025, 0.03, 0.98};
        };
        class Title: RscText {
            idc = -1;
            text = "RACA Runtime Administration";
            style = 2;
            x = "safeZoneX + 0.05 * safeZoneW";
            y = "safeZoneY + 0.055 * safeZoneH";
            w = "0.90 * safeZoneW";
            h = "0.05 * safeZoneH";
            colorBackground[] = {"(profileNamespace getVariable ['GUI_BCG_RGB_R',0.19])", "(profileNamespace getVariable ['GUI_BCG_RGB_G',0.42])", "(profileNamespace getVariable ['GUI_BCG_RGB_B',0.19])", 0.95};
            colorBackground2[] = {"(profileNamespace getVariable ['GUI_BCG_RGB_R',0.19])", "(profileNamespace getVariable ['GUI_BCG_RGB_G',0.42])", "(profileNamespace getVariable ['GUI_BCG_RGB_B',0.19])", 0.95};
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
            colorBackground2[] = {0.12, 0.13, 0.14, 0.95};
        };
        class Objects: RscListNBox {
            idc = RACA_IDC_ADMIN_OBJECTS;
            x = "safeZoneX + 0.05 * safeZoneW";
            y = "safeZoneY + 0.16 * safeZoneH";
            w = "0.90 * safeZoneW";
            h = "0.27 * safeZoneH";
            columns[] = {0.01, 0.18, 0.37, 0.82, 0.91};
            colorBackground[] = {0, 0, 0, 0.45};
            colorBackground2[] = {0, 0, 0, 0.45};
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
        class Refresh: RACA_Button {
            idc = RACA_IDC_ADMIN_REFRESH;
            text = "Refresh";
            x = "safeZoneX + 0.05 * safeZoneW";
            y = "safeZoneY + 0.785 * safeZoneH";
            w = "0.10 * safeZoneW";
            h = "0.045 * safeZoneH";
            onButtonClick = "[ctrlParent (_this select 0), 'refresh'] spawn RACA_fnc_adminExecute";
        };
        class ResetAll: Refresh {
            idc = RACA_IDC_ADMIN_RESET_ALL;
            text = "Reset All Quotas";
            x = "safeZoneX + 0.16 * safeZoneW";
            w = "0.14 * safeZoneW";
            onButtonClick = "[ctrlParent (_this select 0), 'resetquotas'] spawn RACA_fnc_adminExecute";
        };
        class ResetObject: Refresh {
            idc = RACA_IDC_ADMIN_RESET_OBJECT;
            text = "Reset Object";
            x = "safeZoneX + 0.31 * safeZoneW";
            w = "0.12 * safeZoneW";
            onButtonClick = "[ctrlParent (_this select 0), 'resetobject'] spawn RACA_fnc_adminExecute";
        };
        class Enable: Refresh {
            idc = RACA_IDC_ADMIN_ENABLE;
            text = "Enable";
            x = "safeZoneX + 0.44 * safeZoneW";
            w = "0.09 * safeZoneW";
            onButtonClick = "[ctrlParent (_this select 0), 'enable'] spawn RACA_fnc_adminExecute";
        };
        class Disable: Enable {
            idc = RACA_IDC_ADMIN_DISABLE;
            text = "Disable";
            x = "safeZoneX + 0.54 * safeZoneW";
            onButtonClick = "[ctrlParent (_this select 0), 'disable'] spawn RACA_fnc_adminExecute";
        };
        class Clear: Enable {
            idc = RACA_IDC_ADMIN_CLEAR;
            text = "Clear";
            x = "safeZoneX + 0.64 * safeZoneW";
            colorBackground[] = {0.45, 0.12, 0.12, 0.9};
            colorBackground2[] = {0.45, 0.12, 0.12, 0.9};
            onButtonClick = "[ctrlParent (_this select 0), 'clear'] spawn RACA_fnc_adminExecute";
        };
        class CopyAudit: Refresh {
            idc = RACA_IDC_ADMIN_COPY_AUDIT;
            text = "Copy Audit";
            x = "safeZoneX + 0.74 * safeZoneW";
            w = "0.10 * safeZoneW";
            onButtonClick = "ctrlParent (_this select 0) call RACA_fnc_adminCopyAudit";
        };
        class Close: Refresh {
            idc = 2;
            text = "Close";
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
            colorBackground2[] = {0, 0, 0, 0.45};
        };
        class Rehearsal: Refresh {
            idc = RACA_IDC_ADMIN_REHEARSAL;
            text = "MP Rehearsal";
            tooltip = "Open the guided host, client, and join-in-progress synchronization rehearsal";
            x = "safeZoneX + 0.05 * safeZoneW";
            y = "safeZoneY + 0.85 * safeZoneH";
            w = "0.14 * safeZoneW";
            h = "0.06 * safeZoneH";
            colorBackground[] = {"(profileNamespace getVariable ['GUI_BCG_RGB_R',0.19])", "(profileNamespace getVariable ['GUI_BCG_RGB_G',0.42])", "(profileNamespace getVariable ['GUI_BCG_RGB_B',0.19])", 0.95};
            colorBackground2[] = {"(profileNamespace getVariable ['GUI_BCG_RGB_R',0.19])", "(profileNamespace getVariable ['GUI_BCG_RGB_G',0.42])", "(profileNamespace getVariable ['GUI_BCG_RGB_B',0.19])", 0.95};
            onButtonClick = "ctrlParent (_this select 0) call RACA_fnc_openRehearsal";
        };
    };
};

class RACA_RscDisplayPreflight {
    idd = RACA_IDD_PREFLIGHT;
    movingEnable = 0;
    enableSimulation = 1;
    onLoad = "(_this select 0) call RACA_fnc_preflightOnLoad";
    onUnload = "uiNamespace setVariable ['RACA_preflightParent', displayNull]; uiNamespace setVariable ['RACA_preflightDisplay', displayNull]";

    class controlsBackground {
        class Background: RscText {
            idc = -1;
            x = "safeZoneX + 0.07 * safeZoneW";
            y = "safeZoneY + 0.07 * safeZoneH";
            w = "0.86 * safeZoneW";
            h = "0.86 * safeZoneH";
            colorBackground[] = {0.02, 0.025, 0.03, 0.99};
            colorBackground2[] = {0.02, 0.025, 0.03, 0.99};
        };
        class Header: RscText {
            idc = -1;
            text = "Compatibility Check";
            font = "PuristaSemibold";
            sizeEx = "0.034 * safeZoneH";
            style = 2;
            x = "safeZoneX + 0.0982 * safeZoneW";
            y = "safeZoneY + 0.09 * safeZoneH";
            w = "0.82 * safeZoneW";
            h = "0.05 * safeZoneH";
            colorBackground[] = {"(profileNamespace getVariable ['GUI_BCG_RGB_R',0.19])", "(profileNamespace getVariable ['GUI_BCG_RGB_G',0.42])", "(profileNamespace getVariable ['GUI_BCG_RGB_B',0.19])", 0.95};
            colorBackground2[] = {"(profileNamespace getVariable ['GUI_BCG_RGB_R',0.19])", "(profileNamespace getVariable ['GUI_BCG_RGB_G',0.42])", "(profileNamespace getVariable ['GUI_BCG_RGB_B',0.19])", 0.95};
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
            colorBackground2[] = {0, 0, 0, 0.45};
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
            onLBSelChanged = "if !(ctrlParent (_this select 0) getVariable ['RACA_preflightFilterSuppressed', false]) then {ctrlParent (_this select 0) call RACA_fnc_preflightRefresh}";
        };
        class ListHeading: RscText {
            idc = -1;
            font = "PuristaMedium";
            text = "Severity";
            style = 2;
            x = "safeZoneX + 0.09 * safeZoneW";
            y = "safeZoneY + 0.30 * safeZoneH";
            w = "0.0656 * safeZoneW";
            h = "0.035 * safeZoneH";
            colorBackground[] = {0.12, 0.13, 0.14, 0.95};
            colorBackground2[] = {0.12, 0.13, 0.14, 0.95};
        };
        class CodeHeading: ListHeading {text = "Code"; x = "safeZoneX + 0.1638 * safeZoneW"; w = "0.0902 * safeZoneW";};
        class MessageHeading: ListHeading {text = "Message"; x = "safeZoneX + 0.254 * safeZoneW"; w = "0.2706 * safeZoneW";};
        class ClassHeading: ListHeading {text = "Class"; x = "safeZoneX + 0.5246 * safeZoneW"; w = "0.2214 * safeZoneW";};
        class SourceHeading: ListHeading {text = "Source Mod / Add-on"; x = "safeZoneX + 0.746 * safeZoneW"; w = "0.164 * safeZoneW";};
        class Entries: RscListNBox {
            idc = RACA_IDC_PREFLIGHT_LIST;
            x = "safeZoneX + 0.09 * safeZoneW";
            y = "safeZoneY + 0.34 * safeZoneH";
            w = "0.82 * safeZoneW";
            h = "0.27 * safeZoneH";
            columns[] = {0.01, 0.09, 0.20, 0.53, 0.80};
            colorBackground[] = {0, 0, 0, 0.45};
            colorBackground2[] = {0, 0, 0, 0.45};
            onLBSelChanged = "(_this select 0) call RACA_fnc_preflightSelectionChanged";
            onLBDblClick = "ctrlParent (_this select 0) call RACA_fnc_preflightSelect";
        };
        class ResultDetailsScroll: RscControlsGroup {
            idc = 1811;
            x = "safeZoneX + 0.09 * safeZoneW";
            y = "safeZoneY + 0.62 * safeZoneH";
            w = "0.82 * safeZoneW";
            h = "0.15 * safeZoneH";
            class controls {
                class ResultDetails: RscText {
                    idc = RACA_IDC_PREFLIGHT_DETAILS;
                    text = "Select a compatibility result to read its complete details.";
                    style = 16;
                    font = "PuristaMedium";
                    sizeEx = "0.022 * safeZoneH";
                    x = 0;
                    y = 0;
                    w = "0.795 * safeZoneW";
                    h = "0.15 * safeZoneH";
                    colorBackground[] = {0, 0, 0, 0.45};
                    colorBackground2[] = {0, 0, 0, 0.45};
                };
            };
        };
        class ShowItem: RACA_Button {
            idc = RACA_IDC_PREFLIGHT_SHOW_ITEM;
            text = "Show Available Item";
            tooltip = "Switch to Assignment and select the affected class when it exists in the loaded catalogue";
            x = "safeZoneX + 0.09 * safeZoneW";
            y = "safeZoneY + 0.80 * safeZoneH";
            w = "0.18 * safeZoneW";
            h = "0.05 * safeZoneH";
            onButtonClick = "ctrlParent (_this select 0) call RACA_fnc_preflightSelect";
        };
        class RemoveUnavailable: ShowItem {
            idc = RACA_IDC_PREFLIGHT_REMOVE_UNAVAILABLE;
            text = "Remove Unavailable Item";
            tooltip = "Deliberately remove this unavailable authored class from the draft; Undo restores it";
            x = "safeZoneX + 0.09 * safeZoneW";
            w = "0.18 * safeZoneW";
            colorBackground[] = {0.38, 0.12, 0.12, 1};
            colorBackground2[] = {0.38, 0.12, 0.12, 1};
            onButtonClick = "ctrlParent (_this select 0) spawn RACA_fnc_preflightRemoveUnavailable";
        };
        class Rerun: ShowItem {
            idc = RACA_IDC_PREFLIGHT_RERUN;
            text = "Check Again";
            tooltip = "Repeat compatibility analysis for the current draft";
            x = "safeZoneX + 0.28 * safeZoneW";
            w = "0.15 * safeZoneW";
            onButtonClick = "ctrlParent (_this select 0) call RACA_fnc_preflightRerun";
        };
        class Copy: Rerun {
            idc = RACA_IDC_PREFLIGHT_COPY;
            text = "Copy Report";
            tooltip = "Copy the complete compatibility report to the clipboard";
            x = "safeZoneX + 0.44 * safeZoneW";
            onButtonClick = "ctrlParent (_this select 0) call RACA_fnc_preflightCopy";
        };
        class Close: Rerun {
            idc = 2;
            text = "Close";
            tooltip = "Close the compatibility report";
            x = "safeZoneX + 0.76 * safeZoneW";
            colorBackground[] = {0.12, 0.13, 0.14, 0.95};
            colorBackground2[] = {0.12, 0.13, 0.14, 0.95};
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
            colorBackground2[] = {0.02, 0.025, 0.03, 0.99};
        };
        class Header: RscText {
            idc = -1;
            text = "Saved Filters";
            style = 2;
            font = "PuristaSemibold";
            sizeEx = "0.034 * safeZoneH";
            x = "safeZoneX + 0.09 * safeZoneW";
            y = "safeZoneY + 0.09 * safeZoneH";
            w = "0.82 * safeZoneW";
            h = "0.05 * safeZoneH";
            colorBackground[] = {"(profileNamespace getVariable ['GUI_BCG_RGB_R',0.19])", "(profileNamespace getVariable ['GUI_BCG_RGB_G',0.42])", "(profileNamespace getVariable ['GUI_BCG_RGB_B',0.19])", 0.95};
            colorBackground2[] = {"(profileNamespace getVariable ['GUI_BCG_RGB_R',0.19])", "(profileNamespace getVariable ['GUI_BCG_RGB_G',0.42])", "(profileNamespace getVariable ['GUI_BCG_RGB_B',0.19])", 0.95};
        };
    };

    class controls {
        class Help: RscText {
            idc = -1;
            text = "Saved Filters never change your arsenal items.  1. Set up a search in Arsenal Contents.  2. Enter a name below.  3. Save it. Later, select one and choose Apply.";
            style = 16;
            x = "safeZoneX + 0.09 * safeZoneW";
            y = "safeZoneY + 0.15 * safeZoneH";
            w = "0.82 * safeZoneW";
            h = "0.065 * safeZoneH";
            colorBackground[] = {0, 0, 0, 0.35};
            colorBackground2[] = {0, 0, 0, 0.35};
        };
        class NameLabel: RscText {
            idc = -1;
            text = "Filter name";
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
        class Capture: RACA_Button {
            idc = RACA_IDC_SAVED_VIEW_CAPTURE;
            text = "Save Current Filters";
            tooltip = "Save the current search, category, advanced filters, and sort order under this name; arsenal contents are unaffected";
            x = "safeZoneX + 0.68 * safeZoneW";
            y = "safeZoneY + 0.23 * safeZoneH";
            w = "0.23 * safeZoneW";
            h = "0.04 * safeZoneH";
            colorBackground[] = {"(profileNamespace getVariable ['GUI_BCG_RGB_R',0.19])", "(profileNamespace getVariable ['GUI_BCG_RGB_G',0.42])", "(profileNamespace getVariable ['GUI_BCG_RGB_B',0.19])", 0.95};
            colorBackground2[] = {"(profileNamespace getVariable ['GUI_BCG_RGB_R',0.19])", "(profileNamespace getVariable ['GUI_BCG_RGB_G',0.42])", "(profileNamespace getVariable ['GUI_BCG_RGB_B',0.19])", 0.95};
            onButtonClick = "ctrlParent (_this select 0) call RACA_fnc_savedCatalogViewCapture";
        };
        class ListHeading: RscText {
            idc = -1;
            text = "Name                  Search              Category       Mod          Add-on       Author       Tag          Sort";
            x = "safeZoneX + 0.09 * safeZoneW";
            y = "safeZoneY + 0.29 * safeZoneH";
            w = "0.82 * safeZoneW";
            h = "0.035 * safeZoneH";
            colorBackground[] = {0.12, 0.13, 0.14, 0.95};
            colorBackground2[] = {0.12, 0.13, 0.14, 0.95};
        };
        class Views: RscListNBox {
            idc = RACA_IDC_SAVED_VIEW_LIST;
            x = "safeZoneX + 0.09 * safeZoneW";
            y = "safeZoneY + 0.33 * safeZoneH";
            w = "0.82 * safeZoneW";
            h = "0.41 * safeZoneH";
            columns[] = {0.01, 0.16, 0.30, 0.42, 0.53, 0.64, 0.74, 0.85};
            colorBackground[] = {0, 0, 0, 0.45};
            colorBackground2[] = {0, 0, 0, 0.45};
            onLBSelChanged = "(_this select 0) call RACA_fnc_savedCatalogViewSelect";
            onLBDblClick = "ctrlParent (_this select 0) call RACA_fnc_savedCatalogViewApply";
        };
        class Details: RscText {
            idc = RACA_IDC_SAVED_VIEW_DETAILS;
            text = "No saved filters yet. Set up Arsenal Contents, enter a name above, then choose Save Current Filters.";
            style = 16;
            x = "safeZoneX + 0.09 * safeZoneW";
            y = "safeZoneY + 0.755 * safeZoneH";
            w = "0.82 * safeZoneW";
            h = "0.075 * safeZoneH";
            colorBackground[] = {0, 0, 0, 0.35};
            colorBackground2[] = {0, 0, 0, 0.35};
        };
        class Apply: RACA_Button {
            idc = RACA_IDC_SAVED_VIEW_APPLY;
            text = "Apply Selected Filters";
            tooltip = "Restore only search, filters, and sort order; arsenal contents are not changed";
            x = "safeZoneX + 0.09 * safeZoneW";
            y = "safeZoneY + 0.85 * safeZoneH";
            w = "0.20 * safeZoneW";
            h = "0.05 * safeZoneH";
            colorBackground[] = {"(profileNamespace getVariable ['GUI_BCG_RGB_R',0.19])", "(profileNamespace getVariable ['GUI_BCG_RGB_G',0.42])", "(profileNamespace getVariable ['GUI_BCG_RGB_B',0.19])", 0.95};
            colorBackground2[] = {"(profileNamespace getVariable ['GUI_BCG_RGB_R',0.19])", "(profileNamespace getVariable ['GUI_BCG_RGB_G',0.42])", "(profileNamespace getVariable ['GUI_BCG_RGB_B',0.19])", 0.95};
            onButtonClick = "ctrlParent (_this select 0) call RACA_fnc_savedCatalogViewApply";
        };
        class Delete: Apply {
            idc = RACA_IDC_SAVED_VIEW_DELETE;
            text = "Delete Filter";
            tooltip = "Delete only the selected saved filter after confirmation";
            x = "safeZoneX + 0.31 * safeZoneW";
            w = "0.15 * safeZoneW";
            colorBackground[] = {0.45, 0.12, 0.12, 0.9};
            colorBackground2[] = {0.45, 0.12, 0.12, 0.9};
            onButtonClick = "ctrlParent (_this select 0) call RACA_fnc_savedCatalogViewDelete";
        };
        class Close: Apply {
            idc = 2;
            text = "Close";
            x = "safeZoneX + 0.76 * safeZoneW";
            w = "0.15 * safeZoneW";
            colorBackground[] = {0.12, 0.13, 0.14, 0.95};
            colorBackground2[] = {0.12, 0.13, 0.14, 0.95};
            onButtonClick = "ctrlParent (_this select 0) closeDisplay 2";
        };
    };
};

class RACA_RscDisplayItemDetails {
    idd = RACA_IDD_ITEM_DETAILS;
    movingEnable = 0;
    enableSimulation = 1;
    onLoad = "(_this select 0) call RACA_fnc_itemDetailsOnLoad";
    onUnload = "(_this select 0) call RACA_fnc_itemDetailsOnUnload";

    class controlsBackground {
        class Background: RscText {
            idc = -1;
            x = "safeZoneX + 0.18 * safeZoneW";
            y = "safeZoneY + 0.10 * safeZoneH";
            w = "0.64 * safeZoneW";
            h = "0.80 * safeZoneH";
            colorBackground[] = {0.02, 0.025, 0.03, 0.99};
            colorBackground2[] = {0.02, 0.025, 0.03, 0.99};
        };
        class Header: RscText {
            idc = RACA_IDC_ITEM_DETAILS_TITLE;
            text = "Item Details";
            font = "PuristaSemibold";
            sizeEx = "0.028 * safeZoneH";
            style = 2;
            x = "safeZoneX + 0.20 * safeZoneW";
            y = "safeZoneY + 0.12 * safeZoneH";
            w = "0.60 * safeZoneW";
            h = "0.05 * safeZoneH";
            colorBackground[] = {"(profileNamespace getVariable ['GUI_BCG_RGB_R',0.19])", "(profileNamespace getVariable ['GUI_BCG_RGB_G',0.42])", "(profileNamespace getVariable ['GUI_BCG_RGB_B',0.19])", 0.95};
            colorBackground2[] = {"(profileNamespace getVariable ['GUI_BCG_RGB_R',0.19])", "(profileNamespace getVariable ['GUI_BCG_RGB_G',0.42])", "(profileNamespace getVariable ['GUI_BCG_RGB_B',0.19])", 0.95};
        };
    };

    class controls {
        class Picture: RscPicture {
            style = 48 + 2048;
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
            colorBackground2[] = {0, 0, 0, 0.25};
        };
        class DetailsScroll: RscControlsGroup {
            idc = 1810;
            x = "safeZoneX + 0.39 * safeZoneW";
            y = "safeZoneY + 0.19 * safeZoneH";
            w = "0.40 * safeZoneW";
            h = "0.46 * safeZoneH";
            class controls {
                class Details: RscText {
                    idc = RACA_IDC_ITEM_DETAILS_TEXT;
                    text = "Loading item metadata...";
                    style = 16;
                    font = "PuristaMedium";
                    sizeEx = "0.024 * safeZoneH";
                    x = 0; y = 0;
                    w = "0.375 * safeZoneW";
                    h = "0.46 * safeZoneH";
                };
            };
        };
        class ShowMagazines: RACA_PrimaryButton {
            idc = RACA_IDC_SHOW_MAGAZINES;
            text = "Show Magazines";
            x = "safeZoneX + 0.21 * safeZoneW";
            y = "safeZoneY + 0.59 * safeZoneH";
            w = "0.16 * safeZoneW";
            h = "0.05 * safeZoneH";
            onButtonClick = "ctrlParent (_this select 0) call RACA_fnc_showMagazines";
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
            colorBackground2[] = {0, 0, 0, 0.35};
        };
        class Include: RACA_Button {
            idc = RACA_IDC_ITEM_DETAILS_INCLUDE;
            text = "Include Item";
            x = "safeZoneX + 0.21 * safeZoneW";
            y = "safeZoneY + 0.78 * safeZoneH";
            w = "0.14 * safeZoneW";
            h = "0.05 * safeZoneH";
            colorBackground[] = {"(profileNamespace getVariable ['GUI_BCG_RGB_R',0.19])", "(profileNamespace getVariable ['GUI_BCG_RGB_G',0.42])", "(profileNamespace getVariable ['GUI_BCG_RGB_B',0.19])", 0.95};
            colorBackground2[] = {"(profileNamespace getVariable ['GUI_BCG_RGB_R',0.19])", "(profileNamespace getVariable ['GUI_BCG_RGB_G',0.42])", "(profileNamespace getVariable ['GUI_BCG_RGB_B',0.19])", 0.95};
            onButtonClick = "ctrlParent (_this select 0) call RACA_fnc_itemDetailsToggleIncluded";
        };
        class Favorite: Include {
            idc = RACA_IDC_ITEM_DETAILS_FAVORITE;
            text = "Add Favorite";
            x = "safeZoneX + 0.36 * safeZoneW";
            colorBackground[] = {0.34, 0.29, 0.08, 0.95};
            colorBackground2[] = {0.34, 0.29, 0.08, 0.95};
            onButtonClick = "ctrlParent (_this select 0) call RACA_fnc_itemDetailsToggleFavorite";
        };
        class Copy: Include {
            idc = RACA_IDC_ITEM_DETAILS_COPY;
            text = "Copy Details";
            x = "safeZoneX + 0.51 * safeZoneW";
            colorBackground[] = {0.12, 0.13, 0.14, 0.95};
            colorBackground2[] = {0.12, 0.13, 0.14, 0.95};
            onButtonClick = "ctrlParent (_this select 0) call RACA_fnc_itemDetailsCopy";
        };
        class Close: Include {
            idc = 2;
            text = "Close";
            x = "safeZoneX + 0.66 * safeZoneW";
            w = "0.13 * safeZoneW";
            colorBackground[] = {0.12, 0.13, 0.14, 0.95};
            colorBackground2[] = {0.12, 0.13, 0.14, 0.95};
            onButtonClick = "ctrlParent (_this select 0) closeDisplay 2";
        };
    };
};

class RACA_RscDisplayRolePacks {
    idd = RACA_IDD_ROLE_PACKS;
    movingEnable = 0;
    enableSimulation = 1;
    onLoad = "(_this select 0) call RACA_fnc_rolePackOnLoad";
    onUnload = "uiNamespace setVariable ['RACA_rolePacksParent', displayNull]; uiNamespace setVariable ['RACA_rolePacksReturn', displayNull]";

    class controlsBackground {
        class Background: RscText {
            idc = -1;
            x = "safeZoneX + 0.10 * safeZoneW";
            y = "safeZoneY + 0.08 * safeZoneH";
            w = "0.80 * safeZoneW";
            h = "0.84 * safeZoneH";
            colorBackground[] = {0.055, 0.06, 0.07, 0.99};
            colorBackground2[] = {0.055, 0.06, 0.07, 0.99};
        };
        class Header: RscText {
            idc = -1;
            text = "Custom Unit Role Packs";
            style = 2;
            font = "PuristaSemibold";
            sizeEx = "0.036 * safeZoneH";
            x = "safeZoneX + 0.12 * safeZoneW";
            y = "safeZoneY + 0.10 * safeZoneH";
            w = "0.76 * safeZoneW";
            h = "0.05 * safeZoneH";
            colorBackground[] = {"(profileNamespace getVariable ['GUI_BCG_RGB_R',0.19])", "(profileNamespace getVariable ['GUI_BCG_RGB_G',0.42])", "(profileNamespace getVariable ['GUI_BCG_RGB_B',0.19])", 0.95};
            colorBackground2[] = {"(profileNamespace getVariable ['GUI_BCG_RGB_R',0.19])", "(profileNamespace getVariable ['GUI_BCG_RGB_G',0.42])", "(profileNamespace getVariable ['GUI_BCG_RGB_B',0.19])", 0.95};
        };
    };

    class controls {
        class Help: RscText {
            idc = -1;
            text = "Role packs are reusable starting points for Quick Start. Name the current Creator draft and save it as a pack; packs remain separate from saved arsenal presets.";
            style = 16;
            x = "safeZoneX + 0.12 * safeZoneW";
            y = "safeZoneY + 0.17 * safeZoneH";
            w = "0.76 * safeZoneW";
            h = "0.065 * safeZoneH";
            colorBackground[] = {0.12, 0.13, 0.15, 0.98};
            colorBackground2[] = {0.12, 0.13, 0.15, 0.98};
        };
        class NameLabel: RscText {
            idc = -1;
            text = "Pack Name";
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
        class Capture: RACA_Button {
            idc = RACA_IDC_ROLE_PACK_CAPTURE;
            text = "Save Current Draft";
            tooltip = "Store all currently included classes under this role-pack name";
            x = "safeZoneX + 0.66 * safeZoneW";
            y = "safeZoneY + 0.25 * safeZoneH";
            w = "0.22 * safeZoneW";
            h = "0.04 * safeZoneH";
            colorBackground[] = {"(profileNamespace getVariable ['GUI_BCG_RGB_R',0.19])", "(profileNamespace getVariable ['GUI_BCG_RGB_G',0.42])", "(profileNamespace getVariable ['GUI_BCG_RGB_B',0.19])", 0.95};
            colorBackground2[] = {"(profileNamespace getVariable ['GUI_BCG_RGB_R',0.19])", "(profileNamespace getVariable ['GUI_BCG_RGB_G',0.42])", "(profileNamespace getVariable ['GUI_BCG_RGB_B',0.19])", 0.95};
            onButtonClick = "ctrlParent (_this select 0) call RACA_fnc_rolePackCapture";
        };
        class DescriptionLabel: NameLabel {
            text = "Description (Optional)";
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
            text = "Saved Role Packs        Items        Description";
            font = "PuristaSemibold";
            x = "safeZoneX + 0.12 * safeZoneW";
            y = "safeZoneY + 0.365 * safeZoneH";
            w = "0.76 * safeZoneW";
            h = "0.035 * safeZoneH";
            colorBackground[] = {0.17, 0.18, 0.21, 0.98};
            colorBackground2[] = {0.17, 0.18, 0.21, 0.98};
        };
        class Packs: RscListNBox {
            idc = RACA_IDC_ROLE_PACK_LIST;
            x = "safeZoneX + 0.12 * safeZoneW";
            y = "safeZoneY + 0.405 * safeZoneH";
            w = "0.76 * safeZoneW";
            h = "0.30 * safeZoneH";
            columns[] = {0.01, 0.28, 0.38};
            colorBackground[] = {0.035, 0.04, 0.05, 0.98};
            colorBackground2[] = {0.035, 0.04, 0.05, 0.98};
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
            colorBackground[] = {0.12, 0.13, 0.15, 0.98};
            colorBackground2[] = {0.12, 0.13, 0.15, 0.98};
        };
        class Merge: RACA_Button {
            idc = RACA_IDC_ROLE_PACK_MERGE;
            text = "Merge Into Draft";
            tooltip = "Add available classes from the selected pack without removing current draft classes";
            x = "safeZoneX + 0.12 * safeZoneW";
            y = "safeZoneY + 0.82 * safeZoneH";
            w = "0.16 * safeZoneW";
            h = "0.05 * safeZoneH";
            colorBackground[] = {"(profileNamespace getVariable ['GUI_BCG_RGB_R',0.19])", "(profileNamespace getVariable ['GUI_BCG_RGB_G',0.42])", "(profileNamespace getVariable ['GUI_BCG_RGB_B',0.19])", 0.95};
            colorBackground2[] = {"(profileNamespace getVariable ['GUI_BCG_RGB_R',0.19])", "(profileNamespace getVariable ['GUI_BCG_RGB_G',0.42])", "(profileNamespace getVariable ['GUI_BCG_RGB_B',0.19])", 0.95};
            onButtonClick = "[ctrlParent (_this select 0), 'MERGE'] call RACA_fnc_rolePackApply";
        };
        class Replace: Merge {
            idc = RACA_IDC_ROLE_PACK_REPLACE;
            text = "Replace Draft";
            tooltip = "Replace current draft inclusion with the selected pack's available classes";
            x = "safeZoneX + 0.29 * safeZoneW";
            w = "0.18 * safeZoneW";
            onButtonClick = "[ctrlParent (_this select 0), 'REPLACE'] call RACA_fnc_rolePackApply";
        };
        class Delete: Merge {
            idc = RACA_IDC_ROLE_PACK_DELETE;
            text = "Delete Pack";
            tooltip = "Delete only this custom role pack after confirmation";
            x = "safeZoneX + 0.48 * safeZoneW";
            w = "0.14 * safeZoneW";
            colorBackground[] = {0.45, 0.12, 0.12, 0.9};
            colorBackground2[] = {0.45, 0.12, 0.12, 0.9};
            onButtonClick = "ctrlParent (_this select 0) call RACA_fnc_rolePackDelete";
        };
        class Close: Merge {
            idc = 2;
            text = "Return to Quick Start";
            x = "safeZoneX + 0.68 * safeZoneW";
            w = "0.20 * safeZoneW";
            colorBackground[] = {0.19, 0.20, 0.23, 0.98};
            colorBackground2[] = {0.19, 0.20, 0.23, 0.98};
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
            colorBackground2[] = {0.02, 0.025, 0.03, 0.99};
        };
        class Header: RscText {
            idc = -1;
            text = "RACA Multiplayer Rehearsal";
            style = 2;
            x = "safeZoneX + 0.07 * safeZoneW";
            y = "safeZoneY + 0.07 * safeZoneH";
            w = "0.86 * safeZoneW";
            h = "0.05 * safeZoneH";
            colorBackground[] = {"(profileNamespace getVariable ['GUI_BCG_RGB_R',0.19])", "(profileNamespace getVariable ['GUI_BCG_RGB_G',0.42])", "(profileNamespace getVariable ['GUI_BCG_RGB_B',0.19])", 0.95};
            colorBackground2[] = {"(profileNamespace getVariable ['GUI_BCG_RGB_R',0.19])", "(profileNamespace getVariable ['GUI_BCG_RGB_G',0.42])", "(profileNamespace getVariable ['GUI_BCG_RGB_B',0.19])", 0.95};
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
            colorBackground2[] = {0.42, 0.34, 0.08, 0.95};
        };
        class ListHeading: RscText {
            idc = -1;
            text = "ROLE       NAME                    UID                         OWNER    DEPS      OBJECTS   SLOTS     RESULT    ISSUES";
            x = "safeZoneX + 0.07 * safeZoneW";
            y = "safeZoneY + 0.25 * safeZoneH";
            w = "0.86 * safeZoneW";
            h = "0.035 * safeZoneH";
            colorBackground[] = {0.12, 0.13, 0.14, 0.95};
            colorBackground2[] = {0.12, 0.13, 0.14, 0.95};
        };
        class Participants: RscListNBox {
            idc = RACA_IDC_REHEARSAL_LIST;
            x = "safeZoneX + 0.07 * safeZoneW";
            y = "safeZoneY + 0.29 * safeZoneH";
            w = "0.86 * safeZoneW";
            h = "0.37 * safeZoneH";
            columns[] = {0.01, 0.09, 0.22, 0.39, 0.46, 0.54, 0.62, 0.70, 0.78};
            colorBackground[] = {0, 0, 0, 0.45};
            colorBackground2[] = {0, 0, 0, 0.45};
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
            colorBackground2[] = {0, 0, 0, 0.35};
        };
        class Start: RACA_Button {
            idc = RACA_IDC_REHEARSAL_START;
            text = "Start New";
            tooltip = "Start a new server-authoritative rehearsal and probe every currently connected interface client";
            x = "safeZoneX + 0.07 * safeZoneW";
            y = "safeZoneY + 0.82 * safeZoneH";
            w = "0.15 * safeZoneW";
            h = "0.05 * safeZoneH";
            colorBackground[] = {"(profileNamespace getVariable ['GUI_BCG_RGB_R',0.19])", "(profileNamespace getVariable ['GUI_BCG_RGB_G',0.42])", "(profileNamespace getVariable ['GUI_BCG_RGB_B',0.19])", 0.95};
            colorBackground2[] = {"(profileNamespace getVariable ['GUI_BCG_RGB_R',0.19])", "(profileNamespace getVariable ['GUI_BCG_RGB_G',0.42])", "(profileNamespace getVariable ['GUI_BCG_RGB_B',0.19])", 0.95};
            onButtonClick = "[ctrlParent (_this select 0), 'START'] call RACA_fnc_rehearsalExecute";
        };
        class Refresh: Start {
            idc = RACA_IDC_REHEARSAL_REFRESH;
            text = "Refresh Probes";
            tooltip = "Ask every connected interface client to re-check dependencies and local action registration";
            x = "safeZoneX + 0.23 * safeZoneW";
            w = "0.17 * safeZoneW";
            onButtonClick = "[ctrlParent (_this select 0), 'REFRESH'] call RACA_fnc_rehearsalExecute";
        };
        class Finish: Start {
            idc = RACA_IDC_REHEARSAL_FINISH;
            text = "Finalize";
            tooltip = "Stop accepting JIP probes and freeze the current rehearsal outcome";
            x = "safeZoneX + 0.41 * safeZoneW";
            w = "0.14 * safeZoneW";
            onButtonClick = "[ctrlParent (_this select 0), 'FINISH'] call RACA_fnc_rehearsalExecute";
        };
        class Copy: Start {
            idc = RACA_IDC_REHEARSAL_COPY;
            text = "Copy Report";
            tooltip = "Copy gate and participant evidence as a shareable text report";
            x = "safeZoneX + 0.56 * safeZoneW";
            w = "0.16 * safeZoneW";
            colorBackground[] = {0.12, 0.13, 0.14, 0.95};
            colorBackground2[] = {0.12, 0.13, 0.14, 0.95};
            onButtonClick = "ctrlParent (_this select 0) call RACA_fnc_rehearsalCopy";
        };
        class Close: Start {
            idc = 2;
            text = "Close";
            x = "safeZoneX + 0.78 * safeZoneW";
            w = "0.15 * safeZoneW";
            colorBackground[] = {0.12, 0.13, 0.14, 0.95};
            colorBackground2[] = {0.12, 0.13, 0.14, 0.95};
            onButtonClick = "ctrlParent (_this select 0) closeDisplay 2";
        };
    };
};

class RACA_RscDisplayCatalogTags {
    idd = RACA_IDD_CATALOG_TAGS;
    movingEnable = 0;
    enableSimulation = 1;
    onLoad = "(_this select 0) call RACA_fnc_catalogTagsOnLoad";
    onUnload = "uiNamespace setVariable ['RACA_catalogTagsParent', displayNull]; uiNamespace setVariable ['RACA_catalogTagsSelection', []]; uiNamespace setVariable ['RACA_catalogTagsDisplay', displayNull]";

    class controlsBackground {
        class Background: RscText {
            idc = -1;
            x = "safeZoneX + 0.08 * safeZoneW";
            y = "safeZoneY + 0.08 * safeZoneH";
            w = "0.84 * safeZoneW";
            h = "0.84 * safeZoneH";
            colorBackground[] = {0.02, 0.025, 0.03, 0.99};
            colorBackground2[] = {0.02, 0.025, 0.03, 0.99};
        };
        class Header: RscText {
            idc = -1;
            text = "Catalogue Tags";
            font = "PuristaSemibold";
            style = 2;
            x = "safeZoneX + 0.10 * safeZoneW";
            y = "safeZoneY + 0.10 * safeZoneH";
            w = "0.80 * safeZoneW";
            h = "0.05 * safeZoneH";
            colorBackground[] = {"(profileNamespace getVariable ['GUI_BCG_RGB_R',0.19])", "(profileNamespace getVariable ['GUI_BCG_RGB_G',0.42])", "(profileNamespace getVariable ['GUI_BCG_RGB_B',0.19])", 0.95};
            colorBackground2[] = {"(profileNamespace getVariable ['GUI_BCG_RGB_R',0.19])", "(profileNamespace getVariable ['GUI_BCG_RGB_G',0.42])", "(profileNamespace getVariable ['GUI_BCG_RGB_B',0.19])", 0.95};
        };
    };

    class controls {
        class Help: RscText {
            idc = -1;
            text = "Organize loaded items into reusable profile-wide tags such as medical, logistics, faction, or event kit. Add/remove applies to the creator's current multi-row selection; tags never change presets or missions.";
            style = 16;
            x = "safeZoneX + 0.10 * safeZoneW";
            y = "safeZoneY + 0.17 * safeZoneH";
            w = "0.80 * safeZoneW";
            h = "0.075 * safeZoneH";
            colorBackground[] = {0, 0, 0, 0.35};
            colorBackground2[] = {0, 0, 0, 0.35};
        };
        class NameLabel: RscText {
            idc = -1;
            text = "Tag name";
            x = "safeZoneX + 0.10 * safeZoneW";
            y = "safeZoneY + 0.265 * safeZoneH";
            w = "0.09 * safeZoneW";
            h = "0.04 * safeZoneH";
        };
        class Name: RscEdit {
            idc = RACA_IDC_CATALOG_TAG_NAME;
            x = "safeZoneX + 0.19 * safeZoneW";
            y = "safeZoneY + 0.265 * safeZoneH";
            w = "0.49 * safeZoneW";
            h = "0.04 * safeZoneH";
            maxChars = 48;
        };
        class AssignTop: RACA_Button {
            idc = RACA_IDC_CATALOG_TAG_ASSIGN;
            text = "Add Creator Selection";
            tooltip = "Create this tag if needed and add it to every selected catalogue row";
            x = "safeZoneX + 0.70 * safeZoneW";
            y = "safeZoneY + 0.265 * safeZoneH";
            w = "0.20 * safeZoneW";
            h = "0.04 * safeZoneH";
            colorBackground[] = {"(profileNamespace getVariable ['GUI_BCG_RGB_R',0.19])", "(profileNamespace getVariable ['GUI_BCG_RGB_G',0.42])", "(profileNamespace getVariable ['GUI_BCG_RGB_B',0.19])", 0.95};
            colorBackground2[] = {"(profileNamespace getVariable ['GUI_BCG_RGB_R',0.19])", "(profileNamespace getVariable ['GUI_BCG_RGB_G',0.42])", "(profileNamespace getVariable ['GUI_BCG_RGB_B',0.19])", 0.95};
            onButtonClick = "[ctrlParent (_this select 0), 'ASSIGN'] spawn RACA_fnc_catalogTagsExecute";
        };
        class ListHeading: RscText {
            idc = -1;
            text = "Tag Search";
            x = "safeZoneX + 0.10 * safeZoneW";
            y = "safeZoneY + 0.315 * safeZoneH";
            w = "0.25 * safeZoneW";
            h = "0.025 * safeZoneH";
            font = "PuristaSemibold";
        };
        class MemberHeading: ListHeading {
            text = "Member Search";
            x = "safeZoneX + 0.37 * safeZoneW";
            w = "0.53 * safeZoneW";
        };
        class Tags: RscListNBox {
            idc = RACA_IDC_CATALOG_TAG_LIST;
            x = "safeZoneX + 0.10 * safeZoneW";
            y = "safeZoneY + 0.38 * safeZoneH";
            w = "0.25 * safeZoneW";
            h = "0.24 * safeZoneH";
            columns[] = {0.01, 0.65, 0.82};
            colorBackground[] = {0, 0, 0, 0.45};
            colorBackground2[] = {0, 0, 0, 0.45};
            onLBSelChanged = "(_this select 0) call RACA_fnc_catalogTagsSelect";
            onLBDblClick = "[ctrlParent (_this select 0), 'FILTER'] spawn RACA_fnc_catalogTagsExecute";
        };
        class TagSearch: RscEdit {
            idc = RACA_IDC_CATALOG_TAG_SEARCH;
            x = "safeZoneX + 0.10 * safeZoneW";
            y = "safeZoneY + 0.34 * safeZoneH";
            w = "0.25 * safeZoneW";
            h = "0.035 * safeZoneH";
            onKeyUp = "[ctrlParent (_this select 0),'TAGS'] call RACA_fnc_queueCatalogTagRefresh";
        };
        class MemberSearch: TagSearch {
            idc = RACA_IDC_CATALOG_MEMBER_SEARCH;
            x = "safeZoneX + 0.37 * safeZoneW";
            w = "0.53 * safeZoneW";
            onKeyUp = "[ctrlParent (_this select 0),'MEMBERS'] call RACA_fnc_queueCatalogTagRefresh";
        };
        class Members: RscListNBox {
            idc = RACA_IDC_CATALOG_TAG_MEMBERS;
            style = 32;
            multiSelect = 1;
            x = "safeZoneX + 0.37 * safeZoneW";
            y = "safeZoneY + 0.38 * safeZoneH";
            w = "0.53 * safeZoneW";
            h = "0.24 * safeZoneH";
            columns[] = {0.01, 0.31, 0.60, 0.88};
            colorBackground[] = {0, 0, 0, 0.45};
            onLBSelChanged = "(_this select 0) call RACA_fnc_catalogTagMembersSelect";
        };
        class TagPagePrevious: RACA_Button {
            idc = RACA_IDC_CATALOG_TAG_PAGE_PREV;
            text = "Previous";
            x = "safeZoneX + 0.10 * safeZoneW";
            y = "safeZoneY + 0.63 * safeZoneH";
            w = "0.07 * safeZoneW";
            h = "0.035 * safeZoneH";
            onButtonClick = "[ctrlParent (_this select 0), 'TAG', -1] call RACA_fnc_catalogTagsPage";
        };
        class TagPageLabel: RscText {
            idc = RACA_IDC_CATALOG_TAG_PAGE_LABEL;
            text = "Page 1 / 1";
            style = 2;
            x = "safeZoneX + 0.17 * safeZoneW";
            y = "safeZoneY + 0.63 * safeZoneH";
            w = "0.11 * safeZoneW";
            h = "0.035 * safeZoneH";
        };
        class TagPageNext: TagPagePrevious {
            idc = RACA_IDC_CATALOG_TAG_PAGE_NEXT;
            text = "Next";
            x = "safeZoneX + 0.28 * safeZoneW";
            onButtonClick = "[ctrlParent (_this select 0), 'TAG', 1] call RACA_fnc_catalogTagsPage";
        };
        class MemberPagePrevious: TagPagePrevious {
            idc = RACA_IDC_CATALOG_MEMBER_PAGE_PREV;
            x = "safeZoneX + 0.37 * safeZoneW";
            onButtonClick = "[ctrlParent (_this select 0), 'MEMBER', -1] call RACA_fnc_catalogTagsPage";
        };
        class MemberPageLabel: TagPageLabel {
            idc = RACA_IDC_CATALOG_MEMBER_PAGE_LABEL;
            x = "safeZoneX + 0.45 * safeZoneW";
            w = "0.36 * safeZoneW";
        };
        class MemberPageNext: MemberPagePrevious {
            idc = RACA_IDC_CATALOG_MEMBER_PAGE_NEXT;
            text = "Next";
            x = "safeZoneX + 0.83 * safeZoneW";
            onButtonClick = "[ctrlParent (_this select 0), 'MEMBER', 1] call RACA_fnc_catalogTagsPage";
        };
        class Details: RscText {
            idc = RACA_IDC_CATALOG_TAG_DETAILS;
            text = "No catalogue tags exist yet.";
            style = 16;
            x = "safeZoneX + 0.10 * safeZoneW";
            y = "safeZoneY + 0.695 * safeZoneH";
            w = "0.80 * safeZoneW";
            h = "0.085 * safeZoneH";
            colorBackground[] = {0, 0, 0, 0.35};
            colorBackground2[] = {0, 0, 0, 0.35};
        };
        class Remove: RACA_Button {
            idc = RACA_IDC_CATALOG_TAG_REMOVE;
            text = "Remove From Tag";
            tooltip = "Remove the selected tag only from highlighted rows in the member table";
            x = "safeZoneX + 0.10 * safeZoneW";
            y = "safeZoneY + 0.81 * safeZoneH";
            w = "0.14 * safeZoneW";
            h = "0.05 * safeZoneH";
            onButtonClick = "[ctrlParent (_this select 0), 'REMOVE'] spawn RACA_fnc_catalogTagsExecute";
        };
        class Filter: Remove {
            idc = RACA_IDC_CATALOG_TAG_FILTER;
            text = "Filter To Tag";
            tooltip = "Close this manager and show only catalogue classes carrying the selected tag";
            x = "safeZoneX + 0.25 * safeZoneW";
            w = "0.13 * safeZoneW";
            colorBackground[] = {"(profileNamespace getVariable ['GUI_BCG_RGB_R',0.19])", "(profileNamespace getVariable ['GUI_BCG_RGB_G',0.42])", "(profileNamespace getVariable ['GUI_BCG_RGB_B',0.19])", 0.95};
            colorBackground2[] = {"(profileNamespace getVariable ['GUI_BCG_RGB_R',0.19])", "(profileNamespace getVariable ['GUI_BCG_RGB_G',0.42])", "(profileNamespace getVariable ['GUI_BCG_RGB_B',0.19])", 0.95};
            onButtonClick = "[ctrlParent (_this select 0), 'FILTER'] spawn RACA_fnc_catalogTagsExecute";
        };
        class ClearFilter: Filter {
            idc = RACA_IDC_CATALOG_TAG_CLEAR_FILTER;
            text = "Clear Filter";
            x = "safeZoneX + 0.39 * safeZoneW";
            w = "0.12 * safeZoneW";
            colorBackground[] = {0.12, 0.13, 0.14, 0.95};
            colorBackground2[] = {0.12, 0.13, 0.14, 0.95};
            onButtonClick = "[ctrlParent (_this select 0), 'CLEAR'] spawn RACA_fnc_catalogTagsExecute";
        };
        class UndoEdit: ClearFilter {
            idc = RACA_IDC_CATALOG_TAG_UNDO;
            text = "Undo Tag Edit";
            tooltip = "Restore the complete catalogue-tag collection from before the last committed tag edit";
            x = "safeZoneX + 0.52 * safeZoneW";
            w = "0.10 * safeZoneW";
            onButtonClick = "[ctrlParent (_this select 0), 'UNDO'] spawn RACA_fnc_catalogTagsExecute";
        };
        class Delete: Filter {
            idc = RACA_IDC_CATALOG_TAG_DELETE;
            text = "Delete Tag";
            tooltip = "Delete only this catalogue tag after confirmation; presets and mission objects are unaffected";
            x = "safeZoneX + 0.63 * safeZoneW";
            w = "0.12 * safeZoneW";
            colorBackground[] = {0.45, 0.12, 0.12, 0.9};
            colorBackground2[] = {0.45, 0.12, 0.12, 0.9};
            onButtonClick = "[ctrlParent (_this select 0), 'DELETE'] spawn RACA_fnc_catalogTagsExecute";
        };
        class Close: Filter {
            idc = 2;
            text = "Close";
            x = "safeZoneX + 0.76 * safeZoneW";
            w = "0.14 * safeZoneW";
            colorBackground[] = {0.12, 0.13, 0.14, 0.95};
            colorBackground2[] = {0.12, 0.13, 0.14, 0.95};
            onButtonClick = "ctrlParent (_this select 0) closeDisplay 2";
        };
    };
};
