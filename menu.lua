--[[
	Mod MultiChat para Minetest
	Copyright (C) 2017 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Menu Multichat
	
  ]]

-- Remover grupo de um jogador offline
local remover_grupo = function(name)
	multichat.salas[name] = nil
end

-- Comando de acesso ao menu
multichat.acessar_menu = function(name)
	if not name then return end
	local player = minetest.get_player_by_name(name)
	local st = player:get_attribute("multichat_status")

	local status = "Atualmente\n"
	
	-- Caso esteja no Publico
	if st == nil or st == "pub" then
		status = status .. minetest.colorize("#00FF00", "em Publico")
	
	-- Caso esteja Desativado
	elseif st == "off" then
		status = status .. minetest.colorize("#FF0000", "Desativado")
	
	-- Caso esteja no Grupo
	elseif st == "grupo" then
		status = status .. minetest.colorize("#3366FF", "em Privado")
	
	-- Caso nenhuma situação prevista
	else
		status = status .. "Erro"
	end
	
	-- Avisos sonoros
	local st_som = player:get_attribute("multichat_som") or "true"
	local st_chamada = player:get_attribute("multichat_chamada") or "true"
	
	minetest.show_formspec(name, "multichat:menu", "size[4,5]"
		..default.gui_bg
		..default.gui_bg_img
		.."label[0,0;Meu Bate-Papo \n"..status.."]"
		.."image[3,0;1,1;multichat_botao.png]"
		.."checkbox[0,1;som;Som;"..st_som.."]"
		.."checkbox[0,1.5;chamada;Chamada;"..st_chamada.."]"
		.."button_exit[3,1.2;1,1;sair;Sair]"
		.."button_exit[0,2.2;4,1;desativar;Desativar]"
		.."button_exit[0,3.2;4,1;publico;Publico]"
		.."button_exit[0,4.2;3.3,1;privado;Privado]"
		.."image_button[3.15,4.3;0.825,0.825;default_book_written.png;grupo;]")
end

-- Acessar menu do grupo
local acessar_menu_grupo = function(name)
	
	-- Prepara e armazena tabelas exibidas
	local tb_grupo = multichat.grupos[name] or {}
	multichat.online[name].tb_grupo = {}
	local st_grupo = ""
	for np,v in pairs(tb_grupo) do
		if st_grupo ~= "" then st_grupo = st_grupo .. "," end
		st_grupo = st_grupo .. np
		table.insert(multichat.online[name].tb_grupo, np)
	end
	
	local tb_online = minetest.get_connected_players()
	multichat.online[name].tb_online = {}
	local st_online = ""
	for n,p in ipairs(tb_online) do
		local np = p:get_player_name()
		-- Remove o proprio nome da lista
		if np == name then
			table.remove(tb_online, n)
		-- Remove nomes que estao no grupo
		elseif tb_grupo[np] then
			table.remove(tb_online, n)
		else
			if st_online ~= "" then st_online = st_online .. "," end
			st_online = st_online .. np
			table.insert(multichat.online[name].tb_online, np)
		end
	end
	
	minetest.show_formspec(name, "multichat:menu_grupo", "size[8,6]"
		..default.gui_bg
		..default.gui_bg_img
		.."label[0,0;Meu Bate-Papo Privado]"
		.."button[6.1,-0.1;2,1;voltar;Voltar]"
		
		.."label[0,1.1;Ignorados]"
		.."textlist[0,1.6;3,4.5;online;"..st_online.."]"
		
		.."image[3.5,1.7;1,1;gui_furnace_arrow_bg.png^[transformR270]"
		.."button[3.1,2.5;1.9,1;adicionar;Adicionar]"
		
		.."button[3.1,4.3;1.9,1;remover;Remover]"
		.."image[3.5,5;1,1;gui_furnace_arrow_bg.png^[transformR90]"
		
		.."label[4.85,1.1;Conversando]"
		.."textlist[4.85,1.6;3,4.5;grupo;"..st_grupo.."]"
	)
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname == "multichat:menu" then
		
		-- Botao de desativar bate-papo
		if fields.desativar then
			player:set_attribute("multichat_status", "off")
			minetest.chat_send_player(player:get_player_name(), "Bate-papo desativado")
		
		elseif fields.publico then
			player:set_attribute("multichat_status", "pub")
			minetest.chat_send_player(player:get_player_name(), "Foste para o bate-papo publico")
		
		elseif fields.privado then
			player:set_attribute("multichat_status", "grupo")
			minetest.chat_send_player(player:get_player_name(), "Foste para o bate-papo privado")
		
		elseif fields.grupo then
			acessar_menu_grupo(player:get_player_name())
			
		-- Caixas de seleção (avisos sonoros)
		elseif fields.som then 
			player:set_attribute("multichat_som", fields.som)
		elseif fields.chamada then 
			player:set_attribute("multichat_chamada", fields.chamada)
			
		end
		
	elseif formname == "multichat:menu_grupo" then
		
		-- Verifica seleções
		if fields.online then
			multichat.online[player:get_player_name()].sl_tb_online = string.split(fields.online, ":")[2]
		elseif fields.grupo then
			multichat.online[player:get_player_name()].sl_tb_grupo = string.split(fields.grupo, ":")[2]
		
		-- Voltar ao menu principal
		elseif fields.voltar then
			multichat.acessar_menu(player:get_player_name())
			return
		
		-- Adicionar jogador para conversar
		elseif fields.adicionar then
			-- Verifica se tem algum jogador na tabela
			if table.maxn(multichat.online[player:get_player_name()].tb_online) == 0 then return end
			
			local name = player:get_player_name()
			
			-- Caso o grupo esteja vazio cria
			if multichat.grupos[name] == nil then multichat.grupos[name] = {} end
			
			-- Adiciona jogador
			multichat.grupos[name][multichat.online[name].tb_online[tonumber(multichat.online[name].sl_tb_online)]] = true
			
			-- Atualiza menu do grupo
			acessar_menu_grupo(name)
			
			return
		
		-- Remover jogador
		elseif fields.remover then
			
			-- Verifica se tem algum jogador na tabela
			if table.maxn(multichat.online[player:get_player_name()].tb_grupo) == 0 then return end
			
			local name = player:get_player_name()
			
			-- Remove jogador do grupo
			multichat.grupos[name][multichat.online[name].tb_grupo[tonumber(multichat.online[name].sl_tb_grupo)]] = nil
			
			-- Atualiza menu do grupo
			acessar_menu_grupo(name)
			
			return
		end
	
	end
end)

