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
class ctrlStatic;

#include "Cfg3DEN.hpp"
#include "ui\EdenConfigDialog.hpp"
