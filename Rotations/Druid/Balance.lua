local DMW = DMW
local Druid = DMW.Rotations.DRUID
local Player, Buff, Debuff, Spell, Target, GCD, HUD, Talent, Item
local Player45Y, Player45YC, targets8, targets8count, Friends40Y, Friends40YC

local UI = DMW.UI
local Rotation = DMW.Helpers.Rotation
local wrathCount, starfireCount, eclipse_next, current_eclipse, spellCasting, eclipse_in
local Setting = DMW.Helpers.Rotation.Setting

local function CreateSettings()
    if not UI.HUD.Options then
        UI.HUD.Options = {}
        UI.HUD.Options[1] = {
            Cleanse = {
                [1] = { Text = "Cleanse", Tooltip = "" },
                [2] = { Text = "|cFFFFFF00Dont cleanse", Tooltip = "" },
            }
        }
        UI.AddTab("General")
        --    UI.AddBlank(false)
        UI.AddToggle("TEST", nil, false)
        UI.AddToggle("ROOT", nil, false)
        UI.AddToggle("Auto Soothe", nil, false)
        UI.AddRange("Soothe TTD", nil, 0, 30, 1, 50, false)
        UI.AddToggle("Rebirth Mouseover", nil, true)
        UI.AddBlank(false)
        UI.AddToggle("Auto Sprint")
        UI.AddToggle("Auto Prowl")
        UI.AddToggle("Auto Innervate")
        UI.AddHeader("Defensive")
        UI.AddToggle("Potion/Healthstone")
        UI.AddRange("Pot HP", nil, 0, 100, 5, 60, false)
        UI.AddToggle("Renewal")
        UI.AddRange("Renewal HP", nil, 0, 100, 5, 60, false)
        UI.AddToggle("Swiftmend")
        UI.AddRange("Swiftmend HP", nil, 0, 100, 5, 60, false)
        UI.AddToggle("Rejuv")
        UI.AddRange("Rejuv HP", nil, 0, 100, 5, 60, false)
        UI.AddToggle("Regrowth")
        UI.AddRange("Regrowth HP", nil, 0, 100, 5, 60, false)
        UI.AddToggle("Barkskin")
        UI.AddRange("Barkskin HP", nil, 0, 100, 5, 60, false)

        UI.AddTab("Root List")
        UI.AddToggle("Mist - Spirit vulpin", nil)
        UI.AddToggle("Plague - Globgrod", nil)
        UI.AddToggle("Spiteful", nil)


    end

end
local function int (b)
    return b and 1 or 0
end

local function HasBloodLust()
    if Buff.RecklessForce:Exist() or Buff.SeethingRage:Exist() or Buff.AncientHysteria:Exist() or
            Buff.Bloodlust:Exist() or Buff.DrumsofRage:Exist() or Buff.Heroism:Exist() or Buff.Netherwinds:Exist()
            or Buff.Timewarp:Exist() or Buff.DrumsOfTheMountain:Exist() or Buff.DrumsOfTheMaelstrom:Exist() or Buff.PrimalRage:Exist()
    then
        return true
    else
        return false
    end
end

local function Locals()
    Player = DMW.Player
    Buff = Player.Buffs
    Debuff = Player.Debuffs
    Spell = Player.Spells
    Target = Player.Target or false
    GCD = Player:GCD()
    HUD = DMW.Settings.profile.HUD
    Talent = Player.Talents
    Item = Player.Items
    current_eclipse = "none"
    eclipse_in = false
    spellCasting, _, _, _, _, _ = UnitCastingInfo("player")
    wrathCount = GetSpellCount(190984)
    starfireCount = GetSpellCount(194153)
    Player45Y, Player45YC = Player:GetEnemies(45)
    Friends40Y, Friends40YC = Player:GetFriends(40)
end

local IsInside = IsIndoors()
local OutsideTimer = GetTime()
local function IsIndoorsUpdate()
    if not IsInside and IsIndoors() then
        IsInside = true
        OutsideTimer = false
    elseif IsInside and not IsIndoors() then
        if not OutsideTimer then
            OutsideTimer = DMW.Time + 1.5
        elseif OutsideTimer < DMW.Time then
            IsInside = false
        end
    end
end

local function defensive()

    if Setting("Barkskin") and Player.HP <= Setting("Barkskin HP") and Spell.Barkskin:IsReady() then
        if Spell.Barkskin:Cast() then
            return true
        end
    end

    if Setting("Potion/Healthstone") and Player.HP <= Setting("Pot HP") then
        if Item.Healthstone:Use(Player) then
            return true
        end
        if Item.PhialOfSerenity.InBag() and Item.PhialOfSerenity.IsReady() and Item.PhialOfSerenity:Use(Player) then
            return true
        end
    end
    if Talent.Renewal.Active and Setting("Renewal") and Player.HP <= Setting("Renewal HP") and Spell.Renewal:Cast(Player) then
        return true
    end
    if Talent.RestorationAffinity.Active then
        if Setting("Swiftmend") and Player.HP <= Setting("Swiftmend HP") and Spell.Swiftmend:Cast(Player) then
            return true
        end
        if Setting("Rejuv") and Player.HP <= Setting("Rejuv HP") and Spell.Rejuvenation:Cast(Player) then
            return true
        end
        if Setting("Regrowth") and Player.HP <= Setting("Regrowth HP") and Spell.Regrowth:Cast(Player) then
            return true
        end


    end

end

local function utility()

    if Player.Combat then
        -- Innervate
        if Setting("Auto Innervate") and Spell.Innervate:IsReady() and not (Buff.balanceOfAllThingsNature:Stacks() > 0 or Buff.balanceOfAllThingsArcane:Stacks() > 0) and current_eclipse ~= "lunar" then
            for _, Unit in pairs(Friends40Y) do
                if Unit.Role == "HEALER" and (UnitPower(Unit.Pointer, 0) / UnitPowerMax(Unit.Pointer, 0)) * 100 < 50 then
                    if Spell.Innervate:Cast(Unit) then
                        return true
                    end
                end
            end
        end
        --Soothe
        if Setting("Auto Soothe") and Spell.Soothe:IsReady() then
            for _, Unit in pairs(Player45Y) do
                if Unit.ValidEnemy and Unit:Dispel(Spell.Soothe) and Unit.TTD > Setting("Soothe TTD") then
                    if Spell.Soothe:Cast(Unit) then
                        return true
                    end
                end
            end
        end
        -- Rebirth
        if Setting("Rebirth Mouseover") and not Player.Moving and Spell.Rebirth:IsReady() then
            if Player.Mouseover and Player.Mouseover.Player and Player.Mouseover.Dead and Player.Mouseover.Dead then
                if Spell.Rebirth:Cast(Player.Mouseover) then
                    return true
                end
            end
        end
        --Solar Beam
        if Spell.SolarBeam:IsReady() and HUD.Interrupts == 1 then
            for _, Unit in ipairs(Player45Y) do
                if Unit:Interrupt() then
                    Spell.SolarBeam:Cast(Unit)
                    break
                end
            end
        end
    end

    if DMW.Player.Covenant == "Kyrian" and not Item.PhialOfSerenity:InBag() and Spell.SummonSteward:Cast() then
        return true
    end

    local radar = "off"

    --Building root list
    local root_UnitList = {}
    if Setting("Mist - Spirit vulpin") then
        root_UnitList[165251] = "Spirit vulpin"
        radar = "on"
    end
    if Setting("Plague - Globgrod") then
        root_UnitList[171887] = "Globgrod"
        radar = "on"
    end
    if Setting("Spiteful(M+)") then
        root_UnitList[174773] = "Spiteful"
        radar = "on"
    end
    Setting("ROOT")
    if radar == "on" then

        local root = "EntanglingRoots"
        if Talent.MassEntanglement.Active and Spell.MassEntanglement:IsReady() then
            root = "MassEntanglement"
        end
        if Spell[root]:IsReady() then
            for _, Unit in ipairs(DMW.Attackable) do
                if root_UnitList[Unit.ObjectID] and Unit.HP > 90 and not Unit:InSanguine() and not Unit:CCed() then
                    if Unit.Distance <= 8 and Talent.MightyBash.Active and Spell.MightyBash:IsReady() then
                        if Spell.MightyBash:Cast(Unit) then
                            return true
                        end
                    elseif Unit.Distance < 35 then
                        if Spell[root]:Cast(Unit) then
                            return true
                        end
                    end
                end
            end
        end -- end root
    end -- end radar
end -- end utility

local function Fallthru()
    if Debuff.Moonfire:Remain(Target) > Debuff.Sunfire:Remain(Target) and Spell.Sunfire:Cast(Target) then
        return true
    end
    if Spell.Moonfire:Cast(Target) then
        return true
    end
end

local function EclipseUpdate()
    if (wrathCount == 0 or spellCasting == "Wrath" and wrathCount == 1)
            and (starfireCount == 0 or spellCasting == "Starfire" and starfireCount == 1) then
        eclipse_in = true
    end
    if not eclipse_in then
        if wrathCount == 2 and starfireCount == 2 then
            eclipse_next = "any"
        elseif wrathCount == 0 and starfireCount > 0 then
            eclipse_next = "solar"
        elseif wrathCount > 0 and starfireCount == 0 then
            eclipse_next = "lunar"
        end
    else
        if IsSpellOverlayed(Spell.Wrath.SpellID) or spellCasting == "Starfire" and starfireCount == 1 then
            current_eclipse = "solar"
        end
        if IsSpellOverlayed(Spell.Starfire.SpellID) or spellCasting == "Wrath" and wrathCount == 1 then
            current_eclipse = "lunar"
        end
    end
end

local function coolDowns()

    --warriors of WarriorOfElune
    if Talent.WarriorOfElune.Active and Spell.WarriorOfElune:Cast() then
        return true
    end

    --trinket usage here
    if Item.InscrutableQuantumDevice:Equipped() and Item.InscrutableQuantumDevice:IsReady() and (Buff.CelestialAlignment:Exist() or HasBloodLust()) then
        if Item.InscrutableQuantumDevice:Use() then
            return true
        end
    end

    if Setting("TEST") then
        if DMW.Player.Covenant == "Kyrian" then
            if Buff.LoneSpirit:Exist() and Spell.LoneEmpowerment:IsReady() then
                if ((Buff.CelestialAlignment:Exist() or Spell.CelestialAlignment:CD() > 60) or HasBloodLust()) then
                    if Spell.LoneEmpowerment:Cast(Player) then
                        return true
                    end
                end
            end
            if Buff.KindredSpirits:Exist() and Spell.EmpowerBond:IsReady() then
                for _, Unit in pairs(Friends40Y) do
                    if Unit:AuraByID(326434) and Unit.Name ~= "LocalPlayer" then
                 --       print("EmpowerBond Target: " .. Unit.Name .. " | " .. Unit.Class)
                        if Unit.Class == "MAGE" and Unit:AuraByID(190319)
                                or Unit.Class == "DRUID" and (Unit:AuraByID(194223) or Unit:AuraByID(102560) or Buff.IncarnationChosenOfElune:Exist(Unit))
                                or Unit.Class == "WARRIOR" and Unit:AuraByID(107574)
                        then
                            if Spell.EmpowerBond:Cast(Player) then
                                return true
                            end
                        end
                    end
                end
            end
        end
    end -- end kyrian covenant thingy
end

local function aoe_Rotation()

    --keep starfall up
    if Buff.Starfall:Refresh(Player) and Spell.Starfall:Cast(Player) then
        return true
    end

    --dots
    local splash_count = 0
    if current_eclipse ~= "lunar" then
        for _, Unit in pairs(Player45Y) do
            if Unit.ValidEnemy and (targets8count == Player45YC or targets8count > 2) then
                if Debuff.Sunfire:Refresh(Unit) and Unit.TTD > 14 and Spell.Sunfire:Cast(Unit) then
                    return true
                end
            end
        end
        for _, Unit in pairs(Player45Y) do
            if Unit.ValidEnemy then
                if Debuff.Moonfire:Refresh(Unit) and Unit.TTD > 14 and Spell.Moonfire:Cast(Unit) then
                    return true
                end
            end
        end
    end


    --starsurge
    if (Buff.balanceOfAllThingsNature:Stacks() > 3 or Buff.balanceOfAllThingsArcane:Stacks() > 3) and Player45YC < 4
            or (Buff.CelestialAlignment:Remain() < 5 and Buff.CelestialAlignment:Exist()
            or (Buff.RavenousFrenzy:Remain() < GCD * math.ceil(DMW.Player.Power % 30) and Buff.RavenousFrenzy:Exist()))
            and Player45YC < 3 then
        if Spell.Starsurge:Cast(Target) then
            return true
        end
    end

    --starfire
    if current_eclipse ~= "lunar" and (eclipse_next == "lunar"
            or eclipse_next == "any" and targets8count == 2
            or current_eclipse == "solar" and targets8count < 5) then
        if Spell.Wrath:Cast(Target) then
            return true
        end
    else
        if Spell.Starfire:Cast(Target) then
            return true
        end
    end

end

local function SingleTarget()


    --RavenousFrenzy here
    if Buff.CelestialAlignment:Exist() and Spell.RavenousFrenzy:Cast(Player) then
    end

    --StarSurge
    if Spell.Starsurge:IsReady() and
            (Buff.balanceOfAllThingsNature:Exist() or Buff.balanceOfAllThingsArcane:Exist())
            or (spellCasting == "Wrath" and wrathCount == 1 or spellCasting == "Starfire" and starfireCount == 1)
    then
        if Spell.Starsurge:Cast(Target) then
            return true
        end
    end

    if Target.ValidEnemy then
        if Target.TTD > 16 and Debuff.Sunfire:Refresh(Target) and Spell.Sunfire:Cast(Target) then
            return true
        end
        if Target.TTD > 13.5 and Debuff.Moonfire:Refresh(Target) and Spell.Moonfire:Cast(Target) then
            return true
        end
    end

    local aspPerSec = int(current_eclipse == "lunar") * 8 / Spell.Starfire:CastTime() + int(not current_eclipse == "lunar") * 6 / Spell.Wrath:CastTime() + 0.2 / (GetHaste() / 100)

    --starsurge
    if ((Buff.RavenousFrenzy:Remain() < GCD * math.ceil(DMW.Player.Power % 30)
            and Buff.RavenousFrenzy:Exist()))
            or (DMW.Player.Power + aspPerSec * Buff.EclipseSolar:Remain() or DMW.Player.Power + aspPerSec * Buff.EclipseLunar:Remain() > 120)
            and eclipse_in == "any"
            and (not Buff.CelestialAlignment:Exist() or not Talent.Starlord.Active)
            and Spell.CelestialAlignment:CD() > 0 or DMW.Player.Power > 90 then
        if Spell.Starsurge:Cast(Target) then
            return true
        end
    end

    --starfire,
    if current_eclipse == "lunar"
            or current_eclipse ~= "solar" and eclipse_next == "solar"
            or current_eclipse ~= "solar" and eclipse_next == "any"
            or Buff.WarriorOfElune:Exist() and Buff.EclipseLunar:Exist()
    then
        if Spell.Starfire:Cast(Target) then
            return true
        end
    else
        if Spell.Wrath:Cast(Target) then
            return true
        end
    end

    Fallthru()
end

function Druid.Balance()
    Locals()
    CreateSettings()
    IsIndoorsUpdate()

    if Rotation.Active(true) then


        --auto movement stuff
        local middleMouseDown = GetKeyState(0x04)
        local leftShiftDown = GetKeyState(0xA0)

        if middleMouseDown and not IsInside and not Buff.TravelForm:Exist() and Spell.TravelForm:Cast(Player) then
            return true
        end
        if leftShiftDown then
            if not Buff.CatForm:Exist() and Spell.CatForm:Cast(Player) then
                return true
            end
            if Buff.CatForm:Exist() then
                if Setting("Auto Prowl") and not Buff.Prowl:Exist() and Spell.Prowl:IsReady() and Spell.Prowl:Cast() then
                    return true
                end

                if Setting("Auto Sprint") and not Buff.Dash:Exist() and not Buff.StampedingRoar:Exist() and not Buff.StampedingRoarCat:Exist() then
                    if Spell.StampedingRoarCat:IsReady() then
                        if Spell.StampedingRoarCat:Cast() then
                            return true
                        end
                    end
                    if Spell.Dash:IsReady() then
                        if Spell.Dash:Cast() then
                            return true
                        end
                    end
                end
            end
        end -- end left shift down

        if Target then
            targets8, targets8count = Target:GetEnemies(8)
        end

        Player:AutoTarget(45)
        if Target and Target.ValidEnemy and (not Player.Moving or not Buff.TravelForm:Exist()) then
            if not Buff.MoonkinForm:Exist() and Spell.MoonkinForm:Cast(Player) then
                return true
            end
            if Player.Combat then
                --Convoke the spirit fix
                local ChannelInfo = { UnitChannelInfo("player") }
                if ChannelInfo[4] then
                    return true
                end

                if not (Target and Target.ValidEnemy) then
                    Player:AutoTarget(45)
                    return true
                end
                if utility() then
                    return true
                end
                if coolDowns() then
                    return true
                end
                if defensive() then
                    return true
                end
                if EclipseUpdate() then
                    return true
                end
                if targets8count > 1 or HUD.Mode ~= 2 then
                    if aoe_Rotation() then
                        return true
                    end
                else
                    SingleTarget()
                end
            end
        end

    end
end