-- etanks.lua, made by peachey2k2
-- under MIT license.

local fzy = require("lib/fzy")
local filename = "data/etankdata.txt"

local channels = {
    "white",
    "orange",
    "magenta",
    "light blue",
    "yellow",
    "lime",
    "pink",
    "gray",
    "light gray",
    "cyan",
    "purple",
    "blue",
    "brown",
    "green",
    "red",
    "black"
}

local options

local width, height = term.getSize()

-- no character reading? fuck off.
local string_meta = getmetatable('')
function string_meta:__index( key )
    local val = string[ key ]
    if ( val ) then
        return val
    elseif ( tonumber( key ) ) then
        return self:sub( key, key )
    else
        error( "attempt to index a string value with bad key ('" .. tostring( key ) .. "' is not part of the string library)", 2 )
    end
end

-- functions
function confirm(text, default)
    local suffix = default and " (Y/n): " or " (y/N): "
    print(text .. suffix)
    local res = read()
    local first_char = res[1]
    if first_char == "y" or first_char == "Y" then
        return true
    end
    if first_char == "n" or first_char == "N" then
        return false
    end
    return default
end 

function charToColor(chars)
    return {
        tonumber(chars[1], 16) + 1,
        tonumber(chars[2], 16) + 1,
        tonumber(chars[3], 16) + 1,
    }
end

function colorToChar(colorIndexes)
    return string.format("%x%x%x", colorIndexes[1], colorIndexes[2], colorIndexes[3])
end

function sortFzyOutput(a, b)
    return a[3] > b[3]
end

local menuSelection = 1

function drawMenu()
    term.setCursorPos(1, height)
    term.clearLine()
    for i = 1, #options do
        if i == menuSelection then
            term.write("[")
            term.setTextColor(colors.lightBlue)
            term.write(options[i])
            term.setTextColor(colors.white)
            term.write("]  ")
        else
            term.write(" " .. options[i] .. "   ")
        end
    end
end

function openManageMenu()
    menuSelection = 1
    while true do
        options = {"Add fluid", "Edit fluid", "Remove fluid", "Back"}
        drawMenu()
        local event, key, _ = os.pullEvent("key")
        if key == keys.left and menuSelection > 1 then
            menuSelection = menuSelection - 1
        elseif key == keys.right and menuSelection < #options then
            menuSelection = menuSelection + 1
        elseif key == keys.enter then
            if menuSelection == 1 then
                if openAddMenu() then return true end
                menuSelection = 1
            elseif menuSelection == 2 then
                if openEditMenu() then return true end
                menuSelection = 2
            elseif menuSelection == 3 then
                if openRemoveMenu() then return true end
                menuSelection = 3
            elseif menuSelection == 4 then
                return false
            end
        elseif key == keys.leftCtrl or key == keys.rightCtrl then
            quit()
        end
    end
end

local chInput = ""
local chSelect = 1
local chResult = {}
local chColors = {}

function chUpdate()
    chResult = fzy.filter(chInput, channels, false)
    table.sort(chResult, sortFzyOutput)
    
    term.clear()
    term.setBackgroundColor(colors.black)
    for i = 1, height-1 do
        if chResult[i] == nil then break end
        term.setCursorPos(1, height-i-2)
        
        local curIdx = chResult[i][1]
        local cur = channels[ curIdx ]

        if i == chSelect then
            --term.setBackgroundColor(colors.white)
            term.setTextColor(colors.black)
            if curIdx == 16 then
                term.setBackgroundColor(colors.white)
            else
                term.setBackgroundColor(2^(curIdx-1))
            end
        else
            if curIdx == 16 then
                term.setTextColor(colors.white)
            else
                term.setTextColor(2^(curIdx-1))
            end
        end
        term.write(cur)
        term.setBackgroundColor(colors.black)
        term.setTextColor(colors.white)
    end
    term.setCursorPos(1, height-1)
    for _, i in pairs(chColors) do
        term.setTextColor(i == 16 and 1 or 2^(i-1))
        term.write(channels[i])
        term.setTextColor(colors.white)
        term.write(" - ")
    end
    term.write(chInput)
    term.setCursorPos(1, height)
    term.setTextColor(colors.blue)

    term.write("Select the ")
    term.setTextColor(colors.lightBlue)
    term.write(#chColors == 0 and "first" or (#chColors == 1 and "second" or "third"))
    term.setTextColor(colors.blue)
    term.write(" color.")

    term.setTextColor(colors.white)
end

function chSelector(index)
    chInput = ""
    chColors = {}
    chUpdate()
    while true do
        local event, key, _ = os.pullEvent()
        if event == "char" then
            chInput = chInput .. key
            chSelect = 1
        elseif event == "key" then
            if key == keys.backspace then
                chInput = #chInput > 0 and string.sub(chInput, 1, #chInput - 1) or chInput
                chSelect = 1
            elseif key == keys.enter then
                chColors[#chColors+1] = chResult[chSelect][1]
                chInput = ""
                if #chColors == 3 then
                    return true
                end
            elseif key == keys.leftCtrl or key == keys.rightCtrl then
                quit()
            elseif key == keys.delete then
                chInput = ""
                chSelect = 1
            elseif key == keys.up and chSelect < #chResult then
                chSelect = chSelect + 1
            elseif key == keys.down and chSelect > 1 then
                chSelect = chSelect - 1
            end
        end
        chUpdate()
    end
end

function openAddMenu()
    if chSelector(#fluidData + 1) then
        print(chColors[1]+1)
        fluidStr[#fluidStr+1] = input .. " (" .. channels[chColors[1]] .. " - " .. channels[chColors[2]] .. " - " .. channels[chColors[3]] .. ")"
        local chColorChars = {}
        for i = 1, 3 do
            chColorChars[i] = string.format("%x", chColors[i] - 1)
        end
        fluidData[#fluidData+1] = {input, chColorChars[1], channels[chColors[1]], chColorChars[2], channels[chColors[2]], chColorChars[3], channels[chColors[3]]}
        save()
        return true
    end
end

function openEditMenu()
    local i = result[selection][1]
    if chSelector(i) then
        fluidStr[i] = fluidData[i][1] .. " (" .. channels[chColors[1]] .. " - " .. channels[chColors[2]] .. " - " .. channels[chColors[3]] .. ")"
        local chColorChars = {}
        for i = 1, 3 do
            chColorChars[i] = string.format("%x", chColors[i] - 1)
        end
        fluidData[i] = {fluidData[i][1], chColorChars[1], channels[chColors[1]], chColorChars[2], channels[chColors[2]], chColorChars[3], channels[chColors[3]]}
        save()
        return true
    end
end

function openRemoveMenu()
    menuSelection = 1
    term.setCursorPos(1, height - 1)
    term.clearLine()
    local i = result[selection][1]
    term.write("Are you sure? Fluid \"" .. fluidData[i][1] .. "\" will be deleted.")
    while true do
        options = {"Yes", "No"}
        drawMenu()
        local event, key, _ = os.pullEvent("key")
        if key == keys.left and menuSelection > 1 then
            menuSelection = menuSelection - 1
        elseif key == keys.right and menuSelection < #options then
            menuSelection = menuSelection + 1
        elseif key == keys.enter then
            if menuSelection == 1 then
                table.remove(fluidData, i)
                table.remove(fluidStr, i)
                save()
                return true
            elseif menuSelection == 2 then
                return false
            end
        elseif key == keys.leftCtrl or key == keys.rightCtrl then
            quit()
        end
    end
end

function save()
    local file = io.open(filename, "w")
    if file == nil then
        error("Error saving file. Sorry.")
    end
    for i = 1, #fluidData do
        file:write(fluidData[i][2] .. fluidData[i][4] .. fluidData[i][6] .. fluidData[i][1] .. "\n")
    end
    io.close(file)
end

function quit()
    term.clear()
    term.setCursorPos(1, 1)
    error()
end
        

-- actual program starts here

if fs.isDir("data") == false then
    fs.makeDir("data")
end

if arg[1] == "gen" then
    if confirm("Are you sure you want to generate a new data file? This will overwrite your old data file if you have one.", false) then
        local file = io.open(filename, "w")
        if file == nil then
            print("Error creating file. Sorry.")
        else
            print("File created. Run `etanks` to manage your tanks now.")
            io.close(file)
        end
    end
    return
end

local file = io.open(filename, "r")
if file == nil then
    print("No e-tank data found. To generate one, run `etanks gen`")
    return
end
io.close(file)

input = ""
fluidStr = {}
fluidData = {}
result = {}
selection = 1

local debugText = "" -- for testing purposes

function updateScreen()
    -- get the fuzzy search results
    result = fzy.filter(input, fluidStr, false)
    
    -- sort them
    table.sort(result, sortFzyOutput)
    
    term.clear()
    term.setBackgroundColor(colors.black)
    for i = 1, height-1 do
        if result[i] == nil then break end
        term.setCursorPos(1, height-i-2)
        
        if i == selection then
            term.setBackgroundColor(colors.white)
            term.setTextColor(colors.black)
        end
        local cur = fluidData[ result[i][1] ]
        term.write(cur[1])
        term.setBackgroundColor(colors.black)
        term.setTextColor(colors.white)
        
        term.write(" (")
        for i = 2, 6, 2 do
            if i ~= 2 then term.write(" - ") end
            if cur[i] == "f" then
                term.setTextColor(colors.white)
            else
                term.setTextColor(2^(tonumber(cur[i], 16)))
            end
            term.write(cur[i+1])
            term.setTextColor(colors.white)
        end
        term.write(")")
        --term.write(" (" .. result[i][3] .. ")")
    end
    term.setCursorPos(1, height-1)
    term.write(input)
    term.setCursorPos(1, height)
    term.setTextColor(colors.blue)
    term.write("Type to search, enter->add/manage fluid, ctrl->quit, del->delete text" .. debugText)
    term.setTextColor(colors.white)
end

for line in io.lines(filename) do
    local colorChars = {line[1], line[2], line[3]}
    local c = charToColor(colorChars)
    local fluid = string.sub(line, 4, #line)
    fluidStr[#fluidStr+1] = fluid .. " (" .. channels[c[1]] .. " - " .. channels[c[2]] .. " - " .. channels[c[3]] .. ")"
    fluidData[#fluidData+1] = {fluid, colorChars[1], channels[c[1]], colorChars[2], channels[c[2]], colorChars[3], channels[c[3]]}
end

updateScreen()

while true do
    local event, char, _ = os.pullEvent() -- events are yielded, no need for a sleep.
    if event == "char" then
        input = input .. char
        selection = 1
    end
    if event == "key" then
        --debugText = " " .. keys.getName(char)
        if char == keys.backspace then
            input = #input > 0 and string.sub(input, 1, #input - 1) or input
            selection = 1
        elseif char == keys.enter then
            if openManageMenu() then
                input = ""
            end
        elseif char == keys.leftCtrl or char == keys.rightCtrl then
            quit()
        elseif char == keys.delete then
            input = ""
            selection = 1
        elseif char == keys.up and selection < #result then
            selection = selection + 1
        elseif char == keys.down and selection > 1 then
            selection = selection - 1
        end
    end
    updateScreen()
end








