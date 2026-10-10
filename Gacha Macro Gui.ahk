#SingleInstance Force
SetWorkingDir %A_ScriptDir%
;Process Priority,, High

global IniFile := A_ScriptDir . "\Menu Gacha Macro Settings.ini"
global IniFileSection := "Stored Variables"
if !FileExist(IniFile) then
{
	FileAppend, , % IniFile
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
	, "ServerHop": "Off"
	, "ForceFieldWaitDetection": "Off"
	, "DisconnectDetection": "Off"
	, "WebhookName": "Gacha Macro Webhook"
	, "WBProfilePictureFile": ""
	, "DiscordUserID": 0
	, "ClippingKey": "None"}

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

Gui, Submit, NoHide

if (WebhookName && !WebhookNameSaveInput) then
{
	WebhookNameSaveInput := WebhookName
}

if (WBProfilePictureFile && !WBProfilePictureFileSaveInput) then
{
	WBProfilePictureFileSaveInput := WBProfilePictureFile
}

for v_Name, v_Value in SettingDefaults
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


KeyRecorder:
global KeysPressed
Gui, Submit, NoHide

Letters := ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m"
	, "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"]
Numbers := ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]
Functions := ["F1", "F2", "F3", "F4", "F5", "F6", "F7", "F8", "F9", "F10", "F11", "F2"]
SpecialCharacters := ["Control", "Shift", "Tab", "Alt"]

Loop
{
	for index, value in SpecialCharacters
	{
		if GetKeyState(value, "P") then
		{
			for index2, value2 in KeysPressed
			{
				if (value != value2) then
				{
					continue
				}
				else
				{
					break
				}
			}
			KeysPressed.Push(value)
		}
	}
}
return


WebhookTester:
Gui, Submit, NoHide

Message := "Successfully Sent"
Message .= "`nTesting Pings: <@" DiscordUserID ">"

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


OpenAboutGui:
if !WinExist("About Settings/Webhooks Gui") then
{
	CreateGui2()
}
else
{
	Gui, 2:Hide
}
return


EasterEgg:
global EasterEggClicks, EasterEggClicksTime
Gui, Submit, NoHide

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

if (EasterEggClicks >= 5) then
{
	Msgbox, Little Easter Egg
}
return


CreateGui() {
	global
	static TitleText, DummyText
	
	Gui1_Name := 1
	Gui_Width := 900
	Gui1_Width := 500
	Gui2_Width := 400
	Gui_Height := 300
	Gui_XPos := (A_ScreenWidth // 2) - (Gui_Width // 2)
	Gui_YPos := (A_ScreenHeight // 4) - (Gui_Height // 2) ; (A_ScreenHeight // 2) - (Gui_Height // 2)
	GuiMainColor := "111111"
	GuiTextColor := "E4F0F6"
	GuiFont := "MS Sans Serif"
	
	; GUI 1 -------------------------------------
	
	Gui, %Gui1_Name%:New
	Gui, %Gui1_Name%:Color, c%GuiMainColor%
	Gui, %Gui1_Name%:Font, c%GuiTextColor% s12, %GuiFont%
	Draw_Outline(Gui1_Name, 0, 0, Gui1_Width, Gui_Height, GuiTextColor, 2)
	
	Gui, Add, Text, vDummyText x-1000 y-1000 w0 h0, Dummy Text
	
	Gui, %Gui1_Name%:Add, Text, vTitleText +0x200 y10, Auto FF Gacha Settings
	GuiControlGet, Pos, Pos, TitleText
	GuiControl, %Gui1_Name%:Move, TitleText, % "x" ((Gui1_Width - PosW) // 2) + 2
	Draw_Line(Gui1_Name, 0, 35, Gui1_Width, 2, GuiTextColor)
	Draw_Line(Gui1_Name, Gui1_Width // 2, 35, 2, Gui_Height - 35, GuiTextColor)
	Gui, %Gui1_Name%:Font, c%GuiTextColor% s10 norm, %GuiFont%
	
	if (WBProfilePictureFile != "" && FileExist(WBProfilePictureFile)) then
	{
		Gui, %Gui1_Name%:Add, Picture, gEasterEgg vWBPFP x650 y183 w100 h100, % WBProfilePictureFile
	}
	
	;Gui, %Gui1_Name%:Add, Text, x10 y50, Webhook URL
	Gui, %Gui1_Name%:Add, Text, x10 y50, Clipping
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
	Gui, %Gui1_Name%:Add, Text, x260 y140, Server Hop
	Gui, %Gui1_Name%:Add, Text, x260 y170, Force Field Wait Detection
	Gui, %Gui1_Name%:Add, Text, x260 y200, Disconnect Detection
	
	;Gui, %Gui1_Name%:Add, Text, x260 y260, Made By Akarui
	
	Gui, %Gui1_Name%:Font, c%GuiMainColor% s10 norm, %GuiFont%
	
	;Gui, %Gui1_Name%:Add, Button, gOpenGui x115 y45 h25, Webhook Editor
	Gui, %Gui1_Name%:Add, Edit, gUpdateSettings vClippingKeySaveInput x115 y45 w111 h25, % ClippingKeyText
	Gui, %Gui1_Name%:Add, Edit, gUpdateSettings vChairSlotSaveInput Number x186 y75 w40 h25, % ChairSlot
	Gui, %Gui1_Name%:Add, Edit, gUpdateSettings vForceFieldWaitTimeSaveInput Number x186 y105 w40 h25, % ForceFieldWaitTime
	Gui, %Gui1_Name%:Add, Edit, gUpdateSettings vForceFieldCutoffSaveInput Number x186 y135 w40 h25, % ForceFieldCutoff
	Gui, %Gui1_Name%:Add, Edit, gUpdateSettings vForceFieldCheckDurationSaveInput Number x186 y165 w40 h25, % ForceFieldCheckDuration
	Gui, %Gui1_Name%:Add, Edit, gUpdateSettings vPixelOffsetSaveInput Number x186 y195 w40 h25, % PixelOffset
	Gui, %Gui1_Name%:Add, Edit, gUpdateSettings vScreenshotIntervalSaveInput Number x186 y225 w40 h25, % ScreenshotInterval
	
	SilverCoListText := SilverCutoff . "|"
	for index, value in SilverCoList
		SilverCoListText .= "|" . value
		
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
		
	if (ServerHop == "On") then
		Gui, %Gui1_Name%:Add, DropDownList, gUpdateSettings vServerHopSaveInput x436 y135 w40, % "Off|On||"
	else
		Gui, %Gui1_Name%:Add, DropDownList, gUpdateSettings vServerHopSaveInput x436 y135 w40, % "Off||On"
		
	if (ForceFieldWaitDetection == "On") then
		Gui, %Gui1_Name%:Add, DropDownList, gUpdateSettings vForceFieldWaitDetectionSaveInput x436 y165 w40, % "Off|On||"
	else
		Gui, %Gui1_Name%:Add, DropDownList, gUpdateSettings vForceFieldWaitDetectionSaveInput x436 y165 w40, % "Off||On"
	
	if (DisconnectDetection == "On") then
		Gui, %Gui1_Name%:Add, DropDownList, gUpdateSettings vDisconnectDetectionSaveInput x436 y195 w40, % "Off|On||"
	else
		Gui, %Gui1_Name%:Add, DropDownList, gUpdateSettings vDisconnectDetectionSaveInput x436 y195 w40, % "Off||On"
		
	Gui, %Gui1_Name%:Add, Button, gOpenAboutGui x370 y255 w110 h25, About Settings
	
	; GUI 2 -------------------------------------
	
	Gui, %Gui1_Name%:Font, c%GuiTextColor% s12 norm, %GuiFont%
	Gui, %Gui1_Name%:Add, Text, x614 y85 w250 h25, Webhook Customization
	Gui, %Gui1_Name%:Font, c%GuiTextColor% s10 norm, %GuiFont%
	
	Draw_Outline(Gui1_Name, Gui1_Width - 1, 0, Gui2_Width, Gui_Height, GuiTextColor, 2)
	Draw_Line(Gui1_Name, Gui1_Width - 1, 75, Gui2_Width, 2, GuiTextColor)
	
	Gui, %Gui1_Name%:Add, Text, x510 y15 w250 h25, Webhook URL
	Gui, %Gui1_Name%:Add, Text, x510 y45 w250 h25, Screenshot Webhook URL
	Gui, %Gui1_Name%:Add, Text, x510 y115 h25, Name
	Gui, %Gui1_Name%:Add, Text, x510 y147 h25, Profile Picture
	Gui, %Gui1_Name%:Add, Text, x510 y175 h25, Discord User ID
	
	Gui, %Gui1_Name%:Add, Button, x760 y255 w120 h25, About Webhooks
	Gui, %Gui1_Name%:Add, Button, gWebhookTester x520 y255 w120 h25, Webhook Tester
	Gui, %Gui1_Name%:Add, Button, gFileSelectFile x600 y143 h25, Select File (Image File)
	Gui, %Gui1_Name%:Add, Button, gUpdateSettings x772 y124 h25, Set Name/PFP
	
	Gui, %Gui1_Name%:Font, c%GuiMainColor% s10 norm, %GuiFont%
	
	Gui, %Gui1_Name%:Add, Edit, gUpdateSettings vWebhookURLSaveInput x610 y13 w270 h25, % WebhookURL
	Gui, %Gui1_Name%:Add, Edit, gUpdateSettings vScreenshotWebhookURLSaveInput x685 y43 w195 h25, % ScreenshotWebhookURL
	Gui, %Gui1_Name%:Add, Edit, vWebhookNameSaveInput x555 y113 w150 h25, % WebhookName
	Gui, %Gui1_Name%:Add, Edit, gUpdateSettings vDiscordUserIDSaveInput Number x520 y200 w120 h25, % DiscordUserID
	
	OnMessage(0x201, "WM_LBUTTONDOWN")
	Gui, %Gui1_Name%:+AlwaysOnTop +ToolWindow -Caption
	Gui, %Gui1_Name%:Show, % "NoActivate W" Gui_Width " H" Gui_Height " X" Gui_XPos " Y" Gui_YPos, Main Gui
	GuiControl, Focus, DummyText
}


CreateGui2() {
	static TitleText, DummyText
	
	Gui1_Name := 2
	Gui_Width := 900
	Gui1_Width := 500
	Gui2_Width := 400
	Gui_Height := 300
	WinGetPos, Main_Gui_XPos, Main_Gui_YPos, Main_Gui_Width, Main_Gui_Height, Main Gui
	Gui_XPos := Main_Gui_XPos
	Gui_YPos := Main_Gui_YPos + Main_Gui_Height - 2
	GuiMainColor := "111111"
	GuiTextColor := "E4F0F6"
	GuiFont := "MS Sans Serif"
	
	; GUI 1 -------------------------------------
	
	Gui, %Gui1_Name%:New
	Gui, %Gui1_Name%:Color, c%GuiMainColor%
	Draw_Outline(Gui1_Name, 0, 0, Gui1_Width, Gui_Height, GuiTextColor, 2)
	
	Gui, %Gui1_Name%:Add, Text, vDummyText x-1000 y-1000 w0 h0, Dummy Text
	
	Gui, %Gui1_Name%:Font, c%GuiTextColor% s10 norm, %GuiFont%
	
	; GUI 2 -------------------------------------
	
	Draw_Outline(Gui1_Name, Gui1_Width - 1, 0, Gui2_Width, Gui_Height, GuiTextColor, 2)
	
	OnMessage(0x201, "WM_LBUTTONDOWN")
	Gui, %Gui1_Name%:+AlwaysOnTop +ToolWindow -Caption
	Gui, %Gui1_Name%:Show, % "NoActivate W" Gui_Width " H" Gui_Height " X" Gui_XPos " Y" Gui_YPos, About Settings/Webhooks Gui
	GuiControl, Focus, DummyText
}


LoadVariables(ByRef SettingDefaults, ByRef IniFile, ByRef IniFileSection) {
	global
	
	for v_Name, v_Value in SettingDefaults
	{
		
		%v_Name% := v_Value
		IniRead, t_Value, % IniFile, % IniFileSection, % v_Name
		
		if (t_Value == "ERROR") then
		{
			IniWrite, % v_Value, % IniFile, % IniFileSection, %v_Name%
		}
		
		IniRead, t_Value, % IniFile, % IniFileSection, % v_Name
		%v_Name% := t_Value
		
		t_Value := v_Name . "SaveInput"
		
		%t_Value% := v_Value
	}
	
	if Instr(ClippingKey, " + ") then
	{
		ClippingKeys := StrSplit(ClippingKey, " + ")
		ClippingKeyText := ""
		for order, key in ClippingKeys
		{
			if (order == ClippingKeys.MaxIndex()) then
			{
				ClippingKeyText .= key
			}
			else
			{
				ClippingKeyText .= key " + "
			}		
		}
	}
	else
	{
		ClippingKeyText := "None"
		IniRead, ClippingKey, % IniFile, % IniFileSection, ClippingKey
		if (ClippingKey != "None") then
		{
			ClippingKey := "None"
			IniWrite, % ClippingKey, % IniFile, % IniFileSection, ClippingKey
		}
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
