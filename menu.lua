--[[
	Mod MultiChat para Minetest
	Copyright (C) 2018 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Menu Multichat
	
  ]]

local S = multichat.S

-- Remover grupo de um jogador offline
local remover_grupo = function(name)
	multichat.salas[name] = nil
end

-- Comando de acesso ao menu
multichat.acessar_menu = function(name)
	if not name then return end
	local player = minetest.get_player_by_name(name)
	local st = player:get_attribute("multichat_status")

	local status = S("Atualmente").."\n"
	
	-- Caso esteja no Publico
	if st == nil or st == "pub" then
		status = status .. minetest.colorize("#00FF00", S("em Publico"))
	
	-- Caso esteja Desativado
	elseif st == "off" then
		status = status .. minetest.colorize("#FF0000", S("Desativado"))
	
	-- Caso esteja no Grupo Privado
	elseif st == "grupo" then
		status = status .. minetest.colorize("#3366FF", S("em Privado"))
	
	-- Caso esteja no Grupo da Guilda
	elseif st == "guilda" then
		status = status .. minetest.colorize("#3366FF", S("em Grupo"))
	
	-- Caso nenhuma situação prevista
	else
		status = status .. S("Erro")
	end
	
	-- Avisos sonoros
	local st_som = player:get_attribute("multichat_som") or "true"
	local st_chamada = player:get_attribute("multichat_chamada") or "true"
	
	local formspec = ""
	if multichat.guild == true then
		formspec = formspec .. "size[4,6]"
	else
		formspec = formspec .. "size[4,5]"
	end
	
	formspec = formspec
		..default.gui_bg
		..default.gui_bg_img
		.."label[0,0;"..S("Meu Bate-Papo").."\n"..status.."]"
		.."image[3,0;1,1;multichat_botao.png]"
		.."checkbox[0,1;som;"..S("Som")..";"..st_som.."]"
		.."checkbox[0,1.5;chamada;"..S("Chamada")..";"..st_chamada.."]"
		.."button_exit[3,1.2;1,1;sair;"..S("Sair").."]"
		.."button_exit[0,2.2;4,1;desativar;"..S("Desativar").."]"
		.."button_exit[0,3.2;4,1;publico;"..S("Publico").."]"
		.."button_exit[0,4.2;3.3,1;privado;"..S("Privado").."]"
		.."image_button[3.15,4.3;0.825,0.825;default_book_written.png;grupo;]"
	
	-- Botão de grupo
	if multichat.guild == true then
		formspec = formspec .. "button_exit[0,5.2;4,1;guild;"..S("Grupo").."]"
	end
	minetest.show_formspec(name, "multichat:menu", formspec)
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
	local i = 1
	while i <= table.maxn(tb_online) do
		local np = tb_online[i]:get_player_name()
		
		-- Remove o proprio nome da lista
		if np == name then
			table.remove(tb_online, i)
		-- Remove nomes que estao no grupo
		elseif tb_grupo[np] then
			table.remove(tb_online, i)
		-- Insere na lista
		else
			if st_online ~= "" then st_online = st_online .. "," end
			st_online = st_online .. np
			table.insert(multichat.online[name].tb_online, np)
			i = i + 1
		end
		
	end
	minetest.show_formspec(name, "multichat:menu_grupo", "size[8,6]"
		..default.gui_bg
		..default.gui_bg_img
		.."label[0,0;"..S("Meu Bate-Papo Privado").."]"
		.."button[6.1,-0.1;2,1;voltar;"..S("Voltar").."]"
		
		.."label[0,1.1;"..S("Ignorados").."]"
		.."textlist[0,1.6;3,4.5;online;"..st_online.."]"
		
		.."image[3.5,1.7;1,1;gui_furnace_arrow_bg.png^[transformR270]"
		.."button[3.1,2.5;1.9,1;adicionar;"..S("Adicionar").."]"
		
		.."button[3.1,4.3;1.9,1;remover;"..S("Remover").."]"
		.."image[3.5,5;1,1;gui_furnace_arrow_bg.png^[transformR90]"
		
		.."label[4.85,1.1;"..S("Conversando").."]"
		.."textlist[4.85,1.6;3,4.5;grupo;"..st_grupo.."]"
	)
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	
	if formname == "multichat:menu" then
		
		-- Botao de desativar bate-papo
		if fields.desativar then
			player:set_attribute("multichat_status", "off")
			minetest.chat_send_player(player:get_player_name(), S("Bate-papo desativado"))
			
		elseif fields.publico then
			player:set_attribute("multichat_status", "pub")
			minetest.chat_send_player(player:get_player_name(), S("Foste para o bate-papo publico"))
			
		elseif fields.privado then
			player:set_attribute("multichat_status", "grupo")
			minetest.chat_send_player(player:get_player_name(), S("Foste para o bate-papo privado"))
			
		elseif fields.grupo then
			acessar_menu_grupo(player:get_player_name())
		
		-- Guilda	
		elseif fields.guild then
			-- Manipulus
			if multichat.mod_guild == "manipulus" then
				local grupo = manipulus.get_player_grupo(player:get_player_name())
				if grupo == nil or manipulus.existe_grupo(grupo) == false then
					minetest.chat_send_player(player:get_player_name(), S("Precisa entrar em um grupo"))
				else
					player:set_attribute("multichat_status", "guilda")
					minetest.chat_send_player(player:get_player_name(), S("Foste para o bate-papo do grupo @1", "'"..grupo.."'"))
				end
			end
		
		-- Caixas de seleção (avisos sonoros)
		elseif fields.som then 
			player:set_attribute("multichat_som", fields.som)
		elseif fields.chamada then 
			player:set_attribute("multichat_chamada", fields.chamada)
			
		end
		
	elseif formname == "multichat:menu_grupo" then
		
		-- Limpa variaveis quando sair (evitar o uso delas no futuro)
		if fields.quit then
			multichat.online[player:get_player_name()].sl_tb_online = nil
			multichat.online[player:get_player_name()].sl_tb_grupo = nil
		-- Verifica seleções
		elseif fields.online then
			multichat.online[player:get_player_name()].sl_tb_online = string.split(fields.online, ":")[2]
		elseif fields.grupo then
			multichat.online[player:get_player_name()].sl_tb_grupo = string.split(fields.grupo, ":")[2]
		
		-- Voltar ao menu principal
		elseif fields.voltar then
			multichat.acessar_menu(player:get_player_name())
			return
		
		-- Adicionar jogador para conversar
		elseif fields.adicionar then
			local name = player:get_player_name()
			
			-- Verifica se tem algum jogador na tabela
			if table.maxn(multichat.online[name].tb_online) == 0 then return end
			
			-- Verifica se selecionou umjogador
			if not tonumber(multichat.online[name].sl_tb_online) then return end
			
			-- Caso o grupo esteja vazio cria
			if multichat.grupos[name] == nil then multichat.grupos[name] = {} end
			
			-- Adiciona jogador
			local sl = tonumber(multichat.online[name].sl_tb_online)
			local grupo = multichat.online[name].tb_online[sl]
			multichat.grupos[name][grupo] = true
			
			-- Atualiza menu do grupo
			acessar_menu_grupo(name)
			
			return
		
		-- Remover jogador
		elseif fields.remover then
			local name = player:get_player_name()
			
			-- Verifica se tem algum jogador na tabela
			if table.maxn(multichat.online[name].tb_grupo) == 0 then return end
			
			-- Verifica se selecionou umjogador
			if not tonumber(multichat.online[name].sl_tb_grupo) then return end
			
			-- Remove jogador do grupo
			local sl = tonumber(multichat.online[name].sl_tb_grupo)
			if multichat.grupos[name] ~= nil 
				and multichat.online[name].tb_grupo ~= nil
				and multichat.online[name].tb_grupo[sl] ~= nil
			then
				multichat.grupos[name][multichat.online[name].tb_grupo[sl]] = nil
			end
			
			-- Atualiza menu do grupo
			acessar_menu_grupo(name)
			
			return
		end
	
	end
end)

-- Registrar em 'sfinv'
if mymenu then
	
	-- Registrar metodo de tradução instantanea
	mymenu.register_tr(SS)
	
	-- Registrar botao
	mymenu.register_button("multichat:abrir_menu", S("Bate-Papo"))
	
	-- Receber botao do inventario
	minetest.register_on_player_receive_fields(function(player, formname, fields)
		if fields["multichat:abrir_menu"] then
			multichat.acessar_menu(player:get_player_name())
		end
	end)
	
elseif sfinv then
	sfinv.register_page("multichat:menu", {
		title = S("Bate-Papo"),
		get = function(self, player, context)
			return sfinv.make_formspec(player, context, 
				"button[2.5,1.5;3,1;multichat:abrir_menu;"..S("Abrir Menu").."]"
				.."listring[current_player;main]"
				.."listring[current_player;craft]"
				.."image[0,4.75;1,1;gui_hb_bg.png]"
				.."image[1,4.75;1,1;gui_hb_bg.png]"
				.."image[2,4.75;1,1;gui_hb_bg.png]"
				.."image[3,4.75;1,1;gui_hb_bg.png]"
				.."image[4,4.75;1,1;gui_hb_bg.png]"
				.."image[5,4.75;1,1;gui_hb_bg.png]"
				.."image[6,4.75;1,1;gui_hb_bg.png]"
				.."image[7,4.75;1,1;gui_hb_bg.png]", 
			true)
		end
	})


	-- Receber botao do inventario
	minetest.register_on_player_receive_fields(function(player, formname, fields)
		if fields["multichat:abrir_menu"] then
			multichat.acessar_menu(player:get_player_name())
		end
	end)
	
end
