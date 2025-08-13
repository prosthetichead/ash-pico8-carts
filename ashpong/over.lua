function init_over()

end

function update_over()
    if btnp(4) then
        state = ST.title
        init_title()
    end
end

function draw_over()
    cls(8)
    print("game over", 40, 20, 7)
    print("press ❎ to restart", 30, 50, 7)
end