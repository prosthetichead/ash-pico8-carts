-- 
-- brick width is 8, height is 4
-- posible 16 Columns
-- no block . -- wall #
lveldefs={
    ["1"]={c=11, hp=1}, -- normal brick
    ["2"]={c=12, hp=2}, -- double brick
    ["3"]={c=13, hp=3}, -- triple brick
}

lvls={
    {
        level=1,
        back=0,
        layout={
            "................",
            "................",
            "................",
            "...1111111111...",
            "...1111111111...",
        },
    } 
} 