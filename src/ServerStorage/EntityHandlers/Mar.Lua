local data ={
    entity = {
        description = {
            is_spawnable = true,
            is_summonable = true,
        },
        component_groups = {
            baby = {
               [ "componet.is_baby"] = {},
                ["componet.scale"] = {
                    value = 0.5,
                },
                ["componet.ageable"] = {
                    ["duration"] = 200,
                    feeditems = {
                        stone = 10,
                    },
                    grow_up = {
                        event ="Baby_Grow_Up"
                    }
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
    event ={},
}
return data