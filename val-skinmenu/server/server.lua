ESX = nil
local callbacksRegistered = false
local callbackPrefix = scriptName or GetCurrentResourceName()

CreateThread(function()
    while ESX == nil do
        TriggerEvent(Config["Router"], function(obj)
            ESX = obj
        end)
        Wait(0)
    end
end)

local function getPlayerFromSource(source)
    if source == nil then
        return nil
    end

    return ESX.GetPlayerFromId(source)
end

local function getPrice(skinIndex, priceType)
    if not skinIndex or not priceType then
        return nil
    end

    local shop = Config["SkinPosition"][skinIndex]
    if not shop or not shop.Price then
        return nil
    end

    local price = shop.Price[priceType]
    if type(price) ~= "number" then
        return nil
    end

    if price < 0 then
        return nil
    end

    return math.floor(price)
end

local function hasEnoughMoney(xPlayer, amount)
    return xPlayer.getMoney() >= amount
end

local function registerHandlers()
    if callbacksRegistered or ESX == nil then
        return
    end

    callbacksRegistered = true

    ESX.RegisterServerCallback(callbackPrefix .. '::CheckMoneyBuy', function(source, cb, skinIndex)
        local xPlayer = getPlayerFromSource(source)
        if not xPlayer then
            cb(false)
            return
        end

        local price = getPrice(skinIndex, "BuyPrice")
        if not price then
            cb(false)
            return
        end

        cb(hasEnoughMoney(xPlayer, price))
    end)

    ESX.RegisterServerCallback(callbackPrefix .. '::CheckMoneyAddFavorite', function(source, cb, skinIndex)
        local xPlayer = getPlayerFromSource(source)
        if not xPlayer then
            cb(false)
            return
        end

        local price = getPrice(skinIndex, "AddFavorite")
        if not price then
            cb(false)
            return
        end

        cb(hasEnoughMoney(xPlayer, price))
    end)

    RegisterNetEvent(callbackPrefix .. ':RemoveMoney')
    AddEventHandler(callbackPrefix .. ':RemoveMoney', function(skinIndex, priceType)
        local source = source
        local xPlayer = getPlayerFromSource(source)
        if not xPlayer then
            return
        end

        local price = getPrice(skinIndex, priceType)
        if not price or price <= 0 then
            return
        end

        if not hasEnoughMoney(xPlayer, price) then
            return
        end

        xPlayer.removeMoney(price)
    end)
end

CreateThread(function()
    while ESX == nil do
        Wait(0)
    end

    registerHandlers()
end)
