
function GetCurrentGarage()
    local playerCoords = GetEntityCoords(PlayerPedId(), true)
    local closestDistance = nil
    local closestGarage = nil

    for _, garage in pairs(GarageConfig) do
        local distance = #(playerCoords - garage.menuCoords)

        if closestDistance == nil or distance < closestDistance then
            closestDistance = distance
            closestGarage = garage
        end
    end

    return closestGarage
end

function formatPrice(n)
    -- Convertir le nombre en chaîne de caractères
    local nombre_formate = tostring(n)
    
    -- Séparer les parties entière et décimale (s'il y a lieu)
    local parties = {}
    for partie in nombre_formate:gmatch("%d+") do
        table.insert(parties, partie)
    end
    
    local partie_entiere = parties[1]
    
    -- Formater la partie entière avec les virgules
    local partie_entiere_formatee = ""
    for i = #partie_entiere, 1, -1 do
        if (#partie_entiere - i) % 3 == 0 and i ~= #partie_entiere then
            partie_entiere_formatee = "," .. partie_entiere_formatee
        end
        partie_entiere_formatee = partie_entiere:sub(i, i) .. partie_entiere_formatee
    end
    
    -- Ajouter le symbole du dollar
    nombre_formate = partie_entiere_formatee .. "$"
    
    return nombre_formate
end

function ConfirmChangeGarage(Title, vehicle, vehicles, parking)
    AddTextEntry('FMMC_KEY_TIP1', Title) -- Sets the Text Entry
    DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "", "", "", "", "", 20)

    while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
        Citizen.Wait(0)
    end

    if UpdateOnscreenKeyboard() == 1 then
        local confirmation = GetOnscreenKeyboardResult()

        if confirmation:upper() == "OUI" then
            if getNumberVehicles(vehicles) >= Config.vehicleLimit then
                ESX.ShowNotification("~r~Vous n'avez pas de place dans ce parking.")
            else
                RageUI.CloseAll()
                isMenuOpened = false
                TriggerServerEvent("garage:returnVehicleGarage", vehicle, parking)
            end
        else
            ESX.ShowNotification("Le véhicule " .. GetDisplayNameFromVehicleModel(vehicle.model) .. " n'as pas été ramener.")
        end
    else
        ESX.ShowNotification("Le changement de garage du véhicule : " .. GetDisplayNameFromVehicleModel(vehicle.model) .. " à été annuler")
    end
end

function FindMatchingGarage(position)
    for _, garage in pairs(GarageConfig) do
        if tostring(garage.menuCoords) == tostring(position) then
            return garage.garageName
        end
    end
    return nil
end

function getNumberVehicles(vehicles, menuCoords)
    local count = 0
    for _, v in ipairs(vehicles) do
        local props = v.vehicle
        local garage = props.position
        if garage == tostring(menuCoords) then
           count = count + 1
        end
    end
    return count
end

function getVehicleProps(vehicle)
    local properties = ESX.Game.GetVehicleProperties(vehicle)
    return properties
end

function getIndexGarage(garages)
    local index = 1
    for i,garage in ipairs(garages) do
        if garage == GetCurrentGarage().garageName then
            index = i
        end
    end
    return index
end

function modifyCarData(carData, doorsBroken, engineHealth, bodyHealth, tankHealth, windowsBroken, fuelLevel)
    -- Update the specified values
    carData.doorsBroken = doorsBroken
    carData.engineHealth = engineHealth
    carData.bodyHealth = bodyHealth
    carData.tankHealth = tankHealth
    carData.windowsBroken = windowsBroken
    carData.fuelLevel = fuelLevel

    return carData
end

function checkVehicleInGarage(vehicles, plate)
    local result = false
    for _, v in ipairs(vehicles) do
        local props = v.vehicle
        local plate = string.gsub(plate, "%s+$", "")
        local position = props.position
        if props.plate == plate and tostring(GetCurrentGarage().menuCoords) == tostring(position) then
            result = true
        end
    end
    return result
end