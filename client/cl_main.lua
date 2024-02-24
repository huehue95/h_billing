RegisterNetEvent("h_billing:client:openBillmenu")
AddEventHandler("h_billing:client:openBillmenu", function()
    local players = {}
    local pos = GetEntityCoords(PlayerPedId(), true)
    local closestplayers = ESX.Game.GetPlayersInArea(pos, 4.0)
    for k, v in pairs(closestplayers) do
        table.insert(players, {
            value = GetPlayerServerId(v),
            label = GetPlayerName(v) .. ' - ' .. GetPlayerServerId(v)
        })
    end

    table.insert(players, {
        value = GetPlayerServerId(PlayerId()),
        label = GetPlayerName(PlayerId()) .. '(Minä) - ' .. GetPlayerServerId(PlayerId())
    })

    local input = lib.inputDialog('Laskun luonti', {
        {type = "select", label = "Laskun saaja", options = players, required = true },
        {type = "number", label = "Summa", value = 0, min = 1, max = 500000, required = true},
        {type = "input", label = "Kuvaus", value = "", required = true}
    })

    if input then
        TriggerServerEvent('h_billing:server:createbill', input[1], input[2], input[3])
    end
end)

RegisterNetEvent("h_billing:client:openMyBills")
AddEventHandler("h_billing:client:openMyBills", function()
    local dataa = lib.callback.await('h_billing:server:getmybills')
    if dataa == nil then
        ESX.ShowNotification("Sinulla ei ole laskuja!")
        return
    end
    local element = {}
    for k, v in pairs(dataa[1]) do
        element[#element + 1] = {
            title = v.label,
            description = dataa[2] .. ' - ' .. v.amount .. '€',
            icon = "fas fa-file-invoice-dollar",
            serverEvent = 'h_billing:server:paybill',
            args = v.id
        }
    end

    lib.registerContext({
        id = 'my_bills',
        title = 'Laskut',
        options = element
      })

    lib.showContext('my_bills')
end)

RegisterCommand("laskut", function()
    TriggerEvent("h_billing:client:openMyBills")
end, false)

RegisterKeyMapping('laskut', "Näytälaskut", 'keyboard', 'F7')