ESX = exports["es_extended"]:getSharedObject()

local vehicleLimit = Config.vehicleLimit
local vehicleCount = 0
local selectedVehicle = nil

-- Fonction pour recevoir le nombre de véhicules côté client
RegisterNetEvent('GetVehicleCount')
AddEventHandler('GetVehicleCount', function(count)
    vehicleCount = count -- Met à jour la variable vehicleCount avec la valeur reçue du serveur
end)

local garageNames = {}
local garageCoords = {}

isMenuOpened = false

if #garageNames <= 0 then
    for i = 1, #GarageConfig do
        table.insert(garageNames, GarageConfig[i].garageName)
    end
end

if #garageCoords <= 0 then
    for i = 1, #GarageConfig do
        table.insert(garageCoords, GarageConfig[i].menuCoords)
    end
end


function OpenMenuGarage(garageName)
    local index = {
        garage = getIndexGarage(garageNames)
    }
    MainMenu = RageUI.CreateMenu(garageName, ' ')
    MainMenu.Closed = function()
        isMenuOpened = false
    end
    SubMenu = RageUI.CreateSubMenu(MainMenu, 'Garage', ' ')
    
    if isMenuOpened then
        isMenuOpened = false
        RageUI.Visible(MainMenu, false)
        return
    else
        isMenuOpened = true
        CreateThread(function()
            ESX.TriggerServerCallback('garage:getOwnedVehicles', function(ownedVehicles)
                RageUI.Visible(MainMenu, true) -- Rendre le menu principal visible
                while isMenuOpened do
                    RageUI.IsVisible(MainMenu, function()
                        if #ownedVehicles > 0 then
                            RageUI.Separator("↓     ~b~" .. getNumberVehicles(ownedVehicles, garageCoords[index.garage] ) .. "/" .. vehicleLimit .. " Véhicule(s)     ~s~↓")
                            RageUI.List("Garage", garageNames, index.garage, nil, {}, true, {
                                onListChange = function(Index, Item)
                                    index.garage = Index
                                end
                            })
                            RageUI.Line()
                            local hasDisplayedVehicle = false

                            for k, v in ipairs(ownedVehicles) do
                                local props = v.vehicle
                                local isImpounded = props.isImpounded
                                local nameVehicle = GetDisplayNameFromVehicleModel(props.model)
                                local garage = props.position

                                if not isImpounded and tostring(garage) == tostring(GarageConfig[index.garage].menuCoords) then
                                    RageUI.Button(nameVehicle .. ' ~s~[' .. props.plate .. ']', nil, { RightLabel = '→' }, true, {
                                        onSelected = function()
                                            selectedVehicle = props
                                        end
                                    }, SubMenu)

                                    hasDisplayedVehicle = true
                                end
                            end

                            if not hasDisplayedVehicle then
                                RageUI.Separator("~s~ [ Aucun ] ")
                            end
                        else
                            RageUI.Separator("↓     ~b~Véhicule(s) dans votre garage     ~s~↓")
                            RageUI.Separator("~s~ [ Aucun ] ")
                        end
                    end)
                    RageUI.IsVisible(SubMenu, function()
                        RageUI.Button("Sortir", "Sortir le véhicule", { RightLabel = "" }, true, {
                            onSelected = function()
                                    if(getNumberVehicles(ownedVehicles) <= vehicleLimit) then
                                        SpawnVehicle(selectedVehicle) -- Vérifier le statut du véhicule avant de le sortir
                                        RageUI.CloseAll()
                                        isMenuOpened = false
                                    else
                                        exports.bulletin:Send({
                                            message = 'Vous avez atteint la limite de véhicule : ' .. vehicleLimit,
                                            timeout = 3000,
                                            theme = 'default'
                                        })
                                        RageUI.CloseAll()
                                        isMenuOpened = false
                                    end                     
                            end
                        })

                        RageUI.Button("Ramener le véhicule" .. " (~g~" .. formatPrice(Config.returnPrice) .. "~s~)", "Ramener le véhicule à ce garage", {}, true, {
                            onSelected = function()
                                if tostring(selectedVehicle.position) == tostring(GetCurrentGarage().menuCoords) then
                                    ESX.ShowNotification("~r~Ce véhicule est déjà dans ce garage.")
                                else
                                    ConfirmChangeGarage('~g~Entrez "Oui" pour ramenez le véhicule : ', selectedVehicle, ownedVehicles, GetCurrentGarage().menuCoords)
                                end
                            end
                        })

                        RageUI.Button("~r~Supprimer~s~", "Supprimer le véhicule", { RightLabel = "~r~→~s~" }, true, {
                            onSelected = function()
                                local vehicle = selectedVehicle
                                local plate = vehicle.plate
                                local nameVehicle = GetLabelText(GetDisplayNameFromVehicleModel(vehicle.model))
                    
                                -- Afficher le clavier à l'écran pour demander la confirmation
                                AddTextEntry('FMMC_KEY_TIP1', '~g~Entrez "Oui" pour supprimer le véhicule : ' .. nameVehicle)
                                DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "", "", "", "", "", 20)
                    
                                while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
                                    Citizen.Wait(0)
                                end
                    
                                if UpdateOnscreenKeyboard() == 1 then
                                    local confirmation = GetOnscreenKeyboardResult()
                    
                                    if confirmation:upper() == "OUI" then
                                        -- Supprimer le véhicule
                                        exports.bulletin:Send({
                                            message = 'Votre véhicule a été supprimé.',
                                            timeout = 3000,
                                            theme = 'default'
                                        })
                                        TriggerServerEvent("garage:deleteVehicle", plate)
                                        -- Fermer tous les menus
                                        RageUI.CloseAll()
                                        isMenuOpened = false
                                    else
                                        exports.bulletin:Send({
                                            message = 'Le véhicule n\'a pas été supprimé.',
                                            timeout = 3000,
                                            theme = 'default'
                                        })
                                    end
                                else
                                    -- Annuler la suppression du véhicule
                                    exports.bulletin:Send({
                                        message = 'Suppression du véhicule annulée.',
                                        timeout = 3000,
                                        theme = 'default'
                                    })
                                end
                            end
                        })
                    end)
                    Wait(0)
                end
            end)
        end)
    end
end

function ShowNotification(message)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(message)
    DrawNotification(0, 1)
end

function IsSpawnPointOccupied(coords, maxDistance)
    return not ESX.Game.IsSpawnPointClear(coords, maxDistance)
end

function SpawnVehicle(props)
    local garage = GetCurrentGarage()

    if not garage then
        return
    end

    local spawnCoords = nil
    local heading = nil
    if Config.splitGarages then
        local matchGarage = tostring(props.position) == tostring(GetCurrentGarage().menuCoords)
        if matchGarage then
            for _, spawnPoint in ipairs(garage.vehicleSpawnCoords) do
                if not IsSpawnPointOccupied(spawnPoint.coord, garage.maxDistance) then
                    spawnCoords = spawnPoint.coord
                    heading = spawnPoint.heading
                    break
                end
            end
            if not spawnCoords then
                exports.bulletin:Send({
                    message = 'Tous les points de sortie sont occupés. Veuillez réessayer plus tard.',
                    timeout = 3000,
                    theme = 'default'
                })
                return
            end
            TriggerServerEvent("garage:spawnVehicle", props, spawnCoords, heading)
            TriggerServerEvent("garage:sortieVehicle", props.plate, false)
        else
            local matchedGarage = FindMatchingGarage(props.position)
            exports.bulletin:Send({
                message = 'Ce véhicule est dans le garage : ~b~' .. matchedGarage,
                timeout = 3000,
                theme = 'default'
            })
        end
    else
        for _, spawnPoint in ipairs(garage.vehicleSpawnCoords) do
            if not IsSpawnPointOccupied(spawnPoint.coord, garage.maxDistance) then
                spawnCoords = spawnPoint.coord
                heading = spawnPoint.heading
                break
            end
        end
        if not spawnCoords then
            exports.bulletin:Send({
                message = 'Tous les points de sortie sont occupés. Veuillez réessayer plus tard.',
                timeout = 3000,
                theme = 'default'
            })
            return
        end
        TriggerServerEvent("garage:spawnVehicle", props, spawnCoords, heading)
        TriggerServerEvent("garage:sortieVehicle", props.plate, false)
    end
end


function UpdateVehicle(plate, stored, parking, props)
    TriggerServerEvent('garage:updateVehicle', plate, stored, parking, props)
end

Citizen.CreateThread(function()
    while true do
        local interval = 250
        local pos = GetEntityCoords(PlayerPedId())
        for i = 1, #GarageConfig do
            local garage = GarageConfig[i]
            local distance = #(pos - garage.menuCoords)
            if distance <= 15.0 then
                interval = 2
                DrawMarker(6, garage.menuCoords.x, garage.menuCoords.y, garage.menuCoords.z - 0.99, 0.0, 0.0, 0.0, 270.0, 0.0, 0.0, 1.5, 1.5, 1.5, 91, 211, 247, 177, 0, 1, 2, 0, nil, nil, 0)
                if distance < 3.0 then
                    AddTextEntry("Menu", "Appuyez sur ~INPUT_CONTEXT~ ~s~pour accéder au ~b~Garage~s~.")
                    DisplayHelpTextThisFrame("Menu", false)
                    if IsControlJustReleased(0, 38) then -- Touche E
                        OpenMenuGarage(GetCurrentGarage().garageName)
                    end
                end
            end
        end
        Wait(interval)
    end
end)

-- Fonction pour ranger un véhicule
function RangerVehicule(plate)
    ESX.TriggerServerCallback('garage:getOwnedVehicles', function(ownedVehicles)
        checkVehicleInGarage(ownedVehicles, plate)
        if not checkVehicleInGarage(ownedVehicles, plate) and getNumberVehicles(ownedVehicles) >= Config.vehicleLimit then
            exports.bulletin:Send({
                message = '~r~Vous avez atteint la limite de véhicule.',
                timeout = 3000,
                theme = 'default'
            })
            return
        end
        local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
        local vehicleProps = getVehicleProps(vehicle)
        local parking = GetCurrentGarage().menuCoords
        UpdateVehicle(plate, true, parking, vehicleProps)
        DeleteVehicle(vehicle)
        exports.bulletin:Send({
            message = '~g~Votre véhicule à été ranger dans votre garage.',
            timeout = 3000,
            theme = 'default'
        })
    end)
end

Citizen.CreateThread(function()
    while true do
        local interval = 250
        local pos = GetEntityCoords(PlayerPedId())
        for i = 1, #GarageConfig do
            local garage = GarageConfig[i]
            local distance = #(pos - garage.vehicleReturnCoords)
            if distance <= 15.0 then
                interval = 0
                DrawMarker(6, garage.vehicleReturnCoords.x, garage.vehicleReturnCoords.y, garage.vehicleReturnCoords.z - 0.99, 0.0, 0.0, 0.0, 270.0, 0.0, 0.0, 1.5, 1.0, 1.5, 255, 59, 79, 177, 0, 1, 2, 0, nil, nil, 0)
                if distance < 5.0 then
                    AddTextEntry("Menu", "Appuyez sur ~INPUT_CONTEXT~ ~s~pour ranger votre ~r~Véhicule~s~.")
                    DisplayHelpTextThisFrame("Menu", false)
                    if IsControlJustReleased(0, 38) then -- Touche E
                        local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
                        if DoesEntityExist(vehicle) then
                            local plate = GetVehicleNumberPlateText(vehicle)
                            RangerVehicule(plate)
                        end
                    end
                end
            end
        end
        Wait(interval)
    end
end)

-- Ajouter un blip pour chaque garage
for i = 1, #GarageConfig do
    local garage = GarageConfig[i]
    local blip = AddBlipForCoord(garage.menuCoords.x, garage.menuCoords.y, garage.menuCoords.z)
    SetBlipSprite(blip, 357) -- Sprite du blip (vous pouvez changer la valeur en fonction de votre choix)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 0.6)
    SetBlipColour(blip, 3) -- Couleur du blip (vous pouvez changer la valeur en fonction de votre choix)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(garage.garageName)
    EndTextCommandSetBlipName(blip)
end