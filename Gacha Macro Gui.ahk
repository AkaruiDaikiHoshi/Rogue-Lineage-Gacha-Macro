#SingleInstance Force
SetWorkingDir %A_ScriptDir%

global IniFile := A_ScriptDir . "\Menu Gacha Macro Settings.ini"
global IniFileSection := "Stored Variables"
if !FileExist(IniFile) then
{
	FileAppend, , % IniFile
}

global MacroFolders := ["DisconnectScreenshots"
	, "DiscordWebhook"
	, "Screenshots"
	, "ScrollScreenshots"
	, "SilverScreenshots"]
	
for FolderIndex, FolderName in MacroFolders
{
	%FolderName%Path := A_ScriptDir . "\" . FolderName
	if !FileExist(%FolderName%Path)
		FileCreateDir, % %FolderName%Path
}

global SettingDefaults := {"WebhookURL": ""
    , "ScreenshotWebhookURL": ""
    , "ChairSlot": 1
	, "ForceFieldWaitTime": 115
	, "PixelOffset": 5
	, "ScreenshotInterval": 60
	, "ForceFieldCutoff": 6
	, "ForceFieldCheckDuration": 3
	, "SilverCutoff": "None"
	, "SleepTimer": 0
	, "InputBlock": "On"
	, "TimeGainedToolTip": "On"
	, "ForceFieldWaitCheckDetection": "0.5"
	, "ForceFieldWaitDetection": "Off"
	, "WebhookName": "Gacha Macro Webhook"
	, "WBProfilePictureFile": ""
	, "DiscordUserID": "everyone"
	, "GachaGuyDetectionOffset": "100"
	, "SnarvCutoff": "Off"
	, "HoppaCutoff": "Off"
	, "PercCutoff": "Off"}
	
global SettingEasterEggs := {"ErrorIgnore": false
	, "DisconnectDetection": "Off"}

LoadVariables(SettingDefaults, IniFile, IniFileSection)

SSSC := 0
SilverCoList := []
Loop, Files, % A_ScriptDir . "\*.png", FR
{
	SSSC := SSSC + 1
	SplitPath, A_LoopFilePath, name, dir, ext, name_no_ext, drive
	if !InStr(name_no_ext, "silver") then
	{
		continue
	}
	Temp_SilverCoList := StrSplit(name_no_ext, "silver")
	for Temp_index, Temp_value in Temp_SilverCoList
	{
		SilverCoList.Push(Temp_value)
	}
}

Temp_SilverCoList := []

for index, value in SilverCoList
{
	if (value == "") then
	{
		P_Index := index - 1
		SilverCoList[P_Index] .= " Silver"
		SilverCoList.RemoveAt(index)
	}
}

CreateGui()
return


UpdateSettings:
global SettingDefaults, IniFile, IniFileSection
global WebhookName, WebhookNameSaveInput
global WBProfilePictureFileSaveInput, WBProfilePictureFile

loop, 10
{
	sleep, 100
	if (A_TimeIdle > 250) then
	{
		break
	}
}

Gui, Submit, NoHide

if (WebhookName && !WebhookNameSaveInput) then
{
	WebhookNameSaveInput := WebhookName
}

if (WBProfilePictureFile && !WBProfilePictureFileSaveInput) then
{
	WBProfilePictureFileSaveInput := WBProfilePictureFile
}

SnarvCutoffSaveInput := (SnarvCutoffSaveInput ? "On" : "Off")
HoppaCutoffSaveInput := (HoppaCutoffSaveInput ? "On" : "Off")
PercCutoffSaveInput := (PercCutoffSaveInput ? "On" : "Off")

for v_Name, v_Value in SettingDefaults
{
	InpVarName := v_Name . "SaveInput"
	IniWrite, % %InpVarName%, % IniFile, % IniFileSection, % v_Name
	IniRead, t_Value, % IniFile, % IniFileSection, % v_Name
	if (t_Value != %InpVarName%) then
	{
		IniWrite, % %InpVarName%, % IniFile, % IniFileSection, % v_Name
	}
}

LoadVariables(SettingDefaults, IniFile, IniFileSection)

if (ScreenshotWebhookURL == "" && WebhookURL != "") then
{
	IniWrite, % WebhookURL, % IniFile, % IniFileSection, ScreenshotWebhookURL
}

LoadVariables(SettingDefaults, IniFile, IniFileSection)

if (A_GuiControl == "Set Name/PFP") then
{
	GuiControl,, WBPFP, % WBProfilePictureFile
	GuiControl, Move, WBPFP, w100 h100

	if (WebhookURL && WebhookName && WBProfilePictureFile or WBProfilePictureFileSaveInput) then
	{
		if (WBProfilePictureFileSaveInput) then
		{
			Base64 := FileToBase64(WBProfilePictureFileSaveInput)
		}
		else
		{
			Base64 := FileToBase64(WBProfilePictureFile)
		}
		
		Payload := "{"
		. """name"":""" WebhookName ""","
		. """avatar"":""data:image/png;base64," Base64 """"
		. "}"

		Http := ComObjCreate("WinHttp.WinHttpRequest.5.1")
		Http.Open("PATCH", WebhookURL, false)
		Http.SetRequestHeader("Content-Type", "application/json")
		Http.Send(Payload)
		
		sleep, 250
		
		Http := ComObjCreate("WinHttp.WinHttpRequest.5.1")
		Http.Open("PATCH", ScreenshotWebhookURL, false)
		Http.SetRequestHeader("Content-Type", "application/json")
		Http.Send(Payload)
	}
}
return


WebhookTester:
Gui, Submit, NoHide

Message := "Successfully Sent"
if (DiscordUserID == "everyone") then
{
	Message .= "`nTesting Pings: @" DiscordUserID
}
else
{
	Message .= "`nTesting Pings: <@" DiscordUserID ">"
}

MessageFile := A_Temp . "\YekaUkufunda.txt"
FileDelete, %MessageFile%
FileAppend, %Message%, %MessageFile%
OutputFile := A_Temp . "\toffla.txt"

Command := ComSpec . " /c curl -sS"
	. " -F ""content=<" MessageFile """"
	. " """ WebhookURLSaveInput """"
	. " >""" OutputFile """ 2>&1"

RunWait, %Command%,, Hide
Loop, 10
{
	FileDelete, %MessageFile%
	FileDelete, %OutputFile%
}
return


FileSelectFile:
Gui, Submit, NoHide
FileSelectFile, WBProfilePictureFileSaveInput, 3, % A_ScriptDir . "\", Select a Profile Picture
IniWrite, % WBProfilePictureFileSaveInput, % IniFile, % IniFileSection, WBProfilePictureFile
return


ExpandGui:
Gui, Submit, NoHide
WinGetPos, Gui_X, Gui_Y, Gui_W, Gui_H, Main Gui
if !(Gui_Expanded) then
{
	Gui, %Gui1_Name%:Show, % "NoActivate W" Gui_Width " H" Gui1_Height + Gui2_Height " X" Gui_X " Y" Gui_Y, Main Gui
	Gui_Expanded := true
}
else
{
	Gui, %Gui1_Name%:Show, % "NoActivate W" Gui_Width " H" Gui_Height " X" Gui_X " Y" Gui_Y, Main Gui
	Gui_Expanded := false
}
return


ShowSettingDetails:
Gui, Submit, NoHide
WinGetPos, Gui_X, Gui_Y, , , Main Gui
Gui, 1:Hide
sleep, 50

if (A_GuiControl == "Gacha Guy Detection Offset Details") then
{
	Msgbox % AboutGachaGuyDetectionOffsetText
}
else
if (A_GuiControl == "Chair Slot Details") then
{
	Msgbox % AboutChairSlotText
}
else
if (A_GuiControl == "Force Field Wait Time Details") then
{
	Msgbox % AboutForceFieldWaitTimeText
}
else
if (A_GuiControl == "Force Field Cutoff Details") then
{
	Msgbox % AboutForceFieldCutoffText
}
else
if (A_GuiControl == "Force Field Check Duration Details") then
{
	Msgbox % AboutForceFieldCheckDurationText
}
else
if (A_GuiControl == "Pixel Offset Details") then
{
	Msgbox % AboutPixelOffsetText
}
else
if (A_GuiControl == "Screenshot Interval Details") then
{
	Msgbox % AboutScreenshotIntervalText
}
else
if (A_GuiControl == "Silver Cutoff Details") then
{
	Msgbox % AboutSilverCutOffText
}
else
if (A_GuiControl == "Sleep Timer Details") then
{
	Msgbox % AboutSleepTimerText
}
else
if (A_GuiControl == "Input Block Details") then
{
	Msgbox % AboutInputBlockText
}
else
if (A_GuiControl == "Time Gained ToolTip Details") then
{
	Msgbox % AboutTimeGainedToolTipText
}
else
if (A_GuiControl == "Force Field WaitC Detection Details") then
{
	Msgbox % AboutForceFieldWaitCheckDetectionText
}
else
if (A_GuiControl == "Force Field Wait Detection Details") then
{
	Msgbox % AboutForceFieldWaitDetectionText
}
else
if (A_GuiControl == "Webhook URL Details") then
{
	Msgbox % AboutWebhookURLText
}
else
if (A_GuiControl == "Screenshot Webhook URL Details") then
{
	Msgbox % AboutScreenshotWebhookURLText
}
else
if (A_GuiControl == "Webhook Name Details") then
{
	Msgbox % AboutWebhookNameText
}
else
if (A_GuiControl == "Webhook PFP Details") then
{
	Msgbox % AboutWebhookPFPText
}
else
if (A_GuiControl == "Discord User ID Details") then
{
	Msgbox % AboutDiscordUserIDText
}
else
if (A_GuiControl == "Webhook Tester Details") then
{
	Msgbox % AboutWebhookTesterText
}
else
if (A_GuiControl == "Spell Cutoff Details") then
{
	Msgbox % AboutSpellCutoffText
}
else
if (A_GuiControl == "Spell Cutoff") then
{
	Msgbox, 15 wanted to name this along the lines of "femboy spell"
	sleep, 200
	Gui, %Gui1_Name%:Show, % "NoActivate W" Gui_Width " H" Gui_Height " X" Gui_XPos " Y" Gui_YPos, Main Gui
	return
}

sleep, 200
Gui, %Gui1_Name%:Show, % "NoActivate W" Gui_Width " H" Gui1_Height + Gui2_Height " X" Gui_X " Y" Gui_Y, Main Gui
return


EasterEgg:
global EasterEggClicks, EasterEggClicksTime
Gui, Submit, NoHide

return
if (EasterEggClicksTime && (A_TickCount - EasterEggClicksTime) >= 1000) then
{
	EasterEggClicksTime := 0
	EasterEggClicks := 0
}

if (!EasterEggClicks or EasterEggClicks == 0) then
{
	EasterEggClicksTime := A_TickCount
	EasterEggClicks := 1
}
else
{
	EasterEggClicks++
}

if (EasterEggClicks >= 2) then
{
	if !WinExist("Easter Egg Gui") then
	{
		CreateGui2()
	}
	else
	{
		Gui, 2:Hide
	}
}
return


UpdateEasterEggSettings:
global SettingEasterEggs, IniFile, IniFileSection
Gui, Submit, NoHide

for v_Name, v_Value in SettingEasterEggs
{
	InpVarName := v_Name . "SaveInput"
	IniWrite, % %InpVarName%, % IniFile, % IniFileSection, % v_Name
	Gui, Submit, NoHide
	IniRead, t_Value, % IniFile, % IniFileSection, % v_Name
	if (t_Value != %InpVarName%) then
	{
		IniWrite, % %InpVarName%, % IniFile, % IniFileSection, % v_Name
	}
}

LoadVariables(SettingDefaults, IniFile, IniFileSection)
return


LinkOpen:
Gui, Submit, NoHide
if (A_GuiControl == "Made By Akarui") then
	Run, https://discord.com/users/1148540223681220628
else
if (A_GuiControl == "Might Be On GitHub") then
	Run, https://github.com/AkaruiDaikiHoshi
return


CreateGui() {
	global
	static TitleText, DummyText
	
	Gui1_Name := 1
	Gui_Width := 900 * 1
	Gui1_Width := 500
	Gui2_Width := 400
	Gui_Height := 300 * 1
	Gui1_Height := 300
	Gui2_Height := 300
	Gui_XPos := (A_ScreenWidth // 2) - (Gui_Width // 2)
	Gui_YPos := (A_ScreenHeight // 2) - (Gui_Height // 2) ; (A_ScreenHeight // 2) - (Gui_Height // 2)
	Gui_Expanded := false
	GuiMainColor := "111111"
	GuiTextColor := "E4F0F6"
	GuiLinkColor := "5694EA"
	GuiFont := "MS Sans Serif"
	
	; GUI 1 -------------------------------------
	
	Gui, %Gui1_Name%:New
	Gui, %Gui1_Name%:Color, c%GuiMainColor%
	Gui, %Gui1_Name%:Font, c%GuiTextColor% s12, %GuiFont%
	Draw_Outline(Gui1_Name, 0, 0, Gui1_Width, Gui1_Height, GuiTextColor, 2)
	
	Gui, Add, Text, vDummyText x-1000 y-1000 w0 h0, Dummy Text
	
	Gui, %Gui1_Name%:Add, Text, vTitleText +0x200 y10, Auto FF Gacha Settings
	GuiControlGet, Pos, Pos, TitleText
	GuiControl, %Gui1_Name%:Move, TitleText, % "x" ((Gui1_Width - PosW) // 2) + 2
	Draw_Line(Gui1_Name, 0, 35, Gui1_Width, 2, GuiTextColor)
	Draw_Line(Gui1_Name, Gui1_Width // 2, 35, 2, Gui1_Height - 35, GuiTextColor)
	Gui, %Gui1_Name%:Font, c%GuiTextColor% s10 norm, %GuiFont%
	
	; TEXTS/PICTURES ----------------------------
	
	if (WBProfilePictureFile != "" && FileExist(WBProfilePictureFile)) then
	{
		Gui, %Gui1_Name%:Add, Picture, gEasterEgg vWBPFP x650 y183 w100 h100, % WBProfilePictureFile
	}
	;Gui, %Gui1_Name%:Add, Picture, x725 y390 w150 h150, % "E:\T7\AutoHotKey Scripts\AutoHotKey Scripts\Macro Creation\Real Rogue\Utilities\Auto Gacha Menu\ScrollScreenshots\hoppascroll.png"
	
	Gui, %Gui1_Name%:Add, Text, x10 y50, Gacha Guy Detection Offset
	Gui, %Gui1_Name%:Add, Text, x10 y80, Chair Slot
	Gui, %Gui1_Name%:Add, Text, x10 y110, Force Field Wait Time
	Gui, %Gui1_Name%:Add, Text, x10 y140, Force Field Cutoff
	Gui, %Gui1_Name%:Add, Text, x10 y170, Force Field Check Duration
	Gui, %Gui1_Name%:Add, Text, x10 y200, Pixel Offset
	Gui, %Gui1_Name%:Add, Text, x10 y230, Screenshot Interval
	Gui, %Gui1_Name%:Add, Text, x10 y260, Silver Cutoff
	Gui, %Gui1_Name%:Add, Text, x260 y50, Sleep Timer
	Gui, %Gui1_Name%:Add, Text, x260 y80, Input Block
	Gui, %Gui1_Name%:Add, Text, x260 y110, Time Gained ToolTip
	Gui, %Gui1_Name%:Add, Text, x260 y140, Force Field Wait Detection
	Gui, %Gui1_Name%:Add, Text, x260 y170, Force Field WaitC Detection
	Gui, %Gui1_Name%:Add, Text, x260 y200, Spell Cutoff
	
	Gui, %Gui1_Name%:Font, c%GuiLinkColor% s10 underline, %GuiFont%
	Gui, %Gui1_Name%:Add, Text, gLinkOpen x260 y260, Made By Akarui
	Gui, %Gui1_Name%:Add, Text, gLinkOpen x765 y260, Might Be On GitHub
	
	Gui, %Gui1_Name%:Font, c%GuiMainColor% s10 norm, %GuiFont%
	; INPUT SAVES -------------------------------
	
	Gui, %Gui1_Name%:Add, Edit, gUpdateSettings vGachaGuyDetectionOffsetSaveInput Number x186 y45 w40 h25, % GachaGuyDetectionOffset
	Gui, %Gui1_Name%:Add, Edit, gUpdateSettings vChairSlotSaveInput Number x186 y75 w40 h25, % ChairSlot
	Gui, %Gui1_Name%:Add, Edit, gUpdateSettings vForceFieldWaitTimeSaveInput Number x186 y105 w40 h25, % ForceFieldWaitTime
	Gui, %Gui1_Name%:Add, Edit, gUpdateSettings vForceFieldCutoffSaveInput Number x186 y135 w40 h25, % ForceFieldCutoff
	Gui, %Gui1_Name%:Add, Edit, gUpdateSettings vForceFieldCheckDurationSaveInput Number x186 y165 w40 h25, % ForceFieldCheckDuration
	Gui, %Gui1_Name%:Add, Edit, gUpdateSettings vPixelOffsetSaveInput Number x186 y195 w40 h25, % PixelOffset
	Gui, %Gui1_Name%:Add, Edit, gUpdateSettings vScreenshotIntervalSaveInput Number x186 y225 w40 h25, % ScreenshotInterval
	
	SilverCoListText := SilverCutoff . "|"
	if (SilverCoList.MaxIndex() >= 1) then
	{
		for index, value in SilverCoList
			SilverCoListText .= "|" . value
	}
	else
	{
		SilverCoListText .= "|"
	}
		
	Gui, %Gui1_Name%:Add, DropDownList, gUpdateSettings vSilverCutoffSaveInput x115 y255 w111, % SilverCoListText
	
	Gui, %Gui1_Name%:Add, Edit, gUpdateSettings vSleepTimerSaveInput Number x436 y45 w40 h25, % SleepTimer
	
	if (InputBlock == "On") then
		Gui, %Gui1_Name%:Add, DropDownList, gUpdateSettings vInputBlockSaveInput x436 y75 w40, % "Off|On||"
	else
		Gui, %Gui1_Name%:Add, DropDownList, gUpdateSettings vInputBlockSaveInput x436 y75 w40, % "Off||On"
	
	if (TimeGainedToolTip == "On") then
		Gui, %Gui1_Name%:Add, DropDownList, gUpdateSettings vTimeGainedToolTipSaveInput x436 y105 w40, % "Off|On||"
	else
		Gui, %Gui1_Name%:Add, DropDownList, gUpdateSettings vTimeGainedToolTipSaveInput x436 y105 w40, % "Off||On"
	
	if (ForceFieldWaitDetection == "On") then
		Gui, %Gui1_Name%:Add, DropDownList, gUpdateSettings vForceFieldWaitDetectionSaveInput x436 y135 w40, % "Off|On||"
	else
		Gui, %Gui1_Name%:Add, DropDownList, gUpdateSettings vForceFieldWaitDetectionSaveInput x436 y135 w40, % "Off||On"
		
	Gui, %Gui1_Name%:Add, Edit, gUpdateSettings vForceFieldWaitCheckDetectionSaveInput Number x436 y165 w40, % ForceFieldWaitCheckDetection
	
	CheckBoxSnarvCutoff := SnarvCutoff == "On"
	CheckBoxHoppaCutoff := HoppaCutoff == "On"
	CheckBoxPercCutoff := PercCutoff == "On"
	
	Gui, %Gui1_Name%:Add, CheckBox, gUpdateSettings vSnarvCutoffSaveInput Checked%CheckBoxSnarvCutoff% c%GuiTextColor% x430 y195, Snarv
	Gui, %Gui1_Name%:Add, CheckBox, gUpdateSettings vHoppaCutoffSaveInput Checked%CheckBoxHoppaCutoff% c%GuiTextColor% x430 y215, Hoppa
	Gui, %Gui1_Name%:Add, CheckBox, gUpdateSettings vPercCutoffSaveInput Checked%CheckBoxPercCutoff% c%GuiTextColor% x430 y235, Perc
		
	Gui, %Gui1_Name%:Add, Button, gExpandGui x370 y255 w110 h25, About Settings
	
	; GUI 2 -------------------------------------
	
	Gui, %Gui1_Name%:Font, c%GuiTextColor% s12 norm, %GuiFont%
	Gui, %Gui1_Name%:Add, Text, x614 y85 w250 h25, Webhook Customization
	Gui, %Gui1_Name%:Font, c%GuiTextColor% s10 norm, %GuiFont%
	
	Draw_Outline(Gui1_Name, Gui1_Width - 1, 0, Gui2_Width, Gui2_Height, GuiTextColor, 2)
	Draw_Line(Gui1_Name, Gui1_Width - 1, 75, Gui2_Width, 2, GuiTextColor)
	
	Gui, %Gui1_Name%:Add, Text, x510 y15 w250 h25, Webhook URL
	Gui, %Gui1_Name%:Add, Text, x510 y45 w250 h25, Screenshot Webhook URL
	Gui, %Gui1_Name%:Add, Text, x510 y115 h25, Name
	Gui, %Gui1_Name%:Add, Text, x510 y147 h25, Profile Picture
	Gui, %Gui1_Name%:Add, Text, x510 y175 h25, Discord User ID
	
	;Gui, %Gui1_Name%:Add, Button, gExpandGui x760 y255 w120 h25, About Webhooks
	Gui, %Gui1_Name%:Add, Button, gWebhookTester x520 y255 w120 h25, Webhook Tester
	Gui, %Gui1_Name%:Add, Button, gFileSelectFile x600 y143 h25, Select File (Image File)
	Gui, %Gui1_Name%:Add, Button, gUpdateSettings x772 y124 h25, Set Name/PFP
	
	Gui, %Gui1_Name%:Font, c%GuiMainColor% s10 norm, %GuiFont%
	
	Gui, %Gui1_Name%:Add, Edit, gUpdateSettings vWebhookURLSaveInput x610 y13 w270 h25, % WebhookURL
	Gui, %Gui1_Name%:Add, Edit, gUpdateSettings vScreenshotWebhookURLSaveInput x685 y43 w195 h25, % ScreenshotWebhookURL
	Gui, %Gui1_Name%:Add, Edit, vWebhookNameSaveInput x555 y113 w150 h25, % WebhookName
	Gui, %Gui1_Name%:Add, Edit, gUpdateSettings vDiscordUserIDSaveInput Number x520 y200 w120 h25, % DiscordUserID
	
	; GUI 1.5 -------------------------------------
	
	Gui, %Gui1_Name%:Font, c%GuiTextColor% s10 norm, %GuiFont%
	Draw_Outline(Gui1_Name, 0, Gui2_Height - 1, Gui1_Width, Gui2_Height, GuiTextColor, 2)
	
	; About Settings Part 1
	
	AboutClippingText := "Clipping:`nInputted when you: get ff pushed, roll a good scroll, or when unusual activity is detected at gacha room."
	AboutClippingText .= " Make sure to have clipping on and have the correct clipping keys set."
	AboutClippingText .= " Make sure to have the format like this if it has multiple keys: "
	AboutClippingText .= "Alt + F10, Control + Shift + F1"
	AboutGachaGuyDetectionOffsetText := "Gacha Guy Detection Offset:`nThis will be the pixel offset"
	AboutGachaGuyDetectionOffsetText .= " when trying to detect the gacha guy."
	AboutGachaGuyDetectionOffsetText .= " Having this prevents it from detecting around the borders"
	AboutGachaGuyDetectionOffsetText .= " of your roblox window"
	AboutChairSlotText := "Chair Slot:`nThis will be the key inputted to equip and unequip chair."
	AboutChairSlotText .= " If you do not have a chair then leave this blank."
	AboutForceFieldWaitTimeText := "Force Field Wait Time:`nThis will be (in seconds) how long you stay in ff for day farming."
	AboutForceFieldCutoffText := "Force Field Cutoff:`nThis will be the count for how many force fields it takes"
	AboutForceFieldCutoffText .= " to make sure you have force field."
	AboutForceFieldCheckDurationText := "Force Field Check Duration:`nThis will be (in seconds) how long it checks for force field."
	AboutForceFieldCheckDurationText .= " Please take note that if the macro doesn't have enough correct checks for force field"
	AboutForceFieldCheckDurationText .= ", it will menu. This will also be used for detecting gacha guy."
	AboutPixelOffsetText := "Pixel Offset:`nThis will be the ""MouseMove"" offset when trying to click on gacha."
	AboutPixelOffsetText .= " This is because the cursor may not be able to click on gacha, so this moves it around a bit"
	AboutPixelOffsetText .= " in each direction."
	AboutScreenshotIntervalText := "Screenshot Interval:`nThis is delay (in minutes) between each screenshot taken."
	AboutScreenshotIntervalText .= " Please note that this may be 1-3 minutes off."
	AboutSilverCutOffText := "Silver Cutoff:`nWhen your silver reaches this EXACT amount and detetcts it"
	AboutSilverCutOffText .= ", you will be menu'd and macro will be stopped."
	
	; About Settings Part 2
	
	AboutSleepTimerText := "Sleep Timer:`nIf this isn't 0 and the macro is on, it will menu you and stop"
	AboutSleepTimerText .= " once the current time - when you started the macro is greater than the number you put."
	AboutSleepTimerText .= " Please note that this is in minutes."
	AboutInputBlockText := "Input Block:`nIf this is on then while the macro is NOT waiting in ff doing nothing"
	AboutInputBlockText .= ", it will block inputs to stop you from intefering with the macro."
	AboutInputBlockText .= " Please note that if this is on then it will ask for you to run as admin."
	AboutTimeGainedToolTipText := "Time Gained ToolTip:`nIf on then the tooltip showing time gained will be shown on screen."
	AboutTimeGainedToolTipText .= " This will also be used for the waiting tooltip."
	AboutServerHopText := "Server Hop:`nServer hops you if unusual activity is detected at gacha room"
	AboutServerHopText .= ", when you are ff pushed, or if server gets too big."
	AboutForceFieldWaitDetectionText := "Force Field Wait Detection:`nIf this is turned on the macro will"
	AboutForceFieldWaitDetectionText .= " check for force field while waiting for days."
	AboutForceFieldWaitCheckDetectionText := "Force Field Wait Check Detection:`nThis is the how long (in seconds) that the macro will check"
	AboutForceFieldWaitCheckDetectionText .= " for force field while waiting."
	AboutForceFieldWaitCheckDetectionText .= " Please take note that the lower this is, the faster you menu when out of ff."
	AboutDisconnectDetectionText := "DisconnectDetection:`nThis will make you rejoin if you are disconnected for whatever reason."
	AboutSpellCutoffText := "Spell Cutoff:`nThe macro will stop after it has:`n"
	AboutSpellCutoffText .= "Detected a spell you have checked off and when it menus."
	
	; Gui Adds
	
	Gui, %Gui1_Name%:Add, Button, gShowSettingDetails x10 y314 h25, Gacha Guy Detection Offset Details
	Gui, %Gui1_Name%:Add, Button, gShowSettingDetails x10 y349 h25, Chair Slot Details
	Gui, %Gui1_Name%:Add, Button, gShowSettingDetails x10 y384 h25, Force Field Wait Time Details
	Gui, %Gui1_Name%:Add, Button, gShowSettingDetails x10 y419 h25, Force Field Cutoff Details
	Gui, %Gui1_Name%:Add, Button, gShowSettingDetails x10 y454 h25, Force Field Check Duration Details
	Gui, %Gui1_Name%:Add, Button, gShowSettingDetails x10 y489 h25, Pixel Offset Details
	Gui, %Gui1_Name%:Add, Button, gShowSettingDetails x10 y524 h25, Screenshot Interval Details
	Gui, %Gui1_Name%:Add, Button, gShowSettingDetails x10 y559 h25, Silver Cutoff Details
	
	Gui, %Gui1_Name%:Add, Button, gShowSettingDetails x270 y314 h25, Sleep Timer Details
	Gui, %Gui1_Name%:Add, Button, gShowSettingDetails x270 y349 h25, Input Block Details
	Gui, %Gui1_Name%:Add, Button, gShowSettingDetails x270 y384 h25, Time Gained ToolTip Details
	Gui, %Gui1_Name%:Add, Button, gShowSettingDetails x270 y419 h25, Force Field Wait Detection Details
	Gui, %Gui1_Name%:Add, Button, gShowSettingDetails x270 y454 h25, Force Field WaitC Detection Details
	Gui, %Gui1_Name%:Add, Button, gShowSettingDetails x270 y489 h25, Spell Cutoff Details
	
	Gui, %Gui1_Name%:Add, Text, x270 y550 w220 +Wrap, Theres something you can click on for a little easter egg...
	
	; GUI 2.5 -------------------------------------
	
	Draw_Outline(Gui1_Name, Gui1_Width - 1, Gui2_Height - 1, Gui_Width - Gui1_Width, Gui2_Height, GuiTextColor, 2)
	
	; About Webhooks Part 1
	
	AboutWebhookURLText := "Webhook URL:`nThis is the URL to the webhook you are using."
	AboutWebhookURLText .= " Please take note that the macro will not work without one. (because I am too lazy to remove it)"
	AboutScreenshotWebhookURLText := "Screenshot Webhook URL:`nThis will be the url to the webhook you are"
	AboutScreenshotWebhookURLText .= " using for screenshots. If this is blank then it will copy ""Webhook URL"""
	AboutWebhookNameText := "Webhook Name:`nName customization for your webhook."
	AboutWebhookPFPText := "Webhook PFP:`nPFP customization for your webhook."
	AboutDiscordUserIDText := "Discord User ID:`nSince you might be wondering why this macro needs your discord user ID."
	AboutDiscordUserIDText .= " The webhooks will ping you if anything bad or good happens i.e rolling a good spell, getting ff pushed."
	AboutDiscordUserIDText .= " If this is blank it will ping @everyone"
	AboutWebhookTesterText := "Webhook Tester:`nTests out your webhook to see if everything is fine."
	AboutWebhookTesterText .= " Please take note that this will send a message to your webhook and if it doesn't then something is wrong."
	
	; Gui Adds
	
	Gui, %Gui1_Name%:Add, Button, gShowSettingDetails x509 y314 h25, Webhook URL Details
	Gui, %Gui1_Name%:Add, Button, gShowSettingDetails x509 y349 h25, Screenshot Webhook URL Details
	Gui, %Gui1_Name%:Add, Button, gShowSettingDetails x509 y384 h25, Webhook Name Details
	Gui, %Gui1_Name%:Add, Button, gShowSettingDetails x509 y419 h25, Webhook PFP Details
	Gui, %Gui1_Name%:Add, Button, gShowSettingDetails x509 y454 h25, Discord User ID Details
	Gui, %Gui1_Name%:Add, Button, gShowSettingDetails x509 y489 h25, Webhook Tester Details
	
	Gui, %Gui1_Name%:Add, Text, x509 y550 w220 +Wrap, They say you click on it twice within a second...
	Gui, %Gui1_Name%:Add, Text, x750 y550 w140 +Wrap, The easter egg gives more features...
	
	OnMessage(0x201, "WM_LBUTTONDOWN")
	Gui, %Gui1_Name%:+AlwaysOnTop +ToolWindow -Caption
	Gui, %Gui1_Name%:Show, % "NoActivate W" Gui_Width " H" Gui_Height " X" Gui_XPos " Y" Gui_YPos, Main Gui
	GuiControl, Focus, DummyText
}


CreateGui2() {
	global
	static TitleText, DummyText
	
	WinGetPos, Gui_X, Gui_Y, Gui_W, Gui_H, Main Gui
	
	Gui2_Name := 2
	Gui_Width2 := 400
	Gui_Height2 := 300
	Gui_XPos2 := (Gui_X + (Gui_W // 2) - (Gui_Width2 // 2)) ; (A_ScreenWidth // 2) - (Gui_Width2 // 2)
	Gui_YPos2 := Gui_Y + Gui_H
	GuiMainColor := "111111"
	GuiTextColor := "E4F0F6"
	GuiFont := "MS Sans Serif"
	
	; GUI 1 -------------------------------------
	
	Gui, %Gui2_Name%:New
	Gui, %Gui2_Name%:Color, c%GuiMainColor%
	Gui, %Gui2_Name%:Font, c%GuiTextColor% s10 norm, %GuiFont%
	Draw_Outline(Gui2_Name, 0, 0, Gui_Width2, Gui_Height2, GuiTextColor, 2)
	
	Gui, Add, Text, vDummyText x-1000 y-1000 w0 h0, Dummy Text
	
	Gui, %Gui2_Name%:Add, Text, x10 y10, Error Ignore
	Gui, %Gui2_Name%:Add, Text, x10 y40, Disconnect Detection
	
	
	Gui, %Gui2_Name%:Add, CheckBox, gUpdateEasterEggSettings vErrorIgnoreSaveInput Checked%ErrorIgnore% x90 y11, 
	if (DisconnectDetection == "On") then
		Gui, %Gui2_Name%:Add, DropDownList, gUpdateEasterEggSettings vDisconnectDetectionSaveInput x145 y36 w40, % "Off|On||"
	else
		Gui, %Gui2_Name%:Add, DropDownList, gUpdateEasterEggSettings vDisconnectDetectionSaveInput x145 y36 w40, % "Off||On"
	
	Gui, %Gui2_Name%:+AlwaysOnTop +ToolWindow -Caption
	Gui, %Gui2_Name%:Show, % "NoActivate W" Gui_Width2 " H" Gui_Height2 " X" Gui_XPos2 " Y" Gui_YPos2, Easter Egg Gui
	GuiControl, Focus, DummyText
}


LoadVariables(ByRef SettingDefaults, ByRef IniFile, ByRef IniFileSection) {
	global
	
	for v_Name, v_Value in SettingDefaults
	{
		%v_Name% := v_Value
		IniRead, t_Value, % IniFile, % IniFileSection, % v_Name
		
		if (v_Name == "DiscordUserID" && t_Value == "") then
		{
			t_Value := "everyone"
			IniWrite, % t_Value, % IniFile, % IniFileSection, %v_Name%
		}
		
		if (t_Value == "ERROR") then
		{
			IniWrite, % v_Value, % IniFile, % IniFileSection, %v_Name%
		}
		
		IniRead, t_Value, % IniFile, % IniFileSection, % v_Name
		%v_Name% := t_Value
		
		t_Value := v_Name . "SaveInput"
		
		%t_Value% := v_Value
	}
	
	for v_Name, v_Value in SettingEasterEggs
	{
		
		%v_Name% := v_Value
		IniRead, t_Value, % IniFile, % IniFileSection, % v_Name
		%v_Name% := t_Value
		
		t_Value := v_Name . "SaveInput"
		
		%t_Value% := v_Value
	}
}


FileToBase64(FilePath)
{
    File := FileOpen(FilePath, "r")
    if !IsObject(File)
        return ""

    Size := File.Length
    VarSetCapacity(Data, Size, 0)
    File.RawRead(Data, Size)
    File.Close()

    DllCall("Crypt32.dll\CryptBinaryToString"
        , "Ptr", &Data
        , "UInt", Size
        , "UInt", 0x40000001 ; BASE64 | NOCRLF
        , "Ptr", 0
        , "UInt*", Length)

    VarSetCapacity(Base64, Length * 2, 0)

    DllCall("Crypt32.dll\CryptBinaryToString"
        , "Ptr", &Data
        , "UInt", Size
        , "UInt", 0x40000001
        , "Str", Base64
        , "UInt*", Length)

    return Base64
}


SystemTime()
{
	SetBatchLines, -1
	Process Priority,, High
    freq := 0, tick := 0
    If (!freq)
        DllCall("QueryPerformanceFrequency", "Int64*", freq)
    DllCall("QueryPerformanceCounter", "Int64*", tick)
    Return tick / freq * 1000
}


HyperSleep(value)
{
	SetBatchLines, -1
	Process Priority,, High
    s_begin_time := SystemTime()
    freq := 0, t_current := 0
    DllCall("QueryPerformanceFrequency", "Int64*", freq)
    s_end_time := (s_begin_time + value) * freq / 1000 
    While, (t_current < s_end_time)
    {
        If (s_end_time - t_current) > 20000
        {
            DllCall("Winmm.dll\timeBeginPeriod", UInt, 1)
            DllCall("Sleep", "UInt", 1)
            DllCall("Winmm.dll\timeEndPeriod", UInt, 1)
            DllCall("QueryPerformanceCounter", "Int64*", t_current)
        }
        Else
            DllCall("QueryPerformanceCounter", "Int64*", t_current)
    }
}


CoreSleep(s)
{
    SetBatchLines, -1
    Process Priority,, High

    DllCall("QueryPerformanceFrequency", "Int64*", freq)
    DllCall("QueryPerformanceCounter", "Int64*", CounterBefore)
    
    While (((counterAfter - CounterBefore) / freq * 1000) < s)
        DllCall("QueryPerformanceCounter", "Int64*", CounterAfter)

    return ((counterAfter - CounterBefore) / freq * 1000) 
}


Draw_Outline(Gui_Name,x,y,w,h,Color:="Black",thickness:=1){
    x2:=X+W-thickness
    Gui,% Gui_Name ":Add",Progress,% "x" X " y" Y " w" W " h" thickness " Background" Color 
    Gui,% Gui_Name ":Add",Progress,% "x" X " y" Y " w" thickness " h" H " Background" Color 
    Gui,% Gui_Name ":Add",Progress,% "x" X " y" Y+H-thickness " w" W " h" thickness " Background" Color 
    Gui,% Gui_Name ":Add",Progress,% "x" X+W-thickness " y" Y " w" thickness " h" H " Background" Color     
}
Draw_Line(Gui_Name,x,y,w,h,color){
    Gui,% Gui_Name ":Add",Progress,% "x" X " y" Y " w" W " h" H " Background" Color 
}


WM_LBUTTONDOWN(wParam, lParam, msg, hwnd) {
		if (A_GuiControl == "") then
			PostMessage, 0xA1, 2,,, A
}


#If


*$f7::
Reload
return


*$End::
ExitApp
return


RemoveTT:
ToolTip
return
