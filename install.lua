-- script to fetch and install etanks.lua easily

local etanksURL = "https://raw.githubusercontent.com/peachey2k2/etanks/main/etanks.lua"
local fzyURL = "https://raw.githubusercontent.com/peachey2k2/etanks/main/lib/fzy.lua"

local curFile

if not http then
    printError("HTTP API is disabled")
    printError("Set http/enabled to true in computercraft.cfg")
    return
end

if not fs.isDir("lib") then
    print("/lib doesn't exist. Creating...")
    fs.makeDir("lib")
end

print("Fetching etanks.lua")
curFile = fs.open("etanks.lua", "w")
if not curFile then
    printError("Failed to open etanks.lua for writing")
    return
end
curFile.write(http.get(etanksURL).readAll())
curFile.close()

print("Fetching fzy.lua")
curFile = fs.open("lib/fzy.lua", "w")
if not curFile then
    printError("Failed to open fzy.lua for writing")
    return
end
curFile.write(http.get(fzyURL).readAll())
curFile.close()

print("Done!") -- chess battle advanced

