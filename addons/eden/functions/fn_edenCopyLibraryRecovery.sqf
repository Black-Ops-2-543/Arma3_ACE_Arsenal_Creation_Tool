params [["_display",displayNull,[displayNull]]];
private _state=call RACA_fnc_edenGetConfigurationState;
private _text=toJSON (_state select 3);
[_text,"Eden raw mission-library recovery"] call RACA_fnc_copyTextAndLog;
if (!isNull _display) then {(_display displayCtrl RACA_EDEN_IDC_EDITOR_STATUS) ctrlSetText format ["Copied exact raw library version %1 for recovery. No mission data changed.",_state select 1]};
true
