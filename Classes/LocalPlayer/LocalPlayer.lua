local DMW = DMW
local LocalPlayer = DMW.Classes.LocalPlayer

function LocalPlayer:New(Pointer)
    self.Pointer = Pointer
    self.Name = "LocalPlayer"
    self.CombatReach = UnitCombatReach(Pointer)
    self.PosX, self.PosY, self.PosZ = ObjectPosition(Pointer)
    self.GUID = ObjectGUID(Pointer)
    self.Class = select(2, UnitClass(Pointer)):gsub("%s+", "")
    self.Level = UnitLevel(Pointer)
    self.SpecID = GetSpecializationInfo(GetSpecialization())
    self.Spec = DMW.Enums.Specs[self.SpecID] or ""
    self.Distance = 0
    self.Combat = UnitAffectingCombat(self.Pointer) and DMW.Time or false
    self.EID = false
    self.NoControl = false
    DMW.Functions.AuraCache.Refresh(Pointer)
    self:GetSpells()
    self:GetTalents()
    self.Equipment = {}
    self.EquipmentID = {}
    self.Items = {}
    self:UpdateEquipment()
    self:GetItems()
    DMW.Helpers.Queue.GetBindings()
end

function LocalPlayer:Update()
    self.PosX, self.PosY, self.PosZ = ObjectPosition(self.Pointer)
    self.Health = UnitHealth(self.Pointer)
    self.HealthMax = UnitHealthMax(self.Pointer)
    self.HP = self.Health / self.HealthMax * 100
    self.Power = UnitPower(self.Pointer)
    self.PowerMax = UnitPowerMax(self.Pointer)
    self.PowerDeficit = self.PowerMax - self.Power
    self.PowerPct = self.Power / self.PowerMax * 100
    self.PowerRegen = GetPowerRegen()
    if self.Class == "ROGUE" or self.Class == "DRUID" then
        self.ComboPoints = UnitPower(self.Pointer, 4)
        self.ComboMax = UnitPowerMax(self.Pointer, 4)
        self.ComboDeficit = self.ComboMax - self.ComboPoints
    elseif self.SpecID == 70 then
        self.HolyPower = UnitPower(self.Pointer, 9)
        self.HolyPowerMax = UnitPowerMax(self.Pointer, 9)
        self.HolyPowerDeficit = self.HolyPowerMax - self.HolyPower
    elseif self.Class == "DEATHKNIGHT" then
        self.Runes = self:GetRunes()
    end
    if not self.Combat and UnitAffectingCombat("player") then
        self.Combat = DMW.Time
    end
    self.InInstance, self.Instance = IsInInstance()
    self.Casting = UnitCastingInfo(self.Pointer) or UnitChannelInfo(self.Pointer)
    self.Moving = GetUnitSpeed(self.Pointer) > 0
    self.MovingTime = self:TimeMoving()
    self.PetActive = UnitIsVisible("pet")
    self.InGroup = IsInGroup()
    self.CombatTime = self.Combat and (DMW.Time - self.Combat) or 0
    self.Resting = IsResting()
end

function LocalPlayer:GCD()
    if DMW.Enums.GCDOneSec[self.SpecID] then
        return 1
    else
        return math.max(1.5 / (1 + GetHaste() / 100), 0.75)
    end
end

function LocalPlayer:GCDMax()
    if DMW.Enums.GCDOneSec[self.SpecID] then
        return 1
    else
        return 1.5
    end
end

local movingTimer = GetTime()
function LocalPlayer:TimeMoving()
    if not self.Moving then
        movingTimer = DMW.Time
    end
    return DMW.Time - movingTimer
end

function LocalPlayer:CDs()
    if DMW.Settings.profile.HUD.CDs and DMW.Settings.profile.HUD.CDs == 3 then
        return false
    elseif DMW.Settings.profile.HUD.CDs and DMW.Settings.profile.HUD.CDs == 2 and self.Target and self.Target.TTD > 4 then
        return true
    elseif self.Target and self.Target:IsBoss() and self.Target.TTD > 4 then
        return true
    end
    return false
end

function LocalPlayer:CritPct()
    return GetCritChance()
end

function LocalPlayer:TTM()
    local PowerMissing = self.PowerMax - self.Power
    if PowerMissing > 0 then
        return PowerMissing / self.PowerRegen
    else
        return 0
    end
end

function LocalPlayer:Standing() --wait for fix??
    return true
    -- if ObjectDescriptor("player", GetOffset("CGUnitData__AnimTier"), Types.Byte) == 0 then
    --     return true
    -- end
    -- return false
end

function LocalPlayer:HasFlag(Flag)
    return bit.band(ObjectDescriptor(self.Pointer, GetOffset("CGUnitData__Flags"), "int"), Flag) > 0
end

function LocalPlayer:HasMovementFlag(Flag)
    local SelfFlag = UnitMovementFlags(self.Pointer)
    if SelfFlag then
        return bit.band(UnitMovementFlags(self.Pointer), Flag) > 0
    end
    return false
end

function LocalPlayer:GetFreeBagSlots()
    local Slots = 0
    local Temp
    for i = 0, 4, 1 do
        Slots = Slots + GetContainerNumFreeSlots(i)
    end
    return Slots
end

function LocalPlayer:HasItemEquipped(ItemID)
    return DMW.Player.EquipmentID[ItemID] ~= nil
end

function LocalPlayer:Dispel(Spell)
    return DMW.Units[self.Pointer]:Dispel(Spell)
end

function LocalPlayer:GetRunes()
    local Count = 0
    if GetRuneCount(1) then
        for i=1,6 do
            Count = Count + GetRuneCount(i)
        end
    end
    return Count
end

function LocalPlayer:AuraByID(SpellID, OnlyPlayer)
    OnlyPlayer = OnlyPlayer or false
    local SpellName = GetSpellInfo(SpellID)
    local Unit = self.Pointer
    if DMW.Tables.AuraCache[Unit] ~= nil and DMW.Tables.AuraCache[Unit][SpellName] ~= nil and (not OnlyPlayer or DMW.Tables.AuraCache[Unit][SpellName]["player"] ~= nil) then
        local AuraReturn
        if OnlyPlayer then
            AuraReturn = DMW.Tables.AuraCache[Unit][SpellName]["player"].AuraReturn
        else
            AuraReturn = DMW.Tables.AuraCache[Unit][SpellName].AuraReturn
        end
        return unpack(AuraReturn)
    end
    return nil
end