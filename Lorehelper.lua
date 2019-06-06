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
function Lorehelper_FormEventPostanswers (prefix, standard_postanswers)--adds a prefix to an array of strings
processed_postanswers = {};

for i=1,#standard_postanswers do
	processed_postanswers[i] = prefix.." "..standard_postanswers[i];
end

return processed_postanswers;
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
function Lorehelper_PresentAnswers(picture)--no other input because LorehelperVarFrame.responses is global
	--BUG: "questions" are alphabetically ordered, need to keep their order as separate variable
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
	
	--sort the responses by "time"
	--[[oh fuck it, I'll sort it later
	local numberlist = {}
	local answerlist = {}
	-- populate the table that holds the keys
	for question,answer in pairs(varframe.responses) do 
		table.insert(numberlist, answer[1])
		table.insert(answerlist, answer[2]) 
	end

	for a, b in pairs(numberlist) do
		print(a)
		print(b)
	end
	for a, b in pairs(answerlist) do
		print(a)
		print(b)
	end

	--sort the keys??
	table.sort(numberlist)
	for a, b in pairs(numberlist) do
		print(a)
		print(b)
	end
	-- use the keys to retrieve the values in the sorted order??
	for _, k in ipairs(numberlist) do print(k, numberlist[k], answerlist[k]) end--]]

-----------------------------------------------------
--Will need to have another argument in this function - order of the answers - and sort them in this order
-----------------------------------------------------
	for question,answer in pairs(varframe.responses) do
		--for key,value in pairs(answer) do
		--	print("found member " .. key.."--"..value);
		--end
		--answer contains a pair {number_of_test_question, text_of_answer}. The string below adds text_of_answer without |n's to the frame
		text = text..question..": "..string.gsub(answer, "|n", " ").."|n";
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
--local age = Lorehelpre_AskAge();

Lorehelper_TestQuestion ("Home city", 
"Where're you from? Human lol, orc lol, whoever the fuck you are hahah peo peo poe poepro poekiinguhiasudhye", 
{"haha", "yes", "no"}, 
{"haha indeed", "yes indeed", "no way"});


end
-------------------------------------------------
-------------------------------------------------
-------------------------------------------------
function Lorehelper_Dwarf ()
--local age = Lorehelpre_AskAge();

Lorehelper_TestQuestion ("Home city", 
"Where're you from? Human lol, orc lol, whoever the fuck you are hahah peo peo poe poepro poekiinguhiasudhye", 
{"haha", "yes", "no"}, 
{"haha indeed", "yes indeed", "no way"});


end
-------------------------------------------------
-------------------------------------------------
-------------------------------------------------
function Lorehelper_Gnome ()
--local age = Lorehelpre_AskAge();

Lorehelper_TestQuestion ("Home city", 
"Where're you from? Human lol, orc lol, whoever the fuck you are hahah peo peo poe poepro poekiinguhiasudhye", 
{"haha", "yes", "no"}, 
{"haha indeed", "yes indeed", "no way"});


end
-------------------------------------------------
-------------------------------------------------
-------------------------------------------------
function Lorehelper_Human ()

local varframe = Lorehelper_VarFrame;
--local fr = nil; --current frame, will be returned and varframe.curframe will be equal to it
local childage = 18;
local oldage = 80;
local ageticks = {23, 33, 39, 43, 61};--will still be partially hardcoded
-------------------------------------------------
--Ask about age
-------------------------------------------------
if varframe.age == nil then
	varframe.curframe = Lorehelper_AskAge(childage, oldage, ageticks, 
	{LHT("HumanAge18-23"), LHT("HumanAge23-33"), LHT("HumanAge33-39"), LHT("HumanAge39-43"), LHT("HumanAge43-61"), LHT("HumanAge61-80")},
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
	varframe.curframe = Lorehelper_PresentAnswers(LHART_SOMEJUNGLES);
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
	gurubashi_postanswers = Lorehelper_FormEventPostanswers (LHT("HumanEventGurubashiWarStormwind"),standard_postanswers);	
	firstwar_postanswers = Lorehelper_FormEventPostanswers (LHT("HumanEventFirstWarStormwind"),standard_postanswers);	
else 
	gurubashi_postanswers = Lorehelper_FormEventPostanswers (LHT("HumanEventGurubashiWarStandard"), standard_postanswers);
	firstwar_postanswers = Lorehelper_FormEventPostanswers (LHT("HumanEventFirstWarStandard"),standard_postanswers);	
end

secondwar_postanswers = Lorehelper_FormEventPostanswers (LHT("HumanEventSecondWarStandard"),standard_postanswers);	

if varframe.responses["Home Kingdom"] == "Lordaeron" then
	thirdwarplague_postanswers = Lorehelper_FormEventPostanswers (LHT("HumanEventThirdWarPlagueLordaeron"),standard_postanswers);	
else 
	thirdwarplague_postanswers = Lorehelper_FormEventPostanswers (LHT("HumanEventThirdWarPlagueStandard"),standard_postanswers);	
end

if varframe.responses["Home Kingdom"] == "Kul Tiras" or varframe.responses["Home Kingdom"] == "Lordaeron" then
	thirdwarkalimdor_postanswers = Lorehelper_FormEventPostanswers (LHT("HumanEventThirdWarKalimdorKulTirasLordaeron"),standard_postanswers);	
else 
	thirdwarkalimdor_postanswers = Lorehelper_FormEventPostanswers (LHT("HumanEventThirdWarKalimdorStandard"),standard_postanswers);	
end

--varframe.age+childage >= ageticks[#ageticks] indicates whether player was born during the event
--(varframe.age < ageticks[#ageticks]) is the logical waschild variable
if varframe.responses["Gurubashi War"]==nil then
	if age+childage >= ageticks[#ageticks] then
		varframe.curframe = Lorehelper_EventTestQuestion (LHT("Gurubashi War"), LHT("HumanEventGurubashiWar"), (age < ageticks[#ageticks]), gurubashi_postanswers, LHART_GURUBASHIWAR);
		return varframe.curframe;
	end
end

if varframe.responses["Third War: Kalimdor"]==nil then
	if age+childage >= ageticks[1] then
		varframe.curframe = Lorehelper_EventTestQuestion (LHT("Third War: Kalimdor"), LHT("HumanEventThirdWarKalimdor"), (age < ageticks[1]), thirdwarkalimdor_postanswers, LHART_THIRDWARKALIMDOR);
		return varframe.curframe;
	end	
end

return varframe.curframe;
end
-------------------------------------------------
-------------------------------------------------
-------------------------------------------------
function Lorehelper_Troll ()
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
function Lorehelper_Tauren ()
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


	
