local data ={
    entity = {
        description = {
            is_spawnable = true,
            is_summonable = true,
        },
        component_groups = {
            baby = {
               [ "nbt.is_baby"] = {},
                ["nbt.scale"] = {0.5},
                ageable = {
                    ["nbt.duration"] = 200,
                    feeditems = {
                        stone = 10,
                    },
                    event = "Baby_Grow_Up"
                },
                ["behavior.follow_parent"] ={
                    priority = 5,
                    speed_multiplier = 1.1,
                }
            },
            adult ={
                on_interact ={

                },
                loot = {
                    table 
                },
                experience_reward = {
                    on_bred = {xp = math.random(1,7)},
                    on_death  = {
                        condition = {
                          If =  "hit_by_player",
                          Is = "=",
                          To = true,
                    },
                        xp = math.random(1,7),
                    },
                },
            },
        },
    },
    CustomEvents ={},
}
return data