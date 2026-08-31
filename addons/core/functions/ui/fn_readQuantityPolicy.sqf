#include "..\..\script_component.hpp"
params [["_display", displayNull, [displayNull]]];
if (isNull _display) exitWith {[false, -1, "arsenal", "never", "The creator display is unavailable."]};

private _limitText = trim ctrlText (_display displayCtrl RACA_IDC_LIMIT_VALUE);
private _characters = toArray _limitText;
private _digitStart = [0, 1] select ((_characters param [0, -1]) isEqualTo 45);
private _digits = if (_digitStart < count _characters) then {_characters select [_digitStart]} else {[]};
private _invalidDigits = {!(_x >= 48 && {_x <= 57})} count _digits;
if (_characters isEqualTo [] || {_digits isEqualTo []} || {_invalidDigits > 0}) exitWith {
    [false, -1, "arsenal", "never", "Maximum quantity must be a whole number: -1 (unlimited), zero, or a positive number."]
};

private _limit = parseNumber _limitText;
if (_limit < -1) exitWith {
    [false, -1, "arsenal", "never", "Maximum quantity must be -1 (unlimited), zero, or a positive number."]
};

private _scopeCtrl = _display displayCtrl RACA_IDC_LIMIT_SCOPE;
private _scope = _scopeCtrl lbData (lbCurSel _scopeCtrl);
private _resetCtrl = _display displayCtrl RACA_IDC_LIMIT_RESET;
private _reset = _resetCtrl lbData (lbCurSel _resetCtrl);
if !(_scope in ["interaction", "player", "life", "mission", "arsenal"]) then {_scope = "arsenal"};
if !(_reset in ["never", "interaction", "respawn", "round", "phase"]) then {_reset = "never"};
if (_scope isEqualTo "interaction") then {_reset = "interaction"};
[true, floor _limit, _scope, _reset, ""]
