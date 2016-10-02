json = require "json"
posix = require('posix')
convidados_filename = "dados/convidados.json"
removidos_filename = "dados/removidos.json"
convidados = {}
removidos = {}


function exists(n)
    print(n)
    print(posix.stat(n))
    return posix.stat(n) ~= nil
end


function load_file()
    if exists(convidados_filename) then
        local file = io.open(convidados_filename, "r")
        local data_file = file:read "*a"
        convidados = json.decode(data_file)
        file:close()
    else
        write_file('[]', convidados_filename)
    end
    if exists(removidos_filename) then
        local file = io.open(removidos_filename, "r")
        local data_file = file:read "*a"
        removidos = json.decode(data_file)
        file:close()
    else
        write_file('[]', removidos_filename)
    end
end


function write_file(data, filename)
    file = io.open(filename, "w")
    file:write(data)
    file:close()
end


function save_convidados()
    write_file(json.encode(convidados), convidados_filename)
end


function save_removidos()
    write_file(json.encode(removidos), removidos_filename)
end


function show_item(item)
    print(item["nome"], '\t',item["cpf"])
end


function list()
    print("Nome\tCPF")
    for k, v in pairs(convidados) do
        show_item(v)
    end
end


function list_removed()
    print("Nome\tCPF\tMotivo")
    for k, v in pairs(removidos) do
        print(v["convidado"]["nome"], v["convidado"]["cpf"], v["motivo"])
    end
end


function action_add()
    print('')
    io.write('Nome: ')
    local nome = io.read()
    io.write('CPF: ')
    local cpf = io.read()
    local convidado = {nome = nome, cpf = cpf}
    if next(convidados) == nil then
        convidados = {convidado}
    else
        table.insert(convidados, convidado)
    end
    save_convidados()
    print('Convidado adicionado com sucesso!')
end


function check_value(val, arr)
    for _, value in pairs(arr) do
        if string.find(string.lower(value), string.lower(val)) then
            return true
        end
    end
    return false
end


function action_search()
    print('')
    io.write('Busca: ')
    local key = io.read()
    for k, v in ipairs(convidados) do
        if check_value(key, v) then
            show_item(v)
        end
    end

end


function action_remove()
    print('')
    io.write('Busca: ')
    local key = io.read()
    local count = 0
    local itens = {}
    for k, v in ipairs(convidados) do
        if check_value(key, v) then
            itens[count] = k
            io.write(count .. '\t')
            show_item(v)
            count = count + 1
        end
    end
    io.write('Confirme o item que deseja remover: ')
    local index = io.read()
    io.write('Qual o motivo da remoção? ')
    local motivo = io.read()
    table.insert(removidos, {convidado = convidados[itens[tonumber(index)]], motivo = motivo})
    table.remove(convidados, itens[tonumber(index)])
    save_removidos()
    save_convidados()
    print('Convidado removido com sucesso!')
end


function actions_main()
    print('')
    print('O que você deseja fazer?')
    print('Adicionar (a)')
    print('Remover (r)')
    print('Listar (l)')
    print('Listar Removidos (lr)')
    print('Buscar (b)')
    print('Sair (q)')
    local action = io.read()
    if action == 'a' then
        action_add()
    elseif action == 'r' then
        action_remove()
    elseif action == 'b' then
        action_search()
    elseif action == 'l' then
        list()
    elseif action == 'lr' then
        list_removed()
    elseif action == 'q' then
        os.exit()
    end

end


function main()
    print('### Bem vindo ao gestor de convidados ###')
    load_file()
    while true do
        actions_main()
    end
end


main()
