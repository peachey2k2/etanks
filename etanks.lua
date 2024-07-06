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
        

-- actual program starts here
if arg[1] == "help" then
    print([[
        test
        test
    ]])
    return
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

local width, height = term.getSize()
local input = ""
local fluidStr = {}
local fluidData = {}
local result = {}
local selection = 1

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
            term.setTextColor(colors.fromBlit(cur[i]))
            term. write(cur[i+1])
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
    local colorChars = string.sub(line, 1, 3)
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
            --
        elseif char == keys.leftCtrl or char == keys.rightCtrl then
            term.clear()
            term.setCursorPos(1, 1)
            return
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








