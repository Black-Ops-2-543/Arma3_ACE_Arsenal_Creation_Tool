class RACA_PresetAttribute: ctrlControlsGroupNoScrollbars {
    idc = -1;
    x = 0;
    y = 0;
    w = 130 * RACA_EDEN_GRID_W;
    h = 30 * RACA_EDEN_GRID_H;
    onLoad = "_this call RACA_fnc_edenAttributeOnLoad";
    attributeLoad = "[_this, +_value] call RACA_fnc_edenAttributeLoad";
    attributeSave = "_this call RACA_fnc_edenAttributeSave";

    class controls {
        class Configuration: ctrlCombo {
            idc = RACA_EDEN_IDC_PRESET;
            text = "";
            x = 0;
            y = 1 * RACA_EDEN_GRID_H;
            w = 130 * RACA_EDEN_GRID_W;
            h = 9 * RACA_EDEN_GRID_H;
            font = "PuristaMedium";
            tooltip = "Choose a reusable Arsenal Configuration created in the Eden RACA tool.";
        };

        class Summary: ctrlStatic {
            idc = RACA_EDEN_IDC_SUMMARY;
            text = "Additional Arsenal Configurations can be created in the Eden RACA tool accessible in the toolbar.";
            style = 16;
            font = "PuristaMedium";
            sizeEx = 4.2 * RACA_EDEN_GRID_H;
            x = 0;
            y = 12 * RACA_EDEN_GRID_H;
            w = 130 * RACA_EDEN_GRID_W;
            h = 16 * RACA_EDEN_GRID_H;
            colorBackground[] = {0, 0, 0, 0.14};
            colorBackground2[] = {0, 0, 0, 0.14};
        };
    };
};
