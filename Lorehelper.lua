--local Lorehelper_MainFrame = CreateFrame("Frame")
--Lorehelper_MainFrame:RegisterEvent("PLAYER_LOGIN")
--Lorehelper_MainFrame:SetScript("OnEvent",
--	function(self, event, ...)
--		local arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9 = ...
--		print('Congratulations on reaching level ')
--	end)

--[[myCheckButton = CreateFrame("CheckButton", "myCheckButton_GlobalName", Lorehelper_MainFrame, "ChatConfigCheckButtonTemplate");
myCheckButton:ClearAllPoints();
myCheckButton:SetPoint("TOPLEFT", -320,20);
myCheckButton:SetWidth(100);
myCheckButton:SetHeight(100);
--myCheckButton:SetPoint("TOPLEFT", Lorehelper_MainFrame);
myCheckButton_GlobalNameText:SetText("CheckBox Name");
myCheckButton.tooltip = "This is where you place MouseOver Text.";
myCheckButton:SetScript("OnClick", 
  function()
    --do stuff
  end
);
myCheckButton:Show();--]]
------------------------------------------
------------------------------------------
------------------------------------------
-- Need a frame for events
--[[local Lorehelper_eventFrame = CreateFrame("Frame")
Lorehelper_eventFrame:RegisterEvent("VARIABLES_LOADED")
Lorehelper_eventFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
--Lorehelper_eventFrame:RegisterEvent("ZONE_CHANGED_INDOORS")
--Lorehelper_eventFrame:RegisterEvent("ZONE_CHANGED")
Lorehelper_eventFrame:SetScript("OnEvent",function(self,event,...) self[event](self,event,...);end)

function Lorehelper_eventFrame:VARIABLES_LOADED()
	--if (not CoordinatesDB) then
	--	CoordinatesDB = {}
	--	CoordinatesDB["worldmap"] = true
	--	CoordinatesDB["minimap"] = true
	--end
	Lorehelper_eventFrame:SetScript("OnUpdate", function(self, elapsed) Lorehelper_OnUpdate(self, elapsed) end)
end

local Lorehelper_UpdateInterval = 1
local timeSinceLastUpdate = 0
function Lorehelper_OnUpdate(self, elapsed)
	timeSinceLastUpdate = timeSinceLastUpdate + elapsed
	if (timeSinceLastUpdate > Lorehelper_UpdateInterval) then
		-- Update the update time
		timeSinceLastUpdate = 0
		--Coordinates_UpdateCoordinates()
		print(Lorehelper_VarFrame.lastanswer);
		print(Lorehelper_VarFrame.lastquestiontitle);
		
		if Lorehelper_VarFrame.lastanswer ~= nil then
			Lorehelper_NewQuestion (Lorehelper_VarFrame.lastquestiontitle, Lorehelper_VarFrame.lastanswer);
			Lorehelper_VarFrame.lastanswer = nil;
		end
	end
end--]]
------------------------------------------
------------------------------------------
------------------------------------------
--a global shortcut
local LHT = Lorehelper_Text;--function to get a long, possibly Lorehelper_VarFrame-dependant text from a key
--global frame for variables, won't actually be shown
Lorehelper_VarFrame = nil;

Lorehelper_ZoneDropDown = nil;
Lorehelper_PerspectiveDropDown = nil;

Lorehelper_DungeonDropDown = nil;

local Lorehelper_EventFrame = CreateFrame("FRAME"); -- Need a frame to respond to events
Lorehelper_EventFrame:RegisterEvent("ADDON_LOADED"); -- Fired when saved variables are loaded
Lorehelper_EventFrame:RegisterEvent("PLAYER_LOGOUT"); -- Fired when about to log out
--Lorehelper_EventFrame:RegisterEvent("PLAYER_LOGOUT"); -- Fired when about to log out
Lorehelper_EventFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA");
--Lorehelper_EventFrame:RegisterEvent("ZONE_CHANGED_INDOORS");
--Lorehelper_EventFrame:RegisterEvent("ZONE_CHANGED");
Lorehelper_EventFrame:RegisterEvent("PLAYER_ENTERING_WORLD");

function Lorehelper_EventFrame:OnEvent(event, arg1)
	if event == "ADDON_LOADED" and arg1 == "Lorehelper" then
		-- Our saved variables are ready at this point. If there are none, the variables will set to nil.
		if Lorehelper_VarFrame==nil then
			Lorehelper_Init();
			--int main (void) lol
			--{
			Lorehelper_VarFrame.curframe = Lorehelper_DoTest();
			--}
		else 
			print(LHT("MsgAnswersLoaded"));
			Lorehelper_MinimapButton_Reposition();--the minimap icon is slightly behind otherwise
			Lorehelper_PopulateAllZonesFrame ();
			Lorehelper_PopulateDungeonPlayerFrame ();
			Lorehelper_VarFrame.curframe = Lorehelper_DoTest();
		end
	end
--------------------------------------------------------
	if event == "ZONE_CHANGED_NEW_AREA" then
		--local thezone = GetRealZoneText();
		--thezone = Lorehelper_DelocalizeZone(thezone);
		local zoneid = C_Map.GetBestMapForUnit("player");
		--local thezone = C_Map.GetMapInfo(zoneid)["name"];
		local thezone = Lorehelper_MapIDsNames[zoneid];--have to store zone names with IDs in a file to make them locale-independent
		--thezone = thezone:gsub(" ", "");--e.g. "TheBarrens" - no longer needed because I store them without spaces (Indian code in its best)
		if thezone ~= nil then
			if _G["Lorehelper_ZoneButton"..thezone] then
				local zonebutton = _G["Lorehelper_ZoneButton"..thezone];
				if zonebutton.unlocked == false then--only to popup once
					zonebutton.unlocked = true;
					Lorehelper_VarFrame.unlockedzones[thezone] = true;
					zonebutton:GetScript("OnClick")();
				end
			end
		end
--		print(thezone);
	end
--------------------------------------------------------------------------
	if event == "PLAYER_ENTERING_WORLD" then
		local inInstance, instanceType = IsInInstance();
		--print(instanceType);
		if ((inInstance == true) and ((instanceType == "party") or (instanceType == "raid"))) then

			local name, instType, difficultyID, difficultyName, maxPlayers, dynamicDifficulty, isDynamic, instanceID, instanceGroupSize, LfgDungeonID = GetInstanceInfo();
			
			if Lorehelper_MapIDsNames[instanceID] then
				Lorehelper_VarFrame.curdungeon = Lorehelper_MapIDsNames[instanceID];--would be locale-specific if I used 'name' instead
				Lorehelper_DungeonDropDown:SetValue(Lorehelper_VarFrame.curdungeon);
				Lorehelper_DungeonPlayerFrame:Show ();
				Lorehelper_DungeonTextPlay ();
			else print ("Lorehelper: no lore for this dungeon! If it's a raid, forget about lore and listen to RL :)");
			end
			
		end
	end
end

Lorehelper_EventFrame:SetScript("OnEvent", Lorehelper_EventFrame.OnEvent);
------------------------------------------
------------------------------------------
--Various auxiliary functions
------------------------------------------
function Lorehelper_SimpleMessage (text)
StaticPopupDialogs["LOREHELPER_SIMPLEMESSAGE"] = {
  text = text,
  --showAlert = true,
  button1 = "OK",
  timeout = 0,
  whileDead = true,
  hideOnEscape = true,
  preferredIndex = 3,  -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
  --[[OnShow = function(self)
	print(self.icon)
	end,--]]
}

StaticPopup_Show ("LOREHELPER_SIMPLEMESSAGE");
end
------------------------------------------
function Lorehelper_TextFromAgeTicks (age, ageticks, postanswertexts)
local i = 1;

assert (table.getn(ageticks) + 1 == table.getn(postanswertexts));

while i < table.getn(postanswertexts) and age >= ageticks[i] do
	i = i + 1;
end

return (postanswertexts[i]);
end
------------------------------------------
function Lorehelper_PositionButtons (buttonframe, buttonnumber, framewidth, textheight)
	if -75+80*(buttonnumber+1) < framewidth then
		buttonframe:SetPoint("TOPLEFT",-75+80*buttonnumber,-35-textheight)--80 is the hardcoded button width
	elseif -75+80*(buttonnumber-3) < framewidth then
		buttonframe:SetPoint("TOPLEFT",-75+80*(buttonnumber-4),-80-textheight)--and 4 is 390/80, where 390 is the standard framewidth. I'll make it more flexible one day
	else buttonframe:SetPoint("TOPLEFT",-75+80*(buttonnumber-8),-125-textheight)
	end
end
------------------------------------------
function Lorehelper_EventTestQuestion (title, text, wasborn, waschild, postanswertexts, picture)--special sort of test question - about an event, whether the character has participated in it, has lost someone, or not
local varframe = Lorehelper_VarFrame; --global variable frame

if wasborn==false then
	varframe.curframe = Lorehelper_TestQuestion (title, text, {LHT("Wasn't born")}, {postanswertexts[5]}, picture);--no postpictures; postanswertexts[5] is the only followup to "wasn't born"-way of participance in an event
	return varframe.curframe;
end

if waschild==true then
	varframe.curframe = Lorehelper_TestQuestion (title, text, {LHT("Avoided"), LHT("Lost someone")}, postanswertexts, picture);
else varframe.curframe = Lorehelper_TestQuestion (title, text, {LHT("Avoided"), LHT("Lost someone"), LHT("Participated"), LHT("Lost everything")}, postanswertexts, picture);
end

return varframe.curframe;
end
------------------------------------------
function Lorehelper_FormEventPostanswers (prefix, standard_postanswers, shouldnotbeimportant)--adds a prefix to an array of strings
processed_postanswers = {};

if shouldnotbeimportant==true then 
	processed_postanswers[1] = prefix.."|n|n"..standard_postanswers[1];--avoided the event as suggested by lore
	for i=2,#standard_postanswers do
		processed_postanswers[i] = prefix.."|n|nHowever, "..Lorehelper_LowerFirstLetter(standard_postanswers[i]);--was affected "despite" lore
	end
end
	
if shouldnotbeimportant==false then 
	processed_postanswers[1] = prefix.."|n|nLuckily, "..Lorehelper_LowerFirstLetter(standard_postanswers[1]);--avoided despite lore
	for i=2,#standard_postanswers do
		processed_postanswers[i] = prefix.."|n|n"..standard_postanswers[i];--was affected as suggested by lore
	end
end

processed_postanswers[5]=prefix;--"If the character wasn't born, the postanswer shall just describe the event, without any "you didn't participate because you wasn't born"

return processed_postanswers;
end
------------------------------------------
function Lorehelper_FormAgeTicks (childage, yearsofevents)--adds a prefix to an array of strings
ageticks = {};

for i=1,#yearsofevents do
	ageticks[i] = childage+25-yearsofevents[i];--25 is the current year in WoW
end

return ageticks;
end
------------------------------------------
function Lorehelper_LowerFirstLetter(str)
    return (str:gsub("^%u", string.lower))
end
------------------------------------------
function Lorehelper_BreakLineOnSpace(str)
    return (str:gsub(" ", "|n"))
end
------------------------------------------
function Lorehelper_Weight_Importance(text)--function that gives standard weights to player's participation in events
if text=="Avoided" or text=="Wasn't born" then
	return 0;
elseif text=="Lost someone" then
	return 12;
elseif text=="Participated" then
	return 6;
elseif text=="Lost everything" then
	return 24;
else
	print("Lorehelper internal error: can't assign weight to the wrong text");
	return 0;
end
end
------------------------------------------
function Lorehelper_Link_Zone_with_Answer (zones, thezone, thequestion, theanswer, prefix, weight)
--adds a weight depending on player's answer to an event, and a text
local varframe = Lorehelper_VarFrame; --global variable frame
local nozone = true;

--find "thezone" key in the table "zones" (which is stored in first column actually)
for i,z in ipairs(zones) do
	if z[1]==thezone then
		nozone = false;
		thekey=i;
	end
end

if nozone then
	print(LHT("Lorehelper internal error: wrong zone name."));
	return;
end

if varframe.responses[thequestion] == theanswer then
	zones[thekey][2]=zones[thekey][2] + weight;
	zones[thekey][3]=zones[thekey][3].."|n|n"..LHT(prefix..thequestion..theanswer);--eg TaurenZoneGrimtotemYes
end
--return zones happens implicitly - the function modifies the table "zones"
end
------------------------------------------
function Lorehelper_Link_Zone_with_Event (zones, thezone, theevent, prefix)--adds a weight of player's participance to an event, and a text
local varframe = Lorehelper_VarFrame; --global variable frame

if not varframe.responses[theevent] then--player didn't answer this question - most likely because of age
	return;
end

--find "thezone" key in the table "zones" (which is stored in first column actually)
for i,z in ipairs(zones) do
	if z[1]==thezone then
		thekey=i;
	end
end

zones[thekey][2]=zones[thekey][2] + Lorehelper_Weight_Importance(varframe.responses[theevent]);
zones[thekey][3]=zones[thekey][3].."|n|n"..LHT(prefix..varframe.responses[theevent]);
--return zones happens implicitly - the function modifies the table "zones"
end
------------------------------------------
function Lorehelper_CompareBy2ndElement(a, b)--don't pass anything but arrays with 2+ elements here :)    
    if tonumber(a[2]) > tonumber(b[2]) then    
        return true    
    end
end 
------------------------------------------
function Lorehelper_Contains (array, value)
    for i, v in ipairs(array) do
        if v == value then
            return true
        end
    end

    return false
end
------------------------------------------
------------------------------------------
function Lorehelper_FindZoneInRawZoneData (rawzonedatalist, zone)

    for i=1,#rawzonedatalist do
		for j=1,#rawzonedatalist[i] do
			if rawzonedatalist[i][j][1] == zone then--technically j isn't needed - rawzonedatalist[i][1][1] would be enough
				return rawzonedatalist[i];
			end
		end
    end

    return nil;
end
------------------------------------------
function Lorehelper_FindRaceInRawZoneData (rawzonedata, race)--accepts a different argument than the previous function
    for i=1,#rawzonedata do
		if rawzonedata[i][5] == race then--technically j isn't needed - rawzonedatalist[i][1][1] would be enough
			return rawzonedata[i];
		end
    end

    return nil;
end
------------------------------------------
function Lorehelper_PopulateAllZonesFrame ()
	local fr = Lorehelper_AllZonesFrame;
	
	local zonelist = {["Eastern Kingdoms"] = {"Alterac Mountains", "Arathi Highlands", "Badlands", "Blasted Lands", "Burning Steppes", "Dun Morogh", "Duskwood", "Eastern Plaguelands", "Hillsbrad Foothills", "Redridge Mountains", "Searing Gorge","Silverpine Forest", "Stranglethorn Vale", "Swamp of Sorrows", "The Hinterlands", "Western Plaguelands", "Westfall", "Wetlands"},
	["Kalimdor"] = {"Ashenvale", "Azshara", "Darkshore", "Desolace", "Dustwallow Marsh", "Felwood", "Feralas", "Moonglade", "Silithus", "Stonetalon Mountains", "Tanaris", "The Barrens", "Thousand Needles", "Un'Goro Crater"}};--continental-alphabetic order, skipping those I have no texts about
	
	local rawzonedatalist = {};
	
	--super ugly but works
	local zones = Lorehelper_Orc_Zones (true);
	for _, z in pairs (zones) do
		z[5] = "Orc";
	end
	local temp = Lorehelper_Undead_Zones (true);
	for _, z in pairs (temp) do
		z[5] = "Undead";
	end
	for _, v in pairs(temp) do table.insert(zones, v) end
	temp = Lorehelper_Tauren_Zones (true);
	for _, z in pairs (temp) do
		z[5] = "Tauren";
	end
	for _, v in pairs(temp) do table.insert(zones, v) end
	temp = Lorehelper_Troll_Zones (true);
	for _, z in pairs (temp) do
		z[5] = "Troll";
	end
	for _, v in pairs(temp) do table.insert(zones, v) end
	temp = Lorehelper_Human_Zones (true);
	for _, z in pairs (temp) do
		z[5] = "Human";
	end
	for _, v in pairs(temp) do table.insert(zones, v) end
	temp = Lorehelper_Gnome_Zones (true);
	for _, z in pairs (temp) do
		z[5] = "Gnome";
	end
	for _, v in pairs(temp) do table.insert(zones, v) end
	temp = Lorehelper_Dwarf_Zones (true);
	for _, z in pairs (temp) do
		z[5] = "Dwarf";
	end
	for _, v in pairs(temp) do table.insert(zones, v) end
	temp = Lorehelper_NightElf_Zones (true);
	for _, z in pairs (temp) do
		z[5] = "Night Elf";
	end
	for _, v in pairs(temp) do table.insert(zones, v) end
	--so we now have a table with entries like {Zone_Name, nonsense number, Zone_Text_for_Race, Zone_Tooltip_for_Race, Race}

---------------------
	zonelistexpanded = {}
	for i=1,#zonelist["Eastern Kingdoms"] do
		zonelistexpanded[i] = zonelist["Eastern Kingdoms"][i];
	end
	for i=1,#zonelist["Kalimdor"] do
		zonelistexpanded[i+#zonelist["Eastern Kingdoms"]] = zonelist["Kalimdor"][i];
	end	
	
	for i=1,#zonelistexpanded do
		local thezone = zonelistexpanded[i];
		local rawzonedata = Lorehelper_GetRawZoneData (thezone, zones);
		rawzonedatalist[i] = rawzonedata
	end
---------------------
	
	local curzone = "Alterac Mountains" -- A user-configurable setting

	-- Create the dropdown, and configure its appearance
	Lorehelper_ZoneDropDown = CreateFrame("FRAME", "Lorehelper_Global_ZoneDropDown", fr, "UIDropDownMenuTemplate")
	Lorehelper_ZoneDropDown:SetPoint("TOPLEFT", fr, "TOPLEFT", -20, 25)
	UIDropDownMenu_SetWidth(Lorehelper_ZoneDropDown, 120)
	UIDropDownMenu_SetText(Lorehelper_ZoneDropDown, "Zone")

	-- Create and bind the initialization function to the dropdown menu
	UIDropDownMenu_Initialize(Lorehelper_ZoneDropDown, function(self, level, menuList)
	local info = UIDropDownMenu_CreateInfo()
	if (level or 1) == 1 then
		-- Display the continents
		info.text, info.checked = "Eastern Kingdoms", Lorehelper_Contains (zonelist["Eastern Kingdoms"], curzone)
		info.menuList, info.hasArrow = "Eastern Kingdoms", true
		UIDropDownMenu_AddButton(info)
		info.text, info.checked = "Kalimdor", Lorehelper_Contains (zonelist["Kalimdor"], curzone)
		info.menuList, info.hasArrow = "Kalimdor", true
		UIDropDownMenu_AddButton(info)

	else
		-- Display a nested group of zones on the continent
		info.func = self.SetValue
		for i=1,#zonelist[menuList] do
		info.text, info.arg1, info.checked = zonelist[menuList][i], zonelist[menuList][i], zonelist[menuList][i] == curzone
		UIDropDownMenu_AddButton(info, level)
		end
	end
	end)

	-- Implement the function to change the zone
	function Lorehelper_ZoneDropDown:SetValue(newValue)
	curzone = newValue
	-- Update the text; if we merely wanted it to display newValue, we would not need to do this
	UIDropDownMenu_SetText(Lorehelper_ZoneDropDown, curzone)
	-- Because this is called from a sub-menu, only that menu level is closed by default.
	-- Close the entire menu with this next call
	CloseDropDownMenus()
	
	--another dropdown needs update
	local rawzonedata = Lorehelper_FindZoneInRawZoneData(rawzonedatalist, curzone);
	Lorehelper_PerspectiveDropDown:SetValue(rawzonedata[1][5])
	end
	
-------------------------------------
-------------------------------------
	
	local curperspective = "Orc" -- A user-configurable setting

	-- Create the dropdown, and configure its appearance
	Lorehelper_PerspectiveDropDown = CreateFrame("FRAME", "Lorehelper_Global_PerspectiveDropDown", fr, "UIDropDownMenuTemplate")
	Lorehelper_PerspectiveDropDown:SetPoint("TOPRIGHT", fr, "TOPRIGHT", 15, 25)
	UIDropDownMenu_SetWidth(Lorehelper_PerspectiveDropDown, 100)
	UIDropDownMenu_SetText(Lorehelper_PerspectiveDropDown, "Perspective")

	-- Create and bind the initialization function to the dropdown menu
	UIDropDownMenu_Initialize(Lorehelper_PerspectiveDropDown, function(self, level, menuList)
	local info = UIDropDownMenu_CreateInfo()
	
	rawzonedata = Lorehelper_FindZoneInRawZoneData(rawzonedatalist, curzone)
	
	if (level or 1) == 1 then--not sure if this if is needed for non-nested list
		-- Display the perspectives
		info.func = self.SetValue
		for i=1,#rawzonedata do
			info.text, info.arg1, info.checked = rawzonedata[i][5], rawzonedata[i][5], rawzonedata[i][5] == curperspective
			--info.fontObject = "GameFontNormal"
			UIDropDownMenu_AddButton(info)
		end
	end
	end)

	-- Implement the function to change the zone
	function Lorehelper_PerspectiveDropDown:SetValue(newValue)
	curperspective = newValue
	-- Update the text; if we merely wanted it to display newValue, we would not need to do this
	UIDropDownMenu_SetText(Lorehelper_PerspectiveDropDown, curperspective)
	
	--actually update the text in the frame and the tooltip
	rawzonedata = Lorehelper_FindZoneInRawZoneData(rawzonedatalist, curzone)
	rawzonedata = Lorehelper_FindRaceInRawZoneData(rawzonedata, curperspective)
	fr.text:SetText(rawzonedata[3]);
	if rawzonedata[4] then
		fr.tooltip = rawzonedata[4];
	else fr.tooltip = nil;
	end
	
	--need to update it in case it's done first time, so the text is no longer just "Zone"
	UIDropDownMenu_SetText(Lorehelper_ZoneDropDown, curzone)
	end
	
-------------------------------------------------------------------
	--[[fr.buttonframes = {};
	
	for i=1,#zonelistexpanded do	
		if rawzonedatalist[i] ~= nil then
			--print (rawzonedatalist[i][1][1])

			fr.buttonframes[i] = CreateFrame("Button", nil, fr, "Lorehelper_SmallButton_Template");
			
			fr.buttonframes[i]:SetPoint("TOPLEFT",fr,"TOPLEFT",5+70*math.floor((i-1)/8),-30-45*((i-1)%8))
			fr.buttonframes[i]:SetFormattedText(Lorehelper_BreakLineOnSpace(rawzonedatalist[i][1][1]));--with SetText, I can't |n on buttons
			
			fr.buttonframes[i]:SetNormalFontObject("GameFontHighlight");
			local font = fr.buttonframes[i]:GetNormalFontObject();
			font:SetTextColor(1, 0.5, 0.25, 1.0);
			fr.buttonframes[i]:SetNormalFontObject(font);
			
			fr.buttonframes[i]:SetScript("OnClick", 
				function()
					Lorehelper_SimpleFrame.title:SetText(rawzonedatalist[i][1][5]);
					Lorehelper_SimpleFrame.text:SetText(rawzonedatalist[i][1][3]);
					if rawzonedatalist[i][1][4] then
						Lorehelper_SimpleFrame.tooltip = rawzonedatalist[i][1][4];
					else Lorehelper_SimpleFrame.tooltip = nil;
					end
					
					Lorehelper_SimpleFrame:SetPoint("RIGHT",fr,"RIGHT",805,0);
					Lorehelper_SimpleFrame:Show();
				end
				);
		end
	end
	
	print("--")--]]
	
	--[[for i=1,#zones do
		local thezone = zones[i][1]:gsub(" ","");--i.e. "TheBarrens"
		fr.buttonframes[i] = CreateFrame("Button", nil, fr, "Lorehelper_Button_Template");
		print(zones[i][1])
		fr.buttonframes[i]:SetPoint("TOP",fr,"TOP",0,35-45*i)
		fr.buttonframes[i]:SetFormattedText(Lorehelper_BreakLineOnSpace(zones[i][1]));--with SetText, I can't |n on buttons
		fr.buttonframes[i]:SetScript("OnClick", 
			function()
				Lorehelper_SimpleFrame.title:SetText(zones[i][1]);
				Lorehelper_SimpleFrame.text:SetText(zones[i][3]);
				if zones[i][4] then
					Lorehelper_SimpleFrame.tooltip = zones[i][4];
				else Lorehelper_SimpleFrame.tooltip = nil;
				end
					
				Lorehelper_SimpleFrame:SetPoint("RIGHT",fr,"RIGHT",255,0);
				Lorehelper_SimpleFrame:Show();
			end
			);
	end--]]

end
------------------------------------------
------------------------------------------
function Lorehelper_PopulateDungeonPlayerFrame ()
	local varframe = Lorehelper_VarFrame; --global variable frame
	local fr = Lorehelper_DungeonPlayerFrame;
	
	local dungeonlist = {"Blackfathom Deeps", "Blackrock Depths", "Blackrock Spire", "Dire Maul", "Gnomeregan","Maraudon", "Ragefire Chasm", "Razorfen Downs", "Razorfen Kraul", "Scarlet Monastery", "Scholomance", "Shadowfang Keep", "Stratholme", "The Deadmines", "The Stockade", "The Temple of Atal'Hakkar", "Uldaman", "Wailing Caverns", "Zul'Farrak"};
---------------------
	
	--varframe.curdungeon = "Gnomeregan" -- A user-configurable setting
	Lorehelper_UpdateDungeonPlayerText ();
	
	-- Create the dropdown, and configure its appearance
	Lorehelper_DungeonDropDown = CreateFrame("FRAME", "Lorehelper_Global_DungeonDropDown", fr, "UIDropDownMenuTemplate")
	Lorehelper_DungeonDropDown:SetPoint("TOPLEFT", fr, "TOPLEFT", -18, -22)
	UIDropDownMenu_SetWidth(Lorehelper_DungeonDropDown, 180)
	UIDropDownMenu_SetText(Lorehelper_DungeonDropDown, varframe.curdungeon)

	-- Create and bind the initialization function to the dropdown menu
	UIDropDownMenu_Initialize(Lorehelper_DungeonDropDown, function(self, level, menuList)
	local info = UIDropDownMenu_CreateInfo()
	
	if (level or 1) == 1 then--not sure if this if is needed for non-nested list
		-- Display the dungeons
		info.func = self.SetValue
		for i=1,#dungeonlist do
			info.text, info.arg1, info.checked = dungeonlist[i], dungeonlist[i], dungeonlist[i] == varframe.curdungeon
			UIDropDownMenu_AddButton(info)
		end
	end
	end)

	-- Implement the function to change the zone
	function Lorehelper_DungeonDropDown:SetValue(newValue)
	varframe.curdungeon = newValue
	-- Update the text; if we merely wanted it to display newValue, we would not need to do this
	UIDropDownMenu_SetText(Lorehelper_DungeonDropDown, varframe.curdungeon)
	
	varframe.curdungeontextpos = 0;
	Lorehelper_UpdateDungeonPlayerText();
	end
end
------------------------------------------
function Lorehelper_GetRawZoneData (thezone, zones)
	local rawzonedata = nil;

	for i,z in pairs(zones) do
		if z[1] == thezone then
			if rawzonedata == nil then
				rawzonedata = {};
			end
			table.insert (rawzonedata, z)
			--print(z[1])
			--print(z[5])
		end
	end
	
return rawzonedata;
end
------------------------------------------
function Lorehelper_BeginningOfText (text)
return string.sub (text, 1, 70);
end
------------------------------------------
------------------------------------------
------------------------------------------
------------------------------------------
--Function that handles all the "test" questions
------------------------------------------
function Lorehelper_TestQuestion(title, text, answers, postanswertexts, picture, postpictures)
	local varframe = Lorehelper_VarFrame; --global variable frame
	local fr = CreateFrame ("Frame",nil,self,"Lorehelper_MainFrame_Template"); --the frame to be shown and interacted with
	local framewidth = fr:GetWidth() - 10;
	
	if picture then
		fr.background:SetTexture(picture)
	end

	--------------------------------------------------
	fr.title:SetText(title);
	--theframe.text:SetFont("Fonts\\ARIALN.ttf", 13, "OUTLINE")
	fr.text:SetText(text);
	---------------------------------------------------
	fr.buttonframes = {};
	for i=1,#answers do
		fr.buttonframes[i] = CreateFrame("Button", nil, fr, "Lorehelper_Button_Template");
		Lorehelper_PositionButtons (fr.buttonframes[i], i, framewidth, fr.text:GetHeight());
		fr.buttonframes[i]:SetFormattedText(Lorehelper_BreakLineOnSpace(answers[i]));--with SetText, I can't |n on buttons
		fr.buttonframes[i]:SetScript("OnClick", 
			function()
			--hide the old text and buttons
			for j=1,#fr.buttonframes do --#fr.buttonframes is the same as #answers but I think it reads better
				fr.buttonframes[j]:Hide();
			end
			fr.text:Hide();

			if postpictures then
				if postpictures[i] then
					fr.background:SetTexture(postpictures[i])
				end
			end
			
			fr.newtext:SetText(postanswertexts[i]);
			fr.newtext:Show();
			
			fr.backbutton = CreateFrame("Button", nil, fr, "Lorehelper_Button_Template");
			fr.backbutton:SetPoint("BOTTOMLEFT",5,5)
			fr.backbutton:SetText(LHT("Back"));
			fr.backbutton:SetScript("OnClick", 
			--re-show the old text and buttons if the player chooses to go back, and hide the new ones
				function()
				for j=1,#fr.buttonframes do --#fr.buttonframes is the same as #answers but I think it reads better
					fr.buttonframes[j]:Show();
				end
				if picture then
					fr.background:SetTexture(picture)
				end
				fr.text:Show();
				fr.newtext:Hide();
				fr.backbutton:Hide();
				fr.okbutton:Hide();
				end
				);
			
			fr.okbutton = CreateFrame("Button", nil, fr, "Lorehelper_Button_Template");
			fr.okbutton:SetPoint("BOTTOMRIGHT",-5,5)
			fr.okbutton:SetText(LHT("Continue"));
			fr.okbutton:SetScript("OnClick", 
				function()
					--update responses global variable 
					varframe.responses[title]=answers[i];
					varframe.curtestquestionnumber = varframe.curtestquestionnumber + 1;
					--and hide everything related to this question
					fr:Hide();
	
					Lorehelper_DoTest ();
--					if nextquestionframe~=nil then nextquestionframe:Show();
					--else print ("The end");
--					end
				end
				);
			end
			);
	end
	return fr;
end
------------------------------------------
--Function that handles the age question
------------------------------------------
-------------------------------------------------
function Lorehelper_AskAge(agelowrange, agehighrange, ageticks, postanswertexts, picture)
	local varframe = Lorehelper_VarFrame; --global variable frame
	local fr = CreateFrame ("Frame",nil,self,"Lorehelper_MainFrame_Template"); --the frame to be shown and interacted with
	local framewidth = fr:GetWidth() - 10;
	--------------------------------------------------
	if picture then
		fr.background:SetTexture(picture)
	end
	
	fr.title:SetText(LHT("Age"));
	fr.text:SetText(LHT("Greetings, "..varframe.name.."!|n|nI see that you are not some under-"..agelowrange.." child. But I also know that some "..varframe.race.."s can still hold a weapon in the venerable age of "..agehighrange.."...|n|nI must stop trying to guess now. How old are you, "..varframe.race.."?"));
	---------------------------------------------------
	fr.agebox = CreateFrame("EditBox", nil, fr, "InputBoxTemplate");
	fr.agebox:SetSize(40, 20)
	fr.agebox:SetPoint("CENTER")
	fr.agebox:SetText("26");
	fr.agebox:SetCursorPosition(0);
	fr.agebox:SetAutoFocus(false);
	fr.agebox:SetMaxLetters(5);--don't want age over 99999
	fr.agebox:Show();
	---------------------------------------------------
	fr.okbutton = CreateFrame("Button", nil, fr, "Lorehelper_Button_Template");
	fr.okbutton:SetPoint("BOTTOMRIGHT",-5,5)
	fr.okbutton:SetText(LHT("Continue"));
	fr.okbutton:SetScript("OnClick", 
		function()
			local age = tonumber(fr.agebox:GetText());
			
			if age == nil then
				Lorehelper_SimpleMessage ("Your age should be a number between "..agelowrange.." and "..agehighrange);
			elseif age < agelowrange or age > agehighrange then 
				Lorehelper_SimpleMessage ("Your age should be a number between "..agelowrange.." and "..agehighrange);		
				
			else 
			--hide the old text and editbox and buttons
			fr.text:Hide();
			fr.agebox:Hide();
			fr.okbutton:Hide();
			fr.disclaimerbutton:Hide();

			--display the lore about player's date of birth
			fr.newtext:SetText(Lorehelper_TextFromAgeTicks (age, ageticks, postanswertexts));
			fr.newtext:Show();
			
			fr.backbutton = CreateFrame("Button", nil, fr, "Lorehelper_Button_Template");
			fr.backbutton:SetPoint("BOTTOMLEFT",5,5)
			fr.backbutton:SetText(LHT("Back"));
			fr.backbutton:SetScript("OnClick", 
			--re-show the old text and editbox if the player chooses to go back, and hide the new ones
				function()
				fr.text:Show();
				fr.agebox:Show();
				fr.okbutton:Show();
				fr.newtext:Hide();
				fr.backbutton:Hide();
				fr.newokbutton:Hide();
				end
				);
			
			fr.newokbutton = CreateFrame("Button", nil, fr, "Lorehelper_Button_Template");
			fr.newokbutton:SetPoint("BOTTOMRIGHT",-5,5);
			fr.newokbutton:SetText(LHT("Continue"));
			fr.newokbutton:SetScript("OnClick", 
				function()
					--the age confirmed by player - update the global age variable
					varframe.age = age;
					--print (varframe.age);
					--hide everything related to this question
					fr:Hide();	
					Lorehelper_DoTest ();
				end
				);
			end	
		end
		);
		
	fr.disclaimerbutton = CreateFrame("Button", nil, fr, "Lorehelper_Button_Template");
	fr.disclaimerbutton:SetPoint("BOTTOMLEFT",5,5)
	fr.disclaimerbutton:SetFormattedText(Lorehelper_BreakLineOnSpace(LHT("About Lorehelper")));
	fr.disclaimerbutton:SetScript("OnClick", 
		function()
		Lorehelper_SimpleMessage(LHT("MsgAboutLH"));
		end
		);
return fr;
end
-------------------------------------------------
------------------------------------------
--Function that presents the players answers, its expected relations with other races (maybe furute FEATURE), and highlights the important zones. Afterwards it calls Lorehelper_AddHelpfulButtons (IN PROGRESS) 
------------------------------------------
-------------------------------------------------
function Lorehelper_PresentAnswers(picture, sortorder, zones)--no other input because LorehelperVarFrame.responses is global
	local varframe = Lorehelper_VarFrame; --global variable frame
	local fr = CreateFrame ("Frame",nil,self,"Lorehelper_MainFrame_Template"); --the frame to be shown and interacted with
	local framewidth = fr:GetWidth() - 10;
	--------------------------------------------------
	if picture then
		fr.background:SetTexture(picture)
	end
	
	fr.title:SetText(LHT("Lore profile"));

	--fill the frame with the text of player's answers
	local text = "Name: "..varframe.name.."|nRace: "..varframe.race.."|nAge: "..varframe.age.."|n";

	for _,question in ipairs(sortorder) do
		if varframe.responses[question] ~= nil then
			text = text..question..": "..string.gsub(varframe.responses[question], "|n", " ").."|n";--the gsub shouldn't be needed, as responses themselves no longer contain |n, but I'll keep it
		end
	end

	fr.text:SetText(text);
	
	fr.retakebutton = CreateFrame("Button", nil, fr, "Lorehelper_Button_Template");
	fr.retakebutton:SetPoint("BOTTOM",-5,5)
	fr.retakebutton:SetText(LHT("Retake test"));
	fr.retakebutton:SetScript("OnClick", 
		function()
		StaticPopupDialogs["LOREHELPER_RETAKEMESSAGE"] = {
		text = LHT("MsgRetakeTest"),
		button1 = LHT("Retake"),
		button2 = LHT("Cancel"),
		OnAccept = function()
			varframe.age = nil;
			varframe.responses = {};
			varframe.testdone = false;
			varframe.curtestquestionnumber = 1;
			Lorehelper_SimpleFrame:Hide();
			Lorehelper_AllZonesFrame:Hide();
			fr:Hide();
			Lorehelper_DoTest();
		end,
		whileDead = true,
		hideOnEscape = true,
		preferredIndex = 3, 
		}
		StaticPopup_Show ("LOREHELPER_RETAKEMESSAGE");
		end
		);
	----------------------------------------
	----------------------------------------
	if zones == nil then
		print("Lorehelper internal error: no zones to highlight!");
		return fr;
	end	
	--frame with buttons for important zones	
	fr.highlightsframe = CreateFrame ("Frame",nil,fr,"Lorehelper_ListFrame_Template")
	fr.highlightsframe:SetPoint("TOPRIGHT",fr,"TOPRIGHT",95,-20)
	
	fr.highlightsframe.buttonframes = {};
	--[[for i,z in pairs(zones) do
		print(i)
		print(z[1])
	end--]]
	for i=1,#zones do
		if zones[i][2]~=0 then --else it's an unimportant zone with zero weight (NOT USED at the moment)
			local thezone = zones[i][1]:gsub(" ","");--i.e. "TheBarrens"
			fr.highlightsframe.buttonframes[i] = CreateFrame("Button", "Lorehelper_ZoneButton"..thezone, fr.highlightsframe, "Lorehelper_UnlockableButton_Template");
			
			if varframe.unlockedzones[thezone]==true then--if the player unlocked zone once, the button will be clickable
				fr.highlightsframe.buttonframes[i].unlocked = true;
			end
			
			fr.highlightsframe.buttonframes[i]:SetPoint("TOP",fr.highlightsframe,"TOP",0,35-45*i)
			fr.highlightsframe.buttonframes[i]:SetFormattedText(Lorehelper_BreakLineOnSpace(zones[i][1]));--with SetText, I can't |n on buttons
			fr.highlightsframe.buttonframes[i]:SetScript("OnClick", 
				function()
				if fr.highlightsframe.buttonframes[i].unlocked then
					--local zoneinfoframe = CreateFrame ("Frame",nil,self,"Lorehelper_SimpleFrame_Template");
					Lorehelper_SimpleFrame.title:SetText(zones[i][1]);
					Lorehelper_SimpleFrame.text:SetText(zones[i][3]);
					if zones[i][4] then
						Lorehelper_SimpleFrame.tooltip = zones[i][4];
					else Lorehelper_SimpleFrame.tooltip = nil;
					end
					
					Lorehelper_SimpleFrame:SetPoint("RIGHT",fr.highlightsframe,"RIGHT",255,0);
					Lorehelper_SimpleFrame:Show();
				end

				end
				);
		end
	end
	----------------------------------------
	----------------------------------------
	Lorehelper_AddHelpfulButtons (fr);
	
return fr;
end
-------------------------------------------------
------------------------------------------
--Function that adds a number of buttons to the left of frame fr: All zones, About Lorehelper  
------------------------------------------
-------------------------------------------------
function Lorehelper_AddHelpfulButtons (fr) 

	if fr == nil then
		print("Lorehelper internal error: no frame to attach buttons to!");
		return fr;
	end	

	--frame with buttons 
	fr.frameofbuttons = CreateFrame ("Frame",nil,fr,"Lorehelper_ListFrame_Template")
	fr.frameofbuttons:SetPoint("TOPLEFT",fr,"TOPLEFT",-100,-20)
	
	fr.frameofbuttons.allzonesbutton = CreateFrame("Button", nil, fr.frameofbuttons, "Lorehelper_Button_Template");
	fr.frameofbuttons.allzonesbutton:SetPoint("TOP",fr.frameofbuttons,"TOP",0,35-45)
	fr.frameofbuttons.allzonesbutton:SetFormattedText("Zonepedia");
	fr.frameofbuttons.allzonesbutton:SetScript("OnClick", 
				function()
				--FEATURE: anchor on curframe instead..?
				Lorehelper_AllZonesFrame:SetPoint("LEFT",fr.frameofbuttons,"LEFT",-255,0);
				Lorehelper_AllZonesFrame:Show();
				end
				);
		
	--[[fr.frameofbuttons.optionsbutton = CreateFrame("Button", nil, fr.frameofbuttons, "Lorehelper_Button_Template");		
	fr.frameofbuttons.optionsbutton:SetPoint("TOP",fr.frameofbuttons,"TOP",0,35-45*3)
	fr.frameofbuttons.optionsbutton:SetFormattedText("Options");
	fr.frameofbuttons.optionsbutton:SetScript("OnClick", 
				function()
				
				end
				);--]]
				
	fr.frameofbuttons.aboutbutton = CreateFrame("Button", nil, fr.frameofbuttons, "Lorehelper_Button_Template");					
	fr.frameofbuttons.aboutbutton:SetPoint("TOP",fr.frameofbuttons,"TOP",0,35-45*2)
	fr.frameofbuttons.aboutbutton:SetFormattedText(Lorehelper_BreakLineOnSpace("About Lorehelper"));--with SetText, I can't |n on buttons
	fr.frameofbuttons.aboutbutton:SetScript("OnClick", 
				function()
				Lorehelper_SimpleMessage(LHT("MsgAboutLH"));
				end
				);
	
return fr;
end
-------------------------------------------------
-------------------------------------------------
-------------------------------------------------
-------------------------------------------------
-------------------------------------------------
function Lorehelper_NightElf ()

local varframe = Lorehelper_VarFrame;
local childage = 20;
local oldage = 15000;
local ageticks = Lorehelper_FormAgeTicks(childage, {22, 21, 20, -975, -1200, -7050, -9300, -10000, -12000})--will still be partially hardcoded
--conflict with Illidan and naga, the end of Third War, the beginning of it, War of the Shifting Sands, genocide of Shen'Dralar, middle of Exile of the High Elves, War of the Satyr, War of the Ancients, founding of Eldre'Thalas
for i=1,#ageticks do
--	print(ageticks[i])
end
-------------------------------------------------
--Ask about age
-------------------------------------------------
if varframe.age == nil then
	varframe.curframe = Lorehelper_AskAge(childage, oldage, ageticks, 
	{LHT("NightElfAgeYoung"), LHT("NightElfAgeThirdWar"), LHT("NightElfAgeThirdWar"), LHT("NightElfAgeThirdWar"), LHT("NightElfAgeShiftingSands"), LHT("NightElfAgeShiftingSands"), LHT("NightElfAgeExileHighElves"), LHT("NightElfAgeWarSatyr"), LHT("NightElfAgeWarAncients"), LHT("NightElfAgeWarAncients")},
	LHART_NIGHTELF); --also updates varframe.age
-------------------------------------------------
--Ask whether a night elf was once Highborne
-------------------------------------------------
elseif varframe.responses["Society"]==nil then
	if varframe.age >= 6825 then--end of High Elves exile
		varframe.curframe = Lorehelper_TestQuestion (LHT("Society"), 
		LHT("NightElfSociety"), 
		{LHT("Kaldorei"), LHT("Highborne"), LHT("Shen'Dralar")}, 
		{LHT("NightElfKaldorei"), LHT("NightElfHighborne"), LHT("NightElfShenDralar")},
		LHART_NIGHTELF,
		{LHART_NIGHTELFKALDOREI, LHART_NIGHTELFHIGHBORNE, LHART_NIGHTELFSHENDRALAR});
	elseif varframe.age >= 1225 then--genocide of Shen'Dralar
		varframe.curframe = Lorehelper_TestQuestion (LHT("Society"), 
		LHT("NightElfSocietyMiddleAge"),--"Kaldorei" and "Shen'Dralar" are the options, but Highborne lore is given
		{LHT("Kaldorei"), LHT("Shen'Dralar")}, 
		{LHT("NightElfKaldorei"), LHT("NightElfShenDralar")},
		LHART_NIGHTELF,
		{LHART_NIGHTELFKALDOREI, LHART_NIGHTELFSHENDRALAR});	
	else
		varframe.curframe = Lorehelper_TestQuestion (LHT("Society"), 
		LHT("NightElfSocietyYoung"),--so only "Kaldorei" is an option, but lore is given
		{LHT("Kaldorei")}, 
		{LHT("NightElfKaldorei")},
		LHART_NIGHTELF,
		{LHART_NIGHTELFKALDOREI});	
	end
-------------------------------------------------
elseif varframe.responses["The Betrayer Ascendant"]==nil then--title of the last of the frames to be generated line below
	varframe.curframe = Lorehelper_NightElf_Events (ageticks, childage);--function generating a few frames, depending on age
-------------------------------------------------
-------------------------------------------------
else 
	local zones = Lorehelper_NightElf_Zones ();
	varframe.curframe = Lorehelper_PresentAnswers(LHART_NIGHTELF, {"Society", "War of the Ancients", "War of the Satyr", "Shen'Dralar genocide", "War of the Shifting Sands", "Third War", "The Betrayer Ascendant"}, zones);--the order of questions is passed 
	if varframe.testdone == true then --if the test was done before and we're just relogging again
		varframe.curframe:Hide ();
		print (LHT("MsgAccessLoreProfile"));
	end
	varframe.testdone = true;
end

return varframe.curframe;
end
-------------------------------------------------
-------------------------------------------------
function Lorehelper_NightElf_Events (ageticks, childage)
local varframe = Lorehelper_VarFrame;
local age = varframe.age;

standard_postanswers = {LHT("NightElfStandardAvoided"), LHT("NightElfStandardLostSomeone"), LHT("NightElfStandardParticipated"), LHT("NightElfStandardLostEverything")};

if varframe.responses["Society"]=="Kaldorei" then
	warancients_postanswers = Lorehelper_FormEventPostanswers (LHT("NightElfEventWarAncientsKaldorei"),standard_postanswers, false);
elseif varframe.responses["Society"]=="Highborne" then
	warancients_postanswers = Lorehelper_FormEventPostanswers (LHT("NightElfEventWarAncientsHighborne"),standard_postanswers, false);
elseif varframe.responses["Society"]=="Shen'Dralar" then
	warancients_postanswers = Lorehelper_FormEventPostanswers (LHT("NightElfEventWarAncientsShenDralar"),standard_postanswers, false);
end

warsatyr_postanswers = Lorehelper_FormEventPostanswers (LHT("NightElfEventWarSatyrStandard"),standard_postanswers, false);

warshiftingsands_postanswers = Lorehelper_FormEventPostanswers (LHT("NightElfEventWarShiftingSandsStandard"),standard_postanswers, false);

if varframe.class == "Druid" then
	thirdwar_postanswers = Lorehelper_FormEventPostanswers (LHT("NightElfEventThirdWarDruid"),standard_postanswers, false);	
else
	thirdwar_postanswers = Lorehelper_FormEventPostanswers (LHT("NightElfEventThirdWarStandard"),standard_postanswers, false);	
end	

betrayer_postanswers = Lorehelper_FormEventPostanswers (LHT("NightElfEventBetrayerStandard"),standard_postanswers, false);	
-------
--ageticks are
--conflict with Illidan and naga, the end of Third War, the beginning of it, War of the Shifting Sands, genocide of Shen'Dralar, middle of Exile of the High Elves, War of the Satyr, War of the Ancients, founding of Eldre'Thalas

--age+childage >= ageticks[...] is the logical variable that indicates whether player was born during the event
--(age < ageticks[...]) is the logical waschild variable
if varframe.responses["War of the Ancients"]==nil then
	varframe.curframe = Lorehelper_EventTestQuestion (LHT("War of the Ancients"), LHT("NightElfEventWarAncients"), (age+childage >= ageticks[8]), (age < ageticks[8]), warancients_postanswers, LHART_WARANCIENTS);
	return varframe.curframe;
end

if varframe.responses["War of the Satyr"]==nil then
	varframe.curframe = Lorehelper_EventTestQuestion (LHT("War of the Satyr"), LHT("NightElfEventWarSatyr"), (age+childage >= ageticks[7]), (age < ageticks[7]), warsatyr_postanswers, LHART_WARSATYR);
	return varframe.curframe;
end

if varframe.responses["Shen'Dralar genocide"]==nil then
	if varframe.responses["Society"]=="Shen'Dralar" then
		shendralargenocide_postanswers = Lorehelper_FormEventPostanswers (LHT("NightElfEventShenDralarGenocideShenDralar"),standard_postanswers, false);
		
		--wasborn should actually always be true in this case - otherwise player can't pick Shen'Dralar as his society
		varframe.curframe = Lorehelper_EventTestQuestion (LHT("Shen'Dralar genocide"), LHT("NightElfEventShenDralarGenocide"), (age+childage >= ageticks[5]), (age < ageticks[5]), shendralargenocide_postanswers, LHART_SHENDRALARGENOCIDE);
		return varframe.curframe;
	end
end

if varframe.responses["War of the Shifting Sands"]==nil then
	varframe.curframe = Lorehelper_EventTestQuestion (LHT("War of the Shifting Sands"), LHT("NightElfEventWarShiftingSands"), (age+childage >= ageticks[4]), (age < ageticks[4]), warshiftingsands_postanswers, LHART_SHIFTINGSANDS);
	return varframe.curframe;
end

if varframe.responses["Third War"]==nil then
	varframe.curframe = Lorehelper_EventTestQuestion (LHT("Third War"), LHT("NightElfEventThirdWar"), (age+childage >= ageticks[2]), (age < ageticks[2]), thirdwar_postanswers, LHART_THIRDWARKALIMDOR);
	return varframe.curframe;
end

if varframe.responses["The Betrayer Ascendant"]==nil then
	varframe.curframe = Lorehelper_EventTestQuestion (LHT("The Betrayer Ascendant"), LHT("NightElfEventBetrayer"), (age+childage >= ageticks[1]), (age < ageticks[1]), betrayer_postanswers, LHART_BETRAYER);
	return varframe.curframe;
end

return varframe.curframe;
end
-------------------------------------------------
-------------------------------------------------
function Lorehelper_NightElf_Zones (forzonepedia)
local varframe = Lorehelper_VarFrame;
		
local zones = {
		{"Stonetalon Mountains", 1, ""},
		{"Felwood", 7, ""},
		{"Moonglade", 10, ""},
		{"Azshara", 2, "", true},
		{"Feralas", 20, "", true},
		{"Ashenvale", 40, ""},
		{"Silithus", 5, ""},
		{"Duskwood", 3, ""},
		{"The Hinterlands", 4, ""}
		};
	 
for i,z in ipairs(zones) do
	z[3]=LHT("NightElfZone"..z[1]);
	if z[4] then
		z[4]=LHT("NightElfZoneTooltip"..z[1]);
	end
end

if forzonepedia then
	return zones;
end

Lorehelper_Link_Zone_with_Answer (zones, "Feralas", "Society", "Shen'Dralar", "NightElfZone", 24)
Lorehelper_Link_Zone_with_Answer (zones, "Azshara", "Society", "Highborne", "NightElfZone", 24)

Lorehelper_Link_Zone_with_Event (zones, "Silithus", "War of the Shifting Sands", "NightElfZone")
Lorehelper_Link_Zone_with_Event (zones, "Azshara", "War of the Ancients", "NightElfZone")

if varframe.responses["War of the Satyr"] == "Avoided" or varframe.responses["War of the Satyr"] == "Wasn't born" or varframe.responses["War of the Satyr"] == nil then--to not link twice
	Lorehelper_Link_Zone_with_Event (zones, "Ashenvale", "Third War", "NightElfZone")
else 
	Lorehelper_Link_Zone_with_Event (zones, "Ashenvale", "War of the Satyr", "NightElfZone")
end

table.sort(zones, Lorehelper_CompareBy2ndElement)
--for i,n in ipairs(zones) do print(n[1]); print(n[2]); print(n[3]); print("--"); end

--print("------");

return zones;
end
-------------------------------------------------
-------------------------------------------------
-------------------------------------------------
function Lorehelper_Dwarf ()

local varframe = Lorehelper_VarFrame;
--local fr = nil; --current frame, will be returned and varframe.curframe will be equal to it
local childage = 20;
local oldage = 500;
local ageticks = Lorehelper_FormAgeTicks(childage, {21, 20, 10, 4, 0, -210})--will still be partially hardcoded
--the end of Third War, the beginning of it, end of Second, beginning, beginning of First, beginning of War of Three Hammers + 20 years (no one knows its length)
for i=1,#ageticks do
--	print(ageticks[i])
end
-------------------------------------------------
--Ask about age
-------------------------------------------------
if varframe.age == nil then
	varframe.curframe = Lorehelper_AskAge(childage, oldage, ageticks, 
	{LHT("DwarfAgeYoung"), LHT("DwarfAgeThirdWar"), LHT("DwarfAgeThirdWar"), LHT("DwarfAgePeace"), LHT("DwarfAgeSecondWar"), LHT("DwarfAgeSecondWar"), LHT("DwarfAgeWarofThreeHammers")},
	LHART_DWARF); --also updates varframe.age
-------------------------------------------------
--Ask about home clan
-------------------------------------------------
--BUG: througout, array indices aren't processed by LHT function (e.g. "Clan" but not "LHT(Clan)"). It'll cause issues if I decide to translate the addon. Should replace it via regex at some point.
elseif varframe.responses["Clan"]==nil then
	varframe.curframe = Lorehelper_TestQuestion (LHT("Clan"), 
	LHT("DwarfClan"), 
	{LHT("Bronzebeard"), LHT("Wildhammer"), LHT("Dark Iron")}, 
	{LHT("DwarfClanBronzebeard"), LHT("DwarfClanWildhammer"), LHT("DwarfClanDarkIron")},
	LHART_DWARF,
	{LHART_DWARFBRONZEBEARD, LHART_DWARFWILDHAMMER, LHART_DWARFDARKIRON});
-------------------------------------------------
-------------------------------------------------
elseif varframe.responses["Third War"]==nil then--title of the last of the frames to be generated line below
	varframe.curframe = Lorehelper_Dwarf_Events (ageticks, childage);--function generating a few frames, depending on age
--	print (varframe.curframe.title:GetText())
-------------------------------------------------
-------------------------------------------------
else 
	local zones = Lorehelper_Dwarf_Zones ();
	varframe.curframe = Lorehelper_PresentAnswers(LHART_DWARF, {"Clan", "War of the Three Hammers", "First War", "Second War", "Third War"}, zones);--the order of questions is passed 
	if varframe.testdone == true then --if the test was done before and we're just relogging again
		varframe.curframe:Hide ();
		print (LHT("MsgAccessLoreProfile"));
	end
	varframe.testdone = true;
end

return varframe.curframe;
end
-------------------------------------------------
-------------------------------------------------
function Lorehelper_Dwarf_Events (ageticks, childage)
local varframe = Lorehelper_VarFrame;
local age = varframe.age;
--local fr = nil; --current frame, will be returned and varframe.curframe will be equal to it

standard_postanswers = {LHT("HumanStandardAvoided"), LHT("HumanStandardLostSomeone"), LHT("HumanStandardParticipated"), LHT("HumanStandardLostEverything")};

if varframe.responses["Clan"] == "Bronzebeard" then
	warofthreehammers_postanswers = Lorehelper_FormEventPostanswers (LHT("DwarfEventWarofThreeHammersBronzebeard"),standard_postanswers, false);	
elseif varframe.responses["Clan"] == "Wildhammer" then 
	warofthreehammers_postanswers = Lorehelper_FormEventPostanswers (LHT("DwarfEventWarofThreeHammersWildhammer"),standard_postanswers, false);	
elseif varframe.responses["Clan"] == "Dark Iron" then 
	warofthreehammers_postanswers = Lorehelper_FormEventPostanswers (LHT("DwarfEventWarofThreeHammersDarkIron"),standard_postanswers, false);	
end

if varframe.class == "Priest" or varframe.class == "Paladin" then
	firstwar_postanswers = Lorehelper_FormEventPostanswers (LHT("DwarfEventFirstWarPriestPaladin"),standard_postanswers, true);	
else 
	firstwar_postanswers = Lorehelper_FormEventPostanswers (LHT("DwarfEventFirstWarStandard"),standard_postanswers, true);	
end

if varframe.responses["Clan"] == "Bronzebeard" then
	secondwar_postanswers = Lorehelper_FormEventPostanswers (LHT("DwarfEventSecondWarBronzebeard"),standard_postanswers, false);	
elseif varframe.responses["Clan"] == "Wildhammer" then 
	secondwar_postanswers = Lorehelper_FormEventPostanswers (LHT("DwarfEventSecondWarWildhammer"),standard_postanswers, false);	
elseif varframe.responses["Clan"] == "Dark Iron" then 
	secondwar_postanswers = Lorehelper_FormEventPostanswers (LHT("DwarfEventSecondWarDarkIron"),standard_postanswers, false);	
end	

thirdwar_postanswers = Lorehelper_FormEventPostanswers (LHT("DwarfEventThirdWarStandard"),standard_postanswers, false);	
-------
--ageticks are
--the end of Third War, the beginning of it, end of Second, beginning, beginning of First, beginning of War of the Three Hammers

--varframe.age+childage >= ageticks[#ageticks] indicates whether player was born during the event
--(varframe.age < ageticks[#ageticks]) is the logical waschild variable
if varframe.responses["War of the Three Hammers"]==nil then--age of 61 (18 by the beginning of Gurubashi) is enough to possibly participate in Gurubashi
	varframe.curframe = Lorehelper_EventTestQuestion (LHT("War of the Three Hammers"), LHT("DwarfEventWarofThreeHammers"), (age+childage >= ageticks[#ageticks]), (age < ageticks[#ageticks]), warofthreehammers_postanswers, LHART_WAROFTHREEHAMMERS);
	return varframe.curframe;

end

if varframe.responses["First War"]==nil then
	--age of 41 (20 by the beginning of Second war) is enough to possibly participate in First
		varframe.curframe = Lorehelper_EventTestQuestion (LHT("First War"), LHT("DwarfEventFirstWar"), (age+childage >= ageticks[#ageticks-2]), (age < ageticks[#ageticks-2]), firstwar_postanswers, LHART_FIRSTWAR);
		return varframe.curframe;
end

if varframe.responses["Second War"]==nil then
	--age of 35 (20 by the end of Second war) is enough to possibly participate in Second
		varframe.curframe = Lorehelper_EventTestQuestion (LHT("Second War"), LHT("DwarfEventSecondWar"), (age+childage >= ageticks[#ageticks-3]), (age < ageticks[#ageticks-3]), secondwar_postanswers, LHART_SECONDWAR);
		return varframe.curframe;
end

if varframe.responses["Third War"]==nil then--age of 25 is enough to possibly participate in Third
		varframe.curframe = Lorehelper_EventTestQuestion (LHT("Third War"), LHT("DwarfEventThirdWar"), (age+childage >= ageticks[2]), (age < ageticks[2]), thirdwar_postanswers, LHART_THIRDWARKALIMDOR);
		return varframe.curframe;
end

return varframe.curframe;
end
-------------------------------------------------
-------------------------------------------------
function Lorehelper_Dwarf_Zones (forzonepedia)
local varframe = Lorehelper_VarFrame;
		
local zones = {
		{"Western Plaguelands", 3, "", true},
		{"Wetlands", 6, ""},
		{"Searing Gorge", 15, "", true},
		{"The Hinterlands", 4, ""},
		{"Redridge Mountains", 1, ""},
		{"Ashenvale", 2, ""},
		{"Badlands", 10, "", true}
		};
	 
for i,z in ipairs(zones) do
	z[3]=LHT("DwarfZone"..z[1]);
	if z[4] then
		z[4]=LHT("DwarfZoneTooltip"..z[1]);
	end
end

if forzonepedia then
	return zones;
end

Lorehelper_Link_Zone_with_Answer (zones, "Badlands", "Clan", "Bronzebeard", "DwarfZone", 5);
Lorehelper_Link_Zone_with_Answer (zones, "Wetlands", "Clan", "Wildhammer", "DwarfZoneWetlands", 12);--non-standard prefix format!	
Lorehelper_Link_Zone_with_Answer (zones, "Searing Gorge", "Clan", "Dark Iron", "DwarfZone", 24);
Lorehelper_Link_Zone_with_Answer (zones, "The Hinterlands", "Clan", "Wildhammer", "DwarfZoneThe Hinterlands", 24);--non-standard prefix format!
Lorehelper_Link_Zone_with_Event (zones, "Ashenvale", "Third War", "DwarfZone");
Lorehelper_Link_Zone_with_Event (zones, "Western Plaguelands", "Third War", "DwarfZone");
Lorehelper_Link_Zone_with_Event (zones, "Searing Gorge", "Second War", "DwarfZone");
Lorehelper_Link_Zone_with_Event (zones, "Redridge Mountains", "First War", "DwarfZone");

table.sort(zones, Lorehelper_CompareBy2ndElement)

return zones;
end
-------------------------------------------------
-------------------------------------------------
-------------------------------------------------
function Lorehelper_Gnome ()

local varframe = Lorehelper_VarFrame;
local childage = 24;
local oldage = 500;
local ageticks = Lorehelper_FormAgeTicks(childage, {21, 20, 10, 4, 0, -230, -400})--will still be partially hardcoded
--the end of Third War, the beginning of it, end of Second, beginning, beginning of First, beginning of War of Three Hammers, King Mechagon disappearance
for i=1,#ageticks do
--	print(ageticks[i])
end
-------------------------------------------------
--Ask about age
-------------------------------------------------
if varframe.age == nil then
	varframe.curframe = Lorehelper_AskAge(childage, oldage, ageticks, 
	{LHT("GnomeAgeYoung"), LHT("GnomeAgeThirdWar"), LHT("GnomeAgeThirdWar"), LHT("GnomeAgePeace"), LHT("GnomeAgeSecondWar"), LHT("GnomeAgeSecondWar"), LHT("GnomeAgeWarofThreeHammers"), LHT("GnomeAgeKingMechagon")},
	LHART_GNOME); --also updates varframe.age
-------------------------------------------------
--Ask whether a gnome is an engineer or not
-------------------------------------------------
elseif varframe.responses["Engineer"]==nil then
	varframe.curframe = Lorehelper_TestQuestion (LHT("Engineer"), 
	LHT("GnomeEngineer"), 
	{LHT("Yes"), LHT("No")}, 
	{LHT("GnomeEngineerYes"), LHT("GnomeEngineerNo")},
	LHART_GNOME,
	{LHART_GNOMEENGINEER, LHART_GNOMENONENGINEER});
-------------------------------------------------
elseif varframe.responses["Third War"]==nil then--title of the last of the frames to be generated line below
	varframe.curframe = Lorehelper_Gnome_Events (ageticks, childage);--function generating a few frames, depending on age
-------------------------------------------------
-------------------------------------------------
else 
	local zones = Lorehelper_Gnome_Zones (forzonepedia);
	varframe.curframe = Lorehelper_PresentAnswers(LHART_GNOME, {"Engineer", "King Mechagon disappearance", "War of the Three Hammers", "First War", "Second War", "Fighting for Gnomeregan", "Third War"}, zones);--the order of questions is passed 
	if varframe.testdone == true then --if the test was done before and we're just relogging again
		varframe.curframe:Hide ();
		print (LHT("MsgAccessLoreProfile"));
	end
	varframe.testdone = true;
end

return varframe.curframe;
end
-------------------------------------------------
-------------------------------------------------
function Lorehelper_Gnome_Events (ageticks, childage)
local varframe = Lorehelper_VarFrame;
local age = varframe.age;

--FEATURE: all the crap below would be more memory-efficient to put under if here and in other functions
standard_postanswers = {LHT("GnomeStandardAvoided"), LHT("GnomeStandardLostSomeone"), LHT("GnomeStandardParticipated"), LHT("GnomeStandardLostEverything")};

kingmechagon_postanswers = Lorehelper_FormEventPostanswers (LHT("GnomeEventKingMechagonStandard"), standard_postanswers, true);	

warofthreehammers_postanswers = Lorehelper_FormEventPostanswers (LHT("GnomeEventWarofThreeHammersStandard"),standard_postanswers, true);	

firstwar_postanswers = Lorehelper_FormEventPostanswers (LHT("GnomeEventFirstWarStandard"),standard_postanswers, true);	

secondwar_postanswers = Lorehelper_FormEventPostanswers (LHT("GnomeEventSecondWarStandard"),standard_postanswers, false);	

gnomeregan_postanswers = Lorehelper_FormEventPostanswers (LHT("GnomeEventGnomereganStandard"),standard_postanswers, false);	

thirdwar_postanswers = Lorehelper_FormEventPostanswers (LHT("GnomeEventThirdWarStandard"),standard_postanswers, true);	
-------
--ageticks are
--the end of Third War, the beginning of it, end of Second, beginning, beginning of First, beginning of War of the Three Hammers, King Mechagon disappearance

--varframe.age+childage >= ageticks[#ageticks] indicates whether player was born during the event
--(varframe.age < ageticks[#ageticks]) is the logical waschild variable

--FEATURE: maybe I need a more-customizable event test question function for non-violent events
if varframe.responses["King Mechagon disappearance"]==nil then
		varframe.curframe = Lorehelper_EventTestQuestion (LHT("King Mechagon disappearance"), LHT("GnomeEventKingMechagon"), (age+childage >= ageticks[#ageticks]), (age < ageticks[#ageticks]), kingmechagon_postanswers, LHART_KINGMECHAGON);
		return varframe.curframe;
end

--FEATURE: maybe I need to automate the creation of text keys by concatenating strings (would work like "GnomeEvent".."War of the Three Hammers"). Or maybe it's an overkill.
if varframe.responses["War of the Three Hammers"]==nil then
		varframe.curframe = Lorehelper_EventTestQuestion (LHT("War of the Three Hammers"), LHT("GnomeEventWarofThreeHammers"), (age+childage >= ageticks[#ageticks-1]), (age < ageticks[#ageticks-1]), warofthreehammers_postanswers, LHART_WAROFTHREEHAMMERS);
		return varframe.curframe;
end

if varframe.responses["First War"]==nil then
		varframe.curframe = Lorehelper_EventTestQuestion (LHT("First War"), LHT("GnomeEventFirstWar"), (age+childage >= ageticks[#ageticks-3]), (age < ageticks[#ageticks-3]), firstwar_postanswers, LHART_FIRSTWAR);
		return varframe.curframe;
end

if varframe.responses["Second War"]==nil then
		varframe.curframe = Lorehelper_EventTestQuestion (LHT("Second War"), LHT("GnomeEventSecondWar"), (age+childage >= ageticks[#ageticks-4]), (age < ageticks[#ageticks-4]), secondwar_postanswers, LHART_SECONDWAR);
		return varframe.curframe;
end

if varframe.responses["Fighting for Gnomeregan"]==nil then
		varframe.curframe = Lorehelper_EventTestQuestion (LHT("Fighting for Gnomeregan"), LHT("GnomeEventGnomeregan"), (age+childage >= ageticks[2]), (age < ageticks[2]), gnomeregan_postanswers, LHART_GNOMEREGAN);
		return varframe.curframe;
end

if varframe.responses["Third War"]==nil then
		varframe.curframe = Lorehelper_EventTestQuestion (LHT("Third War"), LHT("GnomeEventThirdWar"), (age+childage >= ageticks[2]), (age < ageticks[2]), thirdwar_postanswers, LHART_THIRDWARKALIMDOR);
		return varframe.curframe;
end

return varframe.curframe;
end
-------------------------------------------------
-------------------------------------------------
function Lorehelper_Gnome_Zones ()
local varframe = Lorehelper_VarFrame;
		
local zones = {
		{"Badlands", 2, "", true},
		{"Un'Goro Crater", 1, ""},
		{"Tanaris", 3, "", true},
		{"Stonetalon Mountains", 4, ""},
		{"Ashenvale", 7, ""},
		{"Redridge Mountains", 5, ""},
		{"Burning Steppes", 6, ""},
		};
	 
for i,z in ipairs(zones) do
	z[3]=LHT("GnomeZone"..z[1]);
	if z[4] then
		z[4]=LHT("GnomeZoneTooltip"..z[1]);
	end
end

if forzonepedia then
	return zones;
end

Lorehelper_Link_Zone_with_Answer (zones, "Badlands", "Engineer", "Yes", "GnomeZone", 6);
Lorehelper_Link_Zone_with_Answer (zones, "Tanaris", "Engineer", "Yes", "GnomeZone", 24);
Lorehelper_Link_Zone_with_Answer (zones, "Stonetalon Mountains", "Engineer", "Yes", "GnomeZone", 24);
Lorehelper_Link_Zone_with_Answer (zones, "Un'Goro Crater", "Engineer", "Yes", "GnomeZone", 24);
Lorehelper_Link_Zone_with_Answer (zones, "Badlands", "Engineer", "No", "GnomeZone", 3);
Lorehelper_Link_Zone_with_Answer (zones, "Tanaris", "Engineer", "No", "GnomeZone", 6);
Lorehelper_Link_Zone_with_Answer (zones, "Stonetalon Mountains", "Engineer", "No", "GnomeZone", 6);
Lorehelper_Link_Zone_with_Answer (zones, "Un'Goro Crater", "Engineer", "No", "GnomeZone", 6);
Lorehelper_Link_Zone_with_Event (zones, "Ashenvale", "Third War", "GnomeZone");
Lorehelper_Link_Zone_with_Event (zones, "Burning Steppes", "Second War", "GnomeZone");
Lorehelper_Link_Zone_with_Event (zones, "Redridge Mountains", "First War", "GnomeZone");

table.sort(zones, Lorehelper_CompareBy2ndElement)

return zones;
end
-------------------------------------------------
-------------------------------------------------
-------------------------------------------------
function Lorehelper_Human ()
local varframe = Lorehelper_VarFrame;
--local fr = nil; --current frame, will be returned and varframe.curframe will be equal to it
local childage = 18;
local oldage = 80;
local ageticks = Lorehelper_FormAgeTicks(childage, {21, 20, 10, 4, 0, -18})--will still be partially hardcoded
--the end of Third War, the beginning of it, end of Second, beginning, beginning of First, Gurubashi War year
for i=1,#ageticks do
--	print(ageticks[i])
end
-------------------------------------------------
--Ask about age
-------------------------------------------------
if varframe.age == nil then
	varframe.curframe = Lorehelper_AskAge(childage, oldage, ageticks, 
	{LHT("HumanAge18-23"), LHT("HumanAge23-33"), LHT("HumanAge23-33"), LHT("HumanAge33-39"), LHT("HumanAge39-43"), LHT("HumanAge43-61"), LHT("HumanAge61-80")},
	LHART_HUMAN); --also updates varframe.age
-------------------------------------------------
--Ask about home kingdom
-------------------------------------------------
elseif varframe.responses["Home Kingdom"]==nil then
	if varframe.class == "Mage" then
		dalaran_text = LHT("HumanDalaranMage");
	else dalaran_text = LHT("HumanDalaranNonMage");
	end
	if varframe.age >= 35 then
		stormwind_text = LHT("HumanHomeKingdomStormwind35+");
	else stormwind_text = LHT("HumanHomeKingdomStormwind35-");
	end
	if varframe.class == "Warrior" then
		stromgarde_text = LHT("HumanHomeKingdomStromgardeWarrior");
	else stromgarde_text = LHT("HumanHomeKingdomStromgardeNonWarrior");
	end

	varframe.curframe = Lorehelper_TestQuestion (LHT("Home Kingdom"), 
	LHT("HumanHomeKingdom"), 
	{LHT("Alterac"), LHT("Dalaran"), LHT("Gilneas"), LHT("Kul Tiras"), LHT("Lordaeron"), LHT("Stormwind"), LHT("Stromgarde")}, 
	{LHT("HumanHomeKingdomAlterac"), dalaran_text, LHT("HumanHomeKingdomGilneas"), LHT("HumanHomeKingdomKulTiras"), LHT("HumanHomeKingdomLordaeron"), stormwind_text, stromgarde_text},
	LHART_HUMAN,
	{LHART_HUMANALTERAC, LHART_HUMANDALARAN, LHART_HUMANGILNEAS, LHART_HUMANKULTIRAS, LHART_HUMANLORDAERON, LHART_HUMANSTORMWIND, LHART_HUMANSTROMGARDE});
-------------------------------------------------
-------------------------------------------------
elseif varframe.responses["Third War: Kalimdor"]==nil then--title of the last of the frames to be generated line below
	varframe.curframe = Lorehelper_Human_Events (ageticks, childage);--function generating a few frames, depending on age
--	print (varframe.curframe.title:GetText())
-------------------------------------------------
-------------------------------------------------
else 
	local zones = Lorehelper_Human_Zones();
	varframe.curframe = Lorehelper_PresentAnswers(LHART_HUMAN, {"Home Kingdom", "Gurubashi War", "First War", "Second War", "Third War: Plague", "Third War: Kalimdor"}, zones);--the order of questions is passed 
	if varframe.testdone == true then --if the test was done before and we're just relogging again
		varframe.curframe:Hide ();
		print (LHT("MsgAccessLoreProfile"));
	end
	varframe.testdone = true;
	--Lorehelper_SimpleMessage ("Click the Lorehelper button near your minimap, or type /lore to see your answers.");
end

--below is the temporary nonsense to export map IDs
--[[for zoneid = 111,10000 do
	local thezone = ""
	if C_Map.GetMapInfo(zoneid) then
		thezone = C_Map.GetMapInfo(zoneid)["name"];
		thezone = thezone:gsub(" ", "");--i.e. "TheBarrens"
		Lorehelper_MapIDsNames[zoneid]=thezone;
	end
	if _G["Lorehelper_ZoneButton"..thezone] then
		print(thezone)
	end
end
;--]]

return varframe.curframe;
end
-------------------------------------------------
-------------------------------------------------
function Lorehelper_Human_Events (ageticks, childage)
local varframe = Lorehelper_VarFrame;
local age = varframe.age;
--local fr = nil; --current frame, will be returned and varframe.curframe will be equal to it

standard_postanswers = {LHT("HumanStandardAvoided"), LHT("HumanStandardLostSomeone"), LHT("HumanStandardParticipated"), LHT("HumanStandardLostEverything")};

if varframe.responses["Home Kingdom"] == "Stormwind" then
	gurubashi_postanswers = Lorehelper_FormEventPostanswers (LHT("HumanEventGurubashiWarStormwind"),standard_postanswers, false);	
	firstwar_postanswers = Lorehelper_FormEventPostanswers (LHT("HumanEventFirstWarStormwind"),standard_postanswers, false);	
else 
	gurubashi_postanswers = Lorehelper_FormEventPostanswers (LHT("HumanEventGurubashiWarStandard"), standard_postanswers, true);
	firstwar_postanswers = Lorehelper_FormEventPostanswers (LHT("HumanEventFirstWarStandard"),standard_postanswers, true);	
end

secondwar_postanswers = Lorehelper_FormEventPostanswers (LHT("HumanEventSecondWarStandard"),standard_postanswers, false);	

if varframe.responses["Home Kingdom"] == "Lordaeron" then
	thirdwarplague_postanswers = Lorehelper_FormEventPostanswers (LHT("HumanEventThirdWarPlagueLordaeron"),standard_postanswers, false);	
elseif varframe.responses["Home Kingdom"] == "Dalaran" then
	thirdwarplague_postanswers = Lorehelper_FormEventPostanswers (LHT("HumanEventThirdWarPlagueDalaran"),standard_postanswers, false);	
else
	thirdwarplague_postanswers = Lorehelper_FormEventPostanswers (LHT("HumanEventThirdWarPlagueStandard"),standard_postanswers, false);--there will be no "however" for those from e.g. Gilneas participating
end

if varframe.responses["Home Kingdom"] == "Kul Tiras" or varframe.responses["Home Kingdom"] == "Lordaeron" then
	thirdwarkalimdor_postanswers = Lorehelper_FormEventPostanswers (LHT("HumanEventThirdWarKalimdorKulTirasLordaeron"), standard_postanswers, false);	
else 
	thirdwarkalimdor_postanswers = Lorehelper_FormEventPostanswers (LHT("HumanEventThirdWarKalimdorStandard"),standard_postanswers, false);--there will be no "however" for those from e.g. Gilneas participating
end
-------
--ageticks are
--the end of Third War, the beginning of it, end of Second, beginning, beginning of First, Gurubashi War year

--varframe.age+childage >= ageticks[#ageticks] indicates whether player was born during the event
--(varframe.age < ageticks[#ageticks]) is the logical waschild variable
if varframe.responses["Gurubashi War"]==nil then--age of 61 (18 by the beginning of Gurubashi) is enough to possibly participate in Gurubashi
		varframe.curframe = Lorehelper_EventTestQuestion (LHT("Gurubashi War"), LHT("HumanEventGurubashiWar"), (age+childage >= ageticks[#ageticks]), (age < ageticks[#ageticks]), gurubashi_postanswers, LHART_GURUBASHIWAR);
		return varframe.curframe;
end

if varframe.responses["First War"]==nil then
--age of 39 (18 by the beginning of Second war) is enough to possibly participate in First
		varframe.curframe = Lorehelper_EventTestQuestion (LHT("First War"), LHT("HumanEventFirstWar"), (age+childage >= ageticks[#ageticks-2]), (age < ageticks[#ageticks-2]), firstwar_postanswers, LHART_FIRSTWAR);
		return varframe.curframe;
end

if varframe.responses["Second War"]==nil then
	--age of 33 (18 by the end of Second war) is enough to possibly participate in Second
		varframe.curframe = Lorehelper_EventTestQuestion (LHT("Second War"), LHT("HumanEventSecondWar"), (age+childage >= ageticks[#ageticks-3]), (age < ageticks[#ageticks-3]), secondwar_postanswers, LHART_SECONDWAR);
		return varframe.curframe;
end

if varframe.responses["Third War: Plague"]==nil then--age of 23 is enough to possibly participate in Third
	--same array index intended, as both Third Wars are roughly same time!
		varframe.curframe = Lorehelper_EventTestQuestion (LHT("Third War: Plague"), LHT("HumanEventThirdWarPlague"), (age+childage >= ageticks[2]), (age < ageticks[2]), thirdwarplague_postanswers, LHART_THIRDWARPLAGUE);
		return varframe.curframe;
end

if varframe.responses["Third War: Kalimdor"]==nil then
		varframe.curframe = Lorehelper_EventTestQuestion (LHT("Third War: Kalimdor"), LHT("HumanEventThirdWarKalimdor"), (age+childage >= ageticks[2]), (age < ageticks[2]), thirdwarkalimdor_postanswers, LHART_THIRDWARKALIMDOR);
		return varframe.curframe;
end

return varframe.curframe;
end
-------------------------------------------------
function Lorehelper_Human_Zones (forzonepedia)
local varframe = Lorehelper_VarFrame;
		
local zones = {
		{"Dustwallow Marsh", 20, ""},
--		{"Tirisfal Glades", 1, ""},
--		{"Eastern Plaguelands", 1, ""},
--too many zones otherwise - all Lordaeron/Plague lore will be focused in WPL
		{"Western Plaguelands", 2, "", true},
		{"Silverpine Forest", 2, ""},
		{"Alterac Mountains", 2, ""},
		{"Arathi Highlands", 2, ""},
		{"Redridge Mountains", 3, ""},
		{"Burning Steppes", 3, ""},
		{"Westfall", 40, "", true},
		{"Ashenvale", 1, ""},
		{"Stranglethorn Vale", 1, ""}
		};
	 
for i,z in ipairs(zones) do
	z[3]=LHT("HumanZone"..z[1]);
	if z[4] then
		z[4]=LHT("HumanZoneTooltip"..z[1]);
	end
end

if forzonepedia then
	return zones;
end

--Lorehelper_Link_Zone_with_Answer (zones, "Tirisfal Glades", "Home Kingdom", "Lordaeron", "HumanZone", 24);
--Lorehelper_Link_Zone_with_Answer (zones, "Eastern Plaguelands", "Home Kingdom", "Lordaeron", "HumanZone", 24);
Lorehelper_Link_Zone_with_Answer (zones, "Western Plaguelands", "Home Kingdom", "Lordaeron", "HumanZone", 24);
Lorehelper_Link_Zone_with_Answer (zones, "Silverpine Forest", "Home Kingdom", "Gilneas", "HumanZone", 24);
Lorehelper_Link_Zone_with_Answer (zones, "Alterac Mountains", "Home Kingdom", "Alterac", "HumanZone", 24);
Lorehelper_Link_Zone_with_Answer (zones, "Alterac Mountains", "Home Kingdom", "Dalaran", "HumanZone", 24);
Lorehelper_Link_Zone_with_Answer (zones, "Arathi Highlands", "Home Kingdom", "Stromgarde", "HumanZone", 24);
Lorehelper_Link_Zone_with_Answer (zones, "Dustwallow Marsh", "Home Kingdom", "Kul Tiras", "HumanZone", 24);
Lorehelper_Link_Zone_with_Event (zones, "Ashenvale", "Third War: Kalimdor", "HumanZone");
Lorehelper_Link_Zone_with_Event (zones, "Western Plaguelands", "Third War: Plague", "HumanZone")
Lorehelper_Link_Zone_with_Event (zones, "Alterac Mountains", "Third War: Plague", "HumanZone")
Lorehelper_Link_Zone_with_Event (zones, "Burning Steppes", "Second War", "HumanZone");
Lorehelper_Link_Zone_with_Event (zones, "Redridge Mountains", "First War", "HumanZone");
Lorehelper_Link_Zone_with_Event (zones, "Stranglethorn Vale", "Gurubashi War", "HumanZone");

table.sort(zones, Lorehelper_CompareBy2ndElement)

return zones;
end
-------------------------------------------------
-------------------------------------------------
-------------------------------------------------
-------------------------------------------------
function Lorehelper_Troll ()

local varframe = Lorehelper_VarFrame;
local childage = 14;
local oldage = 120;
local ageticks = Lorehelper_FormAgeTicks(childage, {22, 21, 20, 10, 4, 0, -18})--will still be partially hardcoded
--war with Theramore, the end of Third War, the beginning of it, end of Second, beginning, beginning of First (only for jungle trolls really), beginning of Gurubasi War (same)
for i=1,#ageticks do
--	print(ageticks[i])
end
-------------------------------------------------
--Ask about age
-------------------------------------------------
if varframe.age == nil then
	varframe.curframe = Lorehelper_AskAge(childage, oldage, ageticks, 
	{LHT("TrollAgeYoung"), LHT("TrollAgeYoung"), LHT("TrollAgeThirdWar"), LHT("TrollAgeThirdWar"), LHT("TrollAgeBetweenWar"), LHT("TrollAgeSecondWar"), LHT("TrollAgeOld"), LHT("TrollAgeOld")},
	LHART_TROLL); --also updates varframe.age
-------------------------------------------------
--Ask about home tribe
-------------------------------------------------
elseif varframe.responses["Tribe"]==nil then
	varframe.curframe = Lorehelper_TestQuestion (LHT("Tribe"), 
	LHT("TrollTribe"), 
	{LHT("Darkspear"), LHT("Revantusk"), LHT("Shatterspear"), LHT("Zandalari"), LHT("Bad tribe")}, 
	{LHT("TrollTribeDarkspear"), LHT("TrollTribeRevantusk"), LHT("TrollTribeShatterspear"), LHT("TrollTribeZandalari"), LHT("TrollTribeBad")},
	LHART_TROLL,
	{LHART_TROLLDARKSPEAR, LHART_TROLLREVANTUSK, LHART_TROLLSHATTERSPEAR, LHART_TROLLZANDALARI, LHART_TROLLBADTRIBE});
-------------------------------------------------
-------------------------------------------------
elseif varframe.responses["War with Theramore"]==nil then--title of the last of the frames to be generated line below
	varframe.curframe = Lorehelper_Troll_Events (ageticks, childage);--function generating a few frames, depending on age
-------------------------------------------------
-------------------------------------------------
else 
	local zones = Lorehelper_Troll_Zones ();
	varframe.curframe = Lorehelper_PresentAnswers(LHART_TROLL, {"Tribe", "Gurubashi War", "First War", "Second War", "Third War", "War with Theramore"}, zones);--the order of questions is passed 
	if varframe.testdone == true then --if the test was done before and we're just relogging again
		varframe.curframe:Hide ();
		print (LHT("MsgAccessLoreProfile"));
	end
	varframe.testdone = true;
end

return varframe.curframe;
end
-------------------------------------------------
-------------------------------------------------
function Lorehelper_Troll_Events (ageticks, childage)
local varframe = Lorehelper_VarFrame;
local age = varframe.age;

standard_postanswers = {LHT("TrollStandardAvoided"), LHT("TrollStandardLostSomeone"), LHT("TrollStandardParticipated"), LHT("TrollStandardLostEverything")};

if varframe.responses["Tribe"] == "Bad tribe" then
	gurubashiwar_postanswers = Lorehelper_FormEventPostanswers (LHT("TrollEventGurubashiWarBadTribe"),standard_postanswers, false);	
	firstwar_postanswers = Lorehelper_FormEventPostanswers (LHT("TrollEventFirstWarJungleTroll"),standard_postanswers, false);	
	secondwar_postanswers = Lorehelper_FormEventPostanswers (LHT("TrollEventSecondWarForestTroll"),standard_postanswers, false);	
	thirdwar_postanswers = Lorehelper_FormEventPostanswers (LHT("TrollEventThirdWarStandard"),standard_postanswers, true);
	wartheramore_postanswers = Lorehelper_FormEventPostanswers (LHT("TrollEventWarTheramoreStandard"),standard_postanswers, true);
elseif varframe.responses["Tribe"] == "Darkspear" then 
	gurubashiwar_postanswers = Lorehelper_FormEventPostanswers (LHT("TrollEventGurubashiWarStandard"),standard_postanswers, true);	
	firstwar_postanswers = Lorehelper_FormEventPostanswers (LHT("TrollEventFirstWarJungleTroll"),standard_postanswers, false);	
	secondwar_postanswers = Lorehelper_FormEventPostanswers (LHT("TrollEventSecondWarStandard"),standard_postanswers, true);
	thirdwar_postanswers = Lorehelper_FormEventPostanswers (LHT("TrollEventThirdWarDarkspear"),standard_postanswers, false);
	wartheramore_postanswers = Lorehelper_FormEventPostanswers (LHT("TrollEventWarTheramoreDarkspear"),standard_postanswers, false);
elseif varframe.responses["Tribe"] == "Revantusk" then 
	gurubashiwar_postanswers = Lorehelper_FormEventPostanswers (LHT("TrollEventGurubashiWarStandard"),standard_postanswers, true);	
	firstwar_postanswers = Lorehelper_FormEventPostanswers (LHT("TrollEventFirstWarStandard"),standard_postanswers, true);	
	secondwar_postanswers = Lorehelper_FormEventPostanswers (LHT("TrollEventSecondWarForestTroll"),standard_postanswers, false);
	thirdwar_postanswers = Lorehelper_FormEventPostanswers (LHT("TrollEventThirdWarStandard"),standard_postanswers, true);
	wartheramore_postanswers = Lorehelper_FormEventPostanswers (LHT("TrollEventWarTheramoreStandard"),standard_postanswers, true);
else
	gurubashiwar_postanswers = Lorehelper_FormEventPostanswers (LHT("TrollEventGurubashiWarStandard"),standard_postanswers, true);	
	firstwar_postanswers = Lorehelper_FormEventPostanswers (LHT("TrollEventFirstWarStandard"),standard_postanswers, true);	
	secondwar_postanswers = Lorehelper_FormEventPostanswers (LHT("TrollEventSecondWarStandard"),standard_postanswers, true);
	thirdwar_postanswers = Lorehelper_FormEventPostanswers (LHT("TrollEventThirdWarStandard"),standard_postanswers, true);
	wartheramore_postanswers = Lorehelper_FormEventPostanswers (LHT("TrollEventWarTheramoreStandard"),	standard_postanswers, true);
end	
-------
--ageticks are
--the end of Third War, the beginning of it, end of Second, beginning, beginning of First (only for jungle trolls really), beginning of Gurubasi War (same)

--varframe.age+childage >= ageticks[#ageticks] indicates whether player was born during the event
--(varframe.age < ageticks[#ageticks]) is the logical waschild variable
if varframe.responses["Gurubashi War"]==nil then
		varframe.curframe = Lorehelper_EventTestQuestion (LHT("Gurubashi War"), LHT("TrollEventGurubashiWar"), (age+childage >= ageticks[#ageticks]), (age < ageticks[#ageticks]), gurubashiwar_postanswers, LHART_GURUBASHIWAR);
		return varframe.curframe;
end

if varframe.responses["First War"]==nil then
	--age of 36 (14 by the beginning of Second war) is enough to possibly participate in First
		varframe.curframe = Lorehelper_EventTestQuestion (LHT("First War"), LHT("TrollEventFirstWar"), (age+childage >= ageticks[#ageticks-2]), (age < ageticks[#ageticks-2]), firstwar_postanswers, LHART_FIRSTWAR);
		return varframe.curframe;
end

if varframe.responses["Second War"]==nil then
	--age of 29 (14 by the end of Second war) is enough to possibly participate in Second
		varframe.curframe = Lorehelper_EventTestQuestion (LHT("Second War"), LHT("TrollEventSecondWar"), (age+childage >= ageticks[#ageticks-3] ), (age < ageticks[#ageticks-3]), secondwar_postanswers, LHART_SECONDWARHORDE);
		return varframe.curframe;
end

if varframe.responses["Third War"]==nil then--age of 18 is enough to possibly participate in Third
		varframe.curframe = Lorehelper_EventTestQuestion (LHT("Third War"), LHT("TrollEventThirdWar"), (age+childage >= ageticks[2]), (age < ageticks[2]), thirdwar_postanswers, LHART_THIRDWARKALIMDOR);
		return varframe.curframe;
end

if varframe.responses["War with Theramore"]==nil then--age of 17 is enough to possibly participate in it
		varframe.curframe = Lorehelper_EventTestQuestion (LHT("War with Theramore"), LHT("TrollEventWarTheramore"), (age+childage >= ageticks[1]), (age < ageticks[1]), wartheramore_postanswers, LHART_WARWITHTHERAMORE);
		return varframe.curframe;
end


return varframe.curframe;
end
-------------------------------------------------
-------------------------------------------------
function Lorehelper_Troll_Zones (forzonepedia)
local varframe = Lorehelper_VarFrame;
		
local zones = {
		{"Dustwallow Marsh", 10, ""},
		{"Ashenvale", 5, ""},
		{"Stranglethorn Vale", 15, ""},
		{"The Hinterlands", 7, "", true},
		{"Dun Morogh", 2, ""},
		{"Swamp of Sorrows", 6, "", true},
		{"Tanaris", 9, "", true},
		{"Eastern Plaguelands", 4, "", true},
		{"Darkshore", 1, ""},
		{"Hillsbrad Foothills", 3, ""}
		};
	 
for i,z in ipairs(zones) do
	z[3]=LHT("TrollZone"..z[1]);
	if z[4] then
		z[4]=LHT("TrollZoneTooltip"..z[1]);
	end
end

if forzonepedia then
	return zones;
end

Lorehelper_Link_Zone_with_Answer (zones, "Stranglethorn Vale", "Tribe", "Darkspear", "TrollZone", 18)
Lorehelper_Link_Zone_with_Answer (zones, "Stranglethorn Vale", "Tribe", "Zandalari", "TrollZone", 18)
Lorehelper_Link_Zone_with_Answer (zones, "Stranglethorn Vale", "Tribe", "Bad tribe", "TrollZone", 12)
Lorehelper_Link_Zone_with_Answer (zones, "The Hinterlands", "Tribe", "Bad tribe", "TrollZone", 12)
Lorehelper_Link_Zone_with_Answer (zones, "Eastern Plaguelands", "Tribe", "Bad tribe", "TrollZone", 12)
Lorehelper_Link_Zone_with_Answer (zones, "Tanaris", "Tribe", "Bad tribe", "TrollZone", 12)
Lorehelper_Link_Zone_with_Answer (zones, "Dun Morogh", "Tribe", "Bad tribe", "TrollZone", 12)
Lorehelper_Link_Zone_with_Answer (zones, "Swamp of Sorrows", "Tribe", "Bad tribe", "TrollZone", 12)
Lorehelper_Link_Zone_with_Answer (zones, "The Hinterlands", "Tribe", "Revantusk", "TrollZone", 24)
Lorehelper_Link_Zone_with_Answer (zones, "Darkshore", "Tribe", "Shatterspear", "TrollZone", 18)
--Lorehelper_Link_Zone_with_Event (zones, "Stranglethorn Vale", "Gurubashi War", "TrollZone")
--if varframe.responses["Gurubashi War"]=="Avoided" then--to not link twice
--screw linking Gurubashi War to a zone actually
Lorehelper_Link_Zone_with_Event (zones, "Stranglethorn Vale", "First War", "TrollZone")
--end
Lorehelper_Link_Zone_with_Event (zones, "Hillsbrad Foothills", "Second War", "TrollZone")
Lorehelper_Link_Zone_with_Event (zones, "Ashenvale", "Third War", "TrollZone")
Lorehelper_Link_Zone_with_Event (zones, "Dustwallow Marsh", "War with Theramore", "TrollZone");

table.sort(zones, Lorehelper_CompareBy2ndElement)

return zones;
end
-------------------------------------------------
-------------------------------------------------
-------------------------------------------------
function Lorehelper_Tauren ()

local varframe = Lorehelper_VarFrame;
local childage = 14;
local oldage = 120;
local ageticks = Lorehelper_FormAgeTicks(childage, {22, 21, 20, 0})--will still be partially hardcoded
--war with Theramore, the end of Third War, the beginning of it, beginning of First War just to have something 
for i=1,#ageticks do
--	print(ageticks[i])
end
-------------------------------------------------
--Ask about age
-------------------------------------------------
if varframe.age == nil then
	varframe.curframe = Lorehelper_AskAge(childage, oldage, ageticks, 
	{LHT("TaurenAgeYoung"), LHT("TaurenAgeYoung"), LHT("TaurenAgeThirdWar"), LHT("TaurenAgeThirdWar"), LHT("TaurenAgeMiddleAge")},
	LHART_TAUREN); --also updates varframe.age
-------------------------------------------------
--Ask whether a tauren belongs to Grimtotem clan
-------------------------------------------------
elseif varframe.responses["Grimtotem"]==nil then
	if varframe.class == "Druid" then--it's all ugly but I've typed it already
		grimtotem_text = LHT("TaurenGrimtotemDruid");
		nongrimtotem_text = LHT("TaurenNonGrimtotemDruid");
	elseif varframe.class == "Shaman" then		
		grimtotem_text = LHT("TaurenGrimtotemShaman");
		nongrimtotem_text = LHT("TaurenNonGrimtotemShaman");
	elseif varframe.class == "Hunter" then		
		grimtotem_text = LHT("TaurenGrimtotemHunter");
		nongrimtotem_text = LHT("TaurenNonGrimtotemHunter");
	elseif varframe.class == "Warrior" then		
		grimtotem_text = LHT("TaurenGrimtotemWarrior");
		nongrimtotem_text = LHT("TaurenNonGrimtotemWarrior");
	end
	
	varframe.curframe = Lorehelper_TestQuestion (LHT("Grimtotem"), 
	LHT("TaurenGrimtotem"), 
	{LHT("Yes"), LHT("No")}, 
	{grimtotem_text, nongrimtotem_text},
	LHART_TAUREN,
	{LHART_TAURENGRIMTOTEM, LHART_TAURENNONGRIMTOTEM});
-------------------------------------------------
elseif varframe.responses["War with Theramore"]==nil then--title of the last of the frames to be generated line below
	varframe.curframe = Lorehelper_Tauren_Events (ageticks, childage);--function generating a few frames, depending on age
-------------------------------------------------
-------------------------------------------------
else 
	local zones = Lorehelper_Tauren_Zones();
	varframe.curframe = Lorehelper_PresentAnswers(LHART_TAUREN, {"Grimtotem", "Third War", "War with Theramore"}, zones);--the order of questions is passed 
	if varframe.testdone == true then --if the test was done before and we're just relogging again
		varframe.curframe:Hide ();
		print (LHT("MsgAccessLoreProfile"));
	end
	varframe.testdone = true;
end

return varframe.curframe;
end
-------------------------------------------------
-------------------------------------------------
function Lorehelper_Tauren_Events (ageticks, childage)
local varframe = Lorehelper_VarFrame;
local age = varframe.age;

standard_postanswers = {LHT("HumanStandardAvoided"), LHT("HumanStandardLostSomeone"), LHT("HumanStandardParticipated"), LHT("HumanStandardLostEverything")};

thirdwar_postanswers = Lorehelper_FormEventPostanswers (LHT("TaurenEventThirdWarStandard"),standard_postanswers, false);	

wartheramore_postanswers = Lorehelper_FormEventPostanswers (LHT("TaurenEventWarTheramoreStandard"),standard_postanswers, false);	
-------
--ageticks are
--war with Theramore, the end of Third War, the beginning of it, beginning of First

--varframe.age+childage >= ageticks[#ageticks] indicates whether player was born during the event
--(varframe.age < ageticks[#ageticks]) is the logical waschild variable

if varframe.responses["Third War"]==nil then
		varframe.curframe = Lorehelper_EventTestQuestion (LHT("Third War"), LHT("TaurenEventThirdWar"), (age+childage >= ageticks[2]), (age < ageticks[2]), thirdwar_postanswers, LHART_THIRDWARKALIMDOR);
		return varframe.curframe;
end

if varframe.responses["War with Theramore"]==nil then
		varframe.curframe = Lorehelper_EventTestQuestion (LHT("War with Theramore"), LHT("TaurenEventWarTheramore"), (age+childage >= ageticks[1]), (age < ageticks[1]), wartheramore_postanswers, LHART_WARWITHTHERAMORE);
		return varframe.curframe;
end

return varframe.curframe;
end
-------------------------------------------------
-------------------------------------------------
function Lorehelper_Tauren_Zones (forzonepedia)
local varframe = Lorehelper_VarFrame;
		
local zones = {
		{"Stonetalon Mountains", 2, ""},
		{"Thousand Needles", 5, ""},
		{"Dustwallow Marsh", 1, ""},
		{"Desolace", 20, "", true},
		{"Ashenvale", 3, ""},
		{"The Barrens", 40, ""}
		};
	 
for i,z in ipairs(zones) do
	z[3]=LHT("TaurenZone"..z[1]);
	if z[4] then
		z[4]=LHT("TaurenZoneTooltip"..z[1]);
	end
end

if forzonepedia then
	return zones;
end

Lorehelper_Link_Zone_with_Answer (zones, "Thousand Needles", "Grimtotem", "Yes", "TaurenZone", 24)
Lorehelper_Link_Zone_with_Event (zones, "Ashenvale", "Third War", "TaurenZone")
Lorehelper_Link_Zone_with_Event (zones, "Dustwallow Marsh", "War with Theramore", "TaurenZone");
--Lorehelper_Link_Zone_with_Class (zones, "Wailing Caverns", "Druid", "TaurenZone");

table.sort(zones, Lorehelper_CompareBy2ndElement)
--for i,n in ipairs(zones) do print(n[1]); print(n[2]); print(n[3]); print("--"); end

--print("------");

return zones;
end
-------------------------------------------------
-------------------------------------------------
-------------------------------------------------
function Lorehelper_Undead ()

local varframe = Lorehelper_VarFrame;
-------------------------------------------------
--Ask about age
-------------------------------------------------
if varframe.age == nil then
	varframe.age = "N/A";--since it's an undead
	Lorehelper_DoTest();--formally relaunch the function for symmetry with all the other races
-------------------------------------------------
--Ask if undead was a human or elf
-------------------------------------------------
elseif varframe.responses["Former race"]==nil then
	varframe.curframe = Lorehelper_TestQuestion (LHT("Former race"), 
	LHT("UndeadFormerRace"), 
	{LHT("Human"), LHT("Elf")}, 
	{LHT("UndeadFormerRaceHuman"), LHT("UndeadFormerRaceElf")},
	LHART_UNDEAD,
	{LHART_UNDEADHUMAN, LHART_UNDEADELF});
-------------------------------------------------
--Ask where did they die
-------------------------------------------------
elseif varframe.responses["Last living moment"]==nil then

	if varframe.class == "Priest" then
		lordaeron_text = LHT("UndeadLastMomentLordaeronPriest");
	else
		lordaeron_text = LHT("UndeadLastMomentLordaeronNonPriest");
	end
	
	if varframe.class == "Mage" then
		dalaran_text = LHT("UndeadLastMomentDalaranMage");
	else
		dalaran_text = LHT("UndeadLastMomentDalaranNonMage");
	end
	
	if varframe.responses["Former race"] == "Elf" then
		quelthalas_text = LHT("UndeadLastMomentQuelThalasElf");
	else
		quelthalas_text = LHT("UndeadLastMomentQuelThalasHuman");
	end

	varframe.curframe = Lorehelper_TestQuestion (LHT("Last living moment"), 
	LHT("UndeadLastLivingMoment"), 
	{LHT("Brill"), LHT("Andorhal"), LHT("Hearthglen"), LHT("Stratholme"), LHT("Lordaeron city"), LHT("Vandermar Village"), LHT("Quel'Thalas"), LHT("Dalaran")}, 
	{LHT("UndeadLastMomentBrill"), LHT("UndeadLastMomentAndorhal"), LHT("UndeadLastMomentHearthglen"), LHT("UndeadLastMomentStratholme"), lordaeron_text, LHT("UndeadLastMomentVandermar"), quelthalas_text, dalaran_text},
	LHART_UNDEAD);
-------------------------------------------------
elseif varframe.responses["Dreadlords' fall"]==nil then--title of the last of the frames to be generated line below
	varframe.curframe = Lorehelper_Undead_Events ();--function generating a few frames (maybe 1)
-------------------------------------------------
-------------------------------------------------
else 
	local zones = Lorehelper_Undead_Zones();
	varframe.curframe = Lorehelper_PresentAnswers(LHART_UNDEAD, {"Former race", "Last living moment", "Dreadlords' fall"}, zones);--the order of questions is passed 
	if varframe.testdone == true then --if the test was done before and we're just relogging again
		varframe.curframe:Hide ();
		print (LHT("MsgAccessLoreProfile"));
	end
	varframe.testdone = true;
end

return varframe.curframe;
end
-------------------------------------------------
-------------------------------------------------
function Lorehelper_Undead_Events (forzonepedia)
local varframe = Lorehelper_VarFrame;

standard_postanswers = {LHT("UndeadStandardAvoided"), LHT("UndeadStandardLostSomeone"), LHT("UndeadStandardParticipated"), LHT("UndeadStandardLostEverything")};

dreadlords_postanswers = Lorehelper_FormEventPostanswers (LHT("UndeadEventDreadlordsFallStandard"),standard_postanswers, false);	
-------
if varframe.responses["Dreadlords' fall"]==nil then
	varframe.curframe = Lorehelper_EventTestQuestion (LHT("Dreadlords' fall"), LHT("UndeadEventDreadlordsFall"), true, false, dreadlords_postanswers, LHART_DREADLORDS);--wasborn, not waschild
	return varframe.curframe;
end

return varframe.curframe;
end
-------------------------------------------------
-------------------------------------------------
function Lorehelper_Undead_Zones ()
local varframe = Lorehelper_VarFrame;
		
local zones = {
		{"Western Plaguelands", 3, "", true},
		{"Eastern Plaguelands", 4, ""},
		{"Silverpine Forest", 2, ""},
		{"Alterac Mountains", 1, ""},
		};
	 
for i,z in ipairs(zones) do
	z[3]=LHT("UndeadZone"..z[1]);
	if z[4] then
		z[4]=LHT("UndeadZoneTooltip"..z[1]);
	end
end

if forzonepedia then
	return zones;
end

Lorehelper_Link_Zone_with_Answer (zones, "Western Plaguelands", "Last living moment", "Andorhal", "UndeadZone", 24)
Lorehelper_Link_Zone_with_Answer (zones, "Western Plaguelands", "Last living moment", "Hearthglen", "UndeadZone", 24)
Lorehelper_Link_Zone_with_Answer (zones, "Eastern Plaguelands", "Last living moment", "Stratholme", "UndeadZone", 24)
Lorehelper_Link_Zone_with_Answer (zones, "Alterac Mountains", "Last living moment", "Dalaran", "UndeadZone", 24)

table.sort(zones, Lorehelper_CompareBy2ndElement)

return zones;
end
-------------------------------------------------
-------------------------------------------------
-------------------------------------------------
function Lorehelper_Orc ()

local varframe = Lorehelper_VarFrame;
local childage = 12;
local oldage = 90;
local ageticks = Lorehelper_FormAgeTicks(childage, {22, 21, 20, 15, 8, 6, 0, -4})--will still be partially hardcoded
--war with Theramore, the end of Third War, the beginning of it, the New Horde formation, destruction of Draenor, destruction of Dark Portal, beginning of First War, beginning of open war with draenei
for i=1,#ageticks do
--	print(ageticks[i])
end
-------------------------------------------------
--Ask about age
-------------------------------------------------
if varframe.age == nil then
	varframe.curframe = Lorehelper_AskAge(childage, oldage, ageticks, 
	{LHT("OrcAgeYoung"), LHT("OrcAgeYoung"), LHT("OrcAgeThirdWar"), LHT("OrcAgeThirdWar"), LHT("OrcAgeBetweenWar"), LHT("OrcAgeWarsinAzeroth"), LHT("OrcAgeWarsinAzeroth"), LHT("OrcAgeWarsinAzeroth"),LHT("OrcAgeMiddleAge")},
	LHART_ORC); --also updates varframe.age
-------------------------------------------------
--Ask about home clan
-------------------------------------------------
elseif varframe.responses["Clan"]==nil then

	if varframe.class == "Rogue" then
		shatteredhand_text = LHT("OrcClanShatteredHandRogue");
	else
		shatteredhand_text = LHT("OrcClanShatteredHandNonRogue");	
	end
	
	if varframe.class == "Warlock" then
		burningblade_text = LHT("OrcClanBurningBladeWarlock");
		twilighthsammer_text = LHT("OrcClanTwilightsHammerWarlock");
	else
		burningblade_text = LHT("OrcClanBurningBladeNonWarlock");
		twilighthsammer_text = LHT("OrcClanTwilightsHammerNonWarlock");
	end
	
	varframe.curframe = Lorehelper_TestQuestion (LHT("Clan"), 
	LHT("OrcClan"), 
	{LHT("Blackrock"), LHT("Bleeding Hollow"), LHT("Burning Blade"), LHT("Dragonmaw"), LHT("Frostwolf"), LHT("Shattered Hand"), LHT("Twilight's Hammer"), LHT("Warsong"), LHT("Minor clan")}, 
	{LHT("OrcClanBlackrock"), LHT("OrcClanBleedingHollow"), burningblade_text, LHT("OrcClanDragonmaw"), LHT("OrcClanFrostwolf"), shatteredhand_text, twilighthsammer_text, LHT("OrcClanWarsong"), LHT("OrcClanMinor")},
	LHART_ORC,
	{LHART_ORCBLACKROCK, LHART_ORCBLEEDINGHOLLOW, LHART_ORCBURNINGBLADE, LHART_ORCDRAGONMAW, LHART_ORCFROSTWOLF, LHART_ORCSHATTEREDHAND, LHART_ORCTWILIGHTSHAMMER, LHART_ORCWARSONG, LHART_ORCMINOR});
--[[
    Black Tooth Grin clan + Blackrock clan
    Bleeding Hollow clan
    Burning Blade clan
    Dragonmaw clan
    Frostwolf clan
    Shattered Hand clan
    Twilight's Hammer clan
    Warsong clan --]]
-------------------------------------------------
-------------------------------------------------
elseif varframe.responses["War with Theramore"]==nil then--title of the last of the frames to be generated line below
	varframe.curframe = Lorehelper_Orc_Events (ageticks, childage);--function generating a few frames, depending on age
-------------------------------------------------
-------------------------------------------------
else 
	local zones = Lorehelper_Orc_Zones ();
	varframe.curframe = Lorehelper_PresentAnswers(LHART_ORC, {"Clan", "War with draenei", "Wars in Azeroth", "End of Draenor", "Liberation", "Third War", "War with Theramore"}, zones);--the order of questions is passed 
	if varframe.testdone == true then --if the test was done before and we're just relogging again
		varframe.curframe:Hide ();
		print (LHT("MsgAccessLoreProfile"));
	end
	varframe.testdone = true;
end

return varframe.curframe;
end
-------------------------------------------------
function Lorehelper_Orc_Events (ageticks, childage)
local varframe = Lorehelper_VarFrame;
local age = varframe.age;

standard_postanswers = {LHT("HumanStandardAvoided"), LHT("HumanStandardLostSomeone"), LHT("HumanStandardParticipated"), LHT("HumanStandardLostEverything")};

warwithdraenei_postanswers = Lorehelper_FormEventPostanswers (LHT("OrcEventWarwithdraeneiStandard"),standard_postanswers, false);	

if varframe.responses["Clan"] == "Frostwolf" then
	warsinazeroth_postanswers = Lorehelper_FormEventPostanswers (LHT("OrcEventWarsinAzerothFrostwolf"),standard_postanswers, true);	
else
	warsinazeroth_postanswers = Lorehelper_FormEventPostanswers (LHT("OrcEventWarsinAzerothStandard"),standard_postanswers, false);	
end

if varframe.responses["Clan"] == "Frostwolf" then
	endofdraenor_postanswers = Lorehelper_FormEventPostanswers (LHT("OrcEventEndofDraenorFrostwolf"),standard_postanswers, true);	
else
	endofdraenor_postanswers = Lorehelper_FormEventPostanswers (LHT("OrcEventEndofDraenorStandard"),standard_postanswers, false);	
end

liberation_postanswers = Lorehelper_FormEventPostanswers (LHT("OrcEventLiberationStandard"),standard_postanswers, false);	

thirdwar_postanswers = Lorehelper_FormEventPostanswers (LHT("OrcEventThirdWarStandard"),standard_postanswers, false);	

warwiththeramore_postanswers = Lorehelper_FormEventPostanswers (LHT("OrcEventWarwithTheramoreStandard"), standard_postanswers, false);	
-------
--ageticks are
--war with Theramore, the end of Third War, the beginning of it, the New Horde formation, destruction of Draenor, destruction of Dark Portal, beginning of First War, beginning of open war with draenei

--varframe.age+childage >= ageticks[#ageticks] indicates whether player was born during the event
--(varframe.age < ageticks[#ageticks]) is the logical waschild variable
if varframe.responses["War with draenei"]==nil then
		varframe.curframe = Lorehelper_EventTestQuestion (LHT("War with draenei"), LHT("OrcEventWarwithdraenei"), (age+childage >= ageticks[#ageticks]), (age < ageticks[#ageticks]), warwithdraenei_postanswers, LHART_WARWITHDRAENEI);
		return varframe.curframe;
end

if varframe.responses["Wars in Azeroth"]==nil then
	--age of 12 by destruction of Dark Portal is enough to possibly participate in Wars in Azeroth
		varframe.curframe = Lorehelper_EventTestQuestion (LHT("Wars in Azeroth"), LHT("OrcEventWarsinAzeroth"), (age+childage >= ageticks[#ageticks-2]), (age < ageticks[#ageticks-2]), warsinazeroth_postanswers, LHART_SECONDWARHORDE);
		return varframe.curframe;
end

if varframe.responses["End of Draenor"]==nil then
		varframe.curframe = Lorehelper_EventTestQuestion (LHT("End of Draenor"), LHT("OrcEventEndofDraenor"), (age+childage >= ageticks[#ageticks-3]), (age < ageticks[#ageticks-3]), endofdraenor_postanswers, LHART_ENDOFDRAENOR);
		return varframe.curframe;
end

if varframe.responses["Liberation"]==nil then
	--asks orc to be 12 by the beginning of liberation, which is inconsistent but meh
		varframe.curframe = Lorehelper_EventTestQuestion (LHT("Liberation"), LHT("OrcEventLiberation"), (age+childage >= ageticks[#ageticks-4]), (age < ageticks[#ageticks-4]), liberation_postanswers, LHART_NEWHORDE);
		return varframe.curframe;
end

if varframe.responses["Third War"]==nil then
		varframe.curframe = Lorehelper_EventTestQuestion (LHT("Third War"), LHT("OrcEventThirdWar"), (age+childage >= ageticks[2]), (age < ageticks[2]), thirdwar_postanswers, LHART_THIRDWARKALIMDOR);
		return varframe.curframe;
end

if varframe.responses["War with Theramore"]==nil then
		varframe.curframe = Lorehelper_EventTestQuestion (LHT("War with Theramore"), LHT("OrcEventWarTheramore"), (age+childage >= ageticks[1]), (age < ageticks[1]), warwiththeramore_postanswers, LHART_WARWITHTHERAMORE);
		return varframe.curframe;
end

return varframe.curframe;
end
-------------------------------------------------
function Lorehelper_Orc_Zones (forzonepedia)
local varframe = Lorehelper_VarFrame;
		
local zones = {
		{"Dustwallow Marsh", 7, ""},
		{"Alterac Mountains", 5, ""},
		{"Wetlands", 2, ""},
		{"Blasted Lands", 20, "", true},
		{"Burning Steppes", 10, ""},
		{"Ashenvale", 1, ""},
		};
	 
for i,z in ipairs(zones) do
	z[3]=LHT("OrcZone"..z[1]);
	if z[4] then
		z[4]=LHT("OrcZoneTooltip"..z[1]);
	end
end

if forzonepedia then
	return zones;
end

Lorehelper_Link_Zone_with_Answer (zones, "Alterac Mountains", "Clan", "Frostwolf", "OrcZone", 24);
Lorehelper_Link_Zone_with_Answer (zones, "Ashenvale", "Clan", "Warsong", "OrcZone", 24);
Lorehelper_Link_Zone_with_Answer (zones, "Wetlands", "Clan", "Dragonmaw", "OrcZone", 24);
Lorehelper_Link_Zone_with_Answer (zones, "Burning Steppes", "Clan", "Blackrock", "OrcZone", 24);
Lorehelper_Link_Zone_with_Answer (zones, "Burning Steppes", "Clan", "Twilight's Hammer", "OrcZone", 24);

Lorehelper_Link_Zone_with_Event (zones, "Ashenvale", "Third War", "OrcZone");
Lorehelper_Link_Zone_with_Event (zones, "Burning Steppes", "Wars in Azeroth", "OrcZone");
Lorehelper_Link_Zone_with_Event (zones, "Wetlands", "Wars in Azeroth", "OrcZone");

if varframe.responses["Wars in Azeroth"]=="Avoided" or varframe.responses["Wars in Azeroth"]=="Wasn't born" or varframe.responses["Wars in Azeroth"]==nil then--to not link twice
	Lorehelper_Link_Zone_with_Event (zones, "Blasted Lands", "End of Draenor", "OrcZone");
else
	Lorehelper_Link_Zone_with_Event (zones, "Blasted Lands", "Wars in Azeroth", "OrcZone");
end

table.sort(zones, Lorehelper_CompareBy2ndElement)

return zones;
end
-------------------------------------------------
-------------------------------------------------
--Start OR continue the lore test
-------------------------------------------------
function Lorehelper_DoTest ()
local varframe = Lorehelper_VarFrame;
local fr = nil;

if varframe.race == "Night Elf" then fr = Lorehelper_NightElf ();
elseif varframe.race == "Dwarf" then fr = Lorehelper_Dwarf ();
elseif varframe.race == "Gnome" then fr = Lorehelper_Gnome ();
elseif varframe.race == "Human" then fr = Lorehelper_Human ();
elseif varframe.race == "Troll" then fr = Lorehelper_Troll ();
elseif varframe.race == "Tauren" then fr = Lorehelper_Tauren ();
elseif varframe.race == "Undead" then fr = Lorehelper_Undead ();
elseif varframe.race == "Orc" then fr = Lorehelper_Orc ();
else print ("Unknown race");
end

return fr;
end
-------------------------------------------------
-------------------------------------------------
-------------------------------------------------
-------------------------------------------------
-------------------------------------------------
-------------------------------------------------
--Functions related to Dungeon Player
-------------------------------------------------
function Lorehelper_DungeonTextPlay ()
local varframe = Lorehelper_VarFrame;
local fr = Lorehelper_DungeonPlayerFrame;

local text = Lorehelper_DungeonText (varframe.curdungeon)
local chunkoftext = Lorehelper_ChunkOfDungeonText (text);--implicitly uses Lorehelper_VarFrame.curdungeontextpos
if UnitInParty("player") then
	SendChatMessage(chunkoftext, "PARTY")
else
	print (chunkoftext);
end

--print(varframe.curdungeontextpos)
end
-------------------------------------------------
function Lorehelper_ChunkOfDungeonText (text)
local varframe = Lorehelper_VarFrame;

if varframe.curdungeontextpos == 0 then
	return (LHT("DungeonDisclaimer"))
end

--else proceed with actual dungeon text
local chunks = {}
local i = 1;

for t in string.gmatch(text, "[^#]+") do
  chunks[i] = t;
  i = i+1;
end

varframe.curdungeonmaxtextpos = #chunks;

if varframe.curdungeontextpos == varframe.curdungeonmaxtextpos + 1 then
	return (LHT("DungeonEnd"))
end

return (chunks[varframe.curdungeontextpos]);
end
-------------------------------------------------
function Lorehelper_UpdateDungeonPlayerText ()

local text = Lorehelper_DungeonText(Lorehelper_VarFrame.curdungeon);
local chunkoftext = Lorehelper_ChunkOfDungeonText (text)--implicitly uses Lorehelper_VarFrame.curdungeontextpos
chunkoftext = Lorehelper_BeginningOfText(chunkoftext).."...";
Lorehelper_DungeonPlayerFrame.text:SetText(chunkoftext);

end
-------------------------------------------------
-------------------------------------------------
-------------------------------------------------
-------------------------------------------------
-------------------------------------------------
--[[function Lorehelper_NewQuestion(lastquestiontitle, lastanswer)
	if lastanswer == "no" then
		Lorehelper_TestQuestion ("Home", 
			"Wazup", 
			{"haha", "yes"}, 
			{"haha indeed", "yes indeed"});
			Lorehelper_MainFrame.lastanswer = nil;
	else print ("the end");
	end
end--]]
-------------------------------------------------
-------------------------------------------------
-------------------------------------------------
--Various addon UI functions, save/load variables, etc 
-------------------------------------------------
-------------------------------------------------
-------------------------------------------------
SlashCmdList['LOREHELPER_SLASHCMD'] = function(msg)
    --DEFAULT_CHAT_FRAME:AddMessage(msg or 'nil')
	Lorehelper_MinimapButton_OnClick();
end
SLASH_LOREHELPER_SLASHCMD1 = '/lorehelper'
SLASH_LOREHELPER_SLASHCMD2 = '/lore'
SLASH_LOREHELPER_SLASHCMD3 = '/lorehelp'
SLASH_LOREHELPER_SLASHCMD4 = '/loreh'
-----------------------------
-----------------------------
-----------------------------
-- Credits to Gello A Firelord (2006) for this code

-- Call this in a mod's initialization to move the minimap button to its saved position (also used in its movement)
-- ** do not call from the mod's OnLoad, VARIABLES_LOADED or later is fine. **
function Lorehelper_MinimapButton_Reposition()
	local mmpos = Lorehelper_VarFrame.minimappos;

	if mmpos > 120 and mmpos < 170 then--just want it to jump over the default UI's time-of-the-day-circle
		if mmpos-120<170-mmpos then
			mmpos = 120;
		else
			mmpos = 170;
		end
	end
	
	Lorehelper_MinimapButton:SetPoint("TOPLEFT","Minimap","TOPLEFT",52-(80*cos(mmpos)),(80*sin(mmpos))-52)
end

-- Only while the button is dragged this is called every frame
function Lorehelper_MinimapButton_DraggingFrame_OnUpdate()

	local xpos,ypos = GetCursorPosition()
	local xmin,ymin = Minimap:GetLeft(), Minimap:GetBottom()

	xpos = xmin-xpos/UIParent:GetScale()+70 -- get coordinates as differences from the center of the minimap
	ypos = ypos/UIParent:GetScale()-ymin-70

	Lorehelper_VarFrame.minimappos = math.deg(math.atan2(ypos,xpos)) -- save the degrees we are relative to the minimap center
	Lorehelper_MinimapButton_Reposition() -- move the button
end

-- Put your code that you want on a minimap button click here.  arg1="LeftButton", "RightButton", etc
function Lorehelper_MinimapButton_OnClick()

	local mousebutton = GetMouseButtonClicked();
	
	if mousebutton == "LeftButton" then
		if Lorehelper_VarFrame.curframe == nil then
			Lorehelper_SimpleMessage ("No Lorehelper frame to display.");
		elseif Lorehelper_VarFrame.curframe:IsShown() then
			Lorehelper_VarFrame.curframe:Hide();
			Lorehelper_SimpleFrame:Hide();
			Lorehelper_AllZonesFrame:Hide();
		else Lorehelper_VarFrame.curframe:Show();
		end
	end
	
	if mousebutton == "RightButton" then
		if Lorehelper_DungeonPlayerFrame:IsShown() then
			Lorehelper_DungeonPlayerFrame:Hide();
		else Lorehelper_DungeonPlayerFrame:Show();
		end	
	end
end
-----------------------------
-----------------------------
function Lorehelper_Init()--creates Lorehelper_VarFrame and fills it with defaults
	Lorehelper_VarFrame = CreateFrame ("Frame")
			
	Lorehelper_VarFrame.minimappos = 45; --default position in degrees
			
	Lorehelper_VarFrame.mainframepoint = "CENTER";
	--Lorehelper_VarFrame.relativeTo=UIParent;
	Lorehelper_VarFrame.relativePoint="CENTER";
	Lorehelper_VarFrame.xOfs=0;
	Lorehelper_VarFrame.yOfs=0;
			
	Lorehelper_VarFrame.race = UnitRace("player");
	Lorehelper_VarFrame.class = UnitClass("player");
	Lorehelper_VarFrame.name = UnitName("player");
			
	Lorehelper_VarFrame.age = nil;
	Lorehelper_VarFrame.responses = {};
	Lorehelper_VarFrame.curtestquestionnumber = 1;
	Lorehelper_VarFrame.testdone = false;
	
	Lorehelper_VarFrame.unlockedzones = {};
	
	Lorehelper_VarFrame.curdungeon = "Gnomeregan";
	Lorehelper_VarFrame.curdungeontextpos = 0;
	Lorehelper_VarFrame.curdungeonmaxtextpos = 1;
	
	print("Welcome to Lorehelper, "..Lorehelper_VarFrame.name.."!");
	
	Lorehelper_MinimapButton_Reposition();--the minimap icon is slightly behind otherwise
	
	Lorehelper_PopulateAllZonesFrame ();
	Lorehelper_PopulateDungeonPlayerFrame ();
end
-----------------------------


	
