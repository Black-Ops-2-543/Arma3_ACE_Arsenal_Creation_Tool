class RACA_PresetAttribute: ctrlControlsGroupNoScrollbars {
    idc = -1;
    x = 0;
    y = 0;
    w = 130 * RACA_EDEN_GRID_W;
    h = 12 * RACA_EDEN_GRID_H;
    onLoad = "_this call RACA_fnc_edenAttributeOnLoad";
    attributeLoad = "[_this, +_value] call RACA_fnc_edenAttributeLoad";
    attributeSave = "_this call RACA_fnc_edenAttributeSave";

    class controls {
        class Preset: ctrlCombo {
            idc = RACA_EDEN_IDC_PRESET;
            x = 0;
            y = 1 * RACA_EDEN_GRID_H;
            w = 104 * RACA_EDEN_GRID_W;
            h = 10 * RACA_EDEN_GRID_H;
        };

        class Refresh: ctrlButton {
            idc = -1;
            text = "Refresh";
            tooltip = "Reload presets saved in your profile";
            x = 106 * RACA_EDEN_GRID_W;
            y = 1 * RACA_EDEN_GRID_H;
            w = 24 * RACA_EDEN_GRID_W;
            h = 10 * RACA_EDEN_GRID_H;
            onButtonClick = "ctrlParentControlsGroup (_this select 0) call RACA_fnc_edenRefresh";
        };
    };
};
