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
            class analyzeEnvironment {};
            class analyzePreset {};
            class formatDiagnosticReport {};
            class preflightObjectConfig {};
        };

        class Presets {
            file = "\x\raca\addons\core\functions\presets";
            class buildPortablePreset {};
            class buildModManifest {};
            class buildSupportBundle {};
            class applyBasePreset {};
            class archivePreset {};
            class buildPreset {};
            class decodePortablePreset {};
            class decodeSqfPreset {};
            class deletePreset {};
            class exportPreset {};
            class fingerprintPreset {};
            class flattenCurrentPreset {};
            class flattenPresetClasses {};
            class flattenPreset {};
            class formatPortableJson {};
            class formatSqfExport {};
            class getComposition {};
            class getPresetHistory {};
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
            class compareSelectedPreset {};
            class creatorOnLoad {};
            class creatorOnUnload {};
            class applySelectedRoleTemplate {};
            class historyOnLoad {};
            class historySelect {};
            class getSavedCatalogViews {};
            class itemDetailsCopy {};
            class itemDetailsOnLoad {};
            class itemDetailsRefresh {};
            class itemDetailsToggleFavorite {};
            class itemDetailsToggleIncluded {};
            class openPresetHistory {};
            class openCreatorDiagnostics {};
            class openItemDetails {};
            class openSavedCatalogViews {};
            class preflightCopy {};
            class preflightOnLoad {};
            class preflightRefresh {};
            class preflightRerun {};
            class preflightSelect {};
            class openQuickStart {};
            class pushCreatorHistory {};
            class quickStartApply {};
            class quickStartOnLoad {};
            class queueRefresh {};
            class refreshHistoryButtons {};
            class refreshSourceCombo {};
            class refreshCategoryCombo {};
            class refreshItemList {};
            class runCreatorDiagnostics {};
            class restoreCreatorHistory {};
            class restorePresetRevision {};
            class savedCatalogViewApply {};
            class savedCatalogViewCapture {};
            class savedCatalogViewDelete {};
            class savedCatalogViewOnLoad {};
            class savedCatalogViewRefresh {};
            class savedCatalogViewSelect {};
            class requestCreatorClose {};
            class setCategoryLimit {};
            class setCatalogView {};
            class setSortMode {};
            class setItemLimit {};
            class setStatus {};
            class setVisibleSelection {};
            class switchCreatorTab {};
            class toggleFavorite {};
            class toggleRow {};
            class updateSummary {};
        };

        class Runtime {
            file = "\x\raca\addons\core\functions\runtime";
            class adminCopyAudit {};
            class adminCommand {};
            class adminExecute {};
            class adminOnLoad {};
            class adminRefresh {};
            class applyAuthorizedLoadout {};
            class applyCorrectedLoadout {};
            class applyObjectConfig {};
            class applyPlayerLoadout {};
            class applyPreset {};
            class buildActionManifest {};
            class bulkUpdateObjects {};
            class cancelObjectSessions {};
            class countLoadout {};
            class deletePlayerLoadout {};
            class evaluateAccess {};
            class finishSession {};
            class getMissionRegistry {};
            class initRuntime {preInit = 1;};
            class initClient {postInit = 1;};
            class isAdminAuthorized {};
            class listPlayerLoadouts {};
            class logEvent {};
            class normalizeAccess {};
            class normalizeLimits {};
            class normalizeObjectConfig {};
            class openAuthorized {};
            class previewPreset {};
            class registerActions {};
            class registerObject {};
            class receiveAdminSnapshot {};
            class receiveAdminAccess {};
            class receiveQuotaStatus {};
            class requestAdminAccess {};
            class requestAdminSnapshot {};
            class requestQuotaStatus {};
            class requestOpen {};
            class requestLoadoutApply {};
            class resetQuotas {};
            class savePlayerLoadout {};
            class unregisterObject {};
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
