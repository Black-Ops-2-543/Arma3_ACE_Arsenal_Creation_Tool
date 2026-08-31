#include "script_component.hpp"

class CfgPatches {
    class RACA_Core {
        name = "Restricted Arsenal Creation Assistant - Core";
        author = "* Black Ops *";
        url = "https://github.com/Black-Ops-2-543/Arma3_ACE_Arsenal_Creation_Tool";
        requiredVersion = 2.22;
        requiredAddons[] = {"A3_Modules_F", "cba_main", "ace_arsenal", "ace_interact_menu"};
        units[] = {
            "RACA_ModuleAssign",
            "RACA_ModuleClear",
            "RACA_ModuleToggle",
            "RACA_ModuleResetQuotas"
        };
        weapons[] = {};
    };
};

#include "CfgFunctions.hpp"
#include "CfgMissions.hpp"

class CfgRemoteExec {
    class Functions {
        mode = 1;
        jip = 0;
        class RACA_fnc_requestOpen {allowedTargets = 2;};
        class RACA_fnc_openAuthorized {allowedTargets = 1;};
        class RACA_fnc_finishSession {allowedTargets = 2;};
        class RACA_fnc_applyCorrectedLoadout {allowedTargets = 1;};
        class RACA_fnc_applyAuthorizedLoadout {allowedTargets = 1;};
        class RACA_fnc_requestLoadoutApply {allowedTargets = 2;};
        class RACA_fnc_adminCommand {allowedTargets = 2;};
        class RACA_fnc_registerActions {allowedTargets = 0;};
    };
};

class CfgFactionClasses {
    class NO_CATEGORY;
    class RACA_Modules: NO_CATEGORY {
        displayName = "Restricted Arsenals";
    };
};

class CfgVehicles {
    class Logic;
    class Module_F: Logic {
        class AttributesBase;
        class ModuleDescription;
    };

    class RACA_ModuleBase: Module_F {
        scope = 1;
        scopeCurator = 0;
        category = "RACA_Modules";
        author = "* Black Ops *";
        isGlobal = 1;
        isTriggerActivated = 0;
        curatorCanAttach = 1;
        curatorInfoType = "RscDisplayAttributeModuleNuke";
        class Attributes: AttributesBase {
            class PresetName {
                displayName = "Preset name";
                tooltip = "Saved profile preset name used by this module";
                property = "RACA_ModulePresetName";
                control = "Edit";
                expression = "_this setVariable ['RACA_presetName', _value, true]";
                defaultValue = "''";
            };
            class SlotName: PresetName {
                displayName = "Slot name";
                tooltip = "Player-facing ACE interaction name";
                property = "RACA_ModuleSlotName";
                expression = "_this setVariable ['RACA_slotName', _value, true]";
                defaultValue = "'Restricted Arsenal'";
            };
            class ModuleDescription: ModuleDescription {};
        };
    };

    class RACA_ModuleAssign: RACA_ModuleBase {
        scope = 2;
        scopeCurator = 2;
        displayName = "Assign / Replace Restricted Arsenal";
        icon = "\A3\ui_f\data\igui\cfg\simpleTasks\types\rearm_ca.paa";
        function = "RACA_fnc_moduleAssign";
    };

    class RACA_ModuleClear: RACA_ModuleBase {
        scope = 2;
        scopeCurator = 2;
        displayName = "Clear Restricted Arsenal";
        icon = "\A3\ui_f\data\igui\cfg\simpleTasks\types\destroy_ca.paa";
        function = "RACA_fnc_moduleClear";
    };

    class RACA_ModuleToggle: RACA_ModuleBase {
        scope = 2;
        scopeCurator = 2;
        displayName = "Enable / Disable Restricted Arsenal";
        icon = "\A3\ui_f\data\igui\cfg\simpleTasks\types\interact_ca.paa";
        function = "RACA_fnc_moduleToggle";
    };

    class RACA_ModuleResetQuotas: RACA_ModuleBase {
        scope = 2;
        scopeCurator = 2;
        displayName = "Reset Arsenal Quotas";
        icon = "\A3\ui_f\data\igui\cfg\simpleTasks\types\download_ca.paa";
        function = "RACA_fnc_moduleResetQuotas";
    };
};

class RscText;
class RscButton;
class RscEdit;
class RscCombo;
class RscListNBox;
class RscFrame;
class RscControlsGroupNoScrollbars;

#include "ui\RscDisplayCreator.hpp"
#include "RscDisplayMain.hpp"
