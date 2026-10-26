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

IniRead, ClippingKey, % IniFile, % IniFileSection, ClippingKey
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
IniRead, ServerHop, % IniFile, % IniFileSection, ServerHop
IniRead, ForceFieldWaitDetection, % IniFile, % IniFileSection, ForceFieldWaitDetection
IniRead, DisconnectDetection, % IniFile, % IniFileSection, DisconnectDetection
IniRead, WebhookURL, % IniFile, % IniFileSection, WebhookURL
IniRead, ScreenshotWebhookURL, % IniFile, % IniFileSection, ScreenshotWebhookURL
IniRead, DiscordUserID, % IniFile, % IniFileSection, DiscordUserID

IniRead, ErrorIgnore, % IniFile, % IniFileSection, ErrorIgnore

InputBlock := InputBlock == "On"
TimeGainedToolTip := TimeGainedToolTip == "On"
ServerHop := ServerHop == "On"
ForceFieldWaitDetection := ForceFieldWaitDetection == "On"
DisconnectDetection := DisconnectDetection == "On"
HasSilverCutoff := SilverCutoff != "None"

if (!A_IsAdmin && InputBlock or !A_IsAdmin && ClippingKey) then
{
	Run *RunAs "%A_ScriptFullPath%"
	ExitApp
	return
}

if (HasSilverCutoff) then ; gets file paths for silver screenshots
{
	global SilverSSC := 0 ; silver screenshot count
	global ScrollSSC := 0 ; scroll screenshot count
	global SilverScreenshots := []
	global ScrollScreenshots := []
	Loop, Files, % A_ScriptDir . "\*.png", FR
	{
		SplitPath, A_LoopFilePath, name, dir, ext, name_no_ext, drive
		if InStr(name_no_ext, "silver") then
		{
			SilverSSC := SilverSSC + 1
			SilverScreenshots.Push(A_LoopFilePath) ; puts file path in array
		}
		else
		if InStr(name_no_ext, "scroll") then
		{
			ScrollSSC := ScrollSSC + 1
			ScrollScreenshots.Push(A_LoopFilePath) ; puts file path in array
		}
		else
		{
			continue
		}
	}
}

global ScrollSSC := 0 ; scroll screenshot count
global ScrollScreenshots := []
Loop, Files, % A_ScriptDir . "\*.png", FR
{
	SplitPath, A_LoopFilePath, name, dir, ext, name_no_ext, drive
	if InStr(name_no_ext, "scroll") then
	{
		ScrollSSC := ScrollSSC + 1
		ScrollScreenshots.Push(A_LoopFilePath) ; puts file path in array
	}
	else
	{
		continue
	}
}

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
global ForceFieldDetection_TopLeftCorner := [A_ScreenWidth // 2.74, A_ScreenHeight // 2.88]
global ForceFieldDetection_BottomRightCorner := [A_ScreenWidth // 1.59, A_ScreenHeight // 1.32]
global ForceFieldDetectionVariation_1 := 10
global ForceFieldDetectionVariation_2 := 30
global FirstForceFieldDetected := false
global ForceFieldSecondsLeft := 0

global GachaGuyColors := ["0xF5A0B7", "0xF6A3B8", "0xF5A2B6", "0x88444E", "0x7C0AAD", "0xFFDFC4", "0xFFFFC2"]
global GachaGuyCount := 0
global GachaGuyDetectionVariation := 6
global GachaGuySpinStop := false
global GGx := 0 ; gacha guy found x
global GGy := 0 ; gacha guy found y

global ScrollDetection_TopLeftCorner := [A_ScreenWidth // 4.09, A_ScreenHeight // 2.41]
global ScrollDetection_BottomRightCorner := [A_ScreenWidth // 1.33, A_ScreenHeight // 1.08]
global ScrollDetectionVariation := 120

global SilverDetection_TopLeftCorner := [0, A_ScreenHeight // 1.05] ; its on the far left so thats why x is 0
global SilverDetection_BottomRightCorner := [A_ScreenWidth // 15.23, A_ScreenHeight] ; bottom of screen
global SilverDetectionVariation := 120
global LowSilver := false

global NoGachaGuyIndex := [] ; if no detect then it will go here and put the MacroIndex

global ScreenshotInterval_Miliseconds := ((ScreenshotInterval * 1000) * 60)
global LastScreenshot := ScreenshotInterval_Miliseconds ; so it doesnt screenshot off the first macroindex
return
~*/::
    Suspend On
    Loop
        if (GetKeyState("Enter", "P") || GetKeyState("Escape", "P") || GetKeyState("LButton", "P"))
            break
    Suspend Off
return


$f4::
SetKeyDelay, -1
SetMouseDelay, -1
SetBatchLines, -1

send {=}
return


$f3::
MacroStartTime := A_TickCount ; sleep timer, etc

Loop
{

if (MacroForceStop) then
{
	return ; make macro stop
}

MacroIndex++

sleep, 25
SendInput, \
sleep, 25
SendInput, {enter}
SendInput, \

ForceFieldStartTime_1 := A_TickCount

if (TimeGainedToolTip) then
{
	; TimeGained gets turned into seconds and minutes
	TimeGainedOutputText := "Time Gained: " Round((TimeGained / 1000), 0) " Seconds (" Round((TimeGained / 60000), 2) " Minute(s))"
	ToolTip, % TimeGainedOutputText, % ToolTipCords[1], % ToolTipCords[2], 1
}

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

	if (ForceFieldCount < ForceFieldCutoff) then ; NO FF
	{
		SendInput, \
		sleep, 25
		SendInput, {enter}
		SendInput, \
	}
}
else ; NO FF
{
	SendInput, \
	sleep, 25
	SendInput, {enter}
	SendInput, \
	return ; make macro stop
}

GachaGuyDetectionStartTime := A_TickCount
while ((A_TickCount - GachaGuyDetectionStartTime) < (ForceFieldCheckDuration_Miliseconds * 2) && GachaGuyCount < 1)
{
	for index, GachaGuyColorID in GachaGuyColors
	{
		PixelSearch, GGx, GGy, 0, 0, % A_ScreenWidth, % A_ScreenHeight, % GachaGuyColorID, % GachaGuyDetectionVariation, Fast
		if (ErrorLevel = 1) then
		{
			if (index != 1 && !GachaGuySpinStop) then
			{
				sleep, 500
				SendInput, {,}
				sleep, 500
			}
		}
		else
		if (ErrorLevel = 0) then
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
			SendInput, {click}
			sleep, 25
		}
		else
		{
			continue ; even number, y cord
		}
	}
	
	sleep, 3000 ; Delay to let the captcha pop up
	
	SendInput, \
	sleep, 25
	SendInput, {down}
	sleep, 25
	SendInput, {enter}
	SendInput, \
	
	sleep, 2000
	
	SendInput, \
	sleep, 25
	SendInput, {down}
	sleep, 25
	SendInput, {enter}
	SendInput, \
		
	sleep, 6000
	
	SendInput, \
	sleep, 25
	SendInput, {down}
	sleep, 25
	SendInput, {enter}
	SendInput, \
	
	; ^ the downs are because of the menu button.
	
	sleep, 25
	
	GoSub, UseChair
}
else ; NO GACHA GUY
{
	NoGachaGuyIndex.Push(MacroIndex)
	if (NoGachaGuyIndex.MaxIndex() >= 3) then ; didnt detect gacha guy 3+ times
	{
		if (NoGachaGuyIndex[NoGachaGuyIndex.MaxIndex()] - NoGachaGuyIndex[NoGachaGuyIndex.MaxIndex() - 2] == 2) then
		{
			; ^ didnt detect 3 times in a row
			MacroForceStop := true
			; WEBHOOK
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
		; webhook, autopop, something
		break
	}
	else
	{
		continue
	}
}

for SRindex, SRFilePath in SilverScreenshots
{
	ImageSearch, SRx, SRy, % SilverDetection_TopLeftCorner[1], % SilverDetection_TopLeftCorner[2], % SilverDetection_BottomRightCorner[1], % SilverDetection_BottomRightCorner[2], % "*" SilverDetectionVariation " " SRFilePath
	if (ErrorLevel = 0) then
	{
		LowSilver := true
		; webhook
		break
	}
	else
	{
		continue
	}
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
		; webhook
	}
}

while ((A_TickCount - ForceFieldStartTime_1) < (ForceFieldWaitTime_Miliseconds))
{
	sleep, 500 ; delay so that its not that laggy
	
	if (ForceFieldWaitDetection) then
	{
		ForceFieldDetectionStartTime_2 := A_TickCount
		while ((A_TickCount - ForceFieldDetectionStartTime_2) < ForceFieldCheckDuration_Miliseconds && ForceFieldWaitCount <= ForceFieldCutoff)
		{
			for index, ForceFieldColorID in ForceFieldColors
			{
				PixelSearch, FFx, FFy, % ForceFieldDetection_TopLeftCorner[1], % ForceFieldDetection_TopLeftCorner[2], % ForceFieldDetection_BottomRightCorner[1], % ForceFieldDetection_BottomRightCorner[2], % ForceFieldColorID, % ForceFieldDetectionVariation_2, Fast
				if (ErrorLevel = 0) then
				{
					ForceFieldWaitCount++
				}
			}
			
			if (ForceFieldWaitCount < ForceFieldCutoff) then ; NO FF
			{
				SendInput, \
				sleep, 25
				SendInput, {enter}
				SendInput, \
				return ; make macro stop
			}
		}
	}
	
	if (TimeGainedToolTip) then
	{
		ForceFieldSecondsLeft := Round((ForceFieldWaitTime_Miliseconds - (A_TickCount - ForceFieldStartTime_1)) / 1000, 0)
		ToolTip, % "Waiting: " ForceFieldSecondsLeft " seconds...", % ToolTipCords[3], % ToolTipCords[4], 2
	}
}
ToolTip, , , , 2 ; removes the tooltip
TimeGained := TimeGained + (A_TickCount - ForceFieldStartTime_1)

Loop, 3
{
	sleep, 25
	SendInput, \
	sleep, 25
	SendInput, {enter}
	SendInput, \
}

sleep, % 10 * 1000 ; delay so the play button can show up again.
}

; ===============================================
; things that make the macro stop

if (SleepTimer) then
{
	if (SleepTimer_Miliseconds >= (A_TickCount - MacroStartTime)) then
	{
		; make macro stop
	}
}

if (LowSilver) then
{
	; make macro stop
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
