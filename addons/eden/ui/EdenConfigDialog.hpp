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
            text = "RACA EDEN ARSENAL CONFIGURATION";
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
            text = "SLOTS ON THIS OBJECT";
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
            text = "ADD";
            x = "safeZoneX + 0.05 * safeZoneW";
            y = "safeZoneY + 0.645 * safeZoneH";
            w = "0.06 * safeZoneW";
            h = "0.038 * safeZoneH";
            onButtonClick = "ctrlParent (_this select 0) call RACA_fnc_edenEditorAddSlot";
        };
        class RemoveSlot: AddSlot {
            text = "REMOVE";
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
            text = "Each enabled slot becomes a separate ACE interaction. Changes are transactional until APPLY CONFIGURATION is pressed.";
            style = 16;
            x = "safeZoneX + 0.05 * safeZoneW";
            y = "safeZoneY + 0.70 * safeZoneH";
            w = "0.26 * safeZoneW";
            h = "0.075 * safeZoneH";
        };

        class SettingsHeading: SlotsHeading {
            text = "SELECTED SLOT";
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
        };
        class IconLabel: NameLabel {text = "ACE icon path"; y = "safeZoneY + 0.295 * safeZoneH";};
        class SlotIcon: SlotName {
            idc = RACA_EDEN_IDC_SLOT_ICON;
            y = "safeZoneY + 0.295 * safeZoneH";
            tooltip = "Optional texture path; leave blank for the default rearm icon";
        };
        class AccessHeading: SettingsHeading {text = "ACCESS RULES"; y = "safeZoneY + 0.345 * safeZoneH";};
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
            text = "ADD RULE";
            x = "safeZoneX + 0.585 * safeZoneW";
            y = "safeZoneY + 0.565 * safeZoneH";
            w = "0.08 * safeZoneW";
            onButtonClick = "ctrlParent (_this select 0) call RACA_fnc_edenEditorAddCondition";
        };
        class RemoveCondition: AddCondition {
            text = "REMOVE RULE";
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
            text = "SAVE SLOT CHANGES";
            x = "safeZoneX + 0.45 * safeZoneW";
            y = "safeZoneY + 0.715 * safeZoneH";
            w = "0.22 * safeZoneW";
            h = "0.045 * safeZoneH";
            onButtonClick = "[ctrlParent (_this select 0), -1, true] call RACA_fnc_edenEditorCommitSlot";
        };

        class DashboardHeading: SlotsHeading {
            text = "MISSION-WIDE DASHBOARD";
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
            text = "REFRESH";
            x = "safeZoneX + 0.71 * safeZoneW";
            y = "safeZoneY + 0.565 * safeZoneH";
            w = "0.07 * safeZoneW";
            onButtonClick = "ctrlParent (_this select 0) call RACA_fnc_edenDashboardRefresh";
        };
        class SelectDashboard: RefreshDashboard {
            text = "SELECT OBJECT";
            x = "safeZoneX + 0.785 * safeZoneW";
            w = "0.09 * safeZoneW";
            onButtonClick = "ctrlParent (_this select 0) call RACA_fnc_edenDashboardSelect";
        };
        class BulkAssign: RefreshDashboard {
            text = "ASSIGN TO SELECTED";
            x = "safeZoneX + 0.71 * safeZoneW";
            y = "safeZoneY + 0.615 * safeZoneH";
            w = "0.115 * safeZoneW";
            onButtonClick = "[ctrlParent (_this select 0), 'ASSIGN'] spawn RACA_fnc_edenDashboardBulk";
        };
        class BulkClear: BulkAssign {
            text = "CLEAR SELECTED";
            x = "safeZoneX + 0.835 * safeZoneW";
            w = "0.105 * safeZoneW";
            colorBackground[] = {0.45, 0.12, 0.12, 0.9};
            onButtonClick = "[ctrlParent (_this select 0), 'CLEAR'] spawn RACA_fnc_edenDashboardBulk";
        };
        class DashboardHelp: ctrlStatic {
            idc = -1;
            text = "Double-click an entry to select that object in Eden. Bulk operations show a confirmation preview and are recorded in Eden undo history.";
            style = 16;
            x = "safeZoneX + 0.71 * safeZoneW";
            y = "safeZoneY + 0.67 * safeZoneH";
            w = "0.24 * safeZoneW";
            h = "0.10 * safeZoneH";
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
            text = "APPLY CONFIGURATION";
            x = "safeZoneX + 0.73 * safeZoneW";
            y = "safeZoneY + 0.81 * safeZoneH";
            w = "0.14 * safeZoneW";
            h = "0.05 * safeZoneH";
            colorBackground[] = {0.19, 0.42, 0.19, 0.95};
            onButtonClick = "ctrlParent (_this select 0) call RACA_fnc_edenEditorApply";
        };
        class Cancel: Apply {
            idc = 2;
            text = "CANCEL";
            x = "safeZoneX + 0.88 * safeZoneW";
            w = "0.08 * safeZoneW";
            colorBackground[] = {0.12, 0.13, 0.14, 0.95};
            onButtonClick = "ctrlParent (_this select 0) closeDisplay 2";
        };
    };
};
