class RACA_RscDisplayEdenConfig {
    idd = RACA_EDEN_IDD_CONFIG;
    movingEnable = 0;
    enableSimulation = 1;
    onLoad = "(_this select 0) call RACA_fnc_edenEditorOnLoad";
    onUnload = "(_this select 0) call RACA_fnc_edenEditorOnUnload";

    class controlsBackground {
        class Background: ctrlStatic {
            idc = -1;
            x = "safeZoneX + 0.025 * safeZoneW";
            y = "safeZoneY + 0.025 * safeZoneH";
            w = "0.95 * safeZoneW";
            h = "0.95 * safeZoneH";
            colorBackground[] = {0.055, 0.06, 0.07, 0.99};
            colorBackground2[] = {0.055, 0.06, 0.07, 0.99};
        };
        class Frame: ctrlStatic {
            idc = -1;
            text = "";
            style = 64;
            x = "safeZoneX + 0.025 * safeZoneW";
            y = "safeZoneY + 0.025 * safeZoneH";
            w = "0.95 * safeZoneW";
            h = "0.95 * safeZoneH";
            colorText[] = {0.72, 0.74, 0.78, 1};
        };
        class HeaderBar: ctrlStatic {
            idc = -1;
            text = "RACA Mission Arsenal Tool";
            style = 2;
            font = "PuristaSemibold";
            sizeEx = "0.033 * safeZoneH";
            x = "safeZoneX + 0.045 * safeZoneW";
            y = "safeZoneY + 0.045 * safeZoneH";
            w = "0.91 * safeZoneW";
            h = "0.052 * safeZoneH";
            colorText[] = {1, 1, 1, 1};
            colorBackground[] = {"(profileNamespace getVariable ['GUI_BCG_RGB_R',0.13])", "(profileNamespace getVariable ['GUI_BCG_RGB_G',0.41])", "(profileNamespace getVariable ['GUI_BCG_RGB_B',0.67])", 0.95};
            colorBackground2[] = {"(profileNamespace getVariable ['GUI_BCG_RGB_R',0.13])", "(profileNamespace getVariable ['GUI_BCG_RGB_G',0.41])", "(profileNamespace getVariable ['GUI_BCG_RGB_B',0.67])", 0.95};
        };
    };

    class controls {
        class DashboardTab: RACA_Button {
            idc = RACA_EDEN_IDC_TAB_DASHBOARD;
            text = "Mission Dashboard";
            font = "PuristaMedium";
            sizeEx = "0.024 * safeZoneH";
            x = "safeZoneX + 0.05 * safeZoneW";
            y = "safeZoneY + 0.108 * safeZoneH";
            w = "0.17 * safeZoneW";
            h = "0.042 * safeZoneH";
            tooltip = "View every mission object and apply reusable Arsenal Configurations.";
            colorBackground[] = {"(profileNamespace getVariable ['GUI_BCG_RGB_R',0.13])", "(profileNamespace getVariable ['GUI_BCG_RGB_G',0.41])", "(profileNamespace getVariable ['GUI_BCG_RGB_B',0.67])", 0.95};
            colorBackground2[] = {"(profileNamespace getVariable ['GUI_BCG_RGB_R',0.13])", "(profileNamespace getVariable ['GUI_BCG_RGB_G',0.41])", "(profileNamespace getVariable ['GUI_BCG_RGB_B',0.67])", 0.95};
            colorBackgroundActive[] = {"(profileNamespace getVariable ['GUI_BCG_RGB_R',0.13])", "(profileNamespace getVariable ['GUI_BCG_RGB_G',0.41])", "(profileNamespace getVariable ['GUI_BCG_RGB_B',0.67])", 1};
            colorBackgroundActive2[] = {"(profileNamespace getVariable ['GUI_BCG_RGB_R',0.13])", "(profileNamespace getVariable ['GUI_BCG_RGB_G',0.41])", "(profileNamespace getVariable ['GUI_BCG_RGB_B',0.67])", 1};
            onButtonClick = "[ctrlParent (_this select 0), 'DASHBOARD'] call RACA_fnc_edenSwitchTab";
        };
        class ConfigureTab: DashboardTab {
            idc = RACA_EDEN_IDC_TAB_CONFIGURE;
            text = "Configure";
            tooltip = "Create and edit mission-wide Arsenal Configurations.";
            x = "safeZoneX + 0.225 * safeZoneW";
            w = "0.13 * safeZoneW";
            colorBackground[] = {0.13, 0.14, 0.16, 0.95};
            colorBackground2[] = {0.13, 0.14, 0.16, 0.95};
            onButtonClick = "[ctrlParent (_this select 0), 'CONFIGURE'] call RACA_fnc_edenSwitchTab";
        };

        class DashboardGroup: ctrlControlsGroupNoScrollbars {
            idc = RACA_EDEN_IDC_DASHBOARD_GROUP;
            x = "safeZoneX + 0.05 * safeZoneW";
            y = "safeZoneY + 0.162 * safeZoneH";
            w = "0.90 * safeZoneW";
            h = "0.69 * safeZoneH";
            class controls {
                class VariableFilterLabel: ctrlStatic {
                    idc = -1;
                    text = "Variable name";
                    font = "PuristaMedium";
                    sizeEx = "0.021 * safeZoneH";
                    x = 0;
                    y = 0;
                    w = "0.10 * safeZoneW";
                    h = "0.026 * safeZoneH";
                };
                class VariableFilter: ctrlCombo {
                    idc = RACA_EDEN_IDC_VARIABLE_FILTER;
                    font = "PuristaMedium";
                    sizeEx = "0.022 * safeZoneH";
                    x = 0;
                    y = "0.030 * safeZoneH";
                    w = "0.20 * safeZoneW";
                    h = "0.036 * safeZoneH";
                    tooltip = "Show all objects, only objects without a variable name, or only named objects.";
                    onLBSelChanged = "[ctrlParent (_this select 0), false] call RACA_fnc_edenDashboardQueueRefresh";
                };
                class ObjectFilterLabel: VariableFilterLabel {
                    text = "Object type";
                    x = "0.215 * safeZoneW";
                };
                class ObjectFilter: VariableFilter {
                    idc = RACA_EDEN_IDC_OBJECT_FILTER;
                    x = "0.215 * safeZoneW";
                    w = "0.16 * safeZoneW";
                    tooltip = "Show all types or narrow the Dashboard to units, modules, or other objects.";
                };
                class SearchLabel: VariableFilterLabel {
                    text = "Search";
                    x = "0.390 * safeZoneW";
                };
                class Search: ctrlEdit {
                    idc = RACA_EDEN_IDC_DASHBOARD_SEARCH;
                    font = "PuristaMedium";
                    sizeEx = "0.022 * safeZoneH";
                    x = "0.390 * safeZoneW";
                    y = "0.030 * safeZoneH";
                    w = "0.39 * safeZoneW";
                    h = "0.036 * safeZoneH";
                    tooltip = "Search item names, class names, and variable names.";
                    onKeyUp = "[ctrlParent (_this select 0), false] call RACA_fnc_edenDashboardQueueRefresh";
                };
                class Refresh: RACA_Button {
                    idc = -1;
                    text = "Refresh";
                    font = "PuristaMedium";
                    sizeEx = "0.022 * safeZoneH";
                    x = "0.795 * safeZoneW";
                    y = "0.030 * safeZoneH";
                    w = "0.105 * safeZoneW";
                    h = "0.036 * safeZoneH";
                    tooltip = "Refresh objects, assignments, and preflight results from the current mission.";
                    onButtonClick = "[ctrlParent (_this select 0), true] call RACA_fnc_edenDashboardQueueRefresh";
                };
                class ColumnHeader: ctrlStatic {
                    idc = -1;
                    text = "Arsenal Configuration                 Item Name                            Class Name                          Variable Name";
                    font = "PuristaSemibold";
                    sizeEx = "0.021 * safeZoneH";
                    x = 0;
                    y = "0.079 * safeZoneH";
                    w = "0.90 * safeZoneW";
                    h = "0.032 * safeZoneH";
                    colorBackground[] = {0.12, 0.13, 0.15, 0.98};
                    colorBackground2[] = {0.12, 0.13, 0.15, 0.98};
                };
                class DashboardList: ctrlListNBox {
                    idc = RACA_EDEN_IDC_DASHBOARD_LIST;
                    font = "PuristaMedium";
                    sizeEx = "0.022 * safeZoneH";
                    x = 0;
                    y = "0.113 * safeZoneH";
                    w = "0.90 * safeZoneW";
                    h = "0.355 * safeZoneH";
                    columns[] = {0.01, 0.27, 0.53, 0.77};
                    colorBackground[] = {0.025, 0.028, 0.033, 0.94};
                    colorBackground2[] = {0.025, 0.028, 0.033, 0.94};
                    onLBSelChanged = "[ctrlParent (_this select 0), false] call RACA_fnc_edenDashboardSelect";
                    onLBDblClick = "[ctrlParent (_this select 0), true] call RACA_fnc_edenDashboardSelect";
                };
                class PagePrevious: RACA_Button {
                    idc = RACA_EDEN_IDC_DASHBOARD_PAGE_PREV;
                    text = "Previous";
                    font = "PuristaMedium";
                    sizeEx = "0.020 * safeZoneH";
                    x = 0;
                    y = "0.478 * safeZoneH";
                    w = "0.10 * safeZoneW";
                    h = "0.035 * safeZoneH";
                    onButtonClick = "[ctrlParent (_this select 0), -1] call RACA_fnc_edenDashboardPage";
                };
                class PageLabel: ctrlStatic {
                    idc = RACA_EDEN_IDC_DASHBOARD_PAGE_LABEL;
                    text = "Page 1 / 1";
                    style = 2;
                    font = "PuristaMedium";
                    sizeEx = "0.020 * safeZoneH";
                    x = "0.11 * safeZoneW";
                    y = "0.478 * safeZoneH";
                    w = "0.68 * safeZoneW";
                    h = "0.035 * safeZoneH";
                };
                class PageNext: PagePrevious {
                    idc = RACA_EDEN_IDC_DASHBOARD_PAGE_NEXT;
                    text = "Next";
                    x = "0.80 * safeZoneW";
                    onButtonClick = "[ctrlParent (_this select 0), 1] call RACA_fnc_edenDashboardPage";
                };
                class AssignmentLabel: VariableFilterLabel {
                    text = "Selected object's Arsenal Configuration";
                    y = "0.532 * safeZoneH";
                    w = "0.28 * safeZoneW";
                };
                class Assignment: ctrlCombo {
                    idc = RACA_EDEN_IDC_DASHBOARD_ASSIGNMENT;
                    font = "PuristaMedium";
                    sizeEx = "0.022 * safeZoneH";
                    x = 0;
                    y = "0.562 * safeZoneH";
                    w = "0.46 * safeZoneW";
                    h = "0.038 * safeZoneH";
                    tooltip = "Choose the named configuration to apply to the selected Dashboard object.";
                };
                class ApplyToObject: RACA_Button {
                    idc = RACA_EDEN_IDC_DASHBOARD_APPLY;
                    text = "Apply to Object";
                    font = "PuristaMedium";
                    sizeEx = "0.022 * safeZoneH";
                    x = "0.47 * safeZoneW";
                    y = "0.562 * safeZoneH";
                    w = "0.135 * safeZoneW";
                    h = "0.038 * safeZoneH";
                    tooltip = "Apply the chosen configuration as one undoable Eden history step.";
                    colorBackground[] = {"(profileNamespace getVariable ['GUI_BCG_RGB_R',0.13])", "(profileNamespace getVariable ['GUI_BCG_RGB_G',0.41])", "(profileNamespace getVariable ['GUI_BCG_RGB_B',0.67])", 0.95};
                    colorBackground2[] = {"(profileNamespace getVariable ['GUI_BCG_RGB_R',0.13])", "(profileNamespace getVariable ['GUI_BCG_RGB_G',0.41])", "(profileNamespace getVariable ['GUI_BCG_RGB_B',0.67])", 0.95};
                    onButtonClick = "ctrlParent (_this select 0) spawn RACA_fnc_edenDashboardBulk";
                };
                class SelectInEden: ApplyToObject {
                    idc = -1;
                    text = "Select in Eden";
                    x = "0.615 * safeZoneW";
                    w = "0.125 * safeZoneW";
                    colorBackground[] = {0.15, 0.16, 0.18, 0.95};
                    colorBackground2[] = {0.15, 0.16, 0.18, 0.95};
                    tooltip = "Select the highlighted Dashboard object in the 3den scene.";
                    onButtonClick = "[ctrlParent (_this select 0), true] call RACA_fnc_edenDashboardSelect";
                };
                class CopyReport: SelectInEden {
                    text = "Copy Report";
                    x = "0.75 * safeZoneW";
                    w = "0.15 * safeZoneW";
                    tooltip = "Copy a readable report for every object currently visible in the Dashboard.";
                    onButtonClick = "ctrlParent (_this select 0) call RACA_fnc_edenDashboardCopy";
                };
                class Help: ctrlStatic {
                    idc = -1;
                    text = "Tip: double-click a row to select it in Eden. The first column is the current assignment; use the dropdown below to change it.";
                    style = 16;
                    font = "PuristaMedium";
                    sizeEx = "0.020 * safeZoneH";
                    x = 0;
                    y = "0.616 * safeZoneH";
                    w = "0.90 * safeZoneW";
                    h = "0.052 * safeZoneH";
                    colorText[] = {0.78, 0.80, 0.84, 1};
                };
            };
        };

        class ConfigureGroup: ctrlControlsGroupNoScrollbars {
            idc = RACA_EDEN_IDC_CONFIGURE_GROUP;
            x = "safeZoneX + 0.05 * safeZoneW";
            y = "safeZoneY + 0.162 * safeZoneH";
            w = "0.90 * safeZoneW";
            h = "0.69 * safeZoneH";
            class controls {
                class ConfigurationsHeading: ctrlStatic {
                    idc = -1;
                    text = "Arsenal Configurations";
                    font = "PuristaSemibold";
                    sizeEx = "0.024 * safeZoneH";
                    x = 0;
                    y = 0;
                    w = "0.285 * safeZoneW";
                    h = "0.034 * safeZoneH";
                    colorBackground[] = {0.12, 0.13, 0.15, 0.98};
                    colorBackground2[] = {0.12, 0.13, 0.15, 0.98};
                };
                class ConfigurationList: ctrlListbox {
                    idc = RACA_EDEN_IDC_SLOT_LIST;
                    font = "PuristaMedium";
                    sizeEx = "0.022 * safeZoneH";
                    x = 0;
                    y = "0.040 * safeZoneH";
                    w = "0.285 * safeZoneW";
                    h = "0.475 * safeZoneH";
                    colorBackground[] = {0.025, 0.028, 0.033, 0.94};
                    colorBackground2[] = {0.025, 0.028, 0.033, 0.94};
                    onLBSelChanged = "[_this select 0, _this select 1] call RACA_fnc_edenEditorSelectSlot";
                };
                class AddConfiguration: RACA_Button {
                    idc = RACA_EDEN_IDC_CONFIG_ADD;
                    text = "Add Configuration";
                    font = "PuristaMedium";
                    sizeEx = "0.021 * safeZoneH";
                    x = 0;
                    y = "0.528 * safeZoneH";
                    w = "0.158 * safeZoneW";
                    h = "0.040 * safeZoneH";
                    tooltip = "Create a new named configuration from the first available saved preset.";
                    colorBackground[] = {"(profileNamespace getVariable ['GUI_BCG_RGB_R',0.13])", "(profileNamespace getVariable ['GUI_BCG_RGB_G',0.41])", "(profileNamespace getVariable ['GUI_BCG_RGB_B',0.67])", 0.95};
                    colorBackground2[] = {"(profileNamespace getVariable ['GUI_BCG_RGB_R',0.13])", "(profileNamespace getVariable ['GUI_BCG_RGB_G',0.41])", "(profileNamespace getVariable ['GUI_BCG_RGB_B',0.67])", 0.95};
                    onButtonClick = "ctrlParent (_this select 0) call RACA_fnc_edenEditorAddSlot";
                };
                class DeleteConfiguration: AddConfiguration {
                    idc = RACA_EDEN_IDC_CONFIG_DELETE;
                    text = "Delete Configuration";
                    x = "0.163 * safeZoneW";
                    w = "0.122 * safeZoneW";
                    colorBackground[] = {0.52, 0.12, 0.12, 0.95};
                    colorBackground2[] = {0.52, 0.12, 0.12, 0.95};
                    tooltip = "Delete the selected configuration and clear it from linked objects after confirmation.";
                    onButtonClick = "ctrlParent (_this select 0) spawn RACA_fnc_edenEditorRemoveSlot";
                };
                class LibraryHelp: ctrlStatic {
                    idc = -1;
                    text = "Configurations live in this mission. Their presets are stored as standalone snapshots, so the mission does not depend on your local RACA preset library at runtime.";
                    style = 16;
                    font = "PuristaMedium";
                    sizeEx = "0.019 * safeZoneH";
                    x = 0;
                    y = "0.582 * safeZoneH";
                    w = "0.285 * safeZoneW";
                    h = "0.086 * safeZoneH";
                    colorText[] = {0.76, 0.78, 0.82, 1};
                };

                class NameLabel: ctrlStatic {
                    idc = -1;
                    text = "Configuration name";
                    font = "PuristaMedium";
                    sizeEx = "0.020 * safeZoneH";
                    x = "0.315 * safeZoneW";
                    y = 0;
                    w = "0.18 * safeZoneW";
                    h = "0.027 * safeZoneH";
                };
                class ConfigurationName: ctrlEdit {
                    idc = RACA_EDEN_IDC_SLOT_NAME;
                    font = "PuristaMedium";
                    sizeEx = "0.022 * safeZoneH";
                    x = "0.315 * safeZoneW";
                    y = "0.030 * safeZoneH";
                    w = "0.585 * safeZoneW";
                    h = "0.036 * safeZoneH";
                    tooltip = "Use a unique, mission-readable name such as Rifle Squad Arsenal.";
                };
                class PresetLabel: NameLabel {
                    text = "Preset";
                    y = "0.077 * safeZoneH";
                };
                class Preset: ctrlCombo {
                    idc = RACA_EDEN_IDC_SLOT_PRESET;
                    font = "PuristaMedium";
                    sizeEx = "0.022 * safeZoneH";
                    x = "0.315 * safeZoneW";
                    y = "0.107 * safeZoneH";
                    w = "0.585 * safeZoneW";
                    h = "0.036 * safeZoneH";
                    tooltip = "Choose a saved RACA preset. A standalone snapshot is stored in the mission.";
                };
                class IconLabel: NameLabel {
                    text = "Icon path (optional)";
                    y = "0.154 * safeZoneH";
                };
                class Icon: ConfigurationName {
                    idc = RACA_EDEN_IDC_SLOT_ICON;
                    y = "0.184 * safeZoneH";
                    tooltip = "Optional interaction texture path. Leave blank to use the default rearm icon.";
                };
                class AccessHeading: ctrlStatic {
                    idc = -1;
                    text = "Access Rules";
                    font = "PuristaSemibold";
                    sizeEx = "0.024 * safeZoneH";
                    x = "0.315 * safeZoneW";
                    y = "0.232 * safeZoneH";
                    w = "0.585 * safeZoneW";
                    h = "0.034 * safeZoneH";
                    colorBackground[] = {0.12, 0.13, 0.15, 0.98};
                    colorBackground2[] = {0.12, 0.13, 0.15, 0.98};
                };
                class LogicLabel: NameLabel {
                    text = "Logic";
                    y = "0.274 * safeZoneH";
                    w = "0.07 * safeZoneW";
                };
                class Logic: ctrlCombo {
                    idc = RACA_EDEN_IDC_ACCESS_MODE;
                    font = "PuristaMedium";
                    sizeEx = "0.022 * safeZoneH";
                    x = "0.385 * safeZoneW";
                    y = "0.270 * safeZoneH";
                    w = "0.10 * safeZoneW";
                    h = "0.036 * safeZoneH";
                    tooltip = "AND requires every rule. OR requires any one rule. No rules allow everyone.";
                };
                class Rules: ctrlListbox {
                    idc = RACA_EDEN_IDC_CONDITION_LIST;
                    font = "PuristaMedium";
                    sizeEx = "0.021 * safeZoneH";
                    x = "0.315 * safeZoneW";
                    y = "0.315 * safeZoneH";
                    w = "0.585 * safeZoneW";
                    h = "0.135 * safeZoneH";
                    colorBackground[] = {0.025, 0.028, 0.033, 0.94};
                    colorBackground2[] = {0.025, 0.028, 0.033, 0.94};
                };
                class RuleType: ctrlCombo {
                    idc = RACA_EDEN_IDC_CONDITION_KIND;
                    font = "PuristaMedium";
                    sizeEx = "0.021 * safeZoneH";
                    x = "0.315 * safeZoneW";
                    y = "0.462 * safeZoneH";
                    w = "0.19 * safeZoneW";
                    h = "0.036 * safeZoneH";
                    tooltip = "Choose the access property that must match.";
                };
                class RuleValue: ctrlEdit {
                    idc = RACA_EDEN_IDC_CONDITION_VALUE;
                    font = "PuristaMedium";
                    sizeEx = "0.021 * safeZoneH";
                    x = "0.515 * safeZoneW";
                    y = "0.462 * safeZoneH";
                    w = "0.22 * safeZoneW";
                    h = "0.036 * safeZoneH";
                    tooltip = "Enter the exact side, faction, group, rank, class, UID, role, item, or permission key.";
                };
                class AddRule: RACA_Button {
                    idc = -1;
                    text = "Add Rule";
                    font = "PuristaMedium";
                    sizeEx = "0.020 * safeZoneH";
                    x = "0.745 * safeZoneW";
                    y = "0.462 * safeZoneH";
                    w = "0.075 * safeZoneW";
                    h = "0.036 * safeZoneH";
                    onButtonClick = "ctrlParent (_this select 0) call RACA_fnc_edenEditorAddCondition";
                };
                class RemoveRule: AddRule {
                    text = "Remove Rule";
                    x = "0.825 * safeZoneW";
                    w = "0.075 * safeZoneW";
                    onButtonClick = "ctrlParent (_this select 0) call RACA_fnc_edenEditorRemoveCondition";
                };
                class DeniedLabel: NameLabel {
                    text = "Denied message";
                    y = "0.512 * safeZoneH";
                };
                class DeniedMessage: ConfigurationName {
                    idc = RACA_EDEN_IDC_DENIAL_MESSAGE;
                    y = "0.542 * safeZoneH";
                    tooltip = "Message shown when a player does not pass this configuration's access rules.";
                };
                class SaveConfiguration: RACA_Button {
                    idc = RACA_EDEN_IDC_CONFIG_SAVE;
                    text = "Save Configuration";
                    font = "PuristaMedium";
                    sizeEx = "0.022 * safeZoneH";
                    x = "0.315 * safeZoneW";
                    y = "0.595 * safeZoneH";
                    w = "0.285 * safeZoneW";
                    h = "0.044 * safeZoneH";
                    tooltip = "Save this configuration and refresh all linked mission objects.";
                    colorBackground[] = {"(profileNamespace getVariable ['GUI_BCG_RGB_R',0.13])", "(profileNamespace getVariable ['GUI_BCG_RGB_G',0.41])", "(profileNamespace getVariable ['GUI_BCG_RGB_B',0.67])", 0.95};
                    colorBackground2[] = {"(profileNamespace getVariable ['GUI_BCG_RGB_R',0.13])", "(profileNamespace getVariable ['GUI_BCG_RGB_G',0.41])", "(profileNamespace getVariable ['GUI_BCG_RGB_B',0.67])", 0.95};
                    onButtonClick = "[ctrlParent (_this select 0), -1, true] call RACA_fnc_edenEditorCommitSlot";
                };
                class TestAccess: SaveConfiguration {
                    idc = RACA_EDEN_IDC_SIMULATE_ACCESS;
                    text = "Test Access";
                    x = "0.615 * safeZoneW";
                    tooltip = "Rehearse access rules against a unit currently placed in this mission.";
                    colorBackground[] = {0.15, 0.16, 0.18, 0.95};
                    colorBackground2[] = {0.15, 0.16, 0.18, 0.95};
                    onButtonClick = "ctrlParent (_this select 0) call RACA_fnc_edenOpenAccessSimulator";
                };
                class ConfigureHelp: ctrlStatic {
                    idc = -1;
                    text = "Save Configuration updates every linked object. UID and ACE permission rules remain runtime-only and should be verified in multiplayer.";
                    style = 16;
                    font = "PuristaMedium";
                    sizeEx = "0.019 * safeZoneH";
                    x = "0.315 * safeZoneW";
                    y = "0.646 * safeZoneH";
                    w = "0.585 * safeZoneW";
                    h = "0.036 * safeZoneH";
                    colorText[] = {0.76, 0.78, 0.82, 1};
                };
            };
        };

        class Status: ctrlStatic {
            idc = RACA_EDEN_IDC_EDITOR_STATUS;
            text = "Loading mission objects and Arsenal Configurations...";
            style = 16;
            font = "PuristaMedium";
            sizeEx = "0.020 * safeZoneH";
            x = "safeZoneX + 0.05 * safeZoneW";
            y = "safeZoneY + 0.866 * safeZoneH";
            w = "0.63 * safeZoneW";
            h = "0.075 * safeZoneH";
            colorBackground[] = {0.025, 0.028, 0.033, 0.88};
            colorBackground2[] = {0.025, 0.028, 0.033, 0.88};
        };
        class SaveAndClose: RACA_Button {
            idc = RACA_EDEN_IDC_SAVE_CLOSE;
            text = "Save and Close";
            font = "PuristaMedium";
            sizeEx = "0.022 * safeZoneH";
            x = "safeZoneX + 0.695 * safeZoneW";
            y = "safeZoneY + 0.882 * safeZoneH";
            w = "0.145 * safeZoneW";
            h = "0.046 * safeZoneH";
            tooltip = "Validate and save all Arsenal Configurations, then close the tool.";
            colorBackground[] = {"(profileNamespace getVariable ['GUI_BCG_RGB_R',0.13])", "(profileNamespace getVariable ['GUI_BCG_RGB_G',0.41])", "(profileNamespace getVariable ['GUI_BCG_RGB_B',0.67])", 0.95};
            colorBackground2[] = {"(profileNamespace getVariable ['GUI_BCG_RGB_R',0.13])", "(profileNamespace getVariable ['GUI_BCG_RGB_G',0.41])", "(profileNamespace getVariable ['GUI_BCG_RGB_B',0.67])", 0.95};
            onButtonClick = "ctrlParent (_this select 0) call RACA_fnc_edenEditorApply";
        };
        class RepairIds: SaveAndClose {
            idc = RACA_EDEN_IDC_REPAIR;
            text = "Repair IDs";
            x = "safeZoneX + 0.52 * safeZoneW";
            w = "0.08 * safeZoneW";
            onButtonClick = "[ctrlParent (_this select 0), 'REPAIR'] call RACA_fnc_edenRepairConfigurations";
        };
        class RemoveBlocked: RepairIds {
            idc = RACA_EDEN_IDC_REMOVE_BLOCKED;
            text = "Remove Invalid";
            x = "safeZoneX + 0.605 * safeZoneW";
            w = "0.085 * safeZoneW";
            colorBackground[] = {0.38,0.12,0.12,1};
            colorBackground2[] = {0.38,0.12,0.12,1};
            onButtonClick = "[ctrlParent (_this select 0), 'REMOVE'] spawn RACA_fnc_edenRepairConfigurations";
        };
        class Close: SaveAndClose {
            idc = 2;
            text = "Close";
            x = "safeZoneX + 0.85 * safeZoneW";
            w = "0.10 * safeZoneW";
            tooltip = "Close the tool. Changes already saved remain in the mission; uncommitted field edits are discarded.";
            colorBackground[] = {0.13, 0.14, 0.16, 0.95};
            colorBackground2[] = {0.13, 0.14, 0.16, 0.95};
            onButtonClick = "ctrlParent (_this select 0) closeDisplay 2";
        };
    };
};

class RACA_RscDisplayAccessSimulator {
    idd = RACA_EDEN_IDD_ACCESS_SIMULATOR;
    movingEnable = 0;
    enableSimulation = 1;
    onLoad = "(_this select 0) call RACA_fnc_edenAccessSimulatorOnLoad";
    onUnload = "uiNamespace setVariable ['RACA_accessSimulatorParent', displayNull]";

    class controlsBackground {
        class Background: ctrlStatic {
            idc = -1;
            x = "safeZoneX + 0.15 * safeZoneW";
            y = "safeZoneY + 0.12 * safeZoneH";
            w = "0.70 * safeZoneW";
            h = "0.72 * safeZoneH";
            colorBackground[] = {0.055, 0.06, 0.07, 0.99};
            colorBackground2[] = {0.055, 0.06, 0.07, 0.99};
        };
        class HeaderBar: ctrlStatic {
            idc = -1;
            text = "RACA Access-Rule Test";
            style = 2;
            font = "PuristaSemibold";
            sizeEx = "0.030 * safeZoneH";
            x = "safeZoneX + 0.17 * safeZoneW";
            y = "safeZoneY + 0.14 * safeZoneH";
            w = "0.66 * safeZoneW";
            h = "0.05 * safeZoneH";
            colorText[] = {1, 1, 1, 1};
            colorBackground[] = {"(profileNamespace getVariable ['GUI_BCG_RGB_R',0.13])", "(profileNamespace getVariable ['GUI_BCG_RGB_G',0.41])", "(profileNamespace getVariable ['GUI_BCG_RGB_B',0.67])", 0.95};
            colorBackground2[] = {"(profileNamespace getVariable ['GUI_BCG_RGB_R',0.13])", "(profileNamespace getVariable ['GUI_BCG_RGB_G',0.41])", "(profileNamespace getVariable ['GUI_BCG_RGB_B',0.67])", 0.95};
        };
    };

    class controls {
        class UnitLabel: ctrlStatic {
            idc = -1;
            text = "Mission unit";
            font = "PuristaMedium";
            sizeEx = "0.022 * safeZoneH";
            x = "safeZoneX + 0.17 * safeZoneW";
            y = "safeZoneY + 0.205 * safeZoneH";
            w = "0.09 * safeZoneW";
            h = "0.035 * safeZoneH";
        };
        class Unit: ctrlCombo {
            idc = RACA_EDEN_IDC_SIMULATOR_UNIT;
            font = "PuristaMedium";
            sizeEx = "0.022 * safeZoneH";
            x = "safeZoneX + 0.26 * safeZoneW";
            y = "safeZoneY + 0.205 * safeZoneH";
            w = "0.46 * safeZoneW";
            h = "0.035 * safeZoneH";
            tooltip = "Choose any soldier currently placed in the mission.";
        };
        class Summary: ctrlStatic {
            idc = RACA_EDEN_IDC_SIMULATOR_SUMMARY;
            text = "Choose a mission unit to test.";
            style = 16;
            font = "PuristaMedium";
            sizeEx = "0.021 * safeZoneH";
            x = "safeZoneX + 0.17 * safeZoneW";
            y = "safeZoneY + 0.25 * safeZoneH";
            w = "0.66 * safeZoneW";
            h = "0.09 * safeZoneH";
            colorBackground[] = {0.025, 0.028, 0.033, 0.88};
            colorBackground2[] = {0.025, 0.028, 0.033, 0.88};
        };
        class RuleHeading: ctrlStatic {
            idc = -1;
            text = "Result | Rule | Expected | Actual";
            font = "PuristaSemibold";
            sizeEx = "0.021 * safeZoneH";
            x = "safeZoneX + 0.17 * safeZoneW";
            y = "safeZoneY + 0.35 * safeZoneH";
            w = "0.66 * safeZoneW";
            h = "0.035 * safeZoneH";
            colorBackground[] = {0.12, 0.13, 0.15, 0.98};
            colorBackground2[] = {0.12, 0.13, 0.15, 0.98};
        };
        class Rules: ctrlListNBox {
            idc = RACA_EDEN_IDC_SIMULATOR_RULES;
            font = "PuristaMedium";
            sizeEx = "0.021 * safeZoneH";
            x = "safeZoneX + 0.17 * safeZoneW";
            y = "safeZoneY + 0.39 * safeZoneH";
            w = "0.66 * safeZoneW";
            h = "0.31 * safeZoneH";
            columns[] = {0.01, 0.20, 0.50, 0.74};
            colorBackground[] = {0.025, 0.028, 0.033, 0.94};
            colorBackground2[] = {0.025, 0.028, 0.033, 0.94};
        };
        class RunTest: RACA_Button {
            idc = RACA_EDEN_IDC_SIMULATOR_REFRESH;
            text = "Run Test";
            font = "PuristaMedium";
            sizeEx = "0.022 * safeZoneH";
            tooltip = "Evaluate the current configuration's access rules against the chosen Eden unit.";
            x = "safeZoneX + 0.17 * safeZoneW";
            y = "safeZoneY + 0.74 * safeZoneH";
            w = "0.19 * safeZoneW";
            h = "0.05 * safeZoneH";
            colorBackground[] = {"(profileNamespace getVariable ['GUI_BCG_RGB_R',0.13])", "(profileNamespace getVariable ['GUI_BCG_RGB_G',0.41])", "(profileNamespace getVariable ['GUI_BCG_RGB_B',0.67])", 0.95};
            colorBackground2[] = {"(profileNamespace getVariable ['GUI_BCG_RGB_R',0.13])", "(profileNamespace getVariable ['GUI_BCG_RGB_G',0.41])", "(profileNamespace getVariable ['GUI_BCG_RGB_B',0.67])", 0.95};
            onButtonClick = "ctrlParent (_this select 0) call RACA_fnc_edenAccessSimulatorRefresh";
        };
        class Copy: RunTest {
            idc = RACA_EDEN_IDC_SIMULATOR_COPY;
            text = "Copy Report";
            tooltip = "Copy the complete access-rule test report.";
            x = "safeZoneX + 0.37 * safeZoneW";
            w = "0.14 * safeZoneW";
            colorBackground[] = {0.15, 0.16, 0.18, 0.95};
            colorBackground2[] = {0.15, 0.16, 0.18, 0.95};
            onButtonClick = "ctrlParent (_this select 0) call RACA_fnc_edenAccessSimulatorCopy";
        };
        class Close: RunTest {
            idc = 2;
            text = "Close";
            tooltip = "Close the access-rule test.";
            x = "safeZoneX + 0.69 * safeZoneW";
            w = "0.14 * safeZoneW";
            colorBackground[] = {0.13, 0.14, 0.16, 0.95};
            colorBackground2[] = {0.13, 0.14, 0.16, 0.95};
            onButtonClick = "ctrlParent (_this select 0) closeDisplay 2";
        };
    };
};
