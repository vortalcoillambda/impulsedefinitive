/*
** Copyright (c) 2017 Jake Green (TheVingard)
** This file is private and may not be shared, downloaded, used or sold.
*/

-- Uses https://github.com/FredyH/MySQLOO/releases

function IMPULSE:DatabaseConnected()
    local sqlQuery = mysql:Create("impulse_players") -- if not table exist, make it.
        sqlQuery:Create("id", "int unsigned NOT NULL AUTO_INCREMENT") -- index
        sqlQuery:Create("rpname", "varchar(70) NOT NULL") -- rpname
        sqlQuery:Create("steamid", "varchar(25) NOT NULL") -- steamid
        sqlQuery:Create("group", "varchar(70) NOT NULL") -- usergroup
        sqlQuery:Create("rpgroup", "int(11) unsigned NOT NULL") -- rpgroup
        sqlQuery:Create("xp", "int(11) unsigned DEFAULT NULL") -- xp
        sqlQuery:Create("money", "int(11) unsigned DEFAULT NULL") -- money
        sqlQuery:Create("bankmoney", "int(11) unsigned DEFAULT NULL") -- banked money
        sqlQuery:Create("skills", "longtext") -- json skill data seperated from data to avoid corrruption
        sqlQuery:Create("model", "varchar(160) NOT NULL") -- model
        sqlQuery:Create("skin", "tinyint") -- skin
        sqlQuery:Create("cosmetic", "longtext") -- cosmetic extra data
        sqlQuery:Create("data", "longtext") -- general data
        sqlQuery:Create("firstjoin", "int(11) unsigned NOT NULL") -- first join date
        sqlQuery:PrimaryKey("id")
    sqlQuery:Execute()

    local sqlQuery = mysql:Create("impulse_inventory") -- if not table exist, make it.
        sqlQuery:Create("id", "int unsigned NOT NULL AUTO_INCREMENT") -- index
        sqlQuery:Create("uniqueid", "varchar(25) NOT NULL") -- string unique itemid
        sqlQuery:Create("ownerid", "int(11) unsigned DEFAULT NULL") -- owner db id
        sqlQuery:Create("storagetype", "tinyint NOT NULL") -- where item is stored
        sqlQuery:PrimaryKey("id")
    sqlQuery:Execute()

    local sqlQuery = mysql:Create("impulse_reports")
        sqlQuery:Create("id", "int unsigned NOT NULL AUTO_INCREMENT")
        sqlQuery:Create("reporter", "varchar(25) NOT NULL")
        sqlQuery:Create("mod", "varchar(25) NOT NULL")
        sqlQuery:Create("message", "text")
        sqlQuery:Create("start", "datetime")
        sqlQuery:Create("claimwait", "int(11) unsigned NOT NULL")
        sqlQuery:Create("closewait", "int(11) unsigned NOT NULL")
        sqlQuery:PrimaryKey("id")
    sqlQuery:Execute()

    local sqlQuery = mysql:Create("impulse_whitelists")
        sqlQuery:Create("id", "int unsigned NOT NULL AUTO_INCREMENT")
        sqlQuery:Create("steamid", "varchar(25) NOT NULL")
        sqlQuery:Create("team", "varchar(90) NOT NULL")
        sqlQuery:Create("level", "int(11) unsigned NOT NULL")
        sqlQuery:PrimaryKey("id")
    sqlQuery:Execute()

    local sqlQuery = mysql:Create("impulse_refunds")
        sqlQuery:Create("id", "int unsigned NOT NULL AUTO_INCREMENT")
        sqlQuery:Create("steamid", "varchar(25) NOT NULL")
        sqlQuery:Create("item", "varchar(75) NOT NULL")
        sqlQuery:Create("date", "int(11) unsigned NOT NULL")
        sqlQuery:PrimaryKey("id")
    sqlQuery:Execute()
end

timer.Create("impulsedb.Think", 1, 0, function()
    mysql:Think()
end)