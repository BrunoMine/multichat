--[[
	Mod MultiChat para Minetest
	Copyright (C) 2017 BrunoMine (https://github.com/BrunoMine)

	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>.

	Ajuste no comando /msg

  ]]

local som_avisar = multichat.som_avisar

local old_func = minetest.chatcommands.msg.func

function minetest.chatcommands.msg.func(name, param)
	local sendto, message = param:match("^(%S+)%s(.+)$")
	if not sendto then
		return false, "Invalid usage, see /help msg."
	end

	local ouvinte = sendto

	-- Verifica o jogador pode ouvir
	if minetest.player_exists(ouvinte) and minetest.get_player_by_name(ouvinte) then
		local player = minetest.get_player_by_name(ouvinte)
		local status = player:get_attribute("multichat_status")

		-- Verifica se o jogador está no bate-papo público
		if status == nil or status == "pub" then

		-- Verificar se está desativado
		elseif status == "off" then
			som_avisar(name)
			return true, "Message sent." -- Tenta enganar jogador que enviou a mensagem

		-- Verifica se jogador está ouvindo apenas seu grupo
		elseif status == "grupo" and multichat.grupos[ouvinte] then

			-- Verifica se falante está no grupo
			if multichat.grupos[name][falante] == nil then
				som_avisar(name)
				return true, "Message sent." -- Tenta enganar jogador que enviou a mensagem

			end
		end
	end

	local r, msg = old_func(name, param)

	if r == true then
		if ouvinte == name then
			som_avisar(name)
		else
			som_avisar(ouvinte, message)
			som_avisar(name)
		end
	end

	return r, msg
end
