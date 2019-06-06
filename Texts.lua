function Lorehelper_Text (key)
	local text = nil;
	
	if Lorehelper_VarFrame == nil then
		print ("Lorehelper: can't create a text when addon variables aren't loaded");
		return text;	
--first date is beginning of event + 18; recent events are exception 
	elseif key=="HumanAge18-23" then text="\"Four years have passed since the mortal races banded together and stood united against the might of the Burning Legion\". Your childhood was quite peaceful, but during your teenage years the world was shackled by the demonic invasion known as Third War. Perhaps the stories of the Hijal veterans have made you hungry for heroic deeds, or maybe the horrors of the war have influenced your decision to become an independent adventurer.|n|nIn any case, you are an adult now, and your future is in your hands..."	
	elseif key=="HumanAge23-33" then text="\"Four years have passed since the mortal races banded together and stood united against the might of the Burning Legion\". You were an adult when these events, known as Third War, took place.|n|nYou parents might have told you that the orcs are the greatest enemy the Alliance have ever faced, but you know that there are greater horrors."	
	elseif key=="HumanAge33-39" then text="You were lucky enough to have a relatively peaceful youth. The orc invaders were defeated in the Second War, and only a few years ago the world have faced the wrath of their former masters - demons of the Burning Legion.|n|nYou know that the eternal peace is impossible, but you have at least felt the taste it."
	elseif key=="HumanAge39-43" then text="When the orcs have attacked Azeroth and ravaged the city of Stormwind, you were a teenager. But by the time the Alliance of human kingdoms, dwarves, gnomes and high elves was formed, you had grown up already.|n|nThe Second War was the great victory of your youth. Years of relative peace followed, and only a few years ago the world have faced the wrath of demons of the Burning Legion.|n|nYou know that even if an enemy is defeated, there is a chance that a greater foe lurks in shadows, only waiting for the proper moment to attack..."
	elseif key=="HumanAge43-61" then text="When the orcs have attacked Azeroth and ravaged the city of Stormwind, you were already an adult. The Second War have followed, and the Alliance was victorious this time. After only a short break, the former orcish masters - the demons of the Burning Legion - has launched another invasion.|n|nYou have witnessed all three great Wars, and you know how dangerous this world can be."
	elseif key=="HumanAge61-80" then text="A lot of stuff took place during your life. Gurubashi War between the Kingdom of Stormwind and the trolls of Stranglethorn, that is rumored to have been won by a single archmage - Medivh was his name. Orcish invasion, known as First War, in which the same Medivh has assisted the orcs. The defeat of orcs in the Second War. You have even heard that the spirit of Medivh has played some role in the recent demonic invasion that people call Third War!|n|nBut apparently the chaotic and dangerous nature of this world only amuses you. You are ready to be an adventurer again, and only a fool would call you \"retired\"."
-----------------------
	elseif key=="HumanHomeKingdom" then text="You are in the lands of Stormwind, " ..Lorehelper_VarFrame.name.. ", but were you born here? |n|nHundreds of years ago, a mighty human Empire of Arathor existed. Over the course of time, however, the Empire began to disintegrate, and its seven city-states became the Seven Kingdoms. |n|nWhich Kingdom are you from?"
	elseif key=="HumanDalaranMage" then text="I could have guessed that the mage like you comes from the magocratic Kingdom of Dalaran...|n|nThe Kingdom was not a mere part of the Alliance and the wars it led. Hundreds of years ago, humans learnt from the high elves of Silvermoon that the abuse of magic inadvertently tears open rifts in reality. Through such rifts, a horrific demons can enter our world. The Order of Tirisfal was founded in order to protect Azeroth from this threat...|n|nIt all barely matters now. The city was ravaged during the Third War, by the very demons its leaders thought they know how to defend from. Its ruins are now covered by the magical barrier, and some wizards still lurk around them, their intentions unknown.|n|nWhile some mages live the past, some prefer the present. Apparently you are one of the latter, mage of the Alliance."
	elseif key=="HumanDalaranNonMage" then text="The Kingdom of Dalaran, ruled by mages, but inhabited also by merchants, craftsmen, "..Lorehelper_VarFrame.class.."s...|n|nThe Kingdom was not a mere part of the Alliance and the wars it led. Hundreds of years ago, humans learnt from the high elves of Silvermoon that the abuse of magic inadvertently tears open rifts in reality. Through such rifts, a horrific demons can enter our world. The Order of Tirisfal was founded in order to protect Azeroth from this threat...|n|nIt all barely matters now. The city was ravaged during the Third War, by the very demons its leaders thought they know how to defend from. Its ruins are now covered by the magical barrier, and some wizards still lurk around them, their intentions unknown.|n|nWhile some, like those mages, live the past, some prefer the present. Apparently you are one of the latter."
	elseif key=="HumanHomeKingdomAlterac" then text="Oh, you are one of the Alteraci? I would not mention it to strangers if I were you. Many still look down on Alteraci after Aiden Perenolde, the King of Alterac, has betrayed the Alliance in the Second War to ally with the Orcish Horde. After Perenolde's treachery was uncovered, the Alliance army has destroyed the city of Alterac. |n|nAlteraci survivors, however, continued to seek revenge upon Alliance even after the end of the Second War. Those loyal to the Kingdom and its old nobility are now known as Syndicate. But you are smarter than them, aren't you?"
	elseif key=="HumanHomeKingdomGilneas" then text="Genn Greymane, the ruler of Gilneas, was never a strong supporter of the Alliance. Gilneas did assist in the Second War, but have left the Alliance afterwards.|n|nAttempting to forever remove his nation from what he considered \"other people's troubles\", Greymane barricaded the majority of Gilneas behind the Wall. But when the undead Scourge have invaded the neighbouring Lordaeron, the Wall was not enough to stop the walking dead.|n|nGreymane tried to use a \"secret weapon\" of his court archmage Arugal against the undead. The weapon, however, has only made things worse, for the weapon were worgen - wolfmen who soon have turned against the people of Gilneas.|n|nI bet that you are happy to have escaped the Kingdom years ago. Not much is known about the fate of those still locked behind the Wall."
	elseif key=="HumanHomeKingdomKulTiras" then text="Howdy, sailor!|n|nThe island of Kul Tiras was once a great place to live at. The fleet of its ruler, Grand Admiral Daelin Proudmoore, have re-established the Alliance control of the sea during the Second War. On the vessels of Kul Tiras Jaina Proudmoore, the daughter of Daelin, have lead many hundreds of people of the Alliance across the sea, to Kalimdor, where the invaders of the Burning Legion were ultimately defeated.|n|nThe heroic tale ends abruptly. The Grand Admiral was slaughtered by the Horde during the battle for Theramore, Kul Tiras' fortress in Kalimdor - his daughter's peace pact with the Horde intact...|n|nSome Kul Tiran still fight with the Horde near Durotar, their capital. Some rumored to remain on the island. And some, like you, feel more comfortable on the solid ground."
	elseif key=="HumanHomeKingdomLordaeron" then text="Oh, a Lordaeron refugee...|n|nNot everyone remembers the days of Lordaeron glory - the Kingdom being the uniting force for the Alliance, victory in the Second War. Not everyone remembers the brave young paladin, Arthas, Prince of Lordaeron. But everyone knows the story of Arthas turning against his people, killing his father, and leading armies of the undead to destroy the Kingdom...|n|nYour Kingdom is no more, and the living dead are all its inhabitants. Some undead have recently united with the Horde, and the catacombs of your old capital house their abominations.|n|nMany Lordaeronians are now members of Scarlet Crusade that continues the war against the undead. They are quite fanatic though, and would likely kill you on sight.|n|nBut I know that you are not infected with the undead plague. Make yourself comfortable - refugees are welcome here."
	elseif key=="HumanHomeKingdomStormwind35-" then text="So you are local.|n|nYou are perhaps too young to remember the old city of Stormwind... It was beautiful - until the orcs have destroyed it in the First War. But now it again stands in all its glory, thanks to the aid of the Alliance and the efforts of the builders of Stonemason Guild.|n|nI should not have mentioned the Stonemasons... Let us, uhm, discuss something else.|n|nSince the fall of Lordaeron, the kingdom of Stormwind has become the strongest bastion of humanity and the most powerful nation within the Alliance. No Kingdom is without its troubles, but we need a Stormwindian like you to continue to prosper - for the Alliance, and for all the humans!"
	elseif key=="HumanHomeKingdomStormwind35+" then text="So you are local.|n|nYou must be old enough to remember the old city of Stormwind... It was beautiful - until the orcs have destroyed it in the First War. But now it again stands in all its glory, thanks to the aid of the Alliance and the efforts of the builders of Stonemason Guild.|n|nI should not have mentioned the Stonemasons... Let us, uhm, discuss something else.|n|nSince the fall of Lordaeron, the kingdom of Stormwind has become the strongest bastion of humanity and the most powerful nation within the Alliance. No Kingdom is without its troubles, but we need a Stormwindian like you to continue to prosper - for the Alliance, and for all the humans!"
	elseif key=="HumanHomeKingdomStromgardeWarrior" then text="Proud Stromic warrior here I see! Are you one of those who say \"Alliance of Stromgarde\" instead of \"Alliance of Lordaeron\"? Yes, both of the Kingdoms were the Alliance founders...|n|nStromgarde was once the capital of the human Empire, and later a strong Kingdom of humans. These days are gone. The Kingdom has stood strong against the Horde, the Scourge, the Alteraci traitors known as Syndicate - but the doom has come from the inside. The Kingdom ruler, Thoras Trollbane, was murdered by his son, Galen, who sought the throne of Stromgarde for himself. After the treachery, the Syndicate and the ogres managed to occupy much of the weakened Kingdom.|n|nArmies of Stromgarde still maintain a base of operations at the crevasse known as Refuge Pointe, as well as portions of the devastated capital city itself. Stromics are the founders of the League of Arathor, which is fighting to free the rest of the Arathi Highlands, the Arathi Basin, and its many resources from the hands of the Horde.|n|nI am sure you will see your compatriots again in Arathi one day."
	elseif key=="HumanHomeKingdomStromgardeNonWarrior" then text="\"The warriors' nation of Stromgarde\" they say, but I see that you are not a warrior. Of course, each Kingdom needs "..Lorehelper_VarFrame.class.."s too...|n|nStromgarde was once the capital of the human Empire, and later a strong Kingdom of humans. These days are gone. The Kingdom has stood strong against the Horde, the Scourge, the Alteraci traitors known as Syndicate - but the doom has come from the inside. The Kingdom ruler, Thoras Trollbane, was murdered by his son, Galen, who sought the throne of Stromgarde for himself. After the treachery, the Syndicate and the ogres managed to occupy much of the weakened Kingdom.|n|nArmies of Stromgarde still maintain a base of operations at the crevasse known as Refuge Pointe, as well as portions of the devastated capital city itself. Stromics are the founders of the League of Arathor, which is fighting to free the rest of the Arathi Highlands, the Arathi Basin, and its many resources from the hands of the Horde.|n|nI am sure you will see your compatriots again in Arathi one day."
-----------------------
	elseif key=="HumanStandardAvoided" then text="You were not much affected by these events."
	elseif key=="HumanStandardLostSomeone" then text="You have lost someone you loved during these events."
	elseif key=="HumanStandardParticipated" then text="You did fight in this war. Luckily, survived."
	elseif key=="HumanStandardLostEverything" then text="You have suffered a lot during these horrible events. The scars of this war will forever remind you of people you loved and lost, of burnt houses, of crying children, of fresh graves..."
	
	elseif key=="HumanEventGurubashiWarStandard" then text="The Gurubashi War was fought far from your home Kingdom."	
------------------------------------------------------------	
------------------------------------------------------------
------------------------------------------------------------
------------------------------------------------------------
------------------------------------------------------------
------------------------------------------------------------
------------------------------------------------------------
------------------------------------------------------------
------------------------------------------------------------
------------------------------------------------------------
	elseif key=="MsgAnswersLoaded" then text="Lorehelper: your past answers loaded."
	elseif key=="MsgRetakeTest" then text="Are you sure you want to do the lore test again? Your old answers will be lost."
	elseif key=="MsgAccessLoreProfile" then text="Lorehelper: you can access your lore profile via the minimap icon, or by typing /lore"
------------------------------------------------------------	
------------------------------------------------------------
------------------------------------------------------------
------------------------------------------------------------
------------------------------------------------------------
------------------------------------------------------------
------------------------------------------------------------
------------------------------------------------------------
------------------------------------------------------------
------------------------------------------------------------
	else text=key;
	end	
	
return text;
end

