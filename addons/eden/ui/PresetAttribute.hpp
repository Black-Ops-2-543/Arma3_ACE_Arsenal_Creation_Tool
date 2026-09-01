class RACA_PresetAttribute: ctrlControlsGroupNoScrollbars {
    idc = -1;
    x = 0;
    y = 0;
    w = 130 * RACA_EDEN_GRID_W;
    h = 34 * RACA_EDEN_GRID_H;
    onLoad = "_this call RACA_fnc_edenAttributeOnLoad";
    attributeLoad = "[_this, +_value] call RACA_fnc_edenAttributeLoad";
    attributeSave = "_this call RACA_fnc_edenAttributeSave";

    class controls {
        class Summary: ctrlStatic {
            idc = RACA_EDEN_IDC_SUMMARY;
            text = "No restricted arsenal slots configured.";
            style = 16;
            x = 0;
            y = 1 * RACA_EDEN_GRID_H;
            w = 130 * RACA_EDEN_GRID_W;
            h = 20 * RACA_EDEN_GRID_H;
            colorBackground[] = {0, 0, 0, 0.18};
        };

        class Configure: ctrlButton {
            idc = -1;
            text = "Configure Slots";
            tooltip = "Open the transactional multi-slot arsenal editor and mission dashboard";
            x = 0;
            y = 23 * RACA_EDEN_GRID_H;
            w = 58 * RACA_EDEN_GRID_W;
            h = 9 * RACA_EDEN_GRID_H;
            onButtonClick = "ctrlParentControlsGroup (_this select 0) call RACA_fnc_edenOpenEditor";
        };

        class Refresh: Configure {
            idc = -1;
            text = "Refresh Presets";
            tooltip = "Update every configured slot from matching profile presets while preserving slot settings";
            x = 61 * RACA_EDEN_GRID_W;
            w = 42 * RACA_EDEN_GRID_W;
            onButtonClick = "ctrlParentControlsGroup (_this select 0) call RACA_fnc_edenRefresh";
        };

        class Clear: Configure {
            idc = -1;
            text = "Clear";
            tooltip = "Remove all RACA slots from this object";
            x = 106 * RACA_EDEN_GRID_W;
            w = 24 * RACA_EDEN_GRID_W;
            colorBackground[] = {0.45, 0.12, 0.12, 0.9};
            onButtonClick = "ctrlParentControlsGroup (_this select 0) call RACA_fnc_edenClearAttribute";
        };
    };
};
