local data = {
    entity = {
        ["description"] = {
            is_spawnable = true,
            is_summonable = true
        },
        components ={
          ["behavior.nearest_attackable_target"] ={
            ["priority"]= 2,
            ["must_see"]=true,
            ["reselect_targets"]= true,
            ["within_radius"]= 25.0,
            ["entity_types"]={
              {
                
                },
                ["max_dist"]=32,
              },
            },
            ["behavior.random_stroll"] ={
                ["priority"]= 2,
                ["interval"]= 20,
                ["speed_multiplier"]= 1.0,
                ["xz_dist"]= 25,
                ["y_dist"]= 0,
             },
             ["componet.health"] = {
                value = 10,
                max = 10,
             },
             ["componet.HitBoxSize"] = {
               x = 2.2,
               y = 7.5,
             },
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
                        event ="custom.Baby_Grow_Up"
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
    event ={
        ["Baby_Grow_Up"] ={

        },
    },
}
return data