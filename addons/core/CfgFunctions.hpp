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
            class buildPortablePreset {};
            class applyBasePreset {};
            class buildPreset {};
            class decodePortablePreset {};
            class decodeSqfPreset {};
            class exportPreset {};
            class fingerprintPreset {};
            class flattenCurrentPreset {};
            class flattenPresetClasses {};
            class flattenPreset {};
            class formatPortableJson {};
            class formatSqfExport {};
            class getComposition {};
            class getPresetLibrary {};
            class importPreset {};
            class isSafeClassName {};
            class loadSelectedPreset {};
            class refreshBaseCombo {};
            class refreshPresetCombo {};
            class saveCurrentPreset {};
            class validatePreset {};
            class wouldCreateCycle {};
        };

        class UI {
            file = "\x\raca\addons\core\functions\ui";
            class clearSelection {};
            class creatorKeyDown {};
            class creatorOnLoad {};
            class creatorOnUnload {};
            class queueRefresh {};
            class refreshCategoryCombo {};
            class refreshItemList {};
            class setStatus {};
            class setVisibleSelection {};
            class switchCreatorTab {};
            class toggleRow {};
            class updateSummary {};
        };

        class Runtime {
            file = "\x\raca\addons\core\functions\runtime";
            class applyPreset {};
        };
    };
};
