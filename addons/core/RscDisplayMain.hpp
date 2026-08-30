class RscStandardDisplay;
class RscDisplayMain: RscStandardDisplay {
    class controls {
        class GroupSingleplayer: RscControlsGroupNoScrollbars {
            class Controls;
        };

        class GroupTutorials: GroupSingleplayer {
            h = "(7 * 1.5) * (pixelH * pixelGrid * 2)";

            class Controls: Controls {
                class Bootcamp;
                class Arsenal;

                class RACA_OpenCreator: Arsenal {
                    idc = -1;
                    text = "Restricted Arsenal Creator";
                    tooltip = "Create and save restricted ACE Arsenal presets";
                    y = "(4 * 1.5) * (pixelH * pixelGrid * 2) + pixelH";
                    onButtonClick = "playMission ['', '\x\raca\addons\core\missions\Creator.VR']";
                };

                class FieldManual: Bootcamp {
                    y = "(5 * 1.5) * (pixelH * pixelGrid * 2) + pixelH";
                };

                class CommunityGuides: Bootcamp {
                    y = "(6 * 1.5) * (pixelH * pixelGrid * 2) + pixelH";
                };
            };
        };
    };
};
