local data = {
    block = {
        ["description"] = {
            is_spawnable = true,
            is_summonable = true
        },
        components ={
            ["componet.Inventory"] ={
                slots = 10,
             },

        },
    },
    event ={
        ["On_Update"] = {

        },
        ["On_Place"] = {

        },
        ["On_Destroy"] = {

        },
        ["On_Touch"] = {

        },
        ["On_Interact"] = {
            func = function(blockdata)
                print("c")
            end
        },
    },
    functions = {
        SayHi = function(Position)
            print("Hi I'm Bob")
        end
    }
}
return data