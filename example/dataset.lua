local dataset = {
    -- Horizontal lines
    { grid = { { 1, 1, 1 }, { 0, 0, 0 }, { 0, 0, 0 } }, label = { 1, 0, 0 } },
    { grid = { { 0, 0, 0 }, { 1, 1, 1 }, { 0, 0, 0 } }, label = { 1, 0, 0 } },
    { grid = { { 0, 0, 0 }, { 0, 0, 0 }, { 1, 1, 1 } }, label = { 1, 0, 0 } },

    -- Vertical lines
    { grid = { { 1, 0, 0 }, { 1, 0, 0 }, { 1, 0, 0 } }, label = { 0, 1, 0 } },
    { grid = { { 0, 1, 0 }, { 0, 1, 0 }, { 0, 1, 0 } }, label = { 0, 1, 0 } },
    { grid = { { 0, 0, 1 }, { 0, 0, 1 }, { 0, 0, 1 } }, label = { 0, 1, 0 } },

    -- Diagonal lines
    { grid = { { 1, 0, 0 }, { 0, 1, 0 }, { 0, 0, 1 } }, label = { 0, 0, 1 } }, -- top-left to bottom-right
    { grid = { { 0, 0, 1 }, { 0, 1, 0 }, { 1, 0, 0 } }, label = { 0, 0, 1 } }, -- top-right to bottom-left
}

return dataset
