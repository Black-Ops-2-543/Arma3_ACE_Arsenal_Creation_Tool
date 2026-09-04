#include "script_component.hpp"

class CfgPatches {
    class RACA_Eden {
        name = "Restricted Arsenal Creation Assistant - Eden";
        author = "* Black Ops *";
        url = "https://github.com/Black-Ops-2-543/Arma3_ACE_Arsenal_Creation_Tool";
        requiredVersion = 2.22;
        requiredAddons[] = {"3DEN", "RACA_Core"};
        units[] = {};
        weapons[] = {};
        is3DENmod = 1;
    };
};

#include "CfgFunctions.hpp"

class ctrlControlsGroupNoScrollbars;
class ctrlCombo;
class ctrlButton;
class ctrlCheckbox;
class ctrlEdit;
class ctrlListbox;
class ctrlListNBox;
class ctrlMenuStrip;
class ctrlStatic;
class RscButton;
class RACA_Button;
class RACA_PrimaryButton;
class RACA_DestructiveButton;
class RACA_ComplementButton;

class display3DEN {
    class Controls {
        class MenuStrip: ctrlMenuStrip {
            class Items {
                class Tools {
                    items[] += {"RACA_MissionArsenalTool"};
                };
                class RACA_MissionArsenalTool {
                    text = "RACA Mission Arsenal Tool";
                    action = "[] call RACA_fnc_edenOpenEditor;";
                    opensNewWindow = 1;
                };
            };
        };
    };
};

#include "Cfg3DEN.hpp"
#include "ui\EdenConfigDialog.hpp"
