#include "..\..\script_component.hpp"
params [
    ["_display", displayNull, [displayNull]],
    ["_message", "", [""]]
];

if (!isNull _display) then {
    (_display displayCtrl RACA_IDC_STATUS) ctrlSetText _message;
};
