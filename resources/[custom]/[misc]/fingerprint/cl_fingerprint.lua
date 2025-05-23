local QBCore = exports['qb-core']:GetCoreObject()
local PlayerJob = {}

--

UseMDT = false -- Set to true if you want to use MDT option on the fingerprint menu. (true/false)

Event = "randol_fingerprint:client:psmdt" -- The event to trigger for your MDT. (I MADE A PS-MDT EVENT TO TRIGGER BY DEFAULT SO IF YOU USE PS-MDT, LEAVE IT AS IT IS.)

--

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        PlayerJob = QBCore.Functions.GetPlayerData().job
    end
end)

AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    PlayerJob = QBCore.Functions.GetPlayerData().job
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
    PlayerJob = JobInfo
end)

RegisterNetEvent('randol:client:policetablet') 
AddEventHandler('randol:client:policetablet', function()
    if PlayerJob.name == "police" then
        local player, distance = QBCore.Functions.GetClosestPlayer()
        local plyerid = nil
        if player ~= -1 and distance < 2.5 then
            playerId = GetPlayerServerId(player)
        else
            return QBCore.Functions.Notify("Nobody close enough to scan.", "error")
        end

        TriggerEvent('animations:client:EmoteCommandStart', {"tablet2"})
        QBCore.Functions.Progressbar("scan_finger", "Attempting to scan finger..", 5000, false, true, {
            disableMovement = false,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = false,
        }, {}, {}, {}, function() -- Done
            TriggerEvent('animations:client:EmoteCommandStart', {"c"})
            TriggerServerEvent("randolio:server:fingerprintmenu", playerId)
        end, function() -- Cancel
            TriggerEvent('animations:client:EmoteCommandStart', {"c"})
            QBCore.Functions.Notify("You stopped what you were doing.", "error")
        end)
    else
        QBCore.Functions.Notify("This tablet is encrypted.", "error")
    end
end)

RegisterNetEvent('randol_fingerprint:client:psmdt', function()
    local plyPed = PlayerPedId()
    PlayerData = QBCore.Functions.GetPlayerData()
    if not PlayerData.metadata["isdead"] and not PlayerData.metadata["inlaststand"] and not PlayerData.metadata["ishandcuffed"] and not IsPauseMenuActive() then
        if GetJobType(PlayerData.job.name) ~= nil then 
            if PlayerData.job.onduty then
                TriggerServerEvent('mdt:server:openMDT')
            else
                QBCore.Functions.Notify("You must be on duty to use the MDT.", "error")
            end
        else
            QBCore.Functions.Notify("Access denied.", "error")
        end
    else
        QBCore.Functions.Notify("Can't do that!", "error")
    end
end)


RegisterNetEvent('randolio:client:fingerprintmenu') 
AddEventHandler('randolio:client:fingerprintmenu', function(pdata)
name = pdata.charinfo.firstname..' '..pdata.charinfo.lastname
    if UseMDT then
        exports['qb-menu']:openMenu({
            {
                header = "Fingerprint Scanner",
                txt = "",
                isMenuHeader = true
            },
            {
                header = "",
                txt = 'Print ID: '..pdata.metadata.fingerprint..'</p>Name: '..pdata.charinfo.firstname..' '..pdata.charinfo.lastname..'</p>Citizen ID: '..pdata.citizenid..'</p>State ID: '..pdata.source..'',
                icon = "fa-solid fa-fingerprint",
                isMenuHeader = true
            },
            {
                header = "Open MDT",
                icon = "fa-solid fa-laptop",
                params = {
                    event = Event
                }
            },
            {
                header = "Exit",
                icon = "fa-solid fa-angle-left",
                params = {
                    event = "qb-menu:closeMenu"
                }
            },
        })
        Wait(1000)
        TriggerEvent("randol_fingerprint:copyToClipBoard", name)
    else

        lib.registerContext({
            id = 'random_fingerprint_openmenu',
            title = 'Fingerprint Scanner',
            menu = 'random_fingerprint_openmenu__',
            options = {
              {
                title = '',
                description = 'Print ID: '..pdata.metadata.fingerprint..'</p>Name: '..pdata.charinfo.firstname..' '..pdata.charinfo.lastname..'</p>Citizen ID: '..pdata.citizenid..'</p>State ID: '..pdata.source..'',
                icon = 'fa-solid fa-fingerprint',
                disabled = false,
                onSelect = function()
                    TriggerEvent("randol_fingerprint:copyToClipBoard", name)
                end,
              }
            }
          })
         
          lib.showContext('random_fingerprint_openmenu')


        -- exports['qb-menu']:openMenu({
        --     {
        --         header = "Fingerprint Scanner",
        --         txt = "",
        --         isMenuHeader = true
        --     },
        --     {
        --         header = "",
        --         txt = 'Print ID: '..pdata.metadata.fingerprint..'</p>Name: '..pdata.charinfo.firstname..' '..pdata.charinfo.lastname..'</p>Citizen ID: '..pdata.citizenid..'</p>State ID: '..pdata.source..'',
        --         icon = "fa-solid fa-fingerprint",
        --         isMenuHeader = true
        --     },
        --     {
        --         header = "Exit",
        --         icon = "fa-solid fa-angle-left",
        --         params = {
        --             event = "qb-menu:closeMenu"
        --         }
        --     },
        -- })
    end
end)

RegisterNetEvent("randol_fingerprint:copyToClipBoard")
AddEventHandler("randol_fingerprint:copyToClipBoard", function(data)
    QBCore.Functions.Notify("Name Auto Copied: "..data)
    SendNUIMessage({
        type = "clipboard",
        data = "" ..data
    })
end)
