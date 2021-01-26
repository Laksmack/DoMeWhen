local DMW = DMW

DMW.Enums.Spells = {
    GLOBAL = {
        All = {
            Abilities = {
                GCD = { SpellID = 61304, CastType = "Passive", SpellType = "GCD" },
                --Professions, multiple ID's shouldn't matter, just for tracking casts
                Fishing = { SpellID = 131474, SpellType = "Profession" },
                HerbGathering = { SpellID = 110413, SpellType = "Profession" },
                Mining = { SpellID = 50310, SpellType = "Profession" },
                Skinning = { SpellID = 32678, SpellType = "Profession" }
            },
            Buffs = {
                MemoryOfLucidDreams = 298357,
                RecklessForce = 302932,
                SeethingRage = 297126,
                AncientHysteria = 90355,
                Bloodlust = 2825,
                DrumsofRage = 146555,
                Heroism = 32182,
                Netherwinds = 90355,
                Timewarp = 80353,
                DrumsOfTheMountain = 230935,
                DrumsOfTheMaelstrom = 256740,
                PrimalRage = 264667,


            },
            Debuffs = {
                ConcentratedFlame = { SpellID = 299349 }
            }
        }
    }
}
