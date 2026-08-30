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
    };

    class controls {
        class Title: RscText {
            idc = -1;
            text = "RESTRICTED ARSENAL CREATION ASSISTANT";
            x = "safeZoneX + 0.05 * safeZoneW";
            y = "safeZoneY + 0.052 * safeZoneH";
            w = "0.88 * safeZoneW";
            h = "0.045 * safeZoneH";
            colorBackground[] = {0.19, 0.42, 0.19, 0.9};
        };

        class SearchLabel: RscText {
            idc = -1;
            text = "Search";
            x = "safeZoneX + 0.055 * safeZoneW";
            y = "safeZoneY + 0.108 * safeZoneH";
            w = "0.065 * safeZoneW";
            h = "0.035 * safeZoneH";
        };

        class Search: RscEdit {
            idc = RACA_IDC_SEARCH;
            tooltip = "Search display name, class name, category, mod, source addon, or author";
            x = "safeZoneX + 0.12 * safeZoneW";
            y = "safeZoneY + 0.108 * safeZoneH";
            w = "0.37 * safeZoneW";
            h = "0.035 * safeZoneH";
            onKeyUp = "ctrlParent (_this select 0) call RACA_fnc_queueRefresh";
        };

        class CategoryLabel: SearchLabel {
            text = "Category";
            x = "safeZoneX + 0.505 * safeZoneW";
            w = "0.07 * safeZoneW";
        };

        class Category: RscCombo {
            idc = RACA_IDC_CATEGORY;
            x = "safeZoneX + 0.575 * safeZoneW";
            y = "safeZoneY + 0.108 * safeZoneH";
            w = "0.105 * safeZoneW";
            h = "0.035 * safeZoneH";
            onLBSelChanged = "ctrlParent (_this select 0) call RACA_fnc_refreshItemList";
        };

        class ColumnHeaders: RscText {
            idc = -1;
            text = "     INCLUDED     ITEM                              CLASS NAME                         MOD                    AUTHOR";
            x = "safeZoneX + 0.055 * safeZoneW";
            y = "safeZoneY + 0.153 * safeZoneH";
            w = "0.625 * safeZoneW";
            h = "0.03 * safeZoneH";
            colorBackground[] = {0, 0, 0, 0.55};
        };

        class ItemList: RscListNBox {
            idc = RACA_IDC_ITEM_LIST;
            x = "safeZoneX + 0.055 * safeZoneW";
            y = "safeZoneY + 0.185 * safeZoneH";
            w = "0.625 * safeZoneW";
            h = "0.675 * safeZoneH";
            columns[] = {0.015, 0.07, 0.43, 0.68, 0.84};
            drawSideArrows = 0;
            disableOverflow = 1;
            colorBackground[] = {0, 0, 0, 0.45};
            onMouseButtonClick = "_this call RACA_fnc_toggleRow";
        };

        class PresetPanel: RscText {
            idc = -1;
            x = "safeZoneX + 0.70 * safeZoneW";
            y = "safeZoneY + 0.108 * safeZoneH";
            w = "0.245 * safeZoneW";
            h = "0.752 * safeZoneH";
            colorBackground[] = {0, 0, 0, 0.38};
        };

        class PresetHeading: RscText {
            idc = -1;
            text = "PRESET LIBRARY";
            x = "safeZoneX + 0.71 * safeZoneW";
            y = "safeZoneY + 0.125 * safeZoneH";
            w = "0.225 * safeZoneW";
            h = "0.04 * safeZoneH";
            colorBackground[] = {0.19, 0.42, 0.19, 0.75};
        };

        class PresetNameLabel: RscText {
            idc = -1;
            text = "Preset name";
            x = "safeZoneX + 0.71 * safeZoneW";
            y = "safeZoneY + 0.18 * safeZoneH";
            w = "0.225 * safeZoneW";
            h = "0.03 * safeZoneH";
        };

        class PresetName: RscEdit {
            idc = RACA_IDC_PRESET_NAME;
            x = "safeZoneX + 0.71 * safeZoneW";
            y = "safeZoneY + 0.213 * safeZoneH";
            w = "0.225 * safeZoneW";
            h = "0.037 * safeZoneH";
        };

        class SavedPresetLabel: PresetNameLabel {
            text = "Saved presets";
            y = "safeZoneY + 0.268 * safeZoneH";
        };

        class SavedPresets: RscCombo {
            idc = RACA_IDC_PRESET_LIST;
            x = "safeZoneX + 0.71 * safeZoneW";
            y = "safeZoneY + 0.301 * safeZoneH";
            w = "0.225 * safeZoneW";
            h = "0.037 * safeZoneH";
        };

        class SavePreset: RscButton {
            idc = -1;
            text = "SAVE / OVERWRITE";
            tooltip = "Save the current checked items to your Arma profile";
            x = "safeZoneX + 0.71 * safeZoneW";
            y = "safeZoneY + 0.355 * safeZoneH";
            w = "0.108 * safeZoneW";
            h = "0.04 * safeZoneH";
            onButtonClick = "ctrlParent (_this select 0) call RACA_fnc_saveCurrentPreset";
        };

        class LoadPreset: SavePreset {
            text = "LOAD";
            tooltip = "Load the selected saved preset into the creator";
            x = "safeZoneX + 0.827 * safeZoneW";
            onButtonClick = "ctrlParent (_this select 0) call RACA_fnc_loadSelectedPreset";
        };

        class Summary: RscText {
            idc = RACA_IDC_SUMMARY;
            text = "0 items included";
            style = 16;
            x = "safeZoneX + 0.71 * safeZoneW";
            y = "safeZoneY + 0.425 * safeZoneH";
            w = "0.225 * safeZoneW";
            h = "0.075 * safeZoneH";
            colorBackground[] = {0, 0, 0, 0.4};
        };

        class Instructions: Summary {
            idc = -1;
            text = "Click a row or press Space to toggle its checkbox. Search covers names, classes, mods, source add-ons, and authors.";
            y = "safeZoneY + 0.515 * safeZoneH";
            h = "0.12 * safeZoneH";
            colorBackground[] = {0, 0, 0, 0};
        };

        class IncludeVisible: RscButton {
            idc = -1;
            text = "INCLUDE VISIBLE";
            x = "safeZoneX + 0.71 * safeZoneW";
            y = "safeZoneY + 0.66 * safeZoneH";
            w = "0.225 * safeZoneW";
            h = "0.04 * safeZoneH";
            onButtonClick = "[ctrlParent (_this select 0), true] call RACA_fnc_setVisibleSelection";
        };

        class ExcludeVisible: IncludeVisible {
            text = "EXCLUDE VISIBLE";
            y = "safeZoneY + 0.71 * safeZoneH";
            onButtonClick = "[ctrlParent (_this select 0), false] call RACA_fnc_setVisibleSelection";
        };

        class ClearAll: IncludeVisible {
            text = "CLEAR ALL";
            y = "safeZoneY + 0.76 * safeZoneH";
            onButtonClick = "ctrlParent (_this select 0) call RACA_fnc_clearSelection";
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
