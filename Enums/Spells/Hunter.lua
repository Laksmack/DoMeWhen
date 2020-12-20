local Spells = DMW.Enums.Spells

Spells.HUNTER = {
    BeastMastery = {
        Abilities = {
            AMurderOfCrows = {SpellID = 131894},
            AspectOfTheWild = {SpellID = 193530},
            BarbedShot = {SpellID = 217200},
            Barrage = {SpellID = 120360},
            BestialWrath = {SpellID = 19574},
            ChimaeraShot = {SpellID = 53209},
            CobraShot = {SpellID = 193455},
            CounterShot = {SpellID = 147362, SpellType = "Interrupt"},
            DireBeast = {SpellID = 120679},
            FreezingTrap = {SpellID = 187650, CastType = "Ground"},
            Intimidation = {SpellID = 19577},
            KillCommand = {SpellID = 34026},
            Misdirection = {SpellID = 34477},
            Multishot = {SpellID = 2643},
            SpittingCobra = {SpellID = 194407},
            Stampede = {SpellID = 201430}
        },
        Buffs = {
            AspectOfTheWild = 193530,
            BeastCleave = 118455,
            BestialWrath = 19574,
            DanceOfDeath = 274443,
            DireBeast = 120694,
            Frenzy = 272790
        },
        Debuffs = {
            BarbedShot = {SpellID = 217200}
        },
        Talents = {}
    },
    Marksmanship = {
        Abilities = {},
        Buffs = {},
        Debuffs = {},
        Talents = {}
    },
    Survival = {
        Abilities = {},
        Buffs = {},
        Debuffs = {},
        Talents = {}
    },
    All = {
        Abilities = {
            CallPet1 = {SpellID = 883, CastType = "Special"},
            CallPet2 = {SpellID = 83242, CastType = "Special"},
            CallPet3 = {SpellID = 83243, CastType = "Special"},
            CallPet4 = {SpellID = 83244, CastType = "Special"},
            CallPet5 = {SpellID = 83245, CastType = "Special"},
            MendPet = {SpellID = 136},
            RevivePet = {SpellID = 982}
        },
        Buffs = {},
        Debuffs = {}
    }
}
