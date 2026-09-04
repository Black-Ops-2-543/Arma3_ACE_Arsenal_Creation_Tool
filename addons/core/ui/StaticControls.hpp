// RACA-owned CT_BUTTON style. Never patch another mod's global RscButton.
class RACA_Button: RscButton {
    font = "PuristaMedium";
    sizeEx = "0.024 * safeZoneH";
    period = 0;
    periodFocus = 0;
    periodOver = 0;
    colorText[] = {1,1,1,1};
    colorText2[] = {1,1,1,1};
    colorBackground[] = {0.16,0.17,0.19,1};
    colorBackground2[] = {0.16,0.17,0.19,1};
    colorBackgroundActive[] = {0.25,0.27,0.30,1};
    colorBackgroundActive2[] = {0.25,0.27,0.30,1};
    colorBackgroundDisabled[] = {0.10,0.11,0.12,1};
    colorFocused[] = {0.30,0.34,0.39,1};
    colorFocused2[] = {0.30,0.34,0.39,1};
    colorDisabled[] = {0.55,0.55,0.55,1};
};
class RACA_PrimaryButton: RACA_Button {
    colorBackground[] = {"(profileNamespace getVariable ['GUI_BCG_RGB_R',0.19])","(profileNamespace getVariable ['GUI_BCG_RGB_G',0.42])","(profileNamespace getVariable ['GUI_BCG_RGB_B',0.19])",1};
    colorBackground2[] = {"(profileNamespace getVariable ['GUI_BCG_RGB_R',0.19])","(profileNamespace getVariable ['GUI_BCG_RGB_G',0.42])","(profileNamespace getVariable ['GUI_BCG_RGB_B',0.19])",1};
};
class RACA_DestructiveButton: RACA_Button {
    colorBackground[] = {0.38,0.12,0.12,1};
    colorBackground2[] = {0.38,0.12,0.12,1};
};
class RACA_ComplementButton: RACA_Button {
    colorText[] = {0,0,0,1};
    colorText2[] = {0,0,0,1};
    colorBackground[] = {"1 - (profileNamespace getVariable ['GUI_BCG_RGB_R',0.19])","1 - (profileNamespace getVariable ['GUI_BCG_RGB_G',0.42])","1 - (profileNamespace getVariable ['GUI_BCG_RGB_B',0.19])",1};
    colorBackground2[] = {"1 - (profileNamespace getVariable ['GUI_BCG_RGB_R',0.19])","1 - (profileNamespace getVariable ['GUI_BCG_RGB_G',0.42])","1 - (profileNamespace getVariable ['GUI_BCG_RGB_B',0.19])",1};
};
