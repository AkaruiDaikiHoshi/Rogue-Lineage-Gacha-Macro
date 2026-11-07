#IfWinActive, ahk_exe RobloxPlayerBeta.exe
#SingleInstance Force
SetWorkingDir %A_ScriptDir%
Process Priority,, High

#NoEnv
#MaxHotkeysPerInterval 99000000
#HotkeyInterval 99000000
#KeyHistory 0
ListLines Off
SetBatchLines, -1
SetKeyDelay, -1, -1
SetMouseDelay, -1
;SetDefaultMouseSpeed, 0
SetWinDelay, -1
SetControlDelay, -1

DllCall("ntdll\ZwSetTimerResolution", "UInt", 5000, "UInt", 1, "UInt*", currentRes)

CoordMode, Mouse, Screen
CoordMode, Pixel, Screen
CoordMode, ToolTip, Screen

global IniFile := A_ScriptDir . "\Menu Gacha Macro Settings.ini"
global IniFileSection := "Stored Variables"
if !FileExist(IniFile) then
{
	Msgbox, Open The Gui First.
	ExitApp
}

IniRead, GachaGuyDetectionOffset, % IniFile, % IniFileSection, GachaGuyDetectionOffset
IniRead, ChairSlot, % IniFile, % IniFileSection, ChairSlot
IniRead, ForceFieldWaitTime, % IniFile, % IniFileSection, ForceFieldWaitTime
IniRead, ForceFieldCutoff, % IniFile, % IniFileSection, ForceFieldCutoff
IniRead, ForceFieldCheckDuration, % IniFile, % IniFileSection, ForceFieldCheckDuration
IniRead, PixelOffset, % IniFile, % IniFileSection, PixelOffset
IniRead, ScreenshotInterval, % IniFile, % IniFileSection, ScreenshotInterval
IniRead, SilverCutoff, % IniFile, % IniFileSection, SilverCutoff
IniRead, SleepTimer, % IniFile, % IniFileSection, SleepTimer
IniRead, InputBlock, % IniFile, % IniFileSection, InputBlock
IniRead, TimeGainedToolTip, % IniFile, % IniFileSection, TimeGainedToolTip
IniRead, ForceFieldWaitCheckDetection, % IniFile, % IniFileSection, ForceFieldWaitCheckDetection
IniRead, ForceFieldWaitDetection, % IniFile, % IniFileSection, ForceFieldWaitDetection
IniRead, WebhookURL, % IniFile, % IniFileSection, WebhookURL
IniRead, ScreenshotWebhookURL, % IniFile, % IniFileSection, ScreenshotWebhookURL
IniRead, DiscordUserID, % IniFile, % IniFileSection, DiscordUserID
IniRead, SnarvCutoff, % IniFile, % IniFileSection, SnarvCutoff
IniRead, HoppaCutoff, % IniFile, % IniFileSection, HoppaCutoff
IniRead, PercCutoff, % IniFile, % IniFileSection, PercCutoff

IniRead, ErrorIgnore, % IniFile, % IniFileSection, ErrorIgnore
IniRead, DisconnectDetection, % IniFile, % IniFileSection, DisconnectDetection

global InputBlock := InputBlock == "On"
global TimeGainedToolTip := TimeGainedToolTip == "On"
global ForceFieldWaitDetection := ForceFieldWaitDetection == "On"
global HasSilverCutoff := SilverCutoff != "None"
global HasSnarvCutoff := SnarvCutoff == "On"
global HasHoppaCutoff := HoppaCutoff == "On"
global HasPercCutoff := PercCutoff == "On"

global DisconnectDetection := DisconnectDetection == "On" ; idk

if (!A_IsAdmin && InputBlock) then
{
	Run *RunAs "%A_ScriptFullPath%"
	ExitApp
	return
}

if (DisconnectDetection) then ; gets file paths for disconnect screenshots
{
	global DisconnectSSC := 0 ; sdisconnect screenshot count
	global DisconnectScreenshots := []
	Loop, Files, % A_ScriptDir . "\*.png", FR
	{
		SplitPath, A_LoopFilePath, name, dir, ext, name_no_ext, drive
		if InStr(name_no_ext, "connect") then
		{
			DisconnectSSC := DisconnectSSC + 1
			DisconnectScreenshots.Push(A_LoopFilePath) ; puts file path in array
		}
		else
		{
			continue
		}
	}
}

if (HasSilverCutoff) then ; gets file paths for silver screenshots
{
	global SilverSSC := 0 ; silver screenshot count
	global SilverScreenshots := []
	Loop, Files, % A_ScriptDir . "\*.png", FR
	{
		SplitPath, A_LoopFilePath, name, dir, ext, name_no_ext, drive
		if InStr(name_no_ext, "silver") then
		{
			SilverSSC := SilverSSC + 1
			SilverScreenshots.Push(A_LoopFilePath) ; puts file path in array
		}
		else
		{
			continue
		}
	}
}

global ScrollSSC := 0 ; scroll screenshot count
global ScrollScreenshots := []
global ScrollNames := []
Loop, Files, % A_ScriptDir . "\*.png", FR
{
	SplitPath, A_LoopFilePath, name, dir, ext, name_no_ext, drive
	if InStr(name_no_ext, "scroll") then
	{
		ScrollSSC := ScrollSSC + 1
		ScrollScreenshots.Push(A_LoopFilePath) ; puts file path in array
		ScrollNames.Push(StrSplit(name_no_ext, "scroll")[1])
	}
	else
	{
		continue
	}
}

for ScrollIndex, ScrollName in ScrollNames
{
	%ScrollName%Found := false
}

global WebhookMessage := ""

global MacroIndex := 0 ; how many times it has looped
global MacroForceStop := false

global SleepTimer_Miliseconds := SleepTimer * 1000
global MenuButtonShowTime := 6
global MenuButtonShowTime_Miliseconds := MenuButtonShowTime * 1000
global TimeGained := 0
global TimeGainedOutputText := ""
global ToolTipCords := [A_ScreenWidth // 1.52, A_ScreenHeight // 1.91, A_ScreenWidth // 1.52, A_ScreenHeight // 2]
global ScreenshotFilePath := ""

global ForceFieldColors := ["0xB9B496", "0x9FA16B", "0xC2C6A2", "0x50A787", "0xD3D8C8", "0xBBB699"]
global ForceFieldCount := 0
global ForceFieldWaitCount := 0
global ForceFieldWaitTime_Miliseconds := ForceFieldWaitTime * 1000
global ForceFieldCheckDuration_Miliseconds := ForceFieldCheckDuration * 1000
global ForceFieldCheckDuration_2_Miliseconds := ForceFieldWaitCheckDetection * 1000
global ForceFieldDetection_TopLeftCorner := [A_ScreenWidth // 2.74, A_ScreenHeight // 2.88]
global ForceFieldDetection_BottomRightCorner := [A_ScreenWidth // 1.59, A_ScreenHeight // 1.32]
global ForceFieldDetectionVariation_1 := 20
global ForceFieldDetectionVariation_2 := 15
global FirstForceFieldDetected := false
global ForceFieldSecondsLeft := 0

global GachaGuyColors := ["0xF5A0B7", "0xF6A3B8", "0xF5A2B6", "0x88444E", "0x7C0AAD"] ; , "0xFFDFC4"]
global GachaGuyColors := ["0xF5A0B7"]
global GGDO := GachaGuyDetectionOffset ; shorter name
global GachaGuyDetectionSections := [0 + GGDO, 0 + GGDO, 860, A_ScreenHeight - GGDO ; Left Section
		, 0 + GGDO, 0 + GGDO, A_ScreenWidth - GGDO, 480 ; Top Section
		, 1050, 0 + GGDO, A_ScreenWidth - GGDO, A_ScreenHeight - GGDO ; Right Section
		, 0 + GGDO, 700, A_ScreenWidth - GGDO, A_ScreenHeight - GGDO] ; Bottom Section
global GachaGuyCount := 0
global GachaGuyDetectionVariation := 25
global GachaGuySpinStop := false
global GGx := 0 ; gacha guy found x
global GGy := 0 ; gacha guy found y
global GachaGuyErrorLevel := 1

global ScrollDetection_TopLeftCorner := [A_ScreenWidth // 4.09, A_ScreenHeight // 2.41]
global ScrollDetection_BottomRightCorner := [A_ScreenWidth // 1.33, A_ScreenHeight // 1.08]
global ScrollDetectionVariation := 120

global SilverDetection_TopLeftCorner := [0, A_ScreenHeight // 1.05] ; its on the far left so thats why x is 0
global SilverDetection_BottomRightCorner := [A_ScreenWidth // 15.23, A_ScreenHeight] ; bottom of screen
global SilverDetectionVariation := 120
global LowSilver := false

global NoGachaGuyIndex := [] ; if no detect then it will go here and put the MacroIndex

global ScreenshotInterval_Miliseconds := ((ScreenshotInterval * 1000) * 60)
global LastScreenshot := 0
return


$f3::
WinGet, RobloxID, ID, A
MacroStartTime := A_TickCount ; sleep timer, etc
LastScreenshot := A_TickCount ; so screenshotinterval doesnt happen on first macroindex

Loop
{

if (MacroForceStop) then
{
	WebhookMessage := "MACRO STOPPED"
	SendWebhook(WebhookMessage)
	return
}

MacroIndex++

ResetVariables()

ToolTip, , , , 1

if (InputBlock) then
	BlockInput, On

WinActivate, ahk_id %RobloxID%

UiNavigation()

ForceFieldStartTime_1 := A_TickCount

sleep, 3000 ; Bypasses lag if you spawn in while in a ping spike
GoSub, UseChair

GoSub, ResetCameraAngle

sleep, 2000 ; No more motion from resetting camera

for index, ForceFieldColorID in ForceFieldColors
{
	PixelSearch, FFx, FFy, % ForceFieldDetection_TopLeftCorner[1], % ForceFieldDetection_TopLeftCorner[2], % ForceFieldDetection_BottomRightCorner[1], % ForceFieldDetection_BottomRightCorner[2], % ForceFieldColorID, % ForceFieldDetectionVariation_1, Fast
	if (ErrorLevel = 0) then
	{
		FirstForceFieldDetected := true
		break
	}
}

if (FirstForceFieldDetected) then
{
	ForceFieldDetectionStartTime_1 := A_TickCount
	while ((A_TickCount - ForceFieldDetectionStartTime_1) < ForceFieldCheckDuration_Miliseconds && ForceFieldCount <= ForceFieldCutoff)
	{
		for index, ForceFieldColorID in ForceFieldColors
		{
			PixelSearch, FFx, FFy, % ForceFieldDetection_TopLeftCorner[1], % ForceFieldDetection_TopLeftCorner[2], % ForceFieldDetection_BottomRightCorner[1], % ForceFieldDetection_BottomRightCorner[2], % ForceFieldColorID, % ForceFieldDetectionVariation_1, Fast
			if (ErrorLevel = 0) then
			{
				ForceFieldCount++
			}
		}
	}
}

if (ForceFieldCount < ForceFieldCutoff) then ; NO FF
{
	UiNavigation()
	
	WebhookMessage := "NO FORCE FIELD`nFORCE FIELD COUNT: " ForceFieldCount
	WebhookMessage .= "`nMACRO INDEX: " MacroIndex
	WebhookMessage .= "``````INFORMATION:`nAfter Unmenuing`nDid not detect force field at first (Duration)`nOr`nDid not capture enough force field pixels (Cutoff)``````"
	SendWebhook(WebhookMessage)
	return
}

GachaGuyDetectionStartTime := A_TickCount
while ((A_TickCount - GachaGuyDetectionStartTime) < (ForceFieldCheckDuration_Miliseconds * 2) && GachaGuyCount < 1)
{
	for GGi, GachaGuyColorID in GachaGuyColors
	{
		for GSi, Cords in GachaGuyDetectionSections
		{
			; its 4 cords for every section
			; theres 4 sections
			; it goes: 1, 5, 9, 13
			Cords := GachaGuyDetectionSections ; makes it so that the pixel search doesnt go too far
			if (GSi == 1 or GSi == 5 or GSi == 9 or GSi == 13) then
			{
				PixelSearch, GGx, GGy, % Cords[GSi], % Cords[GSi + 1], % Cords[GSi + 2], % Cords[GSi + 3], % GachaGuyColorID, % GachaGuyDetectionVariation, Fast
				if (ErrorLevel == 0) then
				{
					GachaGuyErrorLevel := ErrorLevel
					break
				}
			}
		}
		
		if (GachaGuyErrorLevel = 1) then
		{
			if (!GachaGuySpinStop) then
			{
				sleep, 500
				SendInput, {,}
				sleep, 500
			}
		}
		else
		if (GachaGuyErrorLevel = 0) then
		{
			GachaGuyCount++
			GachaGuySpinStop := true
			break
		}
	}
}

if (GachaGuyCount >= 1) then
{
	PixelOffsetCords := [GGx - PixelOffset, GGy - PixelOffset
	, GGx + PixelOffset, GGy - PixelOffset
	, GGx + PixelOffset, GGy + PixelOffset
	, GGx - PixelOffset, GGy + PixelOffset]
	
	; ^ x cords are odd, y cords are even
	
	for index, CordValue in PixelOffsetCords
	{
		if (Mod(index, 2) == 1) then ; odd number, x cord
		{
			MouseMove, % CordValue, % PixelOffsetCords[index + 1] ; gets the y cords
			sleep, 25
			Loop, 3
			{
				SendInput, {click}
				sleep, 25
			}
		}
		else
		{
			continue ; even number, y cord
		}
	}
	
	sleep, 3000 ; Delay to let the captcha pop up
	
	UiNavigation("down")
	
	sleep, 2000
	
	UiNavigation("down")
		
	sleep, 6000
	
	UiNavigation("down")
	
	; ^ the downs are because of the menu button.
	
	sleep, 25
	
	GoSub, UseChair
}
else ; NO GACHA GUY
{
	NoGachaGuyIndex.Push(MacroIndex)
	WebhookMessage := "NO GACHA GUY`nNO GACHA GUY COUNT: " NoGachaGuyIndex.MaxIndex()
	WebhookMessage .= "`nMACRO INDEX: " MacroIndex
	SendWebhook(WebhookMessage)
	if (NoGachaGuyIndex.MaxIndex() >= 3) then ; didnt detect gacha guy 3+ times
	{
		if (NoGachaGuyIndex[NoGachaGuyIndex.MaxIndex()] - NoGachaGuyIndex[NoGachaGuyIndex.MaxIndex() - 2] == 2) then
		{
			; ^ didnt detect 3 times in a row
			UiNavigation()
			
			MacroForceStop := true
			
			WebhookMessage := "NO GACHA GUY 3 TIMES IN A ROW"
			WebhookMessage .= "`nMOST LIKELY HAVE DIED"
			SendWebhook(WebhookMessage, true)
		}
		NoGachaGuyIndex := []
	}
}

SendInput, `` ; open inv
sleep, 1000 ; let inv open

for SLindex, SLFilePath in ScrollScreenshots
{
	ImageSearch, SLx, SLy, % ScrollDetection_TopLeftCorner[1], % ScrollDetection_TopLeftCorner[2], % ScrollDetection_BottomRightCorner[1], % ScrollDetection_BottomRightCorner[2], % "*" ScrollDetectionVariation " " SLFilePath
	if (ErrorLevel = 0) then
	{
		for ScrollIndex, ScrollName in ScrollNames
		{
			if InStr(SLFilePath, ScrollName) then
			{
				if !(%ScrollName%Found) then
					SendWebhook("ROLLED: " ScrollName, true)
				%ScrollName%Found := true
			}
			
			if (HasSnarvCutoff) then
			{
				if InStr(ScrollName, "snarv") then
					MacroForceStop := true
			}

			if (HasHoppaCutoff) then
			{
				if InStr(ScrollName, "hoppa") then
					MacroForceStop := true
			}
			
			if (HasPercCutoff) then
			{
				if InStr(ScrollName, "perc") then
					MacroForceStop := true
			}
		}
	}
	else
	{
		continue
	}
}

if !(LowSilver) then
{
	for SRindex, SRFilePath in SilverScreenshots
	{
		ImageSearch, SRx, SRy, % SilverDetection_TopLeftCorner[1], % SilverDetection_TopLeftCorner[2], % SilverDetection_BottomRightCorner[1], % SilverDetection_BottomRightCorner[2], % "*" SilverDetectionVariation " " SRFilePath
		if (ErrorLevel = 0) then
		{
			MacroForceStop := true
			LowSilver := true
			SendWebhook("LOW ON SILVER", true)
			break
		}
		else
		{
			continue
		}
	}
}

sleep, 1000 ; let checks happen
SendInput, `` ; close inv

if (TimeGainedToolTip) then
{
	; TimeGained gets turned into seconds and minutes
	TimeGainedOutputText := "Time Gained: " Round((TimeGained / 1000), 0) " Seconds (" Round((TimeGained / 60000), 2) " Minute(s))"
	ToolTip, % TimeGainedOutputText, % ToolTipCords[1], % ToolTipCords[2], 1
}

if ((MacroStartTime - ScreenshotInterval_Miliseconds) >= 0) then
{
	if ((A_TickCount - LastScreenshot) >= ScreenshotInterval_Miliseconds) then
	{
		; ^ if the time between current and last screenshot is more than
		; whatever screenshotinterval is
		LastScreenshot := A_TickCount
		SendInput, {alt down}
		sleep, 250
		SendInput, {PrintScreen}
		sleep, 250
		SendInput, {alt up}
		ScreenshotFilePath := A_ScriptDir . "\Screenshots" . "\Index" . MacroIndex . "Screenshot.png"
		RunWait, PowerShell -Command "Add-Type -AssemblyName System.Windows.Forms; $clipboard = [Windows.Forms.Clipboard]::GetImage(); $clipboard.Save('%ScreenshotFilePath%')",, Hide
		SendWebhook("MACRO INDEX: " MacroIndex, false, ScreenshotFilePath)
	}
}

if (InputBlock) then
	BlockInput, Off

while ((A_TickCount - ForceFieldStartTime_1) < (ForceFieldWaitTime_Miliseconds))
{
	if (ForceFieldWaitDetection) then
	{
		Temp_ForceFieldWaitCount := ForceFieldWaitCount ; 0
		ForceFieldDetectionStartTime_2 := A_TickCount
		while ((A_TickCount - ForceFieldDetectionStartTime_2) < ForceFieldCheckDuration_2_Miliseconds && Temp_ForceFieldWaitCount < ForceFieldCutoff)
		{
			for index, ForceFieldColorID in ForceFieldColors
			{
				PixelSearch, FFx, FFy, % ForceFieldDetection_TopLeftCorner[1], % ForceFieldDetection_TopLeftCorner[2], % ForceFieldDetection_BottomRightCorner[1], % ForceFieldDetection_BottomRightCorner[2], % ForceFieldColorID, % ForceFieldDetectionVariation_2, Fast
				if (ErrorLevel = 0) then
				{
					Temp_ForceFieldWaitCount++
					if (Temp_ForceFieldWaitCount >= ForceFieldCutoff) then
					{
						break
					}
				}
			}
		}
		
		if (Temp_ForceFieldWaitCount && Temp_ForceFieldWaitCount < ForceFieldCutoff) then ; NO FF
		{
			UiNavigation()
			
			WebhookMessage := "NO FORCE FIELD`nFORCE FIELD COUNT: " Temp_ForceFieldWaitCount
			WebhookMessage .= "`nMACRO INDEX: " MacroIndex
			WebhookMessage .= "``````INFORMATION:`nDuring Force Field Wait`nDid not detect force field at first (Duration)`nOr`nDid not capture enough force field pixels (Cutoff)``````"
			SendWebhook(WebhookMessage)
			
			return ; make macro stop
		}
	}
	
	if (TimeGainedToolTip) then
	{
		ForceFieldSecondsLeft := Round((ForceFieldWaitTime_Miliseconds - (A_TickCount - ForceFieldStartTime_1)) / 1000, 0)
		ToolTip, % "Waiting: " ForceFieldSecondsLeft " seconds...", % ToolTipCords[3], % ToolTipCords[4], 2
	}
}

if (InputBlock) then
	BlockInput, On

WinActivate, ahk_id %RobloxID%

ToolTip, , , , 2 ; removes the tooltip
TimeGained := TimeGained + (A_TickCount - ForceFieldStartTime_1)

Loop, 3
{
	UiNavigation()
}

if (SleepTimer) then
{
	if (SleepTimer_Miliseconds >= (A_TickCount - MacroStartTime)) then
	{
		MacroForceStop := true
		SendWebhook("HIT SLEEP TIMER`nMACRO INDEX: " MacroIndex)
	}
}

sleep, % 10 * 1000 ; delay so the play button can show up again.
ResetVariables()
}
return


ResetCameraAngle:
SendInput, {,}
Loop, 12
{
	sleep, 25
	SendInput, {PgUp}
}
Loop, 3
{
	sleep, 25
	SendInput, {PgDn}
}
Loop, 12
{
	sleep, 25
	SendInput, i
}
Loop, 4
{
	sleep, 25
	SendInput, o
}
return


UseChair:
global ChairSlot
SendInput, % ChairSlot
SendInput, {click}
Loop, 20
{
	sleep, 25
	SendInput, {click}
}
sleep, 25
SendInput, % ChairSlot
return


ResetVariables() {
	global
	
	FirstForceFieldDetected := false
	ForceFieldCount := 0
	GachaGuyErrorLevel := 1
	GachaGuyCount := 0
	GachaGuySpinStop := false
	Temp_ForceFieldWaitCount := 0
}


UiNavigation(Direction := "") {
	global
	
	SendInput, \
	sleep, 25
	if (Direction != "") then
	{
		SendInput, {%Direction%}
		sleep, 25
	}
	SendInput, {enter}
	sleep, 25
	SendInput, \
}


SendWebhook(Message := "", Ping := false, ImagePath := "") {
	global
	
	if (WebhookURL != "") then
	{
		if (Ping) then
			Message .= "`n<@" DiscordUserID ">"
			
		if Instr(Message, "NO") then
		{
			ToolTip, , , , 1
			ToolTip, , , , 2
		}
		
		TempLogFile := A_ScriptDir . "\DiscordWebhook\DiscordWebhookLog.txt"
		TempMessageSendFile := A_ScriptDir . "\DiscordWebhook\DiscordWebhookMessage.txt"
		FileDelete, %TempMessageSendFile%
		FileAppend, %Message%, %TempMessageSendFile%
		
		Webhook := WebhookURL
		if (ImagePath != "" && ScreenshotWebhookURL != "") then
			Webhook := ScreenshotWebhookURL
		
		Command := "curl -s -X POST """ Webhook """"
		Command .= " -F ""content=<" TempMessageSendFile """"
		if (ImagePath != "") then
			Command .= " -F ""files[0]=@" ImagePath """"
		Command .= " -o """ TempLogFile """"
		
		RunWait, % ComSpec " /C " Command,, Hide
		FileRead, Response, %TempLogFile%
		return Response
	}
}


#If


$f5::
MouseGetPos, MouseX, MouseY,
PixelGetColor, Color, % MouseX, % MouseY
Msgbox % Color
return


*$f7::
Reload
return


RemoveTT:
ToolTip
return
