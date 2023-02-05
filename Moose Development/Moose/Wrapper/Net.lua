--- **Wrapper** - DCS net functions.
--
-- Encapsules **multiplayer** environment scripting functions from 
--[net](https://wiki.hoggitworld.com/view/DCS_singleton_net)
-- ===
--
-- ### Author: **applevangelist**
--
-- ===
--
-- @module Wrapper.Net
-- @image Utils_Profiler.jpg

do
    --- The NET class
    -- @type NET
    -- @field #string ClassName
    -- @field #string Version
    -- @extends Core.Base#BASE

    --- Encapsules multiplayer environment scripting functions from 
    -- [net](https://wiki.hoggitworld.com/view/DCS_singleton_net)
    -- @field #NET
    NET = {
        ClassName = "NET",
        Version = "0.0.1"
    }

    --- Instantiate a new NET object.
    -- @param #NET self
    -- @return #NET self
    function NET:New()
        -- Inherit base.
        local self = BASE:Inherit(self, BASE:New()) -- #NET
        
        return self
    end

    --- Send chat message.
    -- @param #NET self
    -- @param #string Message Message to send
    -- @param #boolean ToAll (Optional)
    -- @return #NET self
    function NET:SendChat(Message, ToAll)
        if Message and type(Message) == "string" and ToAll ~= nil and type(ToAll) == 'boolean' then
            net.send_chat(Message, ToAll)
        elseif Message and type(Message) == "string" then
            net.send_chat(Message)
        else
            return self
        end
        return self
    end

    --- Send chat message to a specific player.
    -- @param #NET self
    -- @param #string Message The text message
    -- @param Wrapper.Client#CLIENT ToClient Client receiving the message
    -- @param Wrapper.Client#CLIENT FromClient(Optional) Client sending the message
    -- @return #NET self
    function NET:SendChatToPlayer(Message, ToClient, FromClient)
        local PlayerId = ToClient 
        local FromId = FromClient 
        if Message and PlayerId and FromId then
            net.send_chat_to(Message, PlayerId, FromId)
        elseif Message and PlayerId then
            net.send_chat_to(Message, PlayerId)
        end
        return self
    end

    --- Load a specific mission.
    -- @param #NET self
    -- @param #string Path and Mission
    -- @return #boolean success
    -- @usage
    --        mynet:LoadMission(lfs.writeDir() .. 'Missions\\' .. 'MyTotallyAwesomeMission.miz')
    function NET:LoadMission(Path)
        local _outcome = false
        if Path then
            _outcome = net.load_mission(Path)
        end
        return _outcome
    end

    --- Load next mission. Returns false if at the end of list.
    -- @param #NET self
    -- @return #boolean success
    function NET:LoadNextMission()
        local _outcome = false
        _outcome = net.load_next_mission()
        return _outcome
    end

    --- Return a table of players currently connected to the server.
    -- @param #NET self
    -- @return #table PlayerList
    function NET:GetPlayerList()
        local _pllist = nil
        _pllist = net.get_player_list()
        return _pllist
    end

    --- Returns the playerID of the local player. Always returns 1 for server.
    -- @param #NET self
    -- @return #number ID
    function NET:GetMyPlayerID()
        return net.get_my_player_id()
    end

    --- Returns the playerID of the server. Currently always 1.
    -- @param #NET self
    -- @return #number ID
    function NET:GetServerID()
        return net.get_server_id()
    end

    --- Return a table of attributes for a given client. If optional attribute is present, only that value is returned.
    -- @param #NET self
    -- @param #number Client The client.
    -- @param #string Attribute (Optional) The attribute to obtain. List see below.
    -- @return #table PlayerInfo or nil if it cannot be found
    -- @usage
    -- Table holds these attributes:
    --
    --          'id'    : playerID
    --          'name'  : player name
    --          'side'  : 0 - spectators, 1 - red, 2 - blue
    --          'slot'  : slotID of the player or
    --          'ping'  : ping of the player in ms
    --          'ipaddr': IP address of the player, SERVER ONLY
    --          'ucid'  : Unique Client Identifier, SERVER ONLY
    --
    function NET:GetPlayerInfo(Client, Attribute) -- Changed by Wingthor NOT WORKING
        BASE:F({ Client, Attribute })
        if Client ~= nil and type(Client) == 'number' and Attribute ~= nil and type(Attribute) == 'string' then
            return net.get_player_info(Client, Attribute)
        elseif Client and type(Client) == 'number' then
            return net.get_player_info(Client)
        else
            BASE:I('ERROR: Mandatory parameter missing in function GetPlayerInfo PlayerID')
            return false
        end
    end

    --- Kicks a player from the server. Can display a message to the user.
    -- @param #NET self
    -- @param Wrapper.Client#CLIENT Client The client
    -- @param #string Message (Optional) The message to send.
    -- @return #boolean success
    function NET:Kick(Client, Message) --Not working
        if Client and type(Client) == 'number' then
            if Client ~= 1 then -- We will not kick server
                if Message and type(Message) == 'string' then
                    return net.kick(PlayerID, Message)
                else
                    return net.kick(PlayerID)
                end
                BASE:I('ERROR: You tried to kick the server')
                return nil
            else
                BASE:I('ERROR: Missing arguments')
                return nil
            end
        end
    end

    --- Kicks player back to specators. Usefull if you wiish to block certain slots.
    --@param #number playerID
    --@param #string Reject Message to player
    --@return @boolean
    function NET:KickToSpectators(PlayerID, Message)
        if (PlayerID and type(PlayerID) == 'number') then
            NET:ForceSlot(PlayerID, 0, '')
            if Message then
                --TODO So user can manipulate a reject message to the CLASS
                NET:SendChatToPlayer('INFO: YOU HAVE BEEN KICKED TO SPECTATORS FOR A REASON')
            end
            return true
        else
            BASE:I("ERROR: Missing parameter in function KickToSpectators")
            return false
        end
    
    end

    --- Return a statistic for a given client.
    -- @param #NET self
    -- @param Wrapper.Client#CLIENT Client The client
    -- @param #number StatisticID The statistic to obtain
    -- @return #number Statistic or nil
    -- @usage
    -- StatisticIDs are:
    --
    -- net.PS_PING  (0) - ping (in ms)
    -- net.PS_CRASH (1) - number of crashes
    -- net.PS_CAR   (2) - number of destroyed vehicles
    -- net.PS_PLANE (3) - ... planes/helicopters
    -- net.PS_SHIP  (4) - ... ships
    -- net.PS_SCORE (5) - total score
    -- net.PS_LAND  (6) - number of landings
    -- net.PS_EJECT (7) - of ejects
    --
    --          mynet:GetPlayerStatistic(Client,7) -- return number of ejects
    function NET:GetPlayerStatistic(Client, StatisticID) -- Not working
        if Client and type(Client) == 'number' then
            local stats = StatisticID or 0
            if stats > 7 or stats < 0 then stats = 0 end
            return net.get_stat(Client, stats)
        else
            return nil
        end
    end

    --- Return the Wrapper.Client for given player name.
    -- @param #NET self
    -- @param #string PlayerName
    -- @return #Wrapper.Client
    function NET:GetMooseClientByPlayerName(ClientsPlayerName)
        BASE:F({ ClientsPlayerName })
        if ClientsPlayerName == nil or type(ClientsPlayerName) ~= 'string' then
            BASE:I("ERROR: Missing arguments in GetMooseClientByPlayerName")
            return nil
        end
        local _client_set = SET_CLIENT:New():FilterActive():FilterOnce()
        local _MooseUnit = nil
        _client_set:ForEachClient(
            function(MooseClient)
                if MooseClient:GetPlayerName() == ClientsPlayerName then
                    _MooseUnit = MooseClient
                end
            end
        )
        if _MooseUnit ~= nil then
            return _MooseUnit
        else
            BASE:I('INFO: GetMooseClientByPlayerName: No active unit occupied with a player with that name')
            return nil
        end
    end

    --- Return the name of a given client. Same a CLIENT:GetPlayerName().
    -- @param #NET self
    -- @param Wrapper.Client#CLIENT Client The client
    -- @return #string Name
    function NET:GetName(Client)
        BASE:F({ Client })
        if Client and type(Client) == 'number' then
            return net.get_name(Client)
        else
            return nil
        end
    end

    ---Return the player ID from players name
    --@param #string PlayerName
    --@return #number ID
    function NET:GetIDByPlayerName(PlayerName)
        BASE:F({ PlayerName })
        if PlayerName and type(PlayerName) == 'string' then
            _player_list = NET:GetPlayerList()
            for i = 1, #_player_list do
                if NET:GetPlayerInfo(_player_list[i], 'name') == PlayerName then
                    return _player_list[i]
                end
            end
            BASE:I('INFO: Player not found in GetIDByPlayerName')
            return nil
        else
            BASE:I('ERROR: Missing or wrong type of parameter in GetIDByPlayerName')
            return nil
        end
        

    end

    --- Returns the SideId and SlotId of a given client.
    -- @param #NET self
    -- @param #number PlayerID
    -- @return #number SideID i.e. 0 : spectators, 1 : Red, 2 : Blue
    -- @return #number SlotID
    function NET:GetSlot(Client)
        if Client and type(Client) == 'number' then
            local side, slot = net.get_slot(Client)
            return side, slot
        else
            return nil, nil
        end
    end

    --- Force the slot for a specific client.
    -- @param #NET self
    -- @param #number PlayerID
    -- @param #number SideID i.e. 0 : spectators, 1 : Red, 2 : Blue
    -- @param #number SlotID Slot number
    -- @return #boolean Success
    function NET:ForceSlot(Client, SideID, SlotID)
        if Client and type(Client) == 'number' then
            local PlayerID = Client
            if PlayerID then
                return net.force_player_slot(tonumber(PlayerID), SideID, SlotID)
            else
                BASE:I('ERROR: Missing required parameter in ForceSlot')
                return false
            end
    end
    end

    --- Converts a lua value to a JSON string.
    -- @param #string Lua Anything lua
    -- @return #table Json
    function NET.Lua2Json(Lua)
        return net.lua2json(Lua)
    end

    --- Converts a JSON string to a lua value.
    -- @param #string Json Anything JSON
    -- @return #table Lua
    function NET.Lua2Json(Json)
        return net.json2lua(Json)
    end

    --- Executes a lua string in a given lua environment in the game.
    -- @param #NET self
    -- @param #string State The state in which to execute - see below.
    -- @param #string DoString The lua string to be executed.
    -- @return #string Output
    -- @usage
    -- States are:
    -- 'config': the state in which $INSTALL_DIR/Config/main.cfg is executed, as well as $WRITE_DIR/Config/autoexec.cfg 
    -- - used for configuration settings
    -- 'mission': holds current mission
    -- 'export': runs $WRITE_DIR/Scripts/Export.lua and the relevant export API
    function NET:DoStringIn(State, DoString)
        return net.dostring_in(State, DoString)
    end

    ---  Write an "INFO" entry to the DCS log file, with the message Message.
    -- @param #NET self
    -- @param #string Message The message to be logged.
    -- @return #NET self
    function NET:Log(Message)
        net.log(Message)
        return self
    end

    -------------------------------------------------------------------------------
    -- End of NET
    -------------------------------------------------------------------------------
end
