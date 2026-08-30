class CfgFunctions {
    class RACA {
        tag = "RACA";

        class Catalog {
            file = "\x\raca\addons\core\functions\catalog";
            class classifyClass {};
            class scanItems {};
        };

        class Presets {
            file = "\x\raca\addons\core\functions\presets";
            class buildPreset {};
            class getPresetLibrary {};
            class loadSelectedPreset {};
            class refreshPresetCombo {};
            class saveCurrentPreset {};
            class validatePreset {};
        };

        class UI {
            file = "\x\raca\addons\core\functions\ui";
            class clearSelection {};
            class creatorKeyDown {};
            class creatorOnLoad {};
            class creatorOnUnload {};
            class queueRefresh {};
            class refreshItemList {};
            class setStatus {};
            class setVisibleSelection {};
            class toggleRow {};
            class updateSummary {};
        };

        class Runtime {
            file = "\x\raca\addons\core\functions\runtime";
            class applyPreset {};
        };
    };
};
