local jobs = {}

MySQL.ready(function()
    local sqljobs = MySQL.Sync.fetchAll('SELECT * FROM jobs')

    for _, job in pairs(sqljobs) do
        jobs[job.name] = job.label
    end
end)


RegisterNetEvent("h_billing:server:createbill")
AddEventHandler("h_billing:server:createbill", function(target, amount, description)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(target)
    local xPlayer2 = ESX.GetPlayerFromId(source)
    if xPlayer ~= nil and xPlayer2.job.name ~= "unemployed" then
        MySQL.Async.execute('INSERT INTO h_billing (identifier, job, amount, label, sender) VALUES (@identifier, @job, @amount, @label, @sender)', {
            ['@identifier'] = xPlayer.identifier,
            ['@job'] = xPlayer2.job.name,
            ['@amount'] = amount,
            ['@label'] = description,
            ['@sender'] = xPlayer2.identifier
        }, function(rowsChanged)
            if rowsChanged > 0 then
                TriggerClientEvent('esx:showNotification', target, 'Sinulle on lähetetty lasku!')
                TriggerClientEvent('esx:showNotification', source, 'Lasku lähetetty!')
            else
                TriggerClientEvent('esx:showNotification', source, 'Laskun luonti epäonnistui!')
            end
        end)
    else
        TriggerClientEvent('esx:showNotification', source, 'Pelaajaa ei löydy!')
    end
end)

RegisterNetEvent("h_billing:server:paybill")
AddEventHandler("h_billing:server:paybill",  function(invoiceId)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    local identifier = xPlayer.identifier
    MySQL.Async.fetchAll('SELECT * FROM h_billing WHERE id = @id AND identifier = @identifier', {
        ['@id'] = invoiceId,
        ['@identifier'] = identifier
    }, function(result)
        print(result[1])
        if result[1] ~= nil then
            if xPlayer.getAccount('bank').money >= result[1].amount then
                print("on tarpeeks")
                xPlayer.removeAccountMoney('bank', result[1].amount)
                MySQL.Async.execute('DELETE FROM h_billing WHERE id = @id AND identifier = @identifier', {
                    ['@id'] = invoiceId,
                    ['@identifier'] = identifier
                }, function(rowsChanged)
                    TriggerEvent('esx_addonaccount:getSharedAccount', 'society_'..result[1].job, function(account)
                        account.addMoney(result[1].amount)
                    end)
                end)
            else
                TriggerClientEvent('esx:showNotification', source, 'Sinulla ei ole tarpeeksi rahaa!')
            end
        end
    end)
end)

lib.callback.register('h_billing:server:getmybills', function(source)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    local identifier = xPlayer.identifier
    local result = MySQL.Sync.fetchAll('SELECT * FROM h_billing WHERE identifier = @identifier', {
        ['@identifier'] = identifier
    })
    if result[1] == nil then
        return nil
    end
    return {result, jobs}
end)
