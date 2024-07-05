-- etanks.lua, made by peachey2k2
-- under MIT license.

fzy = require("lib/fzy")
filename = "data/etankdata.txt"

channels = {
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
local fluids = {}

local debugText = "" -- for testing purposes

function updateScreen()
    local result = fzy.filter(input, fluids, false)
    term.clear()
    term.setBackgroundColor(colors.black)
    for i = 1, height-1 do
        if result[i] == nil then break end
        term.setCursorPos(1, height-i-2)
        term.write(fluids[result[i][1]])
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
    local colorStr = channels[c[1]] .. " - " .. channels[c[2]] .. " - " .. channels[c[3]]
    fluids[#fluids+1] = string.sub(line, 4, #line) .. " (" .. colorStr .. ")"
    print(#fluids)
end

updateScreen()

while true do
    local event, char, _ = os.pullEvent() -- events are yielded, no need for a sleep.
    if event == "char" then
        input = input .. char
    end
    if event == "key" then
        --debugText = " " .. keys.getName(char)
        if char == keys.backspace then
            input = #input > 0 and string.sub(input, 1, #input - 1) or input
        end
        if char == keys.enter then
            --
        end
        if char == keys.leftCtrl or char == keys.rightCtrl then
            term.clear()
            term.setCursorPos(1, 1)
            return
        end
        if char == keys.delete then
            input = ""
        end
    end
    updateScreen()
end








