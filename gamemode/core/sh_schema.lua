/*
** Copyright (c) 2017 Jake Green (TheVingard)
** This file is private and may not be shared, downloaded, used or sold.
*/

impulse.schema = impulse.schema or {}

function impulse.schema.boot(name)
    SCHEMA = name
    MsgC( Color( 83, 143, 239 ), "[IMPULSE] Loading '"..SCHEMA.."' schema...\n" )
    impulse.lib.includeDir(SCHEMA.."/schema/teams")
    impulse.lib.includeDir(SCHEMA.."/schema/npcs")
    impulse.lib.includeDir(SCHEMA.."/schema/config")

    local mapPath = SCHEMA.."/schema/config/maps/"..game.GetMap()..".lua"
    if file.Exists("gamemodes/"..mapPath, "GAME") then
    	MsgC( Color( 83, 143, 239 ), "[IMPULSE] Loading map config for '"..game.GetMap().."'\n" )
    	include(mapPath)
    	AddCSLuaFile(mapPath)

        if impulse.Config.BlacklistEnts then
            for v,k in pairs(ents.GetAll()) do
                if impulse.Config.BlacklistEnts[k:GetClass()] then
                    k:Remove()
                end
            end
        end
	end

    impulse.lib.includeDir(SCHEMA.."/schema/scripts")

    for files, dir in ipairs(file.Find(SCHEMA.."/plugins/*", "LUA")) do
        MsgC( Color( 83, 143, 239 ), "[IMPULSE] ["..SCHEMA.."] Loading plugin '"..dir.."'\n" )
	    impulse.lib.includeDir(SCHEMA.."/plugins/"..dir)
    end

    hook.Call("OnSchemaLoaded", IMPULSE)
end
