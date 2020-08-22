---------------------------------------------------------------------------------------
-- By Pino - Hydraxian Waterlords
-- For the Seven Thunders guild
-- Feel free to use and adapt.
-- If you do decide to use it, please credit me.
-- GNU General Public License (GPL) v3.0
---------------------------------------------------------------------------------------


local ThunderLoot = LibStub("AceAddon-3.0"):NewAddon("ThunderLoot", "AceEvent-3.0", "AceConsole-3.0")
local AceGUI = LibStub("AceGUI-3.0")
-- Register the Chat Command
ThunderLoot:RegisterChatCommand("tl", "TLCommands")

-- GLOBALS: ThunderLoot
local AddonVersion = "1.5"
local AddonGameVersion = "11305"
local AddonDate = "13:09 22-08-20"
local APBonus = 5
local ServerName = ""
local AddonName = "|cff00ffccThunderLoot|r"


-- GLOBALS: Init
local GUILD_ROSTER_UPDATE_TESTER = true
local ServerTime = nil
local GuildName = nil


-- UI holders
ThunderLoot.ConfigMenu = nil
ThunderLoot.MainMenu = nil

-- Raid UI holders
startRaidLbl = nil
startRaidBtn = nil

-- Roll holders
--self.db.realm[GuildName].IsRollingRandom = false
--self.db.realm[GuildName].IsRolling = false
--self.db.realm[GuildName].IsRollingRandomWinner = false

-- Popups
StaticPopupDialogs["UPDATEADDON"] = {
  text = AddonName.."\n\nYour Thunderloot addon is out of date. Update it from Discord!",
  button1 = "Disable addon!",
  OnAccept = function()
    DisableAddOn("ThunderLoot")
	ReloadUI()
  end,
  timeout = 0,
  whileDead = true,
  hideOnEscape = false,
  preferredIndex = 3,
}
StaticPopupDialogs["NOTIMPLEMENTED"] = {
  text = AddonName.."\n\nThe function you are trying to use is not fully implemented yet. Use at your own risk!",
  button1 = "Ok",
  OnAccept = function()
  end,
  timeout = 0,
  whileDead = true,
  hideOnEscape = true,
  preferredIndex = 3,
}
StaticPopupDialogs["WRONGUSERADDON"] = {
  text = AddonName.."\n\nYou are not in a guild!",
  button1 = "Disable addon!",
  OnAccept = function()
    DisableAddOn("ThunderLoot")
	ReloadUI()
  end,
  timeout = 0,
  whileDead = true,
  hideOnEscape = false,
  preferredIndex = 3,
}
StaticPopupDialogs["WRONGUSERADDONNOTE"] = {
  text = AddonName.."\n\nYou don't have the correct guild permissions in the guild!",
  button1 = "Disable addon!",
  OnAccept = function()
    DisableAddOn("ThunderLoot")
	ReloadUI()
  end,
  timeout = 0,
  whileDead = true,
  hideOnEscape = false,
  preferredIndex = 3,
}
StaticPopupDialogs["WRONGADDONGAME"] = {
  text = AddonName.."\n\nThe addon is not updated to the latest version of the game!",
  button1 = "Disable addon!",
  OnAccept = function()
    DisableAddOn("ThunderLoot")
	ReloadUI()
  end,
  timeout = 0,
  whileDead = true,
  hideOnEscape = false,
  preferredIndex = 3,
}
StaticPopupDialogs["RAIDONGOING"] = {
    text = AddonName.."\n\nRaid is still ongoing. \nDo you want to Continue it or Delete it?",
    button1 = "Continue",
    button2 = "Delete",
    whileDead = true,
    hideOnEscape = false,
    timeout = 0,
    OnAccept = function()
		StaticPopup_Show("RAIDONGOINGCONTINUE")
    end,
    OnCancel = function()
		ThunderLoot.db.realm[GuildName].Raid = {}
		StaticPopup_Show("RAIDONGOINGDELETE")
    end,
	preferredIndex = 3,
}
StaticPopupDialogs["RAIDONGOINGCONTINUE"] = {
  text = AddonName.."\n\nThe raid have been Continued!\nYou have to save it yourself!",
  button1 = "Ok",
  OnAccept = function() end,
  timeout = 0,
  whileDead = true,
  hideOnEscape = false,
  preferredIndex = 3,
}
StaticPopupDialogs["RAIDONGOINGDELETE"] = {
  text = AddonName.."\n\nThe raid data have been deleted!",
  button1 = "Ok",
  OnAccept = function() end,
  timeout = 0,
  whileDead = true,
  hideOnEscape = false,
  preferredIndex = 3,
}
StaticPopupDialogs["RAIDNOTONGOINGBENCH"] = {
  text = AddonName.."\n\nThe raid is not ongoing! \nYou need to start a raid, to be able to bench a player!",
  button1 = "Ok",
  OnAccept = function() end,
  timeout = 0,
  whileDead = true,
  hideOnEscape = false,
  preferredIndex = 3,
}
StaticPopupDialogs["RAIDNOTONGOINGATTEND"] = {
  text = AddonName.."\n\nThe raid is not ongoing! \nYou need to start a raid, to be able to add a player as attended!",
  button1 = "Ok",
  OnAccept = function() end,
  timeout = 0,
  whileDead = true,
  hideOnEscape = false,
  preferredIndex = 3,
}
function Warning(msg, btn, fnc)
	StaticPopupDialogs["CUSTOMWARNING"] = {
	  text = msg,
	  button1 = btn,
	  OnAccept = fnc,
	  timeout = 0,
	  whileDead = true,
	  hideOnEscape = true,
	  preferredIndex = 3,
	}
	StaticPopup_Show("CUSTOMWARNING")
end

-- Init functions
function ThunderLoot:OnInitialize()
	ThunderLoot:RegisterEvent("GUILD_ROSTER_UPDATE")
	
	local frame = CreateFrame("Frame")
	frame:RegisterEvent("GROUP_ROSTER_UPDATE")
	frame:SetScript("OnEvent", function(self, event, ...)
		ThunderLoot:Update()
	end)
	local wframe = CreateFrame("Frame")
	wframe:RegisterEvent("CHAT_MSG_WHISPER")
	wframe:SetScript("OnEvent", function(msg, event, message, sender, ...)
		ThunderLoot:CCommand(message, sender)
	end)

	--ThunderLoot:RegisterEvent("RAID_ROSTER_UPDATE")
end
function ThunderLoot:GUILD_ROSTER_UPDATE()
	local _test = GetGuildRosterInfo(1)
	if(_test ~= nil and GUILD_ROSTER_UPDATE_TESTER) then
		GUILD_ROSTER_UPDATE_TESTER = false
		ThunderLoot:UnregisterEvent("GUILD_ROSTER_UPDATE")
		ThunderLoot:initializeTheDB()
		ThunderLoot:RegisterEvent("CHAT_MSG_SYSTEM")
		ServerTime = C_DateAndTime.GetServerTimeLocal()
	end
end
function ThunderLoot:OnEnable()
	ThunderLoot:Print(AddonName.." V-"..AddonVersion.." Enabled. Last updated "..AddonDate)
end
function ThunderLoot:OnDisable()
	ThunderLoot:Print(AddonName.." Disabled")
end

-- UI functions
function ThunderLoot:OpenConfig()
	if(ThunderLoot.ConfigMenu == nil) then
		ThunderLoot:Print("Opening Config Menu")
		-- Create a container frame
		ThunderLoot.ConfigMenu = AceGUI:Create("Frame")
		ThunderLoot.ConfigMenu:SetCallback("OnClose", function()
														AceGUI:Release(ThunderLoot.ConfigMenu) 
														ThunderLoot.ConfigMenu = nil
													end)
		ThunderLoot.ConfigMenu:SetTitle(AddonName.." v-"..AddonVersion)
		ThunderLoot.ConfigMenu:SetStatusText("Config system by - Pino")
		ThunderLoot.ConfigMenu:SetLayout("Flow")
		ThunderLoot.ConfigMenu:SetWidth(400)
		ThunderLoot.ConfigMenu:SetHeight(300)
		ThunderLoot.ConfigMenu:EnableResize(false)
		
		local BlankLbl1 = AceGUI:Create("Label")
		BlankLbl1:SetText(" ")
		BlankLbl1:SetFullWidth(true)
		local BlankLbl2 = AceGUI:Create("Label")
		BlankLbl1:SetText(" ")
		BlankLbl1:SetFullWidth(true)

		GuildNames = {}
		ThunderLoot:RefreshGuildList()
		for i,v in ipairs(self.db.realm[GuildName].Users) do
			table.insert(GuildNames, v.Name)
		end
		
		table.sort(GuildNames)
		local UNLbl = AceGUI:Create("Label")
		UNLbl:SetText("Select username of the Character in the guild, who will be reserved for data storage!")
		UNLbl:SetFullWidth(true)

		local UNDD = AceGUI:Create("Dropdown")
		UNDD:SetLabel("Username:")
		UNDD:SetList(GuildNames)
		if(self.db.realm[GuildName].AddonGuildVars ~= nil)then
			for i=1,tablelength(GuildNames) do
				--ThunderLoot:Print(i.." "..GuildNames[i].." "..self.db.realm[GuildName].AddonGuildVars)
				if (GuildNames[i]==self.db.realm[GuildName].AddonGuildVars) then
					UNDD:SetValue(i)
					--ThunderLoot:Print(GuildNames[i])
				end
			end
		end
		UNDD:SetWidth(150)
		UNDD:SetCallback("OnValueChanged", function(widget, event, text)
												_GNames = {}
												for i,v in ipairs(self.db.realm[GuildName].Users) do
													table.insert(_GNames, v.Name)
												end
												table.sort(_GNames)
												self.db.realm[GuildName].AddonGuildVars = GuildNames[text]
												ThunderLoot:initializeTheDB()
			end)

		local APLbl = AceGUI:Create("Label")
		APLbl:SetText("AP+- bonus pr Raid")
		APLbl:SetWidth(50)
		APLbl:SetFullWidth(true)
	
		local APBox = AceGUI:Create("EditBox")
		APBox:SetText(""..self.db.realm[GuildName].APBonus)
		APBox:SetWidth(150)
		APBox:SetCallback("OnEnterPressed", function(widget, event, text)
												if (tonumber(text)~=nil)then
													--self.db.realm[GuildName].APBonus = text
													UpdateDBAP(text)
												else
													APBox:SetText(self.db.realm[GuildName].APBonus)
												end
		end)

		local APMaxLbl = AceGUI:Create("Label")
		APMaxLbl:SetText("AP Max")
		APMaxLbl:SetWidth(50)
		APMaxLbl:SetFullWidth(true)
	
		local APMaxBox = AceGUI:Create("EditBox")
		APMaxBox:SetText(""..self.db.realm[GuildName].APMax)
		APMaxBox:SetWidth(150)
		APMaxBox:SetCallback("OnEnterPressed", function(widget, event, text)
												if (tonumber(text)~=nil)then
													--self.db.realm[GuildName].APBonus = text
													UpdateDBAP(text)
												else
													APMaxBox:SetText(self.db.realm[GuildName].APMax)
												end
		end)
	
	

		ThunderLoot.ConfigMenu:AddChild(UNLbl)
		ThunderLoot.ConfigMenu:AddChild(UNDD)

		ThunderLoot.ConfigMenu:AddChild(BlankLbl1)

		ThunderLoot.ConfigMenu:AddChild(APLbl)
		ThunderLoot.ConfigMenu:AddChild(APBox)

		ThunderLoot.ConfigMenu:AddChild(BlankLbl2)

		ThunderLoot.ConfigMenu:AddChild(APMaxLbl)
		ThunderLoot.ConfigMenu:AddChild(APMaxBox)
	else
		AceGUI:Release(ThunderLoot.ConfigMenu)
		ThunderLoot.ConfigMenu = nil
	end
end
function ThunderLoot:ToggleMainMenu()
	if(ThunderLoot.MainMenu == nil) then
		--ThunderLoot:Print("Opening Menu")
		-- Create a container frame
		ThunderLoot.MainMenu = AceGUI:Create("Frame")
		ThunderLoot.MainMenu:SetCallback("OnClose", function()
														AceGUI:Release(ThunderLoot.MainMenu) 
														ThunderLoot.MainMenu = nil
													end)
		ThunderLoot.MainMenu:SetTitle(AddonName.." v-"..AddonVersion)
		ThunderLoot.MainMenu:SetStatusText("Seven Thunders' Loot system by - Pino")
		ThunderLoot.MainMenu:SetLayout("Flow")
		ThunderLoot.MainMenu:SetWidth(400)
		ThunderLoot.MainMenu:SetHeight(200)
		ThunderLoot.MainMenu:EnableResize(false)
		
		startRaidBtn = AceGUI:Create("Button")
		startRaidBtn:SetWidth(150)
		if(self.db.realm[GuildName].Raid.Ongoing ~= nil) then
			startRaidBtn:SetText("Stop raid")
			startRaidBtn:SetCallback("OnClick", function() ThunderLoot:StopRaid() end)
		else
			startRaidBtn:SetText("Start raid")
			startRaidBtn:SetCallback("OnClick", function() ThunderLoot:StartRaid() end)
		end
		
		startRaidLbl = AceGUI:Create("Label")
		if(self.db.realm[GuildName].Raid.Ongoing ~= nil) then
			startRaidLbl:SetText("Ends the raid and rolls current raid over to last raid!")
		else
			startRaidLbl:SetText("Starts the raid and takes attendance!")
		end
		startRaidLbl:SetFullWidth(false)
		startRaidLbl:SetWidth(200)
		
		local nextRollBtn = AceGUI:Create("Button")
		nextRollBtn:SetWidth(150)
		nextRollBtn:SetText("Next roll")
		nextRollBtn:SetCallback("OnClick", function() ThunderLoot:NextRoll() end)
		local nextRollLbl = AceGUI:Create("Label")
		nextRollLbl:SetText("Changes to the next roll priority!")
		nextRollLbl:SetFullWidth(false)
		nextRollLbl:SetWidth(200)
		
		local endRollBtn = AceGUI:Create("Button")
		endRollBtn:SetWidth(150)
		endRollBtn:SetText("End roll")
		endRollBtn:SetCallback("OnClick", function() ThunderLoot:StopRoll() end)
		local endRollLbl = AceGUI:Create("Label")
		endRollLbl:SetText("Ends the roll!")
		endRollLbl:SetFullWidth(false)
		endRollLbl:SetWidth(200)
		
		local randomRollBtn = AceGUI:Create("Button")
		randomRollBtn:SetWidth(150)
		randomRollBtn:SetText("Raid roll")
		randomRollBtn:SetCallback("OnClick", function() ThunderLoot:RaidRoll() end)
		local randomRollLbl = AceGUI:Create("Label")
		randomRollLbl:SetText("Choose a random raid/group member!")
		randomRollLbl:SetFullWidth(false)
		randomRollLbl:SetWidth(200)
		
		local userMenuBtn = AceGUI:Create("Button")
		userMenuBtn:SetWidth(150)
		userMenuBtn:SetText("Management Menu")
		userMenuBtn:SetCallback("OnClick", function() ToggleUserMenuWindow() end)
		local userMenuLbl = AceGUI:Create("Label")
		userMenuLbl:SetText("Menu for the user, raid and loot system! (and help menu)")
		userMenuLbl:SetFullWidth(false)
		userMenuLbl:SetWidth(200)
		
		
		
		
		ThunderLoot.MainMenu:AddChild(startRaidBtn)
		ThunderLoot.MainMenu:AddChild(startRaidLbl)
		
		ThunderLoot.MainMenu:AddChild(nextRollBtn)
		ThunderLoot.MainMenu:AddChild(nextRollLbl)
		
		ThunderLoot.MainMenu:AddChild(endRollBtn)
		ThunderLoot.MainMenu:AddChild(endRollLbl)
		
		ThunderLoot.MainMenu:AddChild(randomRollBtn)
		ThunderLoot.MainMenu:AddChild(randomRollLbl)
		
		--ThunderLoot.MainMenu:AddChild(userMenuBtn)
		--ThunderLoot.MainMenu:AddChild(userMenuLbl)
	else
		AceGUI:Release(ThunderLoot.MainMenu)
		ThunderLoot.MainMenu = nil
	end
end

-- Database functions
function ThunderLoot:initializeTheDB()
	self.db = LibStub("AceDB-3.0"):New("ThunderLootDB")
	if (IsInGuild()) then
		-- Gets the GuildName
		GuildName = GetGuildInfo("player")
		ServerName = GetRealmName()
		-- Global item database
		if self.db.global.TLItemDB == nil then
			self.db.global.TLItemDB = {}
		end

		-- Addon guild database
		if self.db.realm[GuildName] == nil then
			self.db.realm[GuildName] = {}
		end

		-- Addon User database
		if self.db.realm[GuildName].User == nil then
			self.db.realm[GuildName].User = {}
		end

		-- Addon Raid database
		if self.db.realm[GuildName].Raid == nil then
			self.db.realm[GuildName].Raid = {}
		elseif self.db.realm[GuildName].Raid.Ongoing ~= nil then
			StaticPopup_Show("RAIDONGOING")
		end
		ThunderLoot:LoadDatabase()

		-- Checks the addon and game version
		if (self.db.realm[GuildName].AddonGuildVars ~= nil) then
			if (VersionCheck())then
				ThunderLoot:Print("ThunderLootDB initialized")
			end
		end
	else
		ThunderLoot:Print("You are not in a guild!")
		ThunderLoot:Print("Disable the addon!")
		StaticPopup_Show("WRONGUSERADDON")
		return false
	end
end
function ThunderLoot:GetUsername( CharacterName )
	CharacterName = string.gsub(CharacterName, "-" .. string.gsub(ServerName, " ", ""), "")
	for i=1, tablelength(self.db.realm[GuildName].Users) do
		if(self.db.realm[GuildName].Users[i].Name==CharacterName)then
			return self.db.realm[GuildName].Users[i].Username
		end
	end
	return CharacterName
end
function ThunderLoot:GetGuildRank(CharacterName)
	for i=1, tablelength(self.db.realm[GuildName].Users) do
		if(self.db.realm[GuildName].Users[i].Name==CharacterName)then
			return self.db.realm[GuildName].Users[i].Rank
		end
	end

	return "PUG"
end

-- Raid functions
function ThunderLoot:StartRaid()
	if(self.db.realm[GuildName].Raid.Ongoing ~= nil) then
		ThunderLoot:Print("Raid is already running")
		Warning(AddonName.."\n\nRaid is already running", "Ok", (function() end))
	else
		if(IsInRaid()) then
			
			self.db.realm[GuildName].Raid = {}
			--self.db.realm[GuildName].Raid.RaidUsers = {}
			--guildData = {}
			self.db.realm[GuildName].Raid.RaidUsernames = {}
			self.db.realm[GuildName].Raid.RaidUsernamesBench = {}
			--self.db.realm[GuildName].Raid.RaidLootUsers = {}
			self.db.realm[GuildName].Raid.Ongoing = true
			ThunderLoot:RefreshGuildList()
			if(ThunderLoot.MainMenu ~= nil) then
				--ThunderLoot:ToggleMainMenu()
				startRaidBtn:SetText("Stop raid")
				startRaidBtn:SetCallback("OnClick", function() ThunderLoot:StopRaid() end)
				startRaidLbl:SetText("Ends the raid and rolls current raid over to last raid!")
			end
			--RaidUsers = {}
			for raidIndex = 1, 40 do
				local Rname, Rrank, Rsubgroup, Rlevel, Rclass, RfileName, Rzone, Ronline, RisDead, Rrole, RisML = GetRaidRosterInfo(raidIndex);
				table.insert(self.db.realm[GuildName].Raid.RaidUsernames, ThunderLoot:GetUsername(Rname))
			end
			--table.insert(self.db.realm[GuildName].Raid.RaidUsernames, "Pino")
			--table.insert(self.db.realm[GuildName].Raid.RaidUsernames, "Thargor")
			ThunderLoot:Print("Raid started")
		else 
			ThunderLoot:Print("You can't start a raid unless you are IN a raid!")
			Warning(AddonName.."\n\nYou can't start a raid unless you are IN a raid!", "Ok", (function() end))
		end
	end
end
function ThunderLoot:StopRaid()
	if(self.db.realm[GuildName].Raid.Ongoing ~= nil) then
		self.db.realm[GuildName].Raid.Ongoing = nil
		if(ThunderLoot.MainMenu ~= nil) then
			--ThunderLoot:ToggleMainMenu()
			startRaidBtn:SetText("Start raid")
			startRaidBtn:SetCallback("OnClick", function() ThunderLoot:StartRaid() end)
			startRaidLbl:SetText("Starts the raid and takes attendance!")
		end
		ThunderLoot:RefreshGuildList()
		local guildTotalMembers, _, _ = GetNumGuildMembers();
		while (guildTotalMembers > 0) do
			local Gname, Grank, GrankIndex, Glevel, Gclass, Gzone, Gnote, Gofficernote, Gonline, Gstatus, GclassFileName, GachievementPoints, GachievementRank, GisMobile, GisSoREligible, GstandingID = GetGuildRosterInfo(guildTotalMembers)
			Gname = string.gsub(Gname, "-" .. string.gsub(ServerName, " ", ""), "")
			--table.insert(guildData, {name=Gname, rank=Grank, officernote=Gofficernote, index=guildTotalMembers})
			--ThunderLoot:Print(Gname)

			for i = 1, tablelength(self.db.realm[GuildName].Users) do
				if(self.db.realm[GuildName].Users[i].Name == Gname and self.db.realm[GuildName].AddonGuildVars ~= Gname) then
					ThunderLoot:Print("Gname == "..Gname)
					local _raidData = ""
					if(tableContains(self.db.realm[GuildName].Raid.RaidUsernames, self.db.realm[GuildName].Users[i].Username) or tableContains(self.db.realm[GuildName].Raid.RaidUsernamesBench, self.db.realm[GuildName].Users[i].Username)) then
						if(Gofficernote~=nil and Gofficernote~="")then
							local officernoteList = {}
							local noteData = "TL,"..self.db.realm[GuildName].Users[i].Username..","
							for word in string.gmatch(Gofficernote, "([^,]+)") do
								table.insert(officernoteList, word)
							end
							if(officernoteList[1]=="TL")then
								if(officernoteList[4]=="0")then
									local tmptest = true
									local tmpnote = ""
									for num in self.db.realm[GuildName].Users[i].Raids:gmatch('.') do
										if (tmptest) then
											tmptest = false
										else
											tmpnote=tmpnote..num
										end
									end

									if(string.len( tmpnote )+0 == 5)then
										noteData=noteData..tmpnote.."1,"..officernoteList[4]..","
									else
										noteData=noteData.."000001,"..officernoteList[4]..","
									end

									if(self.db.realm[GuildName].Users[i].AP + self.db.realm[GuildName].APBonus >= self.db.realm[GuildName].APMax)then
										noteData=noteData..self.db.realm[GuildName].APMax
									else
										noteData=noteData..(self.db.realm[GuildName].Users[i].AP + self.db.realm[GuildName].APBonus)
									end
									ThunderLoot:Print("DEBUG Note: \""..noteData.."\" "..string.len( tmpnote ))
									GuildRosterSetOfficerNote(guildTotalMembers, noteData)
								elseif(officernoteList[4]=="1")then
									--NOOP
								else
									local tmptest = true
									local tmpnote = ""
									for num in self.db.realm[GuildName].Users[i].Raids:gmatch('.') do
										if (tmptest) then
											tmptest = false
										else
											tmpnote=tmpnote..num
										end
									end

									if(string.len( tmpnote )+0 == 5)then
										noteData=noteData..tmpnote.."1,0,"
									else
										noteData=noteData.."000001,0,"
									end

									if(self.db.realm[GuildName].Users[i].AP + self.db.realm[GuildName].APBonus >= self.db.realm[GuildName].APMax)then
										noteData=noteData..self.db.realm[GuildName].APMax
									else
										noteData=noteData..(self.db.realm[GuildName].Users[i].AP + self.db.realm[GuildName].APBonus)
									end
									ThunderLoot:Print("DEBUG Note: \""..noteData.."\" "..string.len( tmpnote ))
									GuildRosterSetOfficerNote(guildTotalMembers, noteData)
								end
							end
						end
					else
						if(Gofficernote~=nil and Gofficernote~="")then
							local officernoteList = {}
							local noteData = "TL,"..self.db.realm[GuildName].Users[i].Username..","
							for word in string.gmatch(Gofficernote, "([^,]+)") do
								table.insert(officernoteList, word)
							end
							if(officernoteList[1]=="TL")then
								if(officernoteList[4]=="0")then
									local tmptest = true
									local tmpnote = ""
									for num in self.db.realm[GuildName].Users[i].Raids:gmatch('.') do
										if (tmptest) then
											tmptest = false
										else
											tmpnote=tmpnote..num
										end
									end

									if(string.len( tmpnote )+0 == 5)then
										noteData=noteData..tmpnote.."0,"..officernoteList[4]..","
									else
										noteData=noteData.."000000,"..officernoteList[4]..","
									end

									if(self.db.realm[GuildName].Users[i].AP - self.db.realm[GuildName].APBonus <= 0)then
										noteData=noteData.."0"
									else
										noteData=noteData..(self.db.realm[GuildName].Users[i].AP - self.db.realm[GuildName].APBonus)
									end
									ThunderLoot:Print("DEBUG Note: \""..noteData.."\" "..string.len( tmpnote ))
									GuildRosterSetOfficerNote(guildTotalMembers, noteData)
								elseif(officernoteList[4]=="1")then
									--NOOP
								else
									local tmptest = true
									local tmpnote = ""
									for num in self.db.realm[GuildName].Users[i].Raids:gmatch('.') do
										if (tmptest) then
											tmptest = false
										else
											tmpnote=tmpnote..num
										end
									end

									if(string.len( tmpnote )+0 == 5)then
										noteData=noteData..tmpnote.."0,0,"
									else
										noteData=noteData.."000000,0,"
									end

									if(self.db.realm[GuildName].Users[i].AP - self.db.realm[GuildName].APBonus <= 0)then
										noteData=noteData.."0"
									else
										noteData=noteData..(self.db.realm[GuildName].Users[i].AP - self.db.realm[GuildName].APBonus)
									end
									ThunderLoot:Print("DEBUG Note: \""..noteData.."\" "..string.len( tmpnote ))
									GuildRosterSetOfficerNote(guildTotalMembers, noteData)
								end
							end
						end
					end
				end
			end
			guildTotalMembers = guildTotalMembers - 1
		end
		


		ThunderLoot:Print("Raid stoped")
	else
		ThunderLoot:Print("Raid haven't been started")
	end
end
function ThunderLoot:Update()
	--ThunderLoot:Print("RAID_ROSTER_UPDATE")
	if(self.db.realm[GuildName].Raid.Ongoing ~= nil) then
		--ThunderLoot:Print("DEBUG EVENT")
		for RRraidIndex = 1, 40 do
			local RRname, RRrank, RRsubgroup, RRlevel, RRclass, RRfileName, RRzone, RRonline, RRisDead, RRrole, RRisML = GetRaidRosterInfo(RRraidIndex);
			if(tableContains(self.db.realm[GuildName].Raid.RaidUsernames, ThunderLoot:GetUsername(Rname)))then
					--NOP
			else
				table.insert(self.db.realm[GuildName].Raid.RaidUsernames, ThunderLoot:GetUsername(Rname))
				
				ThunderLoot:ChatPrint(RRname.." joined to the raid!")
			end
			--table.insert(RaidLootUsers, RRname)
		end
	end
end

-- Item handlers
function ThunderLoot:ItemAdd(item)
	local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, itemSellPrice = GetItemInfo(item)
	local itemID, itemType, itemSubType, itemEquipLoc, icon, itemClassID, itemSubClassID = GetItemInfoInstant(item)
	if (ThunderLoot.db.global.TLItemDB[itemID] == nil) then
		ThunderLoot.db.global.TLItemDB[itemID] = {itemName=itemName,  ItemSpec={BiSMain="",MainSpec="",Nopoints="",OffSpec=""}}
		return ("Item: "..itemLink.." added to the database!")
	else 
		return ("Item: "..itemLink.." already exists in the database!")
	end
end
function ThunderLoot:ItemDel(item)
	local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, itemSellPrice = GetItemInfo(item)
	local itemID, itemType, itemSubType, itemEquipLoc, icon, itemClassID, itemSubClassID = GetItemInfoInstant(item)
	if (ThunderLoot.db.global.TLItemDB[itemID] == nil) then
		return ("Item: "..itemLink.." does not exist in the database!")
	else 
		ThunderLoot.db.global.TLItemDB[itemID] = nil
		return ("Item: "..itemLink.." deleted from the database!")
	end
end

-- Roll functions
function ThunderLoot:LootPrio(CharacterName)
	for i=1, tablelength(self.db.realm[GuildName].Users) do
		if(self.db.realm[GuildName].Users[i].Name==CharacterName)then
			return self.db.realm[GuildName].GuildRanks[self.db.realm[GuildName].Users[i].Rank].LootPrio
		end
	end

	return 1
end
function ThunderLoot:StartRoll(item)
	if(self.db.realm[GuildName].IsRolling or self.db.realm[GuildName].IsRollingRandomWinner or self.db.realm[GuildName].IsRollingRandom)then
		ThunderLoot:Print("Another roll is active!")
	else
		self.db.realm[GuildName].RollSpec = 0
		local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, itemSellPrice = GetItemInfo(item)
		local itemID, itemType, itemSubType, itemEquipLoc, icon, itemClassID, itemSubClassID = GetItemInfoInstant(item)
		self.db.realm[GuildName].Rolls = {}
		Gtime = GetServerTime()
		if (itemName~=nil and itemName~="") then
			self.db.realm[GuildName].RollingItem = itemID
			if (self.db.global.TLItemDB[itemID] ~= nil) then
				for specindex = 1, ThunderLoot:CountSpecs() do
					if(not self.db.realm[GuildName].IsRolling)then
						if(self.db.realm[GuildName].Specs[specindex] ~= nil) then
							if(self.db.global.TLItemDB[itemID].ItemSpec[self.db.realm[GuildName].Specs[specindex]] ~= nil and self.db.global.TLItemDB[itemID].ItemSpec[self.db.realm[GuildName].Specs[specindex]] ~= "") then
								ThunderLoot:ChatPrint("---------------------")
								if(itemID..""=="19145")then 
									ThunderLoot:ChatPrint("Loot: Starting new roll")
									ThunderLoot:ChatRWPrint("Loot: "..("Priority "..specindex.." "..self.db.realm[GuildName].Specs[specindex]):upper().." [Rope of Blah Blah] ... sorry i mean "..itemLink)
								elseif(itemID..""=="19399")then 
									ThunderLoot:ChatPrint("Loot: Starting new roll")
									ThunderLoot:ChatRWPrint("Loot: "..("Priority "..specindex.." "..self.db.realm[GuildName].Specs[specindex]):upper().." [Black Ass Robe] ... sorry i mean "..itemLink)
								else
									ThunderLoot:ChatPrint("Loot: Starting new roll")
									ThunderLoot:ChatRWPrint("Loot: "..("Priority "..specindex.." "..self.db.realm[GuildName].Specs[specindex]):upper().." "..itemLink)
								end
								ThunderLoot:ChatPrint("Loot: "..self.db.global.TLItemDB[itemID].ItemSpec[self.db.realm[GuildName].Specs[specindex]])
								if(self.db.global.TLItemDB[itemID].ItemSpec[self.db.realm[GuildName].Specs[0]] ~= nil and self.db.global.TLItemDB[itemID].ItemSpec[self.db.realm[GuildName].Specs[0]] ~= "")then
									ThunderLoot:ChatPrint("Loot: "..self.db.global.TLItemDB[itemID].ItemSpec[self.db.realm[GuildName].Specs[0]])
								end
								ThunderLoot:ChatPrint("---------------------")
								self.db.realm[GuildName].IsRolling = true
								self.db.realm[GuildName].RollSpec = specindex
							end
						end
					end
				end
				if(not self.db.realm[GuildName].IsRolling)then
					ThunderLoot:ChatPrint("---------------------")
					ThunderLoot:ChatRWPrint("Loot: Starting new roll for "..itemLink.." (not in the database)")
					ThunderLoot:ChatPrint("---------------------")
					self.db.realm[GuildName].IsRolling = true
				end
			else
				ThunderLoot:ChatPrint("---------------------")
				ThunderLoot:ChatRWPrint("Loot: Starting new roll for "..itemLink.." (not in the database)")
				ThunderLoot:ChatPrint("---------------------")
				self.db.realm[GuildName].IsRolling = true
			end
		else
			ThunderLoot:Print("Error getting item. Try again")
		end
	end
end
function ThunderLoot:NextRoll()
	if(self.db.realm[GuildName].IsRolling) then
		local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, itemSellPrice = GetItemInfo(self.db.realm[GuildName].RollingItem)
		local itemID, itemType, itemSubType, itemEquipLoc, icon, itemClassID, itemSubClassID = GetItemInfoInstant(self.db.realm[GuildName].RollingItem)
		local _timer = GetServerTime()
		self.db.realm[GuildName].IsRolling = false
		ServerTime = GetServerTime()
		self.db.realm[GuildName].RollSpec = self.db.realm[GuildName].RollSpec + 1
		self.db.realm[GuildName].Rolls = {}
		if(self.db.realm[GuildName].RollSpec==1 or self.db.realm[GuildName].RollSpec == ThunderLoot:CountSpecs()) then
			self.db.realm[GuildName].IsRolling = true
			ThunderLoot:StopRoll()
		else
			for specindex = self.db.realm[GuildName].RollSpec, ThunderLoot:CountSpecs() do
				if((not self.db.realm[GuildName].IsRolling) and self.db.realm[GuildName].Specs[specindex] ~= nil) then
					
					if(self.db.global.TLItemDB[itemID].ItemSpec[self.db.realm[GuildName].Specs[specindex]] ~= nil and self.db.global.TLItemDB[itemID].ItemSpec[self.db.realm[GuildName].Specs[specindex]] ~= "") then
						ThunderLoot:ChatPrint("---------------------")
						ThunderLoot:ChatPrint("Loot: Changeing Spec to ")
						ThunderLoot:ChatRWPrint("Loot: "..("Priority "..specindex.." "..self.db.realm[GuildName].Specs[specindex]):upper().." "..itemLink)
						ThunderLoot:ChatPrint("Loot: "..self.db.global.TLItemDB[itemID].ItemSpec[self.db.realm[GuildName].Specs[specindex]])
						if(self.db.global.TLItemDB[itemID].ItemSpec[self.db.realm[GuildName].Specs[0]] ~= nil and self.db.global.TLItemDB[itemID].ItemSpec[self.db.realm[GuildName].Specs[0]] ~= "")then
							ThunderLoot:ChatPrint("Loot: "..self.db.global.TLItemDB[itemID].ItemSpec[self.db.realm[GuildName].Specs[0]])
						end
						ThunderLoot:ChatPrint("---------------------")
						self.db.realm[GuildName].IsRolling = true
						self.db.realm[GuildName].RollSpec = specindex
					end
				end
			end
			if (not self.db.realm[GuildName].IsRolling) then 
				self.db.realm[GuildName].IsRolling = true
				ThunderLoot:StopRoll()
			end
		end
	else
		ThunderLoot:Print("No roll is active!")
	end
end
function ThunderLoot:StopRoll()
	if(self.db.realm[GuildName].IsRolling ~= nil and self.db.realm[GuildName].IsRolling) then
		self.db.realm[GuildName].IsRolling = false
		
		local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, itemSellPrice = GetItemInfo(self.db.realm[GuildName].RollingItem)
		self.db.realm[GuildName].RollWinner = {}
		local wroll = 0
		local wprio = 0
		local _rolls = {}
		local _tester = false
		if(tablelength(self.db.realm[GuildName].Rolls)>0) then
			for k1 in pairs(self.db.realm[GuildName].Rolls) do
				if(self.db.realm[GuildName].Raid.Ongoing ~= nil) then
					if(ThunderLoot:LootPrio(k1) == wprio)then
						if(wroll==self.db.realm[GuildName].Rolls[k1].Roll+self.db.realm[GuildName].Rolls[k1].RollBonus.AP+0) then
							table.insert(self.db.realm[GuildName].RollWinner,k1)
						elseif(wroll<self.db.realm[GuildName].Rolls[k1].Roll+self.db.realm[GuildName].Rolls[k1].RollBonus.AP+0) then
							wroll=self.db.realm[GuildName].Rolls[k1].Roll+self.db.realm[GuildName].Rolls[k1].RollBonus.AP+0
							self.db.realm[GuildName].RollWinner = {}
							table.insert(self.db.realm[GuildName].RollWinner,k1)
						end
					elseif(ThunderLoot:LootPrio(k1) > wprio)then
						wprio=ThunderLoot:LootPrio(k1)
						wroll=self.db.realm[GuildName].Rolls[k1].Roll+self.db.realm[GuildName].Rolls[k1].RollBonus.AP+0
						self.db.realm[GuildName].RollWinner = {}
						table.insert(self.db.realm[GuildName].RollWinner,k1)
					end
					table.insert(_rolls, {Name=k1, RankPrio=ThunderLoot:LootPrio(k1), Roll=self.db.realm[GuildName].Rolls[k1].Roll+self.db.realm[GuildName].Rolls[k1].RollBonus.AP+0, Bonus=self.db.realm[GuildName].Rolls[k1].RollBonus})
				else
					
					if(ThunderLoot:LootPrio(k1) == wprio)then
						if(wroll==self.db.realm[GuildName].Rolls[k1].Roll+0) then
							table.insert(self.db.realm[GuildName].RollWinner,k1)
						elseif(wroll<self.db.realm[GuildName].Rolls[k1].Roll+0) then
							wroll=self.db.realm[GuildName].Rolls[k1].Roll+0
							self.db.realm[GuildName].RollWinner = {}
							table.insert(self.db.realm[GuildName].RollWinner,k1)
						end
					elseif(ThunderLoot:LootPrio(k1) > wprio)then
						wprio=ThunderLoot:LootPrio(k1)
						wroll=self.db.realm[GuildName].Rolls[k1].Roll+0
						self.db.realm[GuildName].RollWinner = {}
						table.insert(self.db.realm[GuildName].RollWinner,k1)
					end
					table.insert(_rolls, {Name=k1, RankPrio=ThunderLoot:LootPrio(k1), Roll=self.db.realm[GuildName].Rolls[k1].Roll+0, Bonus={AP=0}})
					--[[if(wroll==self.db.realm[GuildName].Rolls[k1].Roll+0) then
						wroll=self.db.realm[GuildName].Rolls[k1].Roll+0
						table.insert(self.db.realm[GuildName].RollWinner,k1)
					elseif (wroll<self.db.realm[GuildName].Rolls[k1].Roll+0) then
						self.db.realm[GuildName].RollWinner={}
						wroll=self.db.realm[GuildName].Rolls[k1].Roll+0
						table.insert(self.db.realm[GuildName].RollWinner,k1)
					end
					table.insert(_rolls, {Name=k1, RankPrio=ThunderLoot:LootPrio(k1), Roll=self.db.realm[GuildName].Rolls[k1].Roll+0, Bonus={AP=0}})--]]
				end
			end

			_rolls = ThunderLoot:sortRolls(_rolls, 0, self.db.realm[GuildName].APMax + 100)

			local _prio = -1
			for k1 in pairs(_rolls) do
				local _printstring1 = ""
				local _printstring2 = ""
				if(_prio<_rolls[k1].RankPrio)then
					_prio=_rolls[k1].RankPrio
					ThunderLoot:ChatPrint("---------------------")
				end
				if(self.db.realm[GuildName].Raid.Ongoing ~= nil) then
					if(_rolls[k1].Name~=ThunderLoot:GetUsername(_rolls[k1].Name))then
						_printstring1 = "Loot: "..ThunderLoot:GetUsername(_rolls[k1].Name).." (".._rolls[k1].Name.."): "
						_printstring2 = "".._rolls[k1].Roll - _rolls[k1].Bonus.AP.." + ".._rolls[k1].Bonus.AP.." AP = ".._rolls[k1].Roll.." LoL Points ("..ThunderLoot:GetGuildRank(_rolls[k1].Name)..")"
					else
						_printstring1 = "Loot: ".._rolls[k1].Name..": "
						_printstring2 = "".._rolls[k1].Roll - _rolls[k1].Bonus.AP.."  + ".._rolls[k1].Bonus.AP.." AP = ".._rolls[k1].Roll.." LoL Points ("..ThunderLoot:GetGuildRank(_rolls[k1].Name)..")"
					end
				else
					if(_rolls[k1].Name~=ThunderLoot:GetUsername(_rolls[k1].Name))then
						_printstring1 = "Loot: "..ThunderLoot:GetUsername(_rolls[k1].Name).." (".._rolls[k1].Name.."): "
						_printstring2 = "".._rolls[k1].Roll.." ("..ThunderLoot:GetGuildRank(_rolls[k1].Name)..")"
					else
						_printstring1 = "Loot: ".._rolls[k1].Name..": "
						_printstring2 = "".._rolls[k1].Roll.." ("..ThunderLoot:GetGuildRank(_rolls[k1].Name)..")"
					end
				end
				ThunderLoot:ChatPrint(_printstring1.." ".._printstring2)
			end
			ThunderLoot:ChatPrint("---------------------")
			
			table.sort(self.db.realm[GuildName].RollWinner)
			if(table.getn(self.db.realm[GuildName].RollWinner)>1)then
				local _name = "("
				for name in pairs(self.db.realm[GuildName].RollWinner) do
					if(_name=="(") then
						if(self.db.realm[GuildName].RollWinner[name]~=ThunderLoot:GetUsername(self.db.realm[GuildName].RollWinner[name]))then
							_name = _name.." "..ThunderLoot:GetUsername(self.db.realm[GuildName].RollWinner[name]).."("..self.db.realm[GuildName].RollWinner[name]..")"
						else
							_name = _name.." "..self.db.realm[GuildName].RollWinner[name]
						end
					else
						if(self.db.realm[GuildName].RollWinner[name]~=ThunderLoot:GetUsername(self.db.realm[GuildName].RollWinner[name]))then
							_name = _name..", "..ThunderLoot:GetUsername(self.db.realm[GuildName].RollWinner[name]).."("..self.db.realm[GuildName].RollWinner[name]..")"
						else
							_name = _name..", "..self.db.realm[GuildName].RollWinner[name]
						end
					end
				end
				_name = _name.." )"
				ThunderLoot:ChatPrint("Loot: There was multible winners of "..itemLink.." ".._name.." with the roll of "..wroll)
				ThunderLoot:ChatPrint("Loot: Rolling for random winner:")
				ThunderLoot:ChatPrint("---------------------")
				local _i = 1
				for name in pairs(self.db.realm[GuildName].RollWinner) do
					if(self.db.realm[GuildName].RollWinner[name]~=ThunderLoot:GetUsername(self.db.realm[GuildName].RollWinner[name]))then
						ThunderLoot:ChatPrint("(".._i..") "..ThunderLoot:GetUsername(self.db.realm[GuildName].RollWinner[name]).."("..self.db.realm[GuildName].RollWinner[name]..")")
					else
						ThunderLoot:ChatPrint("(".._i..") "..self.db.realm[GuildName].RollWinner[name])
					end
					_i=_i+1
				end
				self.db.realm[GuildName].IsRollingRandomWinner = true
				ThunderLoot:ChatPrint("---------------------")
				RandomRoll(1, table.getn(self.db.realm[GuildName].RollWinner))
			else
				for name in pairs(self.db.realm[GuildName].RollWinner) do
					if(self.db.realm[GuildName].RollWinner[name]~=ThunderLoot:GetUsername(self.db.realm[GuildName].RollWinner[name]))then
						ThunderLoot:ChatPrint("Loot: The winner of "..itemLink.." was "..ThunderLoot:GetUsername(self.db.realm[GuildName].RollWinner[name]).."("..self.db.realm[GuildName].RollWinner[name]..") with the roll of "..wroll)
					else
						ThunderLoot:ChatPrint("Loot: The winner of "..itemLink.." was "..self.db.realm[GuildName].RollWinner[name].." with the roll of "..wroll)
					end
					ThunderLoot:ChatPrint("---------------------")
				end
				
			end
		else
			ThunderLoot:ChatPrint("---------------------")
			ThunderLoot:ChatPrint("Loot: Noone rolled")
			ThunderLoot:ChatPrint("---------------------")
		end
		self.db.realm[GuildName].Rolls = {}
		self.db.realm[GuildName].RollingItem = nil
		self.db.realm[GuildName].IsRolling = nil
		--self.db.realm[GuildName].IsRollingRandomWinner = nil
		--self.db.realm[GuildName].IsRollingRandom = nil
	else 
		ThunderLoot:Print("No roll is active!")
	end
end
function ThunderLoot:RaidRoll()
	if(self.db.realm[GuildName].IsRolling or self.db.realm[GuildName].IsRollingRandomWinner or self.db.realm[GuildName].IsRollingRandom) then
		ThunderLoot:Print("Another roll is active!")
	else
		--local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, itemSellPrice = GetItemInfo(item)
		local raidnumbers = GetNumGroupMembers()
		if (raidnumbers == 0) then
			ThunderLoot:Print("You are not in a raid or a group!")
		else
			self.db.realm[GuildName].IsRollingRandom = true
			ThunderLoot:ChatPrint("---------------------")
			--if(itemLink ~= "")then
			--	ThunderLoot:ChatRWPrint("Loot: Starting Raid roll for "..itemLink)
			--else
				ThunderLoot:ChatRWPrint("Loot: Starting Raid roll!")
			--end
			ThunderLoot:ChatPrint("---------------------")
			RandomRoll(1, raidnumbers)
		end
	end
end
function ThunderLoot:sortRolls(rollTable,minRoll,maxRoll)
  local minRoll = (minRoll or 0)
  local maxRoll = (maxRoll or 100)
  local sortedByRank = {}
  for rollnr,rollData in pairs(rollTable) do
    if sortedByRank[rollData["RankPrio"]] == nil then
       sortedByRank[rollData["RankPrio"]] = {}
    end
    sortedByRank[rollData["RankPrio"]][rollData["Name"]] = {roll=rollData["Roll"],bonus=rollData["Bonus"]}
  end
  local output = {}
  for rankNumber,rankData in pairs(sortedByRank) do
    local rollTable = {}
    for name,roll in pairs(rankData) do
      if rollTable[roll.roll] == nil then
        rollTable[roll.roll] = {}
      end
      rollTable[roll.roll][#rollTable[roll.roll]+1] = {name,roll.bonus}
    end
	
	--ThunderLoot:Print(tablelength(rollTable))
    for i=minRoll,maxRoll,1 do
      if rollTable[i] ~= nil then
        for roll,name in pairs(rollTable[i]) do
          output[#output+1] = {Name=name[1],Roll=i,RankPrio=rankNumber,Bonus=name[2]}
        end
      end
    end
  end
  return output
end
function ThunderLoot:BonusHandler(name)
	name = string.gsub(name, "-" .. string.gsub(ServerName, " ", ""), "")
	--ThunderLoot:Print("DEBUG "..name)
	for i = 1, tablelength(self.db.realm[GuildName].Users) do
		if(self.db.realm[GuildName].Users[i].Name == name) then
			return {AP=self.db.realm[GuildName].Users[i].AP}
		end
	end
	
	return {AP = "0"}
end

-- Debug 
function ThunderLoot:TestRoll(times)
	self.db.realm[GuildName].Rolls["Randomplayer"] = {Name="Randomplayer", Roll=math.random(1,100), RollBonus=ThunderLoot:BonusHandler("Randomplayer")}
	for i = 1, times do
		local name=math.randomchoice(self.db.realm[GuildName].Users).Name
		ThunderLoot:Print("CHEAT: Adding "..name.." to the roll")
		self.db.realm[GuildName].Rolls[name] = {Name=name, Roll=math.random(1,100), RollBonus=ThunderLoot:BonusHandler(name)}
	end
end
function ThunderLoot:TestRollSame(times)
	local _rollNR = math.random(1,100)
	local _rollBunusNR = math.random(0,50)
	for i = 1, times do
		local name=math.randomchoice(self.db.realm[GuildName].Users).Name
		ThunderLoot:Print("CHEAT: Adding "..name.." to the roll")
		self.db.realm[GuildName].Rolls[name] = {Name=name, Roll=_rollNR, RollBonus={AP=_rollBunusNR}}
	end
end
function math.randomchoice(t) --Selects a random item from a table
    local keys = {}
    for key, value in pairs(t) do
        keys[#keys+1] = key --Store keys in another table
    end
    index = keys[math.random(1, #keys)]
    return t[index]
end

-- Chat handler
function ThunderLoot:CHAT_MSG_SYSTEM(arg1,arg2)
	if (string.match(arg2, "(.*) rolls (%d+) [(](%d+)-(%d+)[)]")) then
		local name, rolled, low, high = string.match(arg2, "(.*) rolls (%d+) [(](%d+)-(%d+)[)]")
		if (self.db.realm[GuildName].IsRollingRandom ~= nil and self.db.realm[GuildName].IsRollingRandom ~= false)then
			self.db.realm[GuildName].IsRollingRandom = false
			local Rname, Rrank, Rsubgroup, Rlevel, Rclass, RfileName, Rzone, Ronline, RisDead, Rrole, RisML, RcombatRole = GetRaidRosterInfo(rolled);
			RUname = ThunderLoot:GetUsername(Rname)

			if(RUname=="")then
				RUname = ("PUG")
			end
			
			ThunderLoot:ChatPrint("---------------------")
			if(Rname~=RUname)then
				ThunderLoot:ChatPrint("Loot: "..RUname.."("..Rname..") won the raid roll ("..rolled..")")
			else
				ThunderLoot:ChatPrint("Loot: "..Rname.." won the raid roll ("..rolled..")")
			end
			ThunderLoot:ChatPrint("---------------------")
		elseif (self.db.realm[GuildName].IsRolling ~= nil and self.db.realm[GuildName].IsRolling ~= false) then
			local Gname = ThunderLoot:GetUsername(name)
			--if(ThunderLoot:isInNotRoll(name)) then
				if (low=="1" and high=="100") then 
					if(self.db.realm[GuildName].Rolls[name]==nil) then 
						--local bonusList = ThunderLoot:BonusHandler(name)
						self.db.realm[GuildName].Rolls[name] = {Name=name, Roll=rolled, RollBonus=ThunderLoot:BonusHandler(name)}
						local _printstring=""
						if(name~=Gname)then
							_printstring = Gname.."("..name..") Rolled ("
						else
							_printstring = Gname.." Rolled ("
						end
						--ThunderLoot:Print(name.. " "..rolled)
						if(rolled+0==69) then
							ThunderLoot:ChatPrint(_printstring.."69). Tihi")
						elseif(rolled+0==1) then
							ThunderLoot:ChatPrint(_printstring.."1). Wow.. noob..")
						elseif(rolled+0==100) then
							ThunderLoot:ChatPrint(_printstring.."100). CHEATER'ish")
						elseif(rolled+0==34) then
							ThunderLoot:ChatPrint(_printstring.."34). Rule 34. No exceptions.")
						elseif(rolled+0==42) then
							ThunderLoot:ChatPrint(_printstring.."42). Thanks for all the fish.")
						end
					else
						if(name~=Gname)then
							ThunderLoot:ChatPrint("Loot: "..Gname.."("..name..") tried to cheat!")
						else
							ThunderLoot:ChatPrint("Loot: "..name.." tried to cheat!")
						end
					end
				else
					if(name~=Gname)then
						ThunderLoot:ChatPrint("Loot: "..Gname.."("..name..") tried to cheat!")
					else
						ThunderLoot:ChatPrint("Loot: "..name.." tried to cheat!")
					end
				end
			--else
			--	if(name~=Gname)then
			--		ThunderLoot:ChatPrint("Loot: "..Gname.."("..name..") tried to cheat!")
			--	else
			--		ThunderLoot:ChatPrint("Loot: "..name.." tried to cheat!")
			--	end
			--end
		elseif (self.db.realm[GuildName].IsRollingRandomWinner ~= nil and self.db.realm[GuildName].IsRollingRandomWinner ~= false) then
			local _i = 1
			for rname in pairs(self.db.realm[GuildName].RollWinner) do
				if(_i+0==rolled+0) then 
					ThunderLoot:ChatPrint("---------------------")
					if(self.db.realm[GuildName].RollWinner[rname]~=ThunderLoot:GetUsername(self.db.realm[GuildName].RollWinner[rname]))then
						ThunderLoot:ChatPrint("Loot: The winner was "..ThunderLoot:GetUsername(self.db.realm[GuildName].RollWinner[rname]).."("..self.db.realm[GuildName].RollWinner[rname]..")!!")
					else
						ThunderLoot:ChatPrint("Loot: The winner was "..self.db.realm[GuildName].RollWinner[rname].."!!")
					end
					ThunderLoot:ChatPrint("---------------------")
				end
				_i=_i+1
			end
			self.db.realm[GuildName].IsRollingRandomWinner = false
		else 
			--ThunderLoot:Print("Ignore "..name)
		end
	end
end
function ThunderLoot:isInNotRoll(name)
	if(tablelength(self.db.realm[GuildName].Rolls) > 0)	then
		if(self.db.realm[GuildName].Rolls[name] == nil) then	
			--ThunderLoot:Print("k1:"..k1)
			--if (k1==name)then
			return false
			--end
		else
			return true
		end
	else
		return true
	end
end

-- Commands
function ThunderLoot:TLCommands(input)
	if (string.len(input) > 0) then
		local commands={}
		for str in string.gmatch(input, "([^%s]+)") do
			table.insert(commands, str)
		end
		if(string.lower(commands[1]) == "config") then 
			ThunderLoot:OpenConfig()
		elseif(string.lower(commands[1]) == "menu") then 
			ThunderLoot:ToggleMainMenu()
		elseif(string.lower(commands[1]) == "bench") then 
			if(self.db.realm[GuildName].Raid.Ongoing ~= nil)then
				if (commands[2] ~= nil) then
					_Username = ThunderLoot:GetUsername(commands[2])
					if(_Username~="")then
						table.insert(self.db.realm[GuildName].Raid.RaidUsernamesBench, _Username)
						ThunderLoot:Print(_Username.." have been added to the raid's bench list")
					else
						ThunderLoot:Print("ERROR.. No Username found for " .. commands[2])
					end
				else
					ThunderLoot:Print("ERROR.. bench are used like:")
					ThunderLoot:Print("/tl bench CharacterName (adds a Character to the raid's bench list)")
				end
			else
				StaticPopup_Show("RAIDNOTONGOINGBENCH")
			end
		elseif(string.lower(commands[1]) == "attend") then 
			if(self.db.realm[GuildName].Raid.Ongoing ~= nil)then
				if (commands[2] ~= nil) then
					_Username = ThunderLoot:GetUsername(commands[2])
					if(_Username~="")then
						table.insert(self.db.realm[GuildName].Raid.RaidUsernames, _Username)
						ThunderLoot:Print(_Username.." have been added to the raid's attendance list")
					else
						ThunderLoot:Print("ERROR.. No Username found for " .. commands[2])
					end
				else
					ThunderLoot:Print("ERROR.. attend are used like:")
					ThunderLoot:Print("/tl attend CharacterName (adds a Character to the raid's attendance list)")
				end
			else
				StaticPopup_Show("RAIDNOTONGOINGATTEND")
			end
		elseif(string.lower(commands[1]) == "startraid") then 
			ThunderLoot:StartRaid()
		elseif(string.lower(commands[1]) == "stopraid") then 
			ThunderLoot:StopRaid()
		elseif(string.lower(commands[1]) == "roll") then 
			if (commands[2] ~= nil) then
				ThunderLoot:StartRoll(commands[2])
			else
				ThunderLoot:Print("ERROR.. rollstart are used like:")
				ThunderLoot:Print("/tl rollstart ItemLink (Starts a roll for an item)")
			end
		elseif(string.lower(commands[1]) == "rollnext") then 
			ThunderLoot:NextRoll()
		elseif(string.lower(commands[1]) == "stoproll") then 
			ThunderLoot:StopRoll()
		elseif(string.lower(commands[1]) == "raidroll") then 
			ThunderLoot:RaidRoll()
		elseif(string.lower(commands[1]) == "ap") then 
			ThunderLoot:Print("Your current AP is "..ThunderLoot:BonusHandler(GetUnitName("player")).AP.."!")
		elseif(string.lower(commands[1]) == "additem") then 
			if (commands[2] ~= nil) then
				ThunderLoot:Print(ThunderLoot:ItemAdd(commands[2]))
			else
				ThunderLoot:Print("ERROR.. additem are used like:")
				ThunderLoot:Print("/tl additem ItemLink (Adds an item to the database)")
			end
		elseif(string.lower(commands[1]) == "delitem") then 
			if (commands[2] ~= nil) then
				ThunderLoot:Print(ThunderLoot:ItemDel(commands[2]))
			else
				ThunderLoot:Print("ERROR.. delitem are used like:")
				ThunderLoot:Print("/tl delitem ItemLink (Removes an item from the database)")
			end
		-- DEBUG Command
		elseif(string.lower(commands[1]) == "test") then 
			ThunderLoot:Print("Start roll")
			ThunderLoot:StartRoll(17078)
		-- DEBUG Command
		elseif(string.lower(commands[1]) == "testroll") then 
			ThunderLoot:Print("Start test roll")
			if(commands[2]~=nil)then
				ThunderLoot:TestRoll(commands[2])
			else
				ThunderLoot:TestRoll(5)
			end
			ThunderLoot:StopRoll()
		-- DEBUG Command
		elseif(string.lower(commands[1]) == "testrollsame") then 
			ThunderLoot:Print("Start test roll")
			if(commands[2]~=nil)then
				ThunderLoot:TestRollSame(commands[2])
			else
				ThunderLoot:TestRollSame(2)
			end
			ThunderLoot:StopRoll()
		else 
			ThunderLoot:Print("ERROR.. Available commands:")
			ThunderLoot:Print("config (Opens and closes the config menu)")
			ThunderLoot:Print("menu (Opens and closes the main menu)")
			ThunderLoot:Print("startraid (Starts a new raid)")
			ThunderLoot:Print("stopraid (Ends the raid)")
			ThunderLoot:Print("bench CharacterName (adds a Character to the raid's bench list)")
			ThunderLoot:Print("attend CharacterName (adds a Character to the raid's attendance list)")
			ThunderLoot:Print("raidroll (Rolls a random group/raid member)")
			ThunderLoot:Print("roll ItemLink (Starts a roll for an item)")
			ThunderLoot:Print("nextroll (Sets the roll priority)")
			ThunderLoot:Print("stoproll (End the roll)")
			ThunderLoot:Print("ap (Shows your current AP)")
			ThunderLoot:Print("additem ItemLink (Adds an item to the database)")
			ThunderLoot:Print("delitem ItemLink (Removes an item from the database)")
		end
	else
		ThunderLoot:Print("Available commands:")
		ThunderLoot:Print("config (Opens and closes the config menu)")
		ThunderLoot:Print("menu (Opens and closes the main menu)")
		ThunderLoot:Print("startraid (Starts a new raid)")
		ThunderLoot:Print("stopraid (Ends the raid)")
		ThunderLoot:Print("bench CharacterName (adds a Character to the raid's bench list)")
		ThunderLoot:Print("attend CharacterName (adds a Character to the raid's attendance list)")
		ThunderLoot:Print("raidroll (Rolls a random group/raid member)")
		ThunderLoot:Print("roll ItemLink (Starts a roll for an item)")
		ThunderLoot:Print("nextroll (Sets the roll priority)")
		ThunderLoot:Print("stoproll (End the roll)")
		ThunderLoot:Print("ap (Shows your current AP)")
		ThunderLoot:Print("additem ItemLink (Adds an item to the database)")
		ThunderLoot:Print("delitem ItemLink (Removes an item from the database)")
	end
end
function ThunderLoot:CCommand(message, sender)
	if (string.lower(message)=="ap")then 
		SendChatMessage("User "..ThunderLoot:GetUsername(sender)..". Your current AP is "..ThunderLoot:BonusHandler(sender).AP.."!", "WHISPER", "Common", sender)
	end
end

-- Utils
function ThunderLoot:ChatPrint(chat)
	--ThunderLoot:Print(chat)
	if IsInRaid() then
		SendChatMessage(chat ,"RAID");
	else
		SendChatMessage(chat ,"PARTY");
		
	end
end
function ThunderLoot:ChatRWPrint(chat)
	if IsInRaid() then
		if(UnitIsGroupLeader("player") or UnitIsGroupAssistant("player")) then
			SendChatMessage(chat ,"RAID_WARNING")
			--ThunderLoot:ChatPrint(chat)
		else
			ThunderLoot:ChatPrint(chat)
		end
	else
		ThunderLoot:ChatPrint(chat)
	end
end
function VersionCheck()
	-- Checks the game version
	local _, _, _, _AddonGameVersion = GetBuildInfo()
	if (_AddonGameVersion..""~=AddonGameVersion.."") then
		ThunderLoot:Print("Game version: ".._AddonGameVersion)
		ThunderLoot:Print("Game version: "..AddonGameVersion)
		StaticPopup_Show("WRONGADDONGAME")
		return false
	end
	
	local _version="0.0"
	local _APBonus="5"
	local _APMax="50"
	-- Checks if the User have permissions to read and edit officernotes
	
	--local _GName = GetGuildInfo("player")
	--if (_GName == guildname) then
	if (CanEditOfficerNote() and CanViewOfficerNote()) then
		local numTotalMembers, numOnlineMaxLevelMembers, numOnlineMembers = GetNumGuildMembers();
		while (numTotalMembers > 0) do
			local Gname, Grank, GrankIndex, Glevel, Gclass, Gzone, Gnote, Gofficernote, Gonline, Gstatus, GclassFileName, GachievementPoints, GachievementRank, GisMobile, GisSoREligible, GstandingID = GetGuildRosterInfo(numTotalMembers)
			Gname = string.gsub(Gname, "-" .. string.gsub(ServerName, " ", ""), "")
			
			if(Gname==ThunderLoot.db.realm[GuildName].AddonGuildVars)then
				local officernoteList = {}
				if(Gofficernote~=nil and Gofficernote~="")then
					for word in string.gmatch(Gofficernote, "([^,]+)") do
						table.insert(officernoteList, word)
					end
				end
				
				
				if(tablelength(officernoteList) ~= 4)then
					GuildRosterSetOfficerNote(numTotalMembers, "TLV,"..AddonVersion..","..ThunderLoot.db.realm[GuildName].APBonus..","..ThunderLoot.db.realm[GuildName].APMax)
					ThunderLoot:Print("Character \"" .. Gname .. "\" have been reset in the Officernote database!")
				else 
					if(officernoteList[1]~="TLV")then 
						GuildRosterSetOfficerNote(numTotalMembers, "TLV,"..AddonVersion..","..ThunderLoot.db.realm[GuildName].APBonus..","..ThunderLoot.db.realm[GuildName].APMax)
						ThunderLoot:Print("Character \"" .. Gname .. "\" have been reset in the Officernote database!")
					else
						_version=officernoteList[2]
						_APBonus=officernoteList[3]
						_APMax=officernoteList[4]
					end
				end
				if(AddonVersion+0<_version+0) then
					ThunderLoot:Print("Addon version is too old!")
					ThunderLoot:Print("Latest version is ".._version.."!")
					ThunderLoot:Print("UPDATE!")
					StaticPopup_Show("UPDATEADDON")
				elseif(AddonVersion+0>_version+0) then
					GuildRosterSetOfficerNote(numTotalMembers, "TLV,"..AddonVersion..","..ThunderLoot.db.realm[GuildName].APBonus..","..ThunderLoot.db.realm[GuildName].APMax)
					ThunderLoot:Print("Addon version is newer than the guild database! Database updated")
					ThunderLoot.db.realm[GuildName].APBonus = _APBonus
					ThunderLoot.db.realm[GuildName].APMax = _APMax
					return true
				else
					ThunderLoot.db.realm[GuildName].APBonus = _APBonus
					ThunderLoot.db.realm[GuildName].APMax = _APMax
					return true
				end
			else
				--ThunderLoot:Print(Gname.." is not "..ThunderLoot.db.realm[GuildName].AddonGuildVars)
			end
			numTotalMembers=numTotalMembers-1
		end
		return false
	else
		ThunderLoot:Print("Can't edit/view officer notes")
		ThunderLoot:Print("Disable the addon!")
		StaticPopup_Show("WRONGUSERADDONNOTE")
		return false
	end
end
function UpdateDBAP( _AP )
	local numTotalMembers, numOnlineMaxLevelMembers, numOnlineMembers = GetNumGuildMembers();
	while (numTotalMembers > 0) do
		local Gname, Grank, GrankIndex, Glevel, Gclass, Gzone, Gnote, Gofficernote, Gonline, Gstatus, GclassFileName, GachievementPoints, GachievementRank, GisMobile, GisSoREligible, GstandingID = GetGuildRosterInfo(numTotalMembers)
		Gname = string.gsub(Gname, "-" .. string.gsub(ServerName, " ", ""), "")
		if(Gname==self.db.realm[GuildName].AddonGuildVars)then
			GuildRosterSetOfficerNote(numTotalMembers, "TLV,"..AddonVersion..",".._AP)
			self.db.realm[GuildName].APBonus = _AP
			return
		end
		numTotalMembers=numTotalMembers-1
	end
	Warning(AddonName.."\n\nDatabase guildmember "..self.db.realm[GuildName].AddonGuildVars.." not found!", "Ok", (function() end))
end
function tablelength(T)
    local count = 0
    if (T==nil or T == {}) then 
        return 0
    end
    for _ in pairs(T) do count = count + 1 end
    return count
end
function tableContains(set, key)
	for i=1,tablelength(set) do
		if (set[i]==key)then
			return true
		end
	end

    return false
end
function ThunderLoot:LoadDatabase()
	
	if (self.db.realm[GuildName].APMax ~= nil) then
		if (tonumber(self.db.realm[GuildName].APMax)~=nil)then
		else
			self.db.realm[GuildName].APMax = 50
		end
	else
		self.db.realm[GuildName].APMax = 50
	end

	if (self.db.realm[GuildName].APBonus ~= nil) then
		if (tonumber(self.db.realm[GuildName].APBonus)~=nil)then
		else
			self.db.realm[GuildName].APBonus = 5
		end
	else
		self.db.realm[GuildName].APBonus = 5
	end
	if (self.db.realm[GuildName].GuildRanks == nil) then
		self.db.realm[GuildName].GuildRanks = {}
	end
	

	if (self.db.realm[GuildName].IsRolling == nil) then
		self.db.realm[GuildName].IsRolling = false
	end
	if (self.db.realm[GuildName].IsRollingRandomWinner == nil) then
		self.db.realm[GuildName].IsRollingRandomWinner = false
	end
	if (self.db.realm[GuildName].IsRollingRandom == nil) then
		self.db.realm[GuildName].IsRollingRandom = false
	end

	if (self.db.realm[GuildName].Specs == nil) then
		self.db.realm[GuildName].Specs = {}
		self.db.realm[GuildName].Specs[0] = "Note"
		self.db.realm[GuildName].Specs[1] = "BiSMain"
		self.db.realm[GuildName].Specs[2] = "MainSpec"
		self.db.realm[GuildName].Specs[3] = "OffSpec"
	end

	if (self.db.realm[GuildName].AddonGuildVars == nil) then
		ThunderLoot:OpenConfig()
	else
		ThunderLoot:RefreshGuildList()
	end
end
function ThunderLoot:RefreshGuildList()
	--_list = {}
	self.db.realm[GuildName].Users = {}
	local numTotalMembers, numOnlineMaxLevelMembers, numOnlineMembers = GetNumGuildMembers();
	while (numTotalMembers > 0) do
		local Gname, Grank, GrankIndex, Glevel, Gclass, Gzone, Gnote, Gofficernote, Gonline, Gstatus, GclassFileName, GachievementPoints, GachievementRank, GisMobile, GisSoREligible, GstandingID = GetGuildRosterInfo(numTotalMembers)
		Gname = string.gsub(Gname, "-" .. string.gsub(ServerName, " ", ""), "")
		if(self.db.realm[GuildName].GuildRanks[Grank] == nil)then
			self.db.realm[GuildName].GuildRanks[Grank] = {Rank=Grank, LootPrio=0}
		end
		--table.insert(_list, Gname)
		local officernoteList = {}
		if(Gofficernote~=nil and Gofficernote~="")then
			for word in string.gmatch(Gofficernote, "([^,]+)") do
				table.insert(officernoteList, word)
			end
		end
		if(officernoteList[1]=="TL")then 
			table.insert(self.db.realm[GuildName].Users, {Name=Gname, Note=Gofficernote, Rank=Grank, Username=officernoteList[2], Raids=officernoteList[3], AP=officernoteList[5]})
		
			--if(self.db.realm[GuildName].UserNames[officernoteList[2]] == nil) then
			--	table.insert(self.db.realm[GuildName].UserNames[officernoteList[2]], {Name=Gname, Rank=Grank, Raids=raid=officernoteList[3], AP=officernoteList[5]})
			--end
		else
			table.insert(self.db.realm[GuildName].Users, {Name=Gname, Note=Gofficernote, Rank=Grank, Username=nil, Raids=nil, AP=nil})
		end


		numTotalMembers=numTotalMembers-1
	end
	--return _list
end
function ThunderLoot:CountSpecs()
	return tablelength(self.db.realm[GuildName].Specs)
end