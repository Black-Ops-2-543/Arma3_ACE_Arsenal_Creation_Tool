#include "..\..\script_component.hpp"
params [["_display", displayNull, [displayNull]]];
if (isNull _display) exitWith {false};
private _snapshot = _display getVariable ["RACA_adminSnapshot", []];
private _audit = _snapshot param [2, []];
if (_audit isEqualTo []) exitWith {(_display displayCtrl RACA_IDC_ADMIN_STATUS) ctrlSetText "There are no audit records to copy."; false};
private _lines = ["RACA runtime audit export", format ["Exported: %1", systemTimeUTC]];
{_lines pushBack str _x} forEach _audit;
forceUnicode 1;
copyToClipboard (_lines joinString toString [13, 10]);
(_display displayCtrl RACA_IDC_ADMIN_STATUS) ctrlSetText format ["Copied %1 recent audit records to the clipboard.", count _audit];
true
