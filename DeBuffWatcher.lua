local in_combat = false
local countdown = 0
local timeStamp = 0
local raid = false


function create_ui()
    if not DeBuffWatcher_config then
        DeBuffWatcher_config = {
            ["x"] = 500,
            ["y"] = 500,
            ["font"] = 12,
            ["background"] = 50,
            ["seconds"] = 420,
            ["only_me"] = false
        }
    end
    context = UI.CreateContext("DeBuffWatcher_frame")
    DeBuffWatcher_frame = UI.CreateFrame('Text', 'UIParent', context )
    DeBuffWatcher_frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", DeBuffWatcher_config["x"], DeBuffWatcher_config["y"])
    DeBuffWatcher_frame:SetFontSize(DeBuffWatcher_config["font"])

    DeBuffWatcher_frame:EventAttach(Event.UI.Input.Mouse.Left.Down, function(self, h)
        self.MouseDown = true
        local mouseData = Inspect.Mouse()
        self.sx = mouseData.x - DeBuffWatcher_frame:GetLeft()
        self.sy = mouseData.y - DeBuffWatcher_frame:GetTop()
    end, "Event.UI.Input.Mouse.Left.Down")

    DeBuffWatcher_frame:EventAttach(Event.UI.Input.Mouse.Cursor.Move, function(self, h)
        if self.MouseDown then
            local nx, ny
            local mouseData = Inspect.Mouse()
            nx = mouseData.x - self.sx
            ny = mouseData.y - self.sy
            DeBuffWatcher_frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", nx,ny)
        end
    end, "Event.UI.Input.Mouse.Cursor.Move")

    DeBuffWatcher_frame:EventAttach(Event.UI.Input.Mouse.Left.Up, function(self, h)
        if self.MouseDown then
            self.MouseDown = false
        end
        DeBuffWatcher_config["x"] = DeBuffWatcher_frame:GetLeft()
        DeBuffWatcher_config["y"] = DeBuffWatcher_frame:GetTop()
    end, "Event.UI.Input.Mouse.Left.Up")

    DeBuffWatcher_frame:EventAttach(Event.UI.Input.Mouse.Right.Up, function(self, h)
        if self.MouseDown then
            self.MouseDown = false
        end
        countdown = 0
        DeBuffWatcher_frame:SetVisible(false)
    end, "Event.UI.Input.Mouse.Right.Up")
end


local function check_target(target)
    local mystic = true
    local Increased_Physical_Damage_Taken = false
    local Increased_Nonphysical_Damage_Taken_1 = false
    local Increased_Nonphysical_Damage_Taken_2 = false
    local Damage_Buff_1 = false
    local Damage_Buff_Mystic_1 = false
    local Damage_Buff_Mystic_2 = false
    local AP_SP_Buff_2 = false
    local Crit_Chance_Buff = false
    local Crit_Chance_Buff_3 = false
    local Stat_Buff_1 = false
    local Stat_Buff_2 = false
    local Stat_Buff_3 = false
    local Stat_Buff_Mystic = false
    local Endurance_Buff_1 = false
    local Endurance_Buff_2 = false
    local Armor_Resistance_Buff = false
    local Reduced_Damage_Taken_1 = false
    local Healing_Received_Buff_1 = false
    local buffs = Inspect.Buff.List(target)
    local missing_debuffs = ""
    if buffs then
        for buffid, typeid in pairs(buffs) do
            local detail = Inspect.Buff.Detail(target, buffid)
            if detail and detail.type then
                if target == "player.target" then
                    if detail.type == "B5085DB9C5B1F666A" or detail.type == "B6586D0E97741AF9E" or detail.type == "B6BA1ADFD5A93F825" or detail.type == "BFA139B4FA150A7DA" or detail.type == "BFDFF85B646DAA2EA"  then -- Increases Physical damage taken by 5% (Archon: Ashen Defense, Cleric: Curse of Frailty, Bard: Coda of Cowardice, Beastmaster: Twin Cuts, Mystic: Hurricane Breach)
                        Increased_Physical_Damage_Taken = true
                    end
                    if detail.type == "B7E3F5A42867CB671" or detail.type == "B6E2FAAA28AC69397" or detail.type == "B28FB2E2C8B594765" or detail.type == "BFA139B4FA150A7DA" or detail.type == "BFDFF85B646DAA2EA" then -- Increases non-Physical damage taken by 7%. (Archon: Crumbling Resistance, Oracel: Curse of Consumption, Bard: Coda of Distress, Beastmaster: Twin Cuts, Mystic: Hurricane Breach)
                        Increased_Nonphysical_Damage_Taken_1 = true
                    end
                    if detail.type == "B491E02360D5FB16B" or detail.type == "B58C8F3A95CAE1CFA" or detail.type == "B1C94A46AE6BD5813" then -- Increases non-Physical damage taken by 5%. (Defiler: Tenebrious Distortion, Inquisitor: Clinging Spirit, Vulcanist: Slagged)
                        Increased_Nonphysical_Damage_Taken_2 = true
                    end
                elseif target == "player" then
                    if detail.type == "B40B9609C0DF37AF1" or detail.type == "BFD4F3DEDCF4401E7" or detail.type == "B02F72F8374F5ACB7" then -- Increases damage done by 5% (Archon: Volcanic Bomb, Beastmaster: Call of Savagery, Mystic: Call of Savagery)
                        Damage_Buff_1 = true
                    end
                    if detail.type == "B54E7963BB7F26353" then -- Increases damage done by 5% (Mystic: Primal Savagery)
                        Damage_Buff_Mystic_1 = true
                    end
                    if detail.type == "B3789B303AAC4EED9" or detail.type == "BFBA778B2D2CEE7B1" or detail.type == "B1262F33677492EDD" then -- 5% Crit Chance (Archon: Earthen Barrage,Beasmaster: Call of Blood, Mystic: Precise Target)
                        Crit_Chance_Buff = true
                    end
                    if detail.type == "B75CF79A3A7B75E32" or detail.type == "Inspiration of Battle" then -- +5% Str/Dex/Int/Wis/End  (Bard: Motif of Bravery, Oracel: Inspiration of Battle)
                        Crit_Chance_Buff_3 = true
                    end
                    if detail.type == "B798CF51711D54B71" or detail.type == "B0E9C7498E1524C2B" then -- +5% Str/Dex/Int/Wis/End  (Oracel: Vitale Inspiration, Bard: Resonance)
                        Stat_Buff_2 = true
                    end
                    if detail.type == "BFB94CE4EDD7620E2" or detail.type == "B75CF79A3A7B75E32" or detail.type == "B44E09C3BAC84FAF8" or detail.type == "B40BA5956C492EA27" then --  Ap Sp Buff (Archon: Granite Salvo,  Bard: Motif of Bravery, Oracel: Inspiration of Battle, Mystic: Aerial Boon)
                        AP_SP_Buff_2 = true
                    end
--                    if detail.type == "B40BA5956C492EA27" or detail.type == "B44E09C3BAC84FAF8" then -- Ap Sp Str Dex Int Wis (Mystic: Aerial Boon, Oracel: Inspiration of Battle overwrite Ariel Boom)
--                        Stat_Buff_Mystic = true
--                    end
                    if detail.type == "B51B584CC19F8B2C4" or detail.type == "B72AED2881E9C8CD7" then -- Increases Strength, Dexterity, Intelligence, and Wisdom (Archon: Vitality of Stone, Beastmaster: Bond of Power)
                        Stat_Buff_1 = true
                    end
                    if detail.type == "B5F75E0061F5806B1" or detail.type == "B3007E29CF12D03AC" then -- Str Dex Int Wis  (Bard: Fanfare of Power, Oracel: Boon of Resurgence)
                        Stat_Buff_3 = true
                    end
                    if detail.type == "B62F881BBF0FCCD2C" or detail.type == "B4F0EF3B2483B48F7" then -- Endurance (Bard: Fanfare of Vigor, Orcael: Boon of Vitality)
                        Endurance_Buff_1 = true
                    end
                    if detail.type == "B023CD8D851AD339D" then -- Endurance (Archon: Shared Vigor)
                        Endurance_Buff_2 = true
                    end
                    if detail.type == "B65677DAB403EB0C9" or detail.type == "B2B02AF47B53C21FC" or detail.type == "BFBB53A78D37A5FC9" or detail.type == "B652E7F8D09C92616" or detail.type == "B6DDCD00446FC9FFA" then -- Armor Resi (Archon: Arcane Aegis, Bard; Anthem of Glory, Beastmaster: Bond of Shelter, Oracel: Defensive Favor, Mystic: living armor)
                        Armor_Resistance_Buff = true
                    end
                    if detail.type == "B60F47F310B4793F6" or detail.type == "BFB1E91C33E5F87CC" or detail.type == "B13FEC95AAB509ADD" then -- Damage Reduce (Bard: Motif of Tenacity, Bm: Call of Stone, Oracel: Inspiration of the Keep)
                        Reduced_Damage_Taken_1 = true
                    end
                    if detail.type == "B0FA41E09E7A89F58" or detail.type == "BFC309907EA2F0FBB" then -- Increase Healing (Bard: Motif of Regeneration, Oracel: Inspiration of Survival)
                        Healing_Received_Buff_1 = true
                    end
                end
            end
        end
        if target == "player.target" then
            if Increased_Physical_Damage_Taken == false then
                missing_debuffs = " 5% Physical (Support) \n"
            end
            if Increased_Nonphysical_Damage_Taken_1 == false then
                missing_debuffs = missing_debuffs .. " 7% Magical (Support) \n"
            end
            if Increased_Nonphysical_Damage_Taken_2 == false then
                missing_debuffs = missing_debuffs .. " 5% Magical (Cleric Vulcanist) \n"
            end
        elseif target == "player" then
            if mystic == true then
--                if Damage_Buff_Mystic_2 == false then
--                    missing_debuffs = missing_debuffs .. " 12 % Damage (Mystic) \n"
--                end
                if Damage_Buff_Mystic_1 == false then
                    missing_debuffs = missing_debuffs .. " 5 % Damage (Mystic) \n"
                end
            end
            if Damage_Buff_1 == false then
                missing_debuffs = missing_debuffs .. " 5 % Damage (Archon Bm Mystic) \n"
            end
            if Crit_Chance_Buff == false then
                missing_debuffs = missing_debuffs .. " 5% Crit Chance (Archon Bm Mystic) \n"
            end
            if Reduced_Damage_Taken_1 == false then
                missing_debuffs = missing_debuffs .. " 5 % Damage Reduce (Bard Bm Oracel) \n"
            end
            if Healing_Received_Buff_1 == false then
                missing_debuffs = missing_debuffs .. " 5 % Increase Healing (Bard Oracel) \n"
            end
            if Stat_Buff_2 == false then
                missing_debuffs = missing_debuffs .. " 5% Mainstats (Bard Oracel) \n"
            end
            if Crit_Chance_Buff_3 == false then
                missing_debuffs = missing_debuffs .. " 1% Crit Chance (Bard Oracel) \n"
            end
            if AP_SP_Buff_2 == false then
                missing_debuffs = missing_debuffs .. " Ap Sp (Archon Bard Oracel Mytic) \n"
            end
--            if Stat_Buff_Mystic == false then
--                missing_debuffs = missing_debuffs .. " Ap Sp Str Dex Int Wis (Mystic) \n"
--            end
            if Stat_Buff_1 == false then
                missing_debuffs = missing_debuffs .. " Str Dex Int Wis (Archon Bm) \n"
            end
            if Stat_Buff_3 == false then
                missing_debuffs = missing_debuffs .. " Str Dex Int Wis (Bard Oracel) \n"
            end
            if Endurance_Buff_1 == false then
                missing_debuffs = missing_debuffs .. " Endurance (Bard Oracel) \n"
            end
            if Endurance_Buff_2 == false then
                missing_debuffs = missing_debuffs .. " Endurance (Archon) \n"
            end
            if Armor_Resistance_Buff == false then
                missing_debuffs = missing_debuffs .. " Armor Resi (Support) \n"
            end
        end
    end
    return missing_debuffs
end


local function in_combat_DeBuffWatcher()
    local textbox = ""
    local missing_debuffs = check_target("player.target")
    local missing_buffs = check_target("player")
    if missing_debuffs ~= "" then
        textbox = " Missing Debuffs: \n" .. missing_debuffs
    end
    if missing_buffs ~= "" then
        if missing_debuffs ~= "" then
            textbox = textbox .. "\n"
        end
        textbox = textbox .. " Missing Buffs: \n" .. missing_buffs
    end
    if textbox ~= "" then
        DeBuffWatcher_frame:SetText(textbox)
        DeBuffWatcher_frame:SetVisible(true)
    else
        DeBuffWatcher_frame:SetVisible(false)
    end
end


local function DeBuffWatcher()
    if in_combat == false then
        local eternal_mage = false
        local eternal_cleric = false
        local eternal_rogue = false
        local eternal_warrior = false
        local eternal_primalist = false
        local eternal_mage_duration = 0
        local eternal_cleric_duration = 0
        local eternal_rogue_duration = 0
        local eternal_warrior_duration = 0
        local eternal_primalist_duration = 0
        local mage = false
        local cleric = false
        local rogue = false
        local warrior = false
        local primalist = false
        local groupmember = ""
        local names = ""
        local buff_count = 0
        local mins = 0
        local secs = 0
        local group = false
        local playercount = 0
        for i=1, 21 do
            local flask = false
            local weaponstone = false
            local food = false
            local flask_duration = 0
            local weaponstone_duration = 0
            local food_duration = 0
            local groupmember = string.format("group%02d", i)
            local player = Inspect.Unit.Detail(groupmember)
            local myplayer = Inspect.Unit.Detail("player")
            local buffs = nil
            if group == false and i == 21 then
                groupmember = "player"
                player = Inspect.Unit.Detail(groupmember)
            end
            if player then
                playercount = playercount + 1
                group = true
                if player.calling == "mage" then
                    mage = true
                elseif player.calling == "cleric" then
                    cleric = true
                elseif player.calling == "rogue" then
                    rogue = true
                elseif player.calling == "warrior" then
                    warrior = true
                elseif player.calling == "primalist" then
                    primalist = true
                end
            end
            if player and DeBuffWatcher_config["only_me"] == true then
                if player.id == myplayer.id then
                    buffs = Inspect.Buff.List("player")
                end
            else
                buffs = Inspect.Buff.List(groupmember)
            end
            if buffs and player then
                if player.role ~= "tank" then
                    for buffid, typeid in pairs(buffs) do
                        local detail = Inspect.Buff.Detail(groupmember, buffid)
                        if detail and player then
                            if detail.rune then
                                if player.calling == "mage" or player.calling == "cleric" then
                                    if detail.rune == "r143A1D7A79A201D6" then -- Faetouched Powerstone = r143A1D7A79A201D6
                                        if detail.remaining > tonumber(DeBuffWatcher_config["seconds"]) then
                                            weaponstone = true
                                        end
                                        if detail.remaining > 0 then
                                            weaponstone_duration = detail.remaining
                                        end
                                    end
                                else
                                    if detail.rune == "rFA65F5184E42C822" or detail.rune == "r70B0A3843EC153B8" then -- Atramentium Whetstone = rFA65F5184E42C822, Atramentium Oilstone = r70B0A3843EC153B8
                                        if detail.remaining > tonumber(DeBuffWatcher_config["seconds"]) then
                                            weaponstone = true
                                        end
                                        if detail.remaining > 0 then
                                            weaponstone_duration = detail.remaining
                                        end
                                    end
                                end
                            end
                            if detail.type then
                                if detail.type == "B5161AA0023BAEFD1" then -- Spirit of the Arcane Mage
                                    if detail.remaining > tonumber(DeBuffWatcher_config["seconds"]) then
                                        eternal_mage = true
                                    end
                                end
                                if detail.type == "B1A7C914C6A849564" then -- Spirit of Divinity
                                    if detail.remaining > tonumber(DeBuffWatcher_config["seconds"]) then
                                        eternal_cleric = true
                                    end
                                end
                                if detail.type == "B5E5E107B687FEDAA" then -- Spirit of the Shadows
                                    if detail.remaining > tonumber(DeBuffWatcher_config["seconds"]) then
                                        eternal_rogue = true
                                    end
                                end
                                if detail.type == "B0EF28442078DA6CD" then -- Spirit of Arms
                                    if detail.remaining > tonumber(DeBuffWatcher_config["seconds"]) then
                                        eternal_warrior = true
                                    end
                                end
                                if detail.type == "B1CD787B134A73183" then -- Spirit of the Wilds
                                    if detail.remaining > tonumber(DeBuffWatcher_config["seconds"]) then
                                        eternal_primalist = true
                                    end
                                end
                                if player.calling == "mage" or player.calling == "cleric" then
                                    if detail.type == "B76F46FAA030D4A53" or detail.type == "B599B39124D958B4F" then --  Visionary Brightsurge Vial = B76F46FAA030D4A53, Prophetic Brightsurge Vial = B599B39124D958B4F
                                        if detail.remaining > tonumber(DeBuffWatcher_config["seconds"]) then
                                            flask = true
                                        end
                                        if detail.remaining > 0 then
                                            flask_duration = detail.remaining
                                        end
                                    end
                                    if detail.type == "B40C3D8E1646C6DD1" then --  Gedlo Curry Pot (SP) = B40C3D8E2646C6DD1
                                        if detail.remaining > tonumber(DeBuffWatcher_config["seconds"]) then
                                            food = true
                                        end
                                        if detail.remaining > 0 then
                                            food_duration = detail.remaining
                                        end
                                    end
                                else
                                    if detail.type == "B6A8C5F8010D4EFBB" or detail.type == "B03ABEAB575CC9A8E" then --  Visionary Powersurge Vial = B6A8C5F8110D4EFBB, Prophetic Powersurge Vial = B03ABEAB575CC9A8E
                                        if detail.remaining > tonumber(DeBuffWatcher_config["seconds"]) then
                                            flask = true
                                        end
                                        if detail.remaining > 0 then
                                            flask_duration = detail.remaining
                                        end
                                    end
                                    if detail.type == "B40C3D8E33D686C51" then --  Gedlo Curry Pot (AP) = B40C3D8E43D686C51
                                        if detail.remaining > tonumber(DeBuffWatcher_config["seconds"]) then
                                            food = true
                                        end
                                        if detail.remaining > 0 then
                                            food_duration = detail.remaining
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
                local playersplit = ""
                if weaponstone == false or flask == false  or food == false then
                    for x in string.gmatch(player.name, '([^@]+)') do
                        playersplit = x
                        break
                    end
                    names = names .." " .. playersplit .. " - "
                    if weaponstone == false then
                        names = names .. "Weapon"
                        if weaponstone_duration > 0 then
                            weaponstone_duration = math.ceil(weaponstone_duration)
                            mins = string.format("%02.f", math.floor(weaponstone_duration/60))
                            secs = string.format("%02.f", math.floor(weaponstone_duration - mins *60))
                            names = names .. "[" .. (mins .. ":" .. secs) .. "] "
                        else
                            names = names .. " "
                        end
                    end
                    if flask == false then
                        names = names .. "Flask"
                        if flask_duration > 0 then
                            flask_duration = math.ceil(flask_duration)
                            mins = string.format("%02.f", math.floor(flask_duration/60))
                            secs = string.format("%02.f", math.floor(flask_duration - mins *60))
                            names = names .. "[" .. (mins .. ":" .. secs) .. "] "
                        else
                            names = names .. " "
                        end
                    end
                    if food == false then
                        names = names .. "Food "
                        if food_duration > 0 then
                            food_duration = math.ceil(food_duration)
                            mins = string.format("%02.f", math.floor(food_duration/60))
                            secs = string.format("%02.f", math.floor(food_duration - mins *60))
                            names = names .. "[" .. (mins .. ":" .. secs) .. "] "
                        else
                            names = names .. " "
                        end
                    end
                    if (mage == true and eternal_mage == false) or (cleric == true and eternal_cleric == false) or (rogue == true and eternal_rogue == false) or (warrior == true and eternal_warrior == false) or (primalist == true and eternal_primalist == false) then
                        names = (names .. "Eternal: ")
                        if rogue == true and eternal_rogue == false then
                            names = (names .. "R ")
                        end
                        if primalist == true and eternal_primalist == false then
                            names = (names .. "P ")
                        end
                        if mage == true and eternal_mage == false then
                            names = (names .. "M ")
                        end
                        if cleric == true and eternal_cleric == false then
                            names = (names .. "C ")
                        end
                        if warrior == true and eternal_warrior == false then
                            names = (names .. "W ")
                        end
                    end
                    names = names .. "\n"
                end
            end
        end
        if playercount > 5 then
            raid = true
        else
            raid = false
        end
        if names == "" then
            DeBuffWatcher_frame:SetVisible(false)
        else
            names = " Missing Buffs: \n" .. names
            DeBuffWatcher_frame:SetText(names)
            DeBuffWatcher_frame:SetVisible(true)
            DeBuffWatcher_frame:SetBackgroundColor(0,0,0,DeBuffWatcher_config["background"]/100)
            if countdown == 0 then
                countdown = Inspect.Time.Real() + 120 -- Time in seconds until the buff window disappears
            end
        end
    end
end


local function DeBuffWatcher_update()
    if in_combat == false and countdown > 0 and (Inspect.Time.Real() - timeStamp) > 2 then
        timeStamp = Inspect.Time.Real()
        if (countdown - Inspect.Time.Frame()) > -0.5 then
            DeBuffWatcher()
        else
            DeBuffWatcher_frame:SetVisible(false)
            countdown = 0
        end
    elseif in_combat and raid == true and (Inspect.Time.Real() - timeStamp) > 1 then
        timeStamp = Inspect.Time.Real()
        in_combat_DeBuffWatcher()
    end
end


local function Ready_Check(event, units)
    local unit_details = Inspect.Unit.Detail(units)
    local player = Inspect.Unit.Detail("player")
    if unit_details and player then
        for id, detail in pairs(unit_details) do
            if detail.id == player.id then
                if detail.ready then
                    DeBuffWatcher()
                end
            end
        end
    end
end


local function Event_Addon_SavedVariables_Load_End()
    if DeBuffWatcher_config then
        create_ui()
    else
        create_ui()
        DeBuffWatcher()
    end
end


function CombatEnter()
    in_combat = true
    countdown = 0
    DeBuffWatcher_frame:SetBackgroundColor(0,0,0,DeBuffWatcher_config["background"]/100)
    DeBuffWatcher_frame:SetVisible(false)
end


function CombatLeave()
    in_combat = false
    countdown = 0
    DeBuffWatcher_frame:SetVisible(false)
end


function slashHandler(h, args)
	if args:find("check") then
        DeBuffWatcher()
	elseif args:find("font") then
		local size
		local pos = args:find("=")
		if pos then
			size = args:sub(pos+1)
			if tonumber(size) and tonumber(size) > 0 then
				DeBuffWatcher_config["font"] = tonumber(size)
                DeBuffWatcher_frame:SetFontSize(tonumber(size))
                DeBuffWatcher()
			end
        end
	elseif args:find("bg") then
		local transparency
		local pos = args:find("=")
		if pos then
			transparency = args:sub(pos+1)
			if tonumber(transparency) and tonumber(transparency) >= 0 and tonumber(transparency) <= 100 then
				DeBuffWatcher_config["background"] = tonumber(transparency)
                DeBuffWatcher()
			end
        end
	elseif args:find("seconds") then
		local seconds
		local pos = args:find("=")
		if pos then
			transparency = args:sub(pos+1)
			if tonumber(seconds) and tonumber(seconds) >= 0 and tonumber(seconds) <= 600 then
				DeBuffWatcher_config["seconds"] = tonumber(seconds)
                print("seconds = " .. tonumber(seconds))
			end
        end
	elseif args:find("me") then
		if DeBuffWatcher_config["only_me"] == false then
            DeBuffWatcher_config["only_me"] = true
            print("Check only me")
        else
            DeBuffWatcher_config["only_me"] = false
            print("Check the whole raid")
        end
	elseif args:find("reset") then
        DeBuffWatcher_config = {
            ["x"] = 500,
            ["y"] = 500,
            ["font"] = 12,
            ["background"] = 50,
            ["seconds"] = 300,
            ["only_me"] = 0
        }
        DeBuffWatcher_frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 500, 500)
        DeBuffWatcher_frame:SetFontSize(12)
        DeBuffWatcher_frame:SetBackgroundColor(0,0,0,0.5)
        DeBuffWatcher()
    else
        print("/dbw check - start raid buff check")
        print("/dbw me - monitor only my buffs (switch on/off default is off)")
		print("/dbw font=X - to change font size (default=12)")
		print("/dbw background=X - to change background transparency (X = 0 - 100)")
        print("/dbw seconds=X - Remaining time of the buffs until a warning occurs in seconds(X = 0 - 600)")
        print("/dbw reset - restore the default settings")
	end
end


Command.Event.Attach(Event.Addon.SavedVariables.Load.End, Event_Addon_SavedVariables_Load_End, "Event.Addon.SavedVariables.Load.End")
Command.Event.Attach(Event.Unit.Detail.Ready, Ready_Check, "DeBuffWatcher")
Command.Event.Attach(Command.Slash.Register("dbw"), slashHandler, "dbw_slashHandler")
Command.Event.Attach(Event.System.Secure.Enter, CombatEnter, "CombatEnter")
Command.Event.Attach(Event.System.Secure.Leave, CombatLeave, "CombatLeave")
Command.Event.Attach(Event.System.Update.Begin, DeBuffWatcher_update, "DeBuffWatcher_update update")
