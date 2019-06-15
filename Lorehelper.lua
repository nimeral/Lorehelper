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

local Lorehelper_EventFrame = CreateFrame("FRAME"); -- Need a frame to respond to events
Lorehelper_EventFrame:RegisterEvent("ADDON_LOADED"); -- Fired when saved variables are loaded
Lorehelper_EventFrame:RegisterEvent("PLAYER_LOGOUT"); -- Fired when about to log out

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
			Lorehelper_VarFrame.curframe = Lorehelper_DoTest();
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
  button1 = "OK",
  timeout = 0,
  whileDead = true,
  hideOnEscape = true,
  preferredIndex = 3,  -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
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
	else buttonframe:SetPoint("TOPLEFT",-75+80*(buttonnumber-4),-80-textheight)--and 4 is 390/80, where 390 is the standard framewidth. I'll make it more flexible one day
	end
end
------------------------------------------
function Lorehelper_EventTestQuestion (title, text, waschild, postanswertexts, picture)--special sort of test question - about an event, whether the character has participated in it, has lost someone, or not
local varframe = Lorehelper_VarFrame; --global variable frame
--local fr = nil;--the frame to be created and shown  

if waschild==true then
	varframe.curframe = Lorehelper_TestQuestion (title, text, {LHT("Avoided"), LHT("Lost|nsomeone")}, postanswertexts, picture);--no postpictures
else varframe.curframe = Lorehelper_TestQuestion (title, text, {LHT("Avoided"), LHT("Lost|nsomeone"), LHT("Participated"), LHT("Lost|neverything")}, postanswertexts, picture);
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
		fr.buttonframes[i]:SetFormattedText(answers[i]);--with SetText, I can't |n on buttons
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
			--hide the old text and editbox and button
			fr.text:Hide();
			fr.agebox:Hide();
			fr.okbutton:Hide();

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
					print (varframe.age);
					--hide everything related to this question
					fr:Hide();	
					Lorehelper_DoTest ();
				end
				);
			end	
		end
		);
return fr;
end
-------------------------------------------------
------------------------------------------
--Function that presents the players answers
------------------------------------------
-------------------------------------------------
function Lorehelper_PresentAnswers(picture, sortorder)--no other input because LorehelperVarFrame.responses is global
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
			text = text..question..": "..string.gsub(varframe.responses[question], "|n", " ").."|n";
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
return fr;
end
-------------------------------------------------
function Lorehelper_NightElf ()

local varframe = Lorehelper_VarFrame;
local childage = 20;
local oldage = 15000;
local ageticks = Lorehelper_FormAgeTicks(childage, {22, 21, 20, -975, -1200, -7050, -9300, -10000, -12000})--will still be partially hardcoded
--conflict with Illidan and naga, the end of Third War, the beginning of it, War of the Shifting Sands, genocide of Shen'Dralar, middle of Exile of the High Elves, War of the Satyr, War of the Ancients, founding of Eldre'Thalas
for i=1,#ageticks do
	print(ageticks[i])
end
-------------------------------------------------
--Ask about age
-------------------------------------------------
if varframe.age == nil then
	varframe.curframe = Lorehelper_AskAge(childage, oldage, ageticks, 
	{LHT("NightElfAgeYoung"), LHT("NightElfAgeThirdWar"), LHT("NightElfAgeThirdWar"), LHT("NightElfAgeThirdWar"), LHT("NightElfAgeShiftingSands"), LHT("NightElfAgeShiftingSands"), LHT("NightElfAgeExileHighElves"), LHT("NightElfAgeWarSatyr"), LHT("NightElfAgeWarAncients"), LHT("NightElfAgeWarAncients")}
	LHART_NIGHTELF); --also updates varframe.age
-------------------------------------------------
--Ask whether a night elf was once Highborne
-------------------------------------------------
elseif varframe.responses["Society"]==nil then
	if varframe.age >= -6800 then--end of High Elves exile
	varframe.curframe = Lorehelper_TestQuestion (LHT("Society"), 
	LHT("NightElfSociety"), 
	{LHT("Kaldorei"), LHT("Highborne"), LHT("Shen'Dralar")}, 
	{LHT("NightElfKaldorei"), LHT("NightElfHighborne"), LHT("NightElfShenDralar")},
	LHART_NIGHTELF,
	{LHART_NIGHTELFKALDOREI, LHART_NIGHTELFHIGHBORNE, LHART_NIGHTELFSHENDRALAR});
	elseif varframe.age >= -1200 then--genocide of Shen'Dralar
	varframe.curframe = Lorehelper_TestQuestion (LHT("Society"), 
	LHT("NightElfSociety"), 
	{LHT("Kaldorei"), LHT("Shen'Dralar")}, 
	{LHT("NightElfKaldorei"), LHT("NightElfShenDralar")},
	LHART_NIGHTELF,
	{LHART_NIGHTELFKALDOREI, LHART_NIGHTELFSHENDRALAR});	
	else varframe.responses["Society"]="Kaldorei";--a bit of a hack 
	end
-------------------------------------------------
elseif varframe.responses["The Betrayer Ascendant"]==nil then--title of the last of the frames to be generated line below
	varframe.curframe = Lorehelper_NightElf_Events (ageticks, childage);--function generating a few frames, depending on age
-------------------------------------------------
-------------------------------------------------
else 
	varframe.curframe = Lorehelper_PresentAnswers(LHART_NIGHTELF, {"Society", "War of the Ancients", "War of the Satyr", "Shen'Dralar genocide", "War of the Shifting Sands", "Third War", "The Betrayer Ascendant"});--the order of questions is passed 
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

standard_postanswers = {LHT("HumanStandardAvoided"), LHT("HumanStandardLostSomeone"), LHT("HumanStandardParticipated"), LHT("HumanStandardLostEverything")};

if varframe.responses["Society"]=="Kaldorei" then
	warancients_postanswers = Lorehelper_FormEventPostanswers (LHT("NightElfEventWarAncientsKaldorei"),standard_postanswers, false);
elseif varframe.responses["Society"]=="Highborne" then
	warancients_postanswers = Lorehelper_FormEventPostanswers (LHT("NightElfEventWarAncientsHighborne"),standard_postanswers, false);
elseif varframe.responses["Society"]=="Shen'Dralar" then
	warancients_postanswers = Lorehelper_FormEventPostanswers (LHT("NightElfEventWarAncientsShenDralar"),standard_postanswers, false);
end

warsatyr_postanswers = Lorehelper_FormEventPostanswers (LHT("NightElfEventWarSatyrStandard"),standard_postanswers, false);

warshiftingsands_postanswers = Lorehelper_FormEventPostanswers (LHT("NightElfEventWarShiftingSandsStandard"),standard_postanswers, false);

thirdwar_postanswers = Lorehelper_FormEventPostanswers (LHT("NightElfEventThirdWarStandard"),standard_postanswers, false);		

betrayer_postanswers = Lorehelper_FormEventPostanswers (LHT("NightElfEventBetrayerStandard"),standard_postanswers, false);	
-------
--ageticks are
--conflict with Illidan and naga, the end of Third War, the beginning of it, War of the Shifting Sands, genocide of Shen'Dralar, middle of Exile of the High Elves, War of the Satyr, War of the Ancients, founding of Eldre'Thalas

--varframe.age+childage >= ageticks[#ageticks] indicates whether player was born during the event
--(varframe.age < ageticks[#ageticks]) is the logical waschild variable
if varframe.responses["War of the Ancients"]==nil then
	if age+childage >= ageticks[7] then
		varframe.curframe = Lorehelper_EventTestQuestion (LHT("War of the Ancients"), LHT("NightElfEventWarAncients"), (age < ageticks[7]), warancients_postanswers, LHART_WARANCIENTS);
		return varframe.curframe;
	end
end

if varframe.responses["War of the Satyr"]==nil then
	if age+childage >= ageticks[6] then
		varframe.curframe = Lorehelper_EventTestQuestion (LHT("War of the Satyr"), LHT("NightElfEventWarSatyr"), (age < ageticks[6]), warsatyr_postanswers, LHART_WARSATYR);
		return varframe.curframe;
	end
end

if varframe.responses["Shen'Dralar genocide"]==nil then
	if varframe.responses["Society"]=="Shen'Dralar" then
		shendralargenocide_postanswers = Lorehelper_FormEventPostanswers (LHT("NightElfEventShenDralarGenocideShenDralar"),standard_postanswers, false);
		if age+childage >= ageticks[5] then
			varframe.curframe = Lorehelper_EventTestQuestion (LHT("Shen'Dralar genocide"), LHT("TaurenEventThirdWar"), (age < ageticks[5]), shendralargenocide_postanswers, LHART_SHENDRALARGENOCIDE);
			return varframe.curframe;
		end
end

if varframe.responses["War of the Shifting Sands"]==nil then
	if age+childage >= ageticks[4] then
		varframe.curframe = Lorehelper_EventTestQuestion (LHT("War of the Shifting Sands"), LHT("NightElfEventShiftingSands"), (age < ageticks[4]), thirdwar_postanswers, LHART_SHIFTINGSANDS);
		return varframe.curframe;
	end
end

if varframe.responses["Third War"]==nil then
	if age+childage >= ageticks[2] then
		varframe.curframe = Lorehelper_EventTestQuestion (LHT("Third War"), LHT("NightElfEventThirdWar"), (age < ageticks[2]), thirdwar_postanswers, LHART_THIRDWARKALIMDOR);
		return varframe.curframe;
	end
end

if varframe.responses["The Betrayer Ascendant"]==nil then
	if age+childage >= ageticks[1] then
		varframe.curframe = Lorehelper_EventTestQuestion (LHT("The Betrayer Ascendant"), LHT("NightElfEventBetrayer"), (age < ageticks[1]), betrayer_postanswers, LHART_BETRAYER);
		return varframe.curframe;
	end
end

return varframe.curframe;
end
-------------------------------------------------
-------------------------------------------------
-------------------------------------------------
function Lorehelper_Dwarf ()

local varframe = Lorehelper_VarFrame;
--local fr = nil; --current frame, will be returned and varframe.curframe will be equal to it
local childage = 20;
local oldage = 400;
local ageticks = Lorehelper_FormAgeTicks(childage, {21, 20, 10, 4, 0, -230})--will still be partially hardcoded
--the end of Third War, the beginning of it, end of Second, beginning, beginning of First, beginning of War of Three Hammers
for i=1,#ageticks do
	print(ageticks[i])
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
	print (varframe.curframe.title:GetText())
-------------------------------------------------
-------------------------------------------------
else 
	varframe.curframe = Lorehelper_PresentAnswers(LHART_DWARF, {"Clan", "War of the Three Hammers", "First War", "Second War", "Third War"});--the order of questions is passed 
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

firstwar_postanswers = Lorehelper_FormEventPostanswers (LHT("DwarfEventFirstWarStandard"),standard_postanswers, true);	

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
	if age+childage >= ageticks[#ageticks] then
		varframe.curframe = Lorehelper_EventTestQuestion (LHT("War of the Three Hammers"), LHT("DwarfEventWarofThreeHammers"), (age < ageticks[#ageticks]), warofthreehammers_postanswers, LHART_WAROFTHREEHAMMERS);
		return varframe.curframe;
	end
end

if varframe.responses["First War"]==nil then
	if age+childage >= ageticks[#ageticks-2] then--age of 41 (20 by the beginning of Second war) is enough to possibly participate in First
		varframe.curframe = Lorehelper_EventTestQuestion (LHT("First War"), LHT("DwarfEventFirstWar"), (age < ageticks[#ageticks-2]), firstwar_postanswers, LHART_FIRSTWAR);
		return varframe.curframe;
	end
end

if varframe.responses["Second War"]==nil then
	if age+childage >= ageticks[#ageticks-3] then--age of 35 (20 by the end of Second war) is enough to possibly participate in Second
		varframe.curframe = Lorehelper_EventTestQuestion (LHT("Second War"), LHT("DwarfEventSecondWar"), (age < ageticks[#ageticks-3]), secondwar_postanswers, LHART_SECONDWAR);
		return varframe.curframe;
	end
end

if varframe.responses["Third War"]==nil then--age of 25 is enough to possibly participate in Third
	if age+childage >= ageticks[2] then
		varframe.curframe = Lorehelper_EventTestQuestion (LHT("Third War"), LHT("DwarfEventThirdWar"), (age < ageticks[2]), thirdwar_postanswers, LHART_THIRDWARKALIMDOR);
		return varframe.curframe;
	end
end

return varframe.curframe;
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
	print(ageticks[i])
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
	varframe.curframe = Lorehelper_PresentAnswers(LHART_GNOME, {"Engineer", "King Mechagon disappearance", "War of the Three Hammers", "First War", "Second War", "Fighting for Gnomeregan", "Third War"});--the order of questions is passed 
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

standard_postanswers = {LHT("HumanStandardAvoided"), LHT("HumanStandardLostSomeone"), LHT("HumanStandardParticipated"), LHT("HumanStandardLostEverything")};

kingmechadon_postanswers = Lorehelper_FormEventPostanswers (LHT("GnomeEventKingMechadonStandard"), standard_postanswers, true);	

warofthreehammers_postanswers = Lorehelper_FormEventPostanswers (LHT("GnomeEventWarofThreeHammersStandard"),standard_postanswers, true);	

firstwar_postanswers = Lorehelper_FormEventPostanswers (LHT("GnomeEventFirstWarStandard"),standard_postanswers, true);	

secondwar_postanswers = Lorehelper_FormEventPostanswers (LHT("GnomeEventSecondWarStandard"),standard_postanswers, false);	

gnomeregan_postanswers = Lorehelper_FormEventPostanswers (LHT("GnomeEventGnomereganStandard"),standard_postanswers, false);	

thirdwar_postanswers = Lorehelper_FormEventPostanswers (LHT("GnomeEventThirdWarStandard"),standard_postanswers, true);	
-------
--ageticks are
--the end of Third War, the beginning of it, end of Second, beginning, beginning of First, beginning of War of the Three Hammers, King Mechadon disappearance

--varframe.age+childage >= ageticks[#ageticks] indicates whether player was born during the event
--(varframe.age < ageticks[#ageticks]) is the logical waschild variable

--FEATURE: maybe I need a more-customizable event test question function for non-violent events
if varframe.responses["King Mechagon disappearance"]==nil then
	if age+childage >= ageticks[#ageticks] then
		varframe.curframe = Lorehelper_EventTestQuestion (LHT("King Mechagon disappearance"), LHT("GnomeEventKingMechagon"), (age < ageticks[#ageticks]), kingmechagon_postanswers, LHART_KINGMECHAGON);
		return varframe.curframe;
	end
end

--FEATURE: maybe I need to automate the creation of text keys by concatenating strings (would work like "GnomeEvent".."War of the Three Hammers"). Or maybe it's an overkill.
if varframe.responses["War of the Three Hammers"]==nil then
	if age+childage >= ageticks[#ageticks-1] then
		varframe.curframe = Lorehelper_EventTestQuestion (LHT("War of the Three Hammers"), LHT("GnomeEventWarofThreeHammers"), (age < ageticks[#ageticks-1]), warofthreehammers_postanswers, LHART_WAROFTHREEHAMMERS);
		return varframe.curframe;
	end
end

if varframe.responses["First War"]==nil then
	if age+childage >= ageticks[#ageticks-3] then
		varframe.curframe = Lorehelper_EventTestQuestion (LHT("First War"), LHT("GnomeEventFirstWar"), (age < ageticks[#ageticks-3]), firstwar_postanswers, LHART_FIRSTWAR);
		return varframe.curframe;
	end
end

if varframe.responses["Second War"]==nil then
	if age+childage >= ageticks[#ageticks-4] then
		varframe.curframe = Lorehelper_EventTestQuestion (LHT("Second War"), LHT("GnomeEventSecondWar"), (age < ageticks[#ageticks-4]), secondwar_postanswers, LHART_SECONDWAR);
		return varframe.curframe;
	end
end

if varframe.responses["Fighting for Gnomeregan"]==nil then
	if age+childage >= ageticks[2] then
		varframe.curframe = Lorehelper_EventTestQuestion (LHT("Fighting for Gnomeregan"), LHT("GnomeEventGnomeregan"), (age < ageticks[2]), gnomeregan_postanswers, LHART_GNOMEREGAN);
		return varframe.curframe;
	end
end

if varframe.responses["Third War"]==nil then
	if age+childage >= ageticks[2] then
		varframe.curframe = Lorehelper_EventTestQuestion (LHT("Third War"), LHT("GnomeEventThirdWar"), (age < ageticks[2]), thirdwar_postanswers, LHART_THIRDWARKALIMDOR);
		return varframe.curframe;
	end
end

return varframe.curframe;
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
	print(ageticks[i])
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
	{LHART_HUMANALTERAC, LHART_HUMANDALARAN, LHART_HUMANGILNEAS, LHART_HUMANKULTIRAS, LHART_HUMANLORDAERON, nil, LHART_HUMANSTROMGARDE});
-------------------------------------------------
-------------------------------------------------
elseif varframe.responses["Third War: Kalimdor"]==nil then--title of the last of the frames to be generated line below
	varframe.curframe = Lorehelper_Human_Events (ageticks, childage);--function generating a few frames, depending on age
	print (varframe.curframe.title:GetText())
-------------------------------------------------
-------------------------------------------------
else 
	varframe.curframe = Lorehelper_PresentAnswers(LHART_HUMAN, {"Home Kingdom", "Gurubashi War", "First War", "Second War", "Third War: Plague", "Third War: Kalimdor"});--the order of questions is passed 
	if varframe.testdone == true then --if the test was done before and we're just relogging again
		varframe.curframe:Hide ();
		print (LHT("MsgAccessLoreProfile"));
	end
	varframe.testdone = true;
	--Lorehelper_SimpleMessage ("Click the Lorehelper button near your minimap, or type /lore to see your answers.");
end

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
	if age+childage >= ageticks[#ageticks] then
		varframe.curframe = Lorehelper_EventTestQuestion (LHT("Gurubashi War"), LHT("HumanEventGurubashiWar"), (age < ageticks[#ageticks]), gurubashi_postanswers, LHART_GURUBASHIWAR);
		return varframe.curframe;
	end
end

if varframe.responses["First War"]==nil then
	if age+childage >= ageticks[#ageticks-2] then--age of 39 (18 by the beginning of Second war) is enough to possibly participate in First
		varframe.curframe = Lorehelper_EventTestQuestion (LHT("First War"), LHT("HumanEventFirstWar"), (age < ageticks[#ageticks-2]), firstwar_postanswers, LHART_FIRSTWAR);
		return varframe.curframe;
	end
end

if varframe.responses["Second War"]==nil then
	if age+childage >= ageticks[#ageticks-3] then--age of 33 (18 by the end of Second war) is enough to possibly participate in Second
		varframe.curframe = Lorehelper_EventTestQuestion (LHT("Second War"), LHT("HumanEventSecondWar"), (age < ageticks[#ageticks-3]), secondwar_postanswers, LHART_SECONDWAR);
		return varframe.curframe;
	end
end

if varframe.responses["Third War: Plague"]==nil then--age of 23 is enough to possibly participate in Third
	if age+childage >= ageticks[2] then--same array index intended, as both Third Wars are roughly same time!
		varframe.curframe = Lorehelper_EventTestQuestion (LHT("Third War: Plague"), LHT("HumanEventThirdWarPlague"), (age < ageticks[2]), thirdwarplague_postanswers, LHART_THIRDWARPLAGUE);
		return varframe.curframe;
	end
end

if varframe.responses["Third War: Kalimdor"]==nil then
	if age+childage >= ageticks[2] then
		varframe.curframe = Lorehelper_EventTestQuestion (LHT("Third War: Kalimdor"), LHT("HumanEventThirdWarKalimdor"), (age < ageticks[2]), thirdwarkalimdor_postanswers, LHART_THIRDWARKALIMDOR);
		return varframe.curframe;
	end	
end

return varframe.curframe;
end
-------------------------------------------------
-------------------------------------------------
-------------------------------------------------
function Lorehelper_Troll ()

local varframe = Lorehelper_VarFrame;
local childage = 14;
local oldage = 100;
local ageticks = Lorehelper_FormAgeTicks(childage, {22, 21, 20, 10, 4, 0, -18})--will still be partially hardcoded
--war with Theramore, the end of Third War, the beginning of it, end of Second, beginning, beginning of First (only for jungle trolls really), beginning of Gurubasi War (same)
for i=1,#ageticks do
	print(ageticks[i])
end
-------------------------------------------------
--Ask about age
-------------------------------------------------
if varframe.age == nil then
	varframe.curframe = Lorehelper_AskAge(childage, oldage, ageticks, 
	{LHT("TrollAgeYoung"), LHT("TrollAgeThirdWar"), LHT("TrollAgeThirdWar"), LHT("TrollAgeThirdWar"), LHT("TrollAgeBetweenWar"), LHT("TrollAgeSecondWar"), LHT("TrollAgeOld"), LHT("TrollAgeOld")},
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
	varframe.curframe = Lorehelper_PresentAnswers(LHART_TROLL, {"Tribe", "Gurubashi War", "First War", "Second War", "Third War", "War with Theramore"});--the order of questions is passed 
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

standard_postanswers = {LHT("HumanStandardAvoided"), LHT("HumanStandardLostSomeone"), LHT("HumanStandardParticipated"), LHT("HumanStandardLostEverything")};

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
	if age+childage >= ageticks[#ageticks] then
		varframe.curframe = Lorehelper_EventTestQuestion (LHT("Gurubashi War"), LHT("TrollEventGurubashiWar"), (age < ageticks[#ageticks]), gurubashiwar_postanswers, LHART_GURUBASHIWAR);
		return varframe.curframe;
	end
end

if varframe.responses["First War"]==nil then
	if age+childage >= ageticks[#ageticks-2] then--age of 36 (14 by the beginning of Second war) is enough to possibly participate in First
		varframe.curframe = Lorehelper_EventTestQuestion (LHT("First War"), LHT("TrollEventFirstWar"), (age < ageticks[#ageticks-2]), firstwar_postanswers, LHART_FIRSTWAR);
		return varframe.curframe;
	end
end

if varframe.responses["Second War"]==nil then
	if age+childage >= ageticks[#ageticks-3] then--age of 29 (14 by the end of Second war) is enough to possibly participate in Second
		varframe.curframe = Lorehelper_EventTestQuestion (LHT("Second War"), LHT("TrollEventSecondWar"), (age < ageticks[#ageticks-3]), secondwar_postanswers, LHART_SECONDWARHORDE);
		return varframe.curframe;
	end
end

if varframe.responses["Third War"]==nil then--age of 18 is enough to possibly participate in Third
	if age+childage >= ageticks[2] then
		varframe.curframe = Lorehelper_EventTestQuestion (LHT("Third War"), LHT("TrollEventThirdWar"), (age < ageticks[2]), thirdwar_postanswers, LHART_THIRDWARKALIMDOR);
		return varframe.curframe;
	end
end

if varframe.responses["War with Theramore"]==nil then--age of 17 is enough to possibly participate in Third
	if age+childage >= ageticks[1] then
		varframe.curframe = Lorehelper_EventTestQuestion (LHT("War with Theramore"), LHT("TrollEventWarTheramore"), (age < ageticks[1]), wartheramore_postanswers, LHART_WARWITHTHERAMORE);
		return varframe.curframe;
	end
end


return varframe.curframe;
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
	print(ageticks[i])
end
-------------------------------------------------
--Ask about age
-------------------------------------------------
if varframe.age == nil then
	varframe.curframe = Lorehelper_AskAge(childage, oldage, ageticks, 
	{LHT("TaurenAgeYoung"), LHT("TaurenAgeThirdWar"), LHT("TaurenAgeThirdWar"), LHT("TaurenAgeThirdWar"), LHT("TaurenAgeMiddleAge")},
	LHART_TAUREN); --also updates varframe.age
-------------------------------------------------
--Ask whether a tauren belongs to Grimtotem clan
-------------------------------------------------
elseif varframe.responses["Grimtotem"]==nil then
	if varframe.class == "Druid" then
		nongrimtotem_text = LHT("TaurenGrimtotemDruid");
		grimtotem_text = LHT("TaurenNonGrimtotemDruid");
	elseif varframe.class == "Shaman" then		
		nongrimtotem_text = LHT("TaurenGrimtotemShaman");
		grimtotem_text = LHT("TaurenNonGrimtotemShaman");
	elseif varframe.class == "Hunter" then		
		nongrimtotem_text = LHT("TaurenGrimtotemHunter");
		grimtotem_text = LHT("TaurenNonGrimtotemHunter");
	elseif varframe.class == "Warrior" then		
		nongrimtotem_text = LHT("TaurenGrimtotemWarrior");
		grimtotem_text = LHT("TaurenNonGrimtotemWarrior");
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
	varframe.curframe = Lorehelper_PresentAnswers(LHART_GNOME, {"Grimtotem", "Third War", "War with Theramore"});--the order of questions is passed 
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
	if age+childage >= ageticks[2] then
		varframe.curframe = Lorehelper_EventTestQuestion (LHT("Third War"), LHT("TaurenEventThirdWar"), (age < ageticks[2]), thirdwar_postanswers, LHART_THIRDWARKALIMDOR);
		return varframe.curframe;
	end
end

if varframe.responses["War with Theramore"]==nil then
	if age+childage >= ageticks[1] then
		varframe.curframe = Lorehelper_EventTestQuestion (LHT("War with Theramore"), LHT("TaurenEventWarTheramore"), (age < ageticks[1]), wartheramore_postanswers, LHART_WARWITHTHERAMORE);
		return varframe.curframe;
	end
end

return varframe.curframe;
end
-------------------------------------------------
-------------------------------------------------
-------------------------------------------------
function Lorehelper_Undead ()
--local age = Lorehelpre_AskAge();

Lorehelper_TestQuestion ("Home city", 
"Where're you from? Human lol, orc lol, whoever the fuck you are hahah peo peo poe poepro poekiinguhiasudhye", 
{"haha", "yes", "no"}, 
{"haha indeed", "yes indeed", "no way"});

return fr;
end
-------------------------------------------------
-------------------------------------------------
-------------------------------------------------
function Lorehelper_Orc ()
--local age = Lorehelpre_AskAge();

Lorehelper_TestQuestion ("Home city", 
"Where're you from? Human lol, orc lol, whoever the fuck you are hahah peo peo poe poepro poekiinguhiasudhye", 
{"haha", "yes", "no"}, 
{"haha indeed", "yes indeed", "no way"});

return fr;
end
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
	Lorehelper_MinimapButton:SetPoint("TOPLEFT","Minimap","TOPLEFT",52-(80*cos(Lorehelper_VarFrame.minimappos)),(80*sin(Lorehelper_VarFrame.minimappos))-52)
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
    if Lorehelper_VarFrame.curframe == nil then
		Lorehelper_SimpleMessage ("No Lorehelper frame to display.");
	elseif Lorehelper_VarFrame.curframe:IsShown() then
		Lorehelper_VarFrame.curframe:Hide();
	else Lorehelper_VarFrame.curframe:Show();
	end
end
-----------------------------
-----------------------------
function Lorehelper_Init()--creates Lorehelper_VarFrame and fills it with defaults
	Lorehelper_VarFrame = CreateFrame ("Frame")
			
	Lorehelper_VarFrame.minimappos = 45; --default position in degrees
			
	--[[Lorehelper_VarFrame.mainframepoint = "CENTER";
	Lorehelper_VarFrame.relativeTo=UIParent;
	Lorehelper_VarFrame.relativePoint="CENTER";
	Lorehelper_VarFrame.xOfs=0;
	Lorehelper_VarFrame.yOfs=0;--]]--the position saving feature bugs too often, idk
			
	Lorehelper_VarFrame.race = UnitRace("player");
	Lorehelper_VarFrame.class = UnitClass("player");
	Lorehelper_VarFrame.name = UnitName("player");
			
	Lorehelper_VarFrame.age = nil;
	Lorehelper_VarFrame.responses = {};
	Lorehelper_VarFrame.curtestquestionnumber = 1;
	Lorehelper_VarFrame.testdone = false;
	
	print("Welcome to Lorehelper, "..Lorehelper_VarFrame.name.."!");
	
	Lorehelper_MinimapButton_Reposition();--the minimap icon is slightly behind otherwise
end
-----------------------------


	
