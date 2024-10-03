--- the usage will depend on this (0.01-0.03ms per hologram)
local MAX_AMOUNT_OF_HOLOGRAMS = 3

local holograms = {
    --{ coords = vec3(999.9, -999.9, 999.9), text = "~w~This is a test", range = 20.0 },
    --{ coords = vec3(-111.1, 111.1, 111.1), text = "~w~[~o~INPUT~w~] This is a test to show how to open something", range = 10.0 },
}

function RotationToDirection(rotation)
    local adjustedRotation = {
        x = math.rad(rotation.x),
        y = math.rad(rotation.y),
        z = math.rad(rotation.z)
    }

    local direction = vec3(
        -math.sin(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
        math.cos(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
        math.sin(adjustedRotation.x)
    )

    return direction
end

function ZobrazitText(x, y, z, textInput, fontId, scaleX, scaleY)
    local px, py, pz = table.unpack(GetGameplayCamCoords())
    local dist = #(vec3(px, py, pz) - vec3(x, y, z))
    local scale = (1 / dist) * 20
    local fov = (1 / GetGameplayCamFov()) * 100
    scale = scale * fov

    SetTextScale(scaleX * scale, scaleY * scale)
    RegisterFontFile('BBN')
    fontId = RegisterFontId('BBN')
    SetTextFont(fontId)
    SetTextProportional(1)
    --SetTextColour(250, 250, 250, 255)
    --SetTextDropshadow(1, 1, 1, 1, 255)
    --SetTextEdge(2, 0, 0, 0, 150)
    --SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(textInput)
    SetDrawOrigin(x, y, z + 2, 0)
    DrawText(0.0, 0.0)
    ClearDrawOrigin()
end

function IsPlayerLookingAtCoords(cameraCoords, targetCoords)
    local camRot = GetGameplayCamRot(2)
    local camDir = RotationToDirection(camRot)
    local directionToHologram = targetCoords - cameraCoords

    directionToHologram = directionToHologram / #directionToHologram

    local dotProduct = camDir.x * directionToHologram.x + camDir.y * directionToHologram.y + camDir.z * directionToHologram.z

    return dotProduct > 0.7
end

function GetNearestHolograms(playerCoords)
    local nearestHolograms = {}
    
    for _, hologram in ipairs(holograms) do
        local dist = #(playerCoords - hologram.coords)
        
        if #nearestHolograms < MAX_AMOUNT_OF_HOLOGRAMS then
            table.insert(nearestHolograms, { hologram = hologram, distance = dist })
        else
            local maxIndex = 1
            for i = MAX_AMOUNT_OF_HOLOGRAMS, #nearestHolograms do
                if nearestHolograms[i].distance > nearestHolograms[maxIndex].distance then
                    maxIndex = i
                end
            end
            
            if dist < nearestHolograms[maxIndex].distance then
                nearestHolograms[maxIndex] = { hologram = hologram, distance = dist }
            end
        end
    end
    
    return nearestHolograms
end

function ShouldCheckHologram(playerCoords, hologram)
    return #(playerCoords - hologram.coords) < (hologram.range + 50.0)
end

Citizen.CreateThread(function()
    sleep = 4
    while true do
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local cameraCoords = GetGameplayCamCoords()

        local nearestHolograms = GetNearestHolograms(playerCoords)

        local _a = 0
        for _, hologramData in ipairs(nearestHolograms) do
            local hologram = hologramData.hologram
            local dist = hologramData.distance

            if dist < hologram.range and IsPlayerLookingAtCoords(cameraCoords, hologram.coords) then
                sleep = 4
                _a += 1
                ZobrazitText(hologram.coords.x, hologram.coords.y, hologram.coords.z - 1.4, hologram.text, 4, 0.1, 0.1)
            end
        end

        if _a == 0 then
            sleep = 500
        end

        Citizen.Wait(sleep)
    end
end)
