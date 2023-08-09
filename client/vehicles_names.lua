function AddTextEntry(key, value)
    Citizen.InvokeNative(GetHashKey("ADD_TEXT_ENTRY"), key, value)
end
    
Citizen.CreateThread(function()
    -- Audi -- 
    AddTextEntry('RS4AVANT', 'Audi RS4 Avant')

    -- Dodge Challenger --
    AddTextEntry('RAID', 'Dodge Challenger Raid')
end)