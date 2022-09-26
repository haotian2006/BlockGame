local data = {
    block = {
        ["description"] = {
            is_spawnable = true,
            is_summonable = true
        },
        components ={
            ["componet.on_interact"] ={
                func = "SayHi"
             },
            ["componet.Inventory"] ={
                func = "SayHi"
             },

        },
        component_groups = {
            
        },
    },
    event ={
        ["On_Update"] = {

        },
        ["On_Place"] = {

        },
        ["On_Destroy"] = {

        },
    },
    functions = {
        SayHi = function(uuid)
            print("Hi I'm Bob")
        end
    }
}
return data