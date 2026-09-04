class RACA_ImportDialog {
    idd = 904210;
    movingEnable = 0;
    enableSimulation = 1;
    class controlsBackground {
        class Background: RscText {
            idc = -1;
            x = "safeZoneX + 0.20 * safeZoneW";
            y = "safeZoneY + 0.22 * safeZoneH";
            w = "0.60 * safeZoneW";
            h = "0.56 * safeZoneH";
            colorBackground[] = {0.055,0.06,0.07,1};
        };
    };
    class controls {
        class Title: RscText {
            idc = -1;
            text = "Import Preset";
            font = "PuristaSemibold";
            x = "safeZoneX + 0.22 * safeZoneW";
            y = "safeZoneY + 0.24 * safeZoneH";
            w = "0.56 * safeZoneW";
            h = "0.05 * safeZoneH";
        };
        class Progress: RscText {
            idc = 1000;
            text = "Preparing import. Cancel leaves your data unchanged.";
            style = 16;
            lineSpacing = 1;
            font = "PuristaMedium";
            x = "safeZoneX + 0.22 * safeZoneW";
            y = "safeZoneY + 0.31 * safeZoneH";
            w = "0.56 * safeZoneW";
            h = "0.34 * safeZoneH";
        };
        class Overwrite: RACA_PrimaryButton {
            idc = 1600;
            text = "Overwrite";
            enable = 0;
            x = "safeZoneX + 0.22 * safeZoneW";
            y = "safeZoneY + 0.70 * safeZoneH";
            w = "0.17 * safeZoneW";
            h = "0.045 * safeZoneH";
            onButtonClick = "private _d=ctrlParent (_this select 0); if ((_d getVariable ['RACA_choice','']) isEqualTo '') then {_d setVariable ['RACA_choice','OVERWRITE']; {(_d displayCtrl _x) ctrlEnable false} forEach [1600,1601]};";
        };
        class Copy: Overwrite {
            idc = 1601;
            text = "Import Copy";
            x = "safeZoneX + 0.415 * safeZoneW";
            onButtonClick = "private _d=ctrlParent (_this select 0); if ((_d getVariable ['RACA_choice','']) isEqualTo '') then {_d setVariable ['RACA_choice','COPY']; {(_d displayCtrl _x) ctrlEnable false} forEach [1600,1601]};";
        };
        class Cancel: RACA_Button {
            idc = 2;
            text = "Cancel";
            x = "safeZoneX + 0.61 * safeZoneW";
            y = "safeZoneY + 0.70 * safeZoneH";
            w = "0.17 * safeZoneW";
            h = "0.045 * safeZoneH";
            onButtonClick = "ctrlParent (_this select 0) closeDisplay 2";
        };
    };
};
