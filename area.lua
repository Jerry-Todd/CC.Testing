local M = {}

M.rooms = {{
    close = {
        x = 0,
        y = 0,
        z = 0
    },
    far = {
        x = 12,
        y = 12,
        z = 12
    },
    name = 'main'
}}

M.blocks = {{
    x = 1,
    y = 0,
    z = 0
}, {
    x = 0,
    y = 0,
    z = 1
}, {
    x = 1,
    y = 1,
    z = 1
}, {
    x = 12,
    y = 0,
    z = 3,
    container = true
},{
    x = 12,
    y = 0,
    z = 5,
    container = true
},{
    x = 12,
    y = 0,
    z = 7,
    container = true
},{
    x = 12,
    y = 0,
    z = 9,
    container = true
},}

return M
