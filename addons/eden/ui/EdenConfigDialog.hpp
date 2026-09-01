class RACA_RscDisplayEdenConfig {
    idd = RACA_EDEN_IDD_CONFIG;
    movingEnable = 0;
    enableSimulation = 1;
    onLoad = "(_this select 0) call RACA_fnc_edenEditorOnLoad";

    class controlsBackground {
        class Background: ctrlStatic {
            idc = -1;
            x = "safeZoneX + 0.025 * safeZoneW";
            y = "safeZoneY + 0.025 * safeZoneH";
            w = "0.95 * safeZoneW";
            h = "0.95 * safeZoneH";
            colorBackground[] = {0.02, 0.025, 0.03, 0.98};
        };
        class Header: ctrlStatic {
            idc = -1;
            text = "Restricted Arsenal Configuration";
            style = 2;
            x = "safeZoneX + 0.04 * safeZoneW";
            y = "safeZoneY + 0.04 * safeZoneH";
            w = "0.92 * safeZoneW";
            h = "0.045 * safeZoneH";
            colorBackground[] = {0.19, 0.42, 0.19, 0.95};
        };
        class SlotPanel: ctrlStatic {
            idc = -1;
            x = "safeZoneX + 0.04 * safeZoneW";
            y = "safeZoneY + 0.10 * safeZoneH";
            w = "0.28 * safeZoneW";
            h = "0.69 * safeZoneH";
            colorBackground[] = {0, 0, 0, 0.35};
        };
        class EditorPanel: SlotPanel {
            x = "safeZoneX + 0.33 * safeZoneW";
            w = "0.36 * safeZoneW";
        };
        class DashboardPanel: SlotPanel {
            x = "safeZoneX + 0.70 * safeZoneW";
            w = "0.26 * safeZoneW";
        };
    };

    class controls {
        class SlotsHeading: ctrlStatic {
            idc = -1;
            text = "Slots";
            x = "safeZoneX + 0.05 * safeZoneW";
            y = "safeZoneY + 0.115 * safeZoneH";
            w = "0.26 * safeZoneW";
            h = "0.035 * safeZoneH";
            colorBackground[] = {0.19, 0.42, 0.19, 0.7};
        };
        class SlotList: ctrlListbox {
            idc = RACA_EDEN_IDC_SLOT_LIST;
            x = "safeZoneX + 0.05 * safeZoneW";
            y = "safeZoneY + 0.16 * safeZoneH";
            w = "0.26 * safeZoneW";
            h = "0.47 * safeZoneH";
            onLBSelChanged = "[_this select 0, _this select 1] call RACA_fnc_edenEditorSelectSlot";
        };
        class AddSlot: ctrlButton {
            idc = -1;
            text = "Add";
            x = "safeZoneX + 0.05 * safeZoneW";
            y = "safeZoneY + 0.645 * safeZoneH";
            w = "0.06 * safeZoneW";
            h = "0.038 * safeZoneH";
            onButtonClick = "ctrlParent (_this select 0) call RACA_fnc_edenEditorAddSlot";
        };
        class RemoveSlot: AddSlot {
            text = "Remove";
            x = "safeZoneX + 0.115 * safeZoneW";
            onButtonClick = "ctrlParent (_this select 0) call RACA_fnc_edenEditorRemoveSlot";
        };
        class MoveUp: AddSlot {
            text = "UP";
            x = "safeZoneX + 0.18 * safeZoneW";
            onButtonClick = "[ctrlParent (_this select 0), -1] call RACA_fnc_edenEditorMoveSlot";
        };
        class MoveDown: AddSlot {
            text = "DOWN";
            x = "safeZoneX + 0.245 * safeZoneW";
            onButtonClick = "[ctrlParent (_this select 0), 1] call RACA_fnc_edenEditorMoveSlot";
        };
        class SlotHelp: ctrlStatic {
            idc = -1;
            text = "Each enabled slot creates a separate ACE interaction. Use Apply Configuration to save all changes.";
            style = 16;
            x = "safeZoneX + 0.05 * safeZoneW";
            y = "safeZoneY + 0.70 * safeZoneH";
            w = "0.26 * safeZoneW";
            h = "0.075 * safeZoneH";
        };

        class SettingsHeading: SlotsHeading {
            text = "Selected Slot";
            x = "safeZoneX + 0.34 * safeZoneW";
            w = "0.34 * safeZoneW";
        };
        class NameLabel: ctrlStatic {
            idc = -1;
            text = "Interaction name";
            x = "safeZoneX + 0.34 * safeZoneW";
            y = "safeZoneY + 0.16 * safeZoneH";
            w = "0.11 * safeZoneW";
            h = "0.03 * safeZoneH";
        };
        class SlotName: ctrlEdit {
            idc = RACA_EDEN_IDC_SLOT_NAME;
            x = "safeZoneX + 0.45 * safeZoneW";
            y = "safeZoneY + 0.16 * safeZoneH";
            w = "0.22 * safeZoneW";
            h = "0.032 * safeZoneH";
        };
        class PresetLabel: NameLabel {text = "Preset"; y = "safeZoneY + 0.205 * safeZoneH";};
        class SlotPreset: ctrlCombo {
            idc = RACA_EDEN_IDC_SLOT_PRESET;
            x = "safeZoneX + 0.45 * safeZoneW";
            y = "safeZoneY + 0.205 * safeZoneH";
            w = "0.22 * safeZoneW";
            h = "0.032 * safeZoneH";
            tooltip = "Choose a saved preset for this slot.";
        };
        class EnabledLabel: NameLabel {text = "Enabled"; y = "safeZoneY + 0.25 * safeZoneH";};
        class SlotEnabled: ctrlCheckbox {
            idc = RACA_EDEN_IDC_SLOT_ENABLED;
            x = "safeZoneX + 0.45 * safeZoneW";
            y = "safeZoneY + 0.25 * safeZoneH";
            w = "0.025 * safeZoneW";
            h = "0.03 * safeZoneH";
        };
        class HideLabel: NameLabel {text = "Hide when denied"; x = "safeZoneX + 0.49 * safeZoneW"; y = "safeZoneY + 0.25 * safeZoneH"; w = "0.12 * safeZoneW";};
        class HideDenied: SlotEnabled {
            idc = RACA_EDEN_IDC_SLOT_HIDE_DENIED;
            x = "safeZoneX + 0.62 * safeZoneW";
            tooltip = "Hide the interaction instead of showing a denial message.";
        };
        class IconLabel: NameLabel {text = "ACE icon path"; y = "safeZoneY + 0.295 * safeZoneH";};
        class SlotIcon: SlotName {
            idc = RACA_EDEN_IDC_SLOT_ICON;
            y = "safeZoneY + 0.295 * safeZoneH";
            tooltip = "Optional texture path; leave blank for the default rearm icon";
        };
        class AccessHeading: SettingsHeading {text = "Access Rules"; y = "safeZoneY + 0.345 * safeZoneH";};
        class MatchLabel: NameLabel {text = "Condition matching"; y = "safeZoneY + 0.39 * safeZoneH";};
        class AccessMode: SlotPreset {
            idc = RACA_EDEN_IDC_ACCESS_MODE;
            y = "safeZoneY + 0.39 * safeZoneH";
            w = "0.08 * safeZoneW";
        };
        class ConditionList: ctrlListbox {
            idc = RACA_EDEN_IDC_CONDITION_LIST;
            x = "safeZoneX + 0.34 * safeZoneW";
            y = "safeZoneY + 0.435 * safeZoneH";
            w = "0.33 * safeZoneW";
            h = "0.12 * safeZoneH";
        };
        class ConditionKind: SlotPreset {
            idc = RACA_EDEN_IDC_CONDITION_KIND;
            x = "safeZoneX + 0.34 * safeZoneW";
            y = "safeZoneY + 0.565 * safeZoneH";
            w = "0.10 * safeZoneW";
        };
        class ConditionValue: SlotName {
            idc = RACA_EDEN_IDC_CONDITION_VALUE;
            x = "safeZoneX + 0.445 * safeZoneW";
            y = "safeZoneY + 0.565 * safeZoneH";
            w = "0.135 * safeZoneW";
            tooltip = "Use the exact side, faction, group, rank, unit class, UID, vehicle role, item class, or permission key";
        };
        class AddCondition: AddSlot {
            text = "Add";
            x = "safeZoneX + 0.585 * safeZoneW";
            y = "safeZoneY + 0.565 * safeZoneH";
            w = "0.08 * safeZoneW";
            onButtonClick = "ctrlParent (_this select 0) call RACA_fnc_edenEditorAddCondition";
        };
        class RemoveCondition: AddCondition {
            text = "Remove";
            x = "safeZoneX + 0.585 * safeZoneW";
            y = "safeZoneY + 0.61 * safeZoneH";
            onButtonClick = "ctrlParent (_this select 0) call RACA_fnc_edenEditorRemoveCondition";
        };
        class DenialLabel: NameLabel {text = "Denial message"; y = "safeZoneY + 0.66 * safeZoneH";};
        class DenialMessage: SlotName {
            idc = RACA_EDEN_IDC_DENIAL_MESSAGE;
            y = "safeZoneY + 0.66 * safeZoneH";
        };
        class SaveSlot: ctrlButton {
            idc = -1;
            text = "SAVE SLOT";
            x = "safeZoneX + 0.45 * safeZoneW";
            y = "safeZoneY + 0.715 * safeZoneH";
            w = "0.22 * safeZoneW";
            h = "0.045 * safeZoneH";
            onButtonClick = "[ctrlParent (_this select 0), -1, true] call RACA_fnc_edenEditorCommitSlot";
        };

        class DashboardHeading: SlotsHeading {
            text = "Mission-wide dashboard";
            x = "safeZoneX + 0.71 * safeZoneW";
            w = "0.24 * safeZoneW";
        };
        class DashboardList: ctrlListbox {
            idc = RACA_EDEN_IDC_DASHBOARD_LIST;
            x = "safeZoneX + 0.71 * safeZoneW";
            y = "safeZoneY + 0.16 * safeZoneH";
            w = "0.24 * safeZoneW";
            h = "0.39 * safeZoneH";
            onLBDblClick = "ctrlParent (_this select 0) call RACA_fnc_edenDashboardSelect";
        };
        class RefreshDashboard: AddSlot {
            text = "Refresh";
            x = "safeZoneX + 0.71 * safeZoneW";
            y = "safeZoneY + 0.565 * safeZoneH";
            w = "0.055 * safeZoneW";
            onButtonClick = "ctrlParent (_this select 0) call RACA_fnc_edenDashboardRefresh";
        };
        class SelectDashboard: RefreshDashboard {
            text = "Select";
            x = "safeZoneX + 0.77 * safeZoneW";
            w = "0.08 * safeZoneW";
            onButtonClick = "ctrlParent (_this select 0) call RACA_fnc_edenDashboardSelect";
        };
        class CopyDashboardReport: RefreshDashboard {
            text = "Copy";
            tooltip = "Copy a detailed compatibility report for every configured arsenal object";
            x = "safeZoneX + 0.855 * safeZoneW";
            w = "0.085 * safeZoneW";
            onButtonClick = "ctrlParent (_this select 0) call RACA_fnc_edenDashboardCopy";
        };
        class BulkAssign: RefreshDashboard {
            text = "Assign to selected";
            x = "safeZoneX + 0.71 * safeZoneW";
            y = "safeZoneY + 0.615 * safeZoneH";
            w = "0.115 * safeZoneW";
            onButtonClick = "[ctrlParent (_this select 0), 'ASSIGN'] spawn RACA_fnc_edenDashboardBulk";
        };
        class BulkClear: BulkAssign {
            text = "Clear selected";
            x = "safeZoneX + 0.835 * safeZoneW";
            w = "0.105 * safeZoneW";
            colorBackground[] = {0.45, 0.12, 0.12, 0.9};
            onButtonClick = "[ctrlParent (_this select 0), 'CLEAR'] spawn RACA_fnc_edenDashboardBulk";
        };
        class SimulateAccess: RefreshDashboard {
            idc = RACA_EDEN_IDC_SIMULATE_ACCESS;
            text = "Test access";
            tooltip = "Open the access-rule simulator and choose any unit in the Eden mission";
            x = "safeZoneX + 0.71 * safeZoneW";
            y = "safeZoneY + 0.665 * safeZoneH";
            w = "0.23 * safeZoneW";
            onButtonClick = "ctrlParent (_this select 0) call RACA_fnc_edenOpenAccessSimulator";
        };
        class DashboardHelp: ctrlStatic {
            idc = -1;
            text = "Rows show READY, WARN, or BLOCKED. Apply editor changes before refreshing.";
            style = 16;
            x = "safeZoneX + 0.71 * safeZoneW";
            y = "safeZoneY + 0.715 * safeZoneH";
            w = "0.24 * safeZoneW";
            h = "0.055 * safeZoneH";
        };

        class Status: ctrlStatic {
            idc = RACA_EDEN_IDC_EDITOR_STATUS;
            text = "Loading configuration...";
            x = "safeZoneX + 0.04 * safeZoneW";
            y = "safeZoneY + 0.81 * safeZoneH";
            w = "0.68 * safeZoneW";
            h = "0.05 * safeZoneH";
            colorBackground[] = {0, 0, 0, 0.5};
        };
        class Apply: ctrlButton {
            idc = -1;
            text = "Apply configuration";
            x = "safeZoneX + 0.73 * safeZoneW";
            y = "safeZoneY + 0.81 * safeZoneH";
            w = "0.14 * safeZoneW";
            h = "0.05 * safeZoneH";
            colorBackground[] = {0.19, 0.42, 0.19, 0.95};
            onButtonClick = "ctrlParent (_this select 0) call RACA_fnc_edenEditorApply";
        };
        class Cancel: Apply {
            idc = 2;
            text = "Cancel";
            x = "safeZoneX + 0.88 * safeZoneW";
            w = "0.08 * safeZoneW";
            colorBackground[] = {0.12, 0.13, 0.14, 0.95};
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
            colorBackground[] = {0.02, 0.025, 0.03, 0.99};
        };
        class Header: ctrlStatic {
            idc = -1;
            text = "RACA ACCESS-RULE SIMULATOR";
            style = 2;
            x = "safeZoneX + 0.17 * safeZoneW";
            y = "safeZoneY + 0.14 * safeZoneH";
            w = "0.66 * safeZoneW";
            h = "0.05 * safeZoneH";
            colorBackground[] = {0.19, 0.42, 0.19, 0.95};
        };
    };

    class controls {
        class Summary: ctrlStatic {
            idc = RACA_EDEN_IDC_SIMULATOR_SUMMARY;
            text = "Choose a mission unit to simulate.";
            style = 16;
            x = "safeZoneX + 0.17 * safeZoneW";
            y = "safeZoneY + 0.25 * safeZoneH";
            w = "0.66 * safeZoneW";
            h = "0.09 * safeZoneH";
            colorBackground[] = {0, 0, 0, 0.45};
        };
        class UnitLabel: ctrlStatic {
            idc = -1;
            text = "Mission unit";
            x = "safeZoneX + 0.17 * safeZoneW";
            y = "safeZoneY + 0.205 * safeZoneH";
            w = "0.09 * safeZoneW";
            h = "0.035 * safeZoneH";
        };
        class Unit: ctrlCombo {
            idc = RACA_EDEN_IDC_SIMULATOR_UNIT;
            x = "safeZoneX + 0.26 * safeZoneW";
            y = "safeZoneY + 0.205 * safeZoneH";
            w = "0.46 * safeZoneW";
            h = "0.035 * safeZoneH";
            tooltip = "Choose any playable or AI soldier currently placed in the Eden mission";
        };
        class RuleHeading: ctrlStatic {
            idc = -1;
            text = "RESULT                RULE                         EXPECTED                                  ACTUAL";
            x = "safeZoneX + 0.17 * safeZoneW";
            y = "safeZoneY + 0.33 * safeZoneH";
            w = "0.66 * safeZoneW";
            h = "0.035 * safeZoneH";
            colorBackground[] = {0.12, 0.13, 0.14, 0.95};
        };
        class Rules: ctrlListNBox {
            idc = RACA_EDEN_IDC_SIMULATOR_RULES;
            x = "safeZoneX + 0.17 * safeZoneW";
            y = "safeZoneY + 0.37 * safeZoneH";
            w = "0.66 * safeZoneW";
            h = "0.34 * safeZoneH";
            columns[] = {0.01, 0.15, 0.36, 0.67};
            colorBackground[] = {0, 0, 0, 0.45};
        };
        class Refresh: ctrlButton {
            idc = RACA_EDEN_IDC_SIMULATOR_REFRESH;
            text = "SIMULATE ACCESS";
            tooltip = "Evaluate the current slot's access rules against the chosen Eden unit";
            x = "safeZoneX + 0.17 * safeZoneW";
            y = "safeZoneY + 0.74 * safeZoneH";
            w = "0.19 * safeZoneW";
            h = "0.05 * safeZoneH";
            onButtonClick = "ctrlParent (_this select 0) call RACA_fnc_edenAccessSimulatorRefresh";
        };
        class Copy: Refresh {
            idc = RACA_EDEN_IDC_SIMULATOR_COPY;
            text = "Copy report";
            tooltip = "Copy the complete access-rule simulation report to the clipboard";
            x = "safeZoneX + 0.37 * safeZoneW";
            w = "0.14 * safeZoneW";
            onButtonClick = "ctrlParent (_this select 0) call RACA_fnc_edenAccessSimulatorCopy";
        };
        class Close: Refresh {
            idc = 2;
            text = "CLOSE";
            tooltip = "Close the access-rule simulator";
            x = "safeZoneX + 0.69 * safeZoneW";
            w = "0.14 * safeZoneW";
            colorBackground[] = {0.12, 0.13, 0.14, 0.95};
            onButtonClick = "ctrlParent (_this select 0) closeDisplay 2";
        };
    };
};
