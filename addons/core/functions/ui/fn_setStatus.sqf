#include "..\..\script_component.hpp"
params [
    ["_display", displayNull, [displayNull]],
    ["_message", "", [""]],
    ["_class", "standard", [""]],
    ["_concise", "", [""]],
    ["_detail", "", [""]]
];

if (!isNull _display) then {
    (_display displayCtrl RACA_IDC_STATUS) ctrlSetText ([_class, _message, _concise, _detail] call RACA_fnc_formatStatus);
};
