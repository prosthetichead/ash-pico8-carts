-- state title
function init_title()

end

function update_title()
    if btnp(4) then
        state = ST.game
        init_game()
    end
end

function draw_title()
    cls(8)
    print("high score: " .. high_score, 2, 2, 7)
    print("ashpong", 50, 40, 7)
    print("press ❎ to start", 30, 50, 7)
end