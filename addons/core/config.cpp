#include "script_component.hpp"

class CfgPatches {
    class RACA_Core {
        name = "Restricted Arsenal Creation Assistant - Core";
        author = "* Black Ops *";
        url = "https://github.com/Black-Ops-2-543/Arma3_ACE_Arsenal_Creation_Tool";
        requiredVersion = 2.22;
        requiredAddons[] = {"ace_arsenal"};
        units[] = {};
        weapons[] = {};
    };
};

#include "CfgFunctions.hpp"
#include "CfgMissions.hpp"

class RscText;
class RscButton;
class RscEdit;
class RscCombo;
class RscListNBox;
class RscFrame;
class RscControlsGroupNoScrollbars;

#include "ui\RscDisplayCreator.hpp"
#include "RscDisplayMain.hpp"
