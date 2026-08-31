class CfgFunctions {
    class RACA {
        tag = "RACA";

        class Catalog {
            file = "\x\raca\addons\core\functions\catalog";
            class classifyClass {};
            class scanItems {};
        };

        class Diagnostics {
            file = "\x\raca\addons\core\functions\diagnostics";
            class analyzePreset {};
            class formatDiagnosticReport {};
            class preflightObjectConfig {};
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
            class getRuntimePolicy {};
            class migratePreset {};
            class refreshBaseCombo {};
            class refreshPresetCombo {};
            class saveCurrentPreset {};
            class setPresetRevision {};
            class validatePreset {};
            class wouldCreateCycle {};
        };

        class Templates {
            file = "\x\raca\addons\core\functions\templates";
            class applyRoleTemplate {};
            class getRoleTemplates {};
        };

        class UI {
            file = "\x\raca\addons\core\functions\ui";
            class clearSelection {};
            class copyCreatorDiagnostics {};
            class creatorKeyDown {};
            class creatorOnLoad {};
            class creatorOnUnload {};
            class queueRefresh {};
            class refreshSourceCombo {};
            class refreshCategoryCombo {};
            class refreshItemList {};
            class runCreatorDiagnostics {};
            class setCatalogView {};
            class setItemLimit {};
            class setStatus {};
            class setVisibleSelection {};
            class switchCreatorTab {};
            class toggleRow {};
            class updateSummary {};
        };

        class Runtime {
            file = "\x\raca\addons\core\functions\runtime";
            class adminCommand {};
            class applyCorrectedLoadout {};
            class applyObjectConfig {};
            class applyPlayerLoadout {};
            class applyPreset {};
            class bulkUpdateObjects {};
            class countLoadout {};
            class deletePlayerLoadout {};
            class evaluateAccess {};
            class finishSession {};
            class getMissionRegistry {};
            class initRuntime {preInit = 1;};
            class isAdminAuthorized {};
            class listPlayerLoadouts {};
            class logEvent {};
            class normalizeLimits {};
            class normalizeObjectConfig {};
            class openAuthorized {};
            class previewPreset {};
            class registerActions {};
            class registerObject {};
            class requestOpen {};
            class resetQuotas {};
            class savePlayerLoadout {};
        };

        class Zeus {
            file = "\x\raca\addons\core\functions\zeus";
            class moduleAssign {};
            class moduleClear {};
            class moduleResetQuotas {};
            class moduleToggle {};
        };
    };
};
