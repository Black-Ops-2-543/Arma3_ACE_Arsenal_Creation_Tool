class Cfg3DEN {
    class Attributes {
        #include "ui\PresetAttribute.hpp"
    };

    class Mission {
        class RACA_RestrictedArsenals {
            displayName = "RACA Arsenal Configurations";
            class AttributeCategories {
                class RACA_ConfigurationStorage {
                    displayName = "RACA Arsenal Configurations";
                    collapsed = 1;
                    class Attributes {
                        class RACA_ArsenalConfigurations {
                            property = "RACA_ArsenalConfigurations";
                            control = "Edit";
                            displayName = "Configuration data";
                            tooltip = "Managed by Tools > RACA Mission Arsenal Tool";
                            expression = "if (!is3DEN) then {missionNamespace setVariable ['RACA_missionArsenalConfigurations', +_value]};";
                            defaultValue = "[]";
                            validate = "none";
                        };
                    };
                };
            };
        };
    };

    class Object {
        class AttributeCategories {
            class RACA_RestrictedArsenals {
                displayName = "Restricted Arsenals";
                collapsed = 1;

                class Attributes {
                    class RACA_Preset {
                        property = "RACA_RestrictedArsenalPreset";
                        control = "RACA_PresetAttribute";
                        displayName = "Arsenal configuration";
                        tooltip = "Assign one reusable RACA Arsenal Configuration to this object";
                        expression = "if (!is3DEN && {isServer} && {_value isNotEqualTo []}) then {[_this, _value] call RACA_fnc_applyObjectConfig}";
                        defaultValue = "[]";
                        condition = "1";
                        validate = "none";
                        wikiType = "[[Array]]";
                    };
                };
            };
        };
    };
};
