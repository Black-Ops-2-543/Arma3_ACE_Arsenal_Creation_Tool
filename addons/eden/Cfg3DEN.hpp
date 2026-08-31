class Cfg3DEN {
    class Attributes {
        #include "ui\PresetAttribute.hpp"
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
                        tooltip = "Configure one or more named restricted arsenal slots, access rules, visibility, and presets";
                        expression = "if (!is3DEN && {isServer} && {_value isNotEqualTo []}) then {[_this, _value] call RACA_fnc_applyObjectConfig}";
                        defaultValue = "[]";
                        condition = "1";
                        validate = "none";
                        wikiType = "[[Array]]";
                        value = 0;
                    };
                };
            };
        };
    };
};
