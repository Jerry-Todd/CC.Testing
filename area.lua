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
}, {
    close = {
        x = 0,
        y = 0,
        z = 12
    },
    far = {
        x = 0,
        y = 0,
        z = 13
    },
    name = 'tunnel'
}, {
    close = {
        x = 0,
        y = 0,
        z = 14
    },
    far = {
        x = 6,
        y = 6,
        z = 20
    },
    name = 'utility'
}}

M.blocks = {{
    x = 4,
    y = 0,
    z = 8,
    container = true
}, {
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
}}

return M
