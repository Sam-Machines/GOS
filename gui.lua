os.loadAPI(shell.resolve("apis/windows.lua"))
--Vars
    args = {...}
    version = "0.0.1 alpha"
    running = true
    w, h = term.getSize()

    --Running programs
    programs = {}

    --Base programs
    P_lua = windows.programs.new(function()
        shell.run("lua")
    end, 30, 3, 20, 10, "LUA")

    P_shell = windows.programs.new(function()
        shell.run("shell")
    end, 30, 3, 20, 10, "Shell")

    P_taskManager = windows.programs.new(function()
        while true do
            term.setBackgroundColor(colors.white)
            term.setTextColor(colors.black)
            term.clear()
            term.setCursorPos(1, 1)
            for i = 1, #programs do
                term.setBackgroundColor(colors.red)
                term.setCursorPos(1, i)
                term.write("X")

                term.setBackgroundColor(colors.white)
                term.setCursorPos(2, i)
                term.write(programs[i].name)
            end
            coroutine.yield()
        end
    end, 28, 10, 20, 10, "Tasks")

    --Images
    _desktop = paintutils.loadImage(shell.resolve("resources/.backgrounds/desktop1"))
    
    --Wheres?
    rightX, rightY = 0

    --Swiches
    isStartMenu = false
    isRightClick = false

--Functions
    --Misc
    local function centerPrint(text, ny)
        if type(text) == "table" then
            for _,v in pairs(text) do
                centerPrint(v)
            end
        else
            local _,y = term.getCursorPos()
            local w,h = term.getSize()
            term.setCursorPos(math.ceil((w-#text)/2), ny or y)
            print(text)
        end
    end

    local function clear(color_)
        term.setBackgroundColour(color_)
        term.clear()
        term.setCursorPos(1,1)
    end
    
    --GUI stuff
    local function drawMenu()
        w, h = term.getSize()
        if isStartMenu == true then

            for i = 1, #programs do
                programs[i].selected = false
            end

            term.setCursorBlink(false)
            paintutils.drawFilledBox(1, 2, math.ceil(w/3), math.ceil(h/2+5-1), colors.lightBlue)
            powerX, powerY = math.ceil(w/3-1), math.ceil(h/2+5-2) 
            term.setCursorPos(powerX, powerY)
            term.setTextColor(colors.white)
            term.setBackgroundColor(colors.red)
            term.write("X")
        else

            for i = 1, #programs do
                if programs[i].selected then
                    term.setTextColor(programs[i].blinkCol)
                    term.setCursorPos(programs[i].blinkX, programs[i].blinkY)
                    term.setCursorBlink(programs[i].blinking)
                end
            end

        end
    end


    local function drawDesktop()
        clear(colours.cyan)
        paintutils.drawImage(_desktop, 1, 1)
    end
    local function drawTaskbar()
        w, h = term.getSize()
        term.setCursorPos(1, 1)
        term.setBackgroundColour(colours.grey)
        term.clearLine()
        term.setCursorPos(1, 1)
        term.setBackgroundColour(colours.black)
        term.setTextColor(colours.white)
        if not isStartMenu then
            term.write(" Menu ")
        else
            term.write("[Menu]")
        end
        w, h = term.getSize()
        term.setBackgroundColour(colours.grey)
        local time = os.time()
        local formattedTime = textutils.formatTime(time, false)
        term.setCursorPos(w-#formattedTime, 1)
        term.setBackgroundColour(colours.black)
        term.setTextColor(colours.white)
        term.write(formattedTime)
    end

    function drawRightClick(x, y)
        w, h = term.getSize()
        if isRightClick == true then
            paintutils.drawFilledBox(x, y, math.ceil(x+w/3)-4, math.ceil(y+h/2+5)-4, colors.white)
            term.setCursorPos(x+1, y)
            term.setBackgroundColor(colors.red)
            term.write("[ Open LUA ]")

            term.setCursorPos(x+1, y+1)
            term.setBackgroundColor(colors.red)
            term.write("[   Tasks  ]")

            term.setCursorPos(x+1, y+2)
            term.setBackgroundColor(colors.red)
            term.write("[   Shell  ]")
        end
    end



    --Runtime
    local function run()
        while running do
            event, p1, p2, p3, p4, p5 = os.pullEventRaw()
            w, h = term.getSize()


            if programs ~= nil and not isStartMenu then
                windows.programs.update(programs, event, p1, p2, p3)
            end               
                                        
            if event == "mouse_click" then
                button, x, y = p1, p2, p3
                if y == 1 and button == 1 then
                    if x < 7 and x > 0 then
                        isStartMenu = true
                    else
                        isStartMenu = false
                    end
                end

                if isRightClick then
                    if x > rightX and x < rightX + 13 then
                        if y == rightY then
                            table.insert(programs, P_lua)
                        end
                        if y == rightY+1 then
                            table.insert(programs, P_taskManager)
                        end
                        if y == rightY+2 then
                            table.insert(programs, P_shell)
                        end
                    end
                end


                if isStartMenu == true then            
                    isRightClick = false
                    powerX, powerY = math.ceil(w/3-1), math.ceil(h/2+5-2)              
                    if button == 1 and x == powerX and y == powerY then
                        clear(colors.black)
                        running = false
                    end
                else
                    if y > 1 and button == 2 then
                        isRightClick = true
                        rightX, rightY = x, y
                    else
                        isRightClick = false
                        rightX, rightY = nil
                    end
                end
            end

            
            if event ~= 'char' then
                drawDesktop()
                drawTaskbar()
                drawRightClick(x,y)
            end

            windows.programs.update(programs, "", "", "", "")
            drawMenu()        
        end
    end
    
    local function init()
       drawDesktop()
       drawTaskbar()
       run()
       clear(colors.black)
    end
--Main
    -- Run

    local _, err = pcall(function() init(unpack(args)) end)
    if err then
        -- Make a nice error handling screen here...
        term.setBackgroundColor(colors.black)
        term.setTextColor(colors.white)
        term.clear()
        term.setCursorPos(1, 3)
        print(" An Error Has Occured! D:\n\n")
        print(" " .. tostring(err) .. "\n\n")
        print(" Press any key to exit...")
        os.pullEvent("key")
    end