Mellan := "v0.1"
Skillnader := "https://pastebin.com/raw/jvfjtnnn"
Pa_Natet := Hamta_Klistra_In_Lankar(Skillnader)
if (Pa_Natet) then
{
	if (Pa_Natet != Mellan) then
	{
		Msgbox, Version Outdated.`nPlease Get The Latest Versions.
		ExitApp
		return
	}
}
else
{
	Msgbox, Version Detection Failed.`nPlease Try Again.
	ExitApp
	return
}
Msgbox, Part 2!
return


Hamta_Klistra_In_Lankar(Lank) {
	try {
		whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
		whr.SetTimeouts(5000, 5000, 5000, 5000)
		whr.Open("GET", Lank, true)
		whr.Send()

		if (!whr.WaitForResponse()) then
		{
			return []
		}

		Skrifter := whr.ResponseText
	}
	catch
	{
		Skrifter := ""
	}

	if (Skrifter == "") then
	{
		return []
	}

	return Skrifter
}
