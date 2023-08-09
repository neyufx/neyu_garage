ESX = exports["es_extended"]:getSharedObject()

ESX.RegisterServerCallback('garage:getOwnedVehicles', function(source, callback)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        local ownedVehicles = {}

        MySQL.Async.fetchAll('SELECT * FROM owned_vehicles WHERE owner = @owner', {
            ['@owner'] = xPlayer.identifier
        }, function(result)
            for _, vehicle in ipairs(result) do
                local vehicleData = json.decode(vehicle.vehicle)
                local model = vehicleData.model
                local plate = vehicleData.plate
                local isImpounded = vehicle.pound
                local isStored = vehicle.stored
                local position = vehicle.parking
                table.insert(ownedVehicles, {
                    vehicle = {
                        vehicle = vehicleData,
                        model = model,
                        plate = plate,
                        isImpounded = isImpounded,
                        isStored = isStored,
                        position = position
                    }
                })
            end

            callback(ownedVehicles)
        end)
    else
        callback({})
    end
end)

-- Partie SQL dans le côté serveur

ESX.RegisterServerCallback('garage:checkVehicle', function(source, callback, plate)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        MySQL.Async.fetchScalar('SELECT stored FROM owned_vehicles WHERE plate = @plate AND stored = 1', {
            ['@plate'] = plate
        }, function(result)
            if result and tonumber(result) > 0 then
                callback(true) -- Le véhicule est déjà rangé (stored = 1)
            else
                callback(false) -- Le véhicule n'est pas rangé (stored = 0 ou non trouvé)
            end
        end)
    else
        callback(false) -- Statut inconnu
    end
end)

RegisterServerEvent('garage:returnVehicleGarage')
AddEventHandler('garage:returnVehicleGarage', function(vehicle, parking)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    local query = "UPDATE owned_vehicles SET parking = @parking WHERE plate = @plate"
    local params = {
        ['@plate'] = vehicle.plate,
        ['@parking'] = tostring(parking)
    }
    local money = xPlayer.getAccount('bank').money
    local amount = Config.returnPrice
	if amount > money then
		TriggerClientEvent('esx:showNotification', source, "~r~Vous n'avez pas assez d'argent en banque.")
	else
		xPlayer.removeAccountMoney('bank', amount)
		TriggerClientEvent('esx:showNotification', source,"~g~Vous avez payez " .. formatPrice(amount) .. " pour ramener votre véhicule.")
        MySQL.Async.execute(query, params)
	end
end)

RegisterServerEvent('garage:spawnVehicle')
AddEventHandler('garage:spawnVehicle', function (props, spawnCoords, heading)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)

    -- Récupérer les propriétés du véhicule à partir de la base de données
    MySQL.Async.fetchAll('SELECT * FROM owned_vehicles WHERE plate = @plate AND owner = @owner', {
        ['@plate'] = props.plate,
        ['@owner'] = xPlayer.identifier
    }, function(result)
        if result and #result > 0 then
            -- Récupérer les propriétés du premier véhicule trouvé
            if result[1].stored == 1 then
                local vehicleProps = json.decode(result[1].vehicle)

                ESX.OneSync.SpawnVehicle(props.model, spawnCoords, heading, vehicleProps, function (id)
                    local vehicle = NetworkGetEntityFromNetworkId(id)
                    for _ = 1, 20 do
                        Wait(0)
                        SetPedIntoVehicle(GetPlayerPed(source), vehicle, -1)
        
                        if GetVehiclePedIsIn(GetPlayerPed(source), false) == vehicle then
                            break
                        end
                    end
                    --TaskWarpPedIntoVehicle(GetPlayerPed(source), vehicle, -1)

                    TriggerClientEvent('esx:showNotification', source, "Votre véhicule a été sorti de votre garage.", "success")
                end)
            else
                TriggerClientEvent('esx:showNotification', source, "Ce véhicule est déjà sorti.")
            end
        else
            -- Le véhicule n'a pas été trouvé dans la base de données ou le joueur n'est pas le propriétaire
            TriggerClientEvent('esx:showNotification', source, "Ce véhicule ne vous appartient pas.")
        end
    end)
end)


RegisterServerEvent('garage:updateVehicle')
AddEventHandler('garage:updateVehicle', function(plate, stored, parking, props)
    local source = source
    -- Effectuer la mise à jour du statut du véhicule dans la BDD

    MySQL.Async.fetchAll('SELECT * FROM owned_vehicles WHERE plate = @plate', {
        ['@plate'] = plate
    }, function(result)
        if result then
            local updatedProps 
            for _, vehicle in ipairs(result) do
                local vehProps = json.decode(vehicle.vehicle)
                updatedProps = json.encode(modifyCarData(vehProps, props.doorsBroken, props.engineHealth, props.bodyHealth, props.tankHealth, props.windowsBroken, props.fuelLevel))
            end
            local query = "UPDATE owned_vehicles SET stored = @stored, parking = @parking, vehicle = @vehicle WHERE plate = @plate"
            local params = {
                ['@plate'] = plate,
                ['@stored'] = stored,
                ['@parking'] = tostring(parking),
                ['@vehicle'] = updatedProps
            }
            MySQL.Async.execute(query, params)
        end
    end)
end)

RegisterServerEvent('garage:sortieVehicle')
AddEventHandler('garage:sortieVehicle', function(plate, stored)
    local query = "UPDATE owned_vehicles SET stored = @stored WHERE plate = @plate"
    local params = {
        ['@plate'] = plate,
        ['@stored'] = stored
    }
    MySQL.Async.execute(query, params)
end)

RegisterServerEvent('garage:deleteVehicle')
AddEventHandler('garage:deleteVehicle', function(plate)
    -- Effectuer ici les vérifications nécessaires avant la suppression du véhicule (par exemple, propriété du joueur, autorisation, etc.)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    -- Supprimer le véhicule

    MySQL.Async.fetchScalar('SELECT owner FROM owned_vehicles WHERE owner = @owner AND plate = @plate', {
        ['@owner'] = xPlayer.identifier,
        ['@plate'] = plate
    }, function (result)
        if result then
            MySQL.Async.execute("DELETE FROM owned_vehicles WHERE owner = @owner AND plate = @plate", {
                ['@owner'] = xPlayer.identifier,
                ['@plate'] = plate
            })
        else
            exports.bulletin:Send({
                message = "Ce n'est pas votre véhicule.",
                timeout = 3000,
                theme = 'default'
            })
            TriggerClientEvent('esx:showNotification', _source, "Ce n'est pas votre véhicule.")
        end
    end)
    
end)

-- Fonction pour réinitialiser toutes les colonnes "stored" à 1 dans la table "owned_vehicles"
function ResetOwnedVehiclesStoredStatus()
    MySQL.Async.execute("UPDATE owned_vehicles SET stored = 1", {})
end

ResetOwnedVehiclesStoredStatus()