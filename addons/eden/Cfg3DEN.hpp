class Cfg3DEN {
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
                        expression = "if (!is3DEN && {_value isNotEqualTo []}) then {[_this, _value] call RACA_fnc_applyPreset}";
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
