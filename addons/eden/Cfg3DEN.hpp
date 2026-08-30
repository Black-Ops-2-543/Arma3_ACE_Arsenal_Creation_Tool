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
                        displayName = "Arsenal preset";
                        tooltip = "Embed and apply a saved restricted ACE Arsenal preset when the scenario starts";
                        expression = "if (!is3DEN && {isServer} && {_value isNotEqualTo []}) then {[_this, _value] call RACA_fnc_applyPreset}";
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
