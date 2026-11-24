
hook.Add("OnEntityCreated", "zajcu37archivt_initialize_gem_2", function(ent)
    timer.Simple(0.01, function()
        if !IsValid(ent) then return end
        if ent:GetClass() ~= "pill_ent_costume" then return end


        if ent.formTable then
            local PuppetEntity = ent:GetPuppet()
            local targetOrigin = ent:LocalToWorld(Vector(0, 0, 50))
local entity
if SherlockHNS then
    entity = SherlockHNS.FindVictim(ply, targetOrigin, 90, {
        filter = function(v)

            local trace = util.TraceLine({
                start = ent:EyePos(),
                endpos = v:EyePos(),
                filter = {ent, ply},
                mask = MASK_VISIBLE
            })
            return not trace.Hit
        end,
    })
else
for k, v in pairs(ents.FindInSphere(ent:LocalToWorld(Vector(0, 0, 50)), 130)) do
            if v:IsPlayer() or v:IsNextBot() or v:IsNPC() then
                if v == ent or v == ply then continue end

                if (v:IsPlayer() and v:Team() ~= TEAM_SPECTATOR) or ((v:IsNPC() or v:IsNextBot()) and v:Health() > 0) then
                    local trace = util.TraceLine({
                        start = ent:EyePos(),
                        endpos = v:EyePos(),
                        filter = {ent, ply},
                        mask = MASK_VISIBLE
                    })

                    if not trace.Hit then
                        entity = v
                        break
                    end
                end
            end
        end
end

if SherlockHNS and IsValid(entity) and entity:IsPlayer() then
            return pk_pills.playHNSJumpscare(ply, ent, entity, 2.3, {
                camera = "zajcu37archiv_jumpscare_gen",
                offset = 37,
                animation = "jumpscare",
                sound = "jumpscare",
                ownerCamera = "zajcu37archiv_jumpscare_gen",
            })
        end

        if not IsValid(entity) then return end

        local pill = ent:GetPuppet()

        if entity:IsPlayer() then
            entity:Freeze(true)
            entity:AddFlags(FL_NOTARGET)
            entity:DrawViewModel(false)
            entity:SetActiveWeapon(nil)

            net.Start('zajcu37archiv_jumpscare_gen')
            net.WriteEntity(pill)
            net.WriteBool(true)
            net.Send(entity)

            net.Start('zajcu37archiv_jumpscare_gen')
            net.WriteEntity(pill)
            net.WriteBool(true)
            net.Send(ply)
        else
            entity:NextThink(CurTime() + 1e9)
        end

        entity:SetPos(pill:GetPos() + pill:GetForward() * 37)

        ply:Freeze(true)
        ply:ConCommand("pk_pill_cl_thirdperson 0")

        ent:PillAnim('jumpscare')
        ent:PillSound('jumpscare')

        timer.Simple(2.3, function()
            if not (IsValid(entity) and IsValid(ent)) then return end
            
            ply:Freeze(false)
            ply:ConCommand("pk_pill_cl_thirdperson 1")

            if entity:IsPlayer() then
                entity:Kill(ply)

                net.Start('zajcu37archiv_jumpscare_gen')
                net.WriteEntity(pill)
                net.WriteBool(false)
                net.Send(entity)

                net.Start('zajcu37archiv_jumpscare_gen')
                net.WriteEntity(pill)
                net.WriteBool(false)
                net.Send(ply)

                entity:RemoveFlags(FL_NOTARGET)
                entity:Freeze(false)
                entity:DrawViewModel(true)
            else
                entity:NextThink(CurTime())
                entity:TakeDamage(1e9, ply)
            end
        end)

        timer.Simple(4, function()
            ply.OnHold = false
            entity = nil -- clear after done
        end)
    end,
},

	
    --Right Click Attack Function
    attack2 = {
        mode = "trigger",
        func = function(ply, ent)
        end,
    },
    
    
    

noragdoll=true,
	
	-- R click function
   	reload=function(ply,ent)
       
    end,

	
    -- F Click function
    flashlight=function(ply,ent)

    end,
	
	-- Jump Attack Spacebar Function 
    jump=function(ply,ent)

    end,

    
}, function(form)
    -- The legacy damage branches are for Sandbox and NPCs.
    form.hnsKillAPI = true
    form.hnsAbilities = {
        { id = "attack", name = "Ataque", key = IN_ATTACK, OnUse = form.attack.func },
    }
    form.attack, form.attack2, form.reload = nil, nil, nil
end)

if CLIENT then
    ARCHIV_AMBIENCE_SOUNDS = {
        "archiv/Ambience/ambience1.wav",
        "archiv/Ambience/ambience2.wav",
        "archiv/Ambience/ambience3.wav",
        "archiv/Ambience/ambience4.wav",
        "archiv/Ambience/ambience5.wav",
        "archiv/Ambience/ambience6.wav",
        "archiv/Ambience/ambience7.wav",
        "archiv/Ambience/ambience8.wav",
        "archiv/Ambience/ambience9.wav",
        "archiv/Ambience/ambience10.wav",
        "archiv/Ambience/ambience11.wav",
        "archiv/Ambience/ambience12.wav",
        "archiv/Ambience/ambience13.wav",
        "archiv/Ambience/ambience14.wav",
        "archiv/Ambience/ambience15.wav",
        "archiv/Ambience/ambience16.wav",
        "archiv/Ambience/ambience17.wav",
        "archiv/Ambience/ambience18.wav",
        "archiv/Ambience/ambience19.wav",
        "archiv/Ambience/ambience20.wav",
        "archiv/Ambience/ambience21.wav",
        "archiv/Ambience/ambience22.wav",
        "archiv/Ambience/ambience23.wav",
        "archiv/Ambience/ambience24.wav",
        "archiv/Ambience/ambience25.wav"
    }

    local ARCHIV_AMBIENCE_CACHE = {}
    local ARCHIV_AMBIENCE_READY = false

    hook.Add("Think", "ARCHIV_PrecacheAmbience", function()
        if ARCHIV_AMBIENCE_READY then return end
        local lp = LocalPlayer()
        if not IsValid(lp) then return end

        for i = 1, #ARCHIV_AMBIENCE_SOUNDS do
            local snd = CreateSound(lp, ARCHIV_AMBIENCE_SOUNDS[i])
            if snd then
                ARCHIV_AMBIENCE_CACHE[i] = snd
                snd:Stop()
            end
        end

        ARCHIV_AMBIENCE_READY = true
        hook.Remove("Think", "ARCHIV_PrecacheAmbience")
    end)

    net.Receive("ARCHIV_GlobalAmbience", function()
        if not ARCHIV_AMBIENCE_READY then return end
        local i = math.random(#ARCHIV_AMBIENCE_SOUNDS)
        local snd = ARCHIV_AMBIENCE_CACHE[i]
        if snd then snd:Play() end
    end)
end

pk_pills.register("pill_archivryan",{

    printName="Ryan the Angel Gamer",
	
    model="models/kaleb/archivryan/archivryan.mdl",
	
	modelScale="1",

    noragdoll = true,
    muteSteps = true,
    _zajcu37archiv_pill_ds = true,
	
    anims={
        default={
            idle="idle",
			run="run",
            walk="walk",
			attack="kill",
			jumpscare="kill",
            crouch = "cidle",
            crouch_walk = "cwalk",
        },
    },
	
    moveSpeed={
        walk=65,
        run=470,
        ducked=65,
    },
	
    sounds={
        jumpscare="archiv/RyanTheAngelGamerKill.wav",
        voiceline=pk_pills.helpers.makeList("archiv/Voicelines/voiceline#.wav",159),
        ambience=pk_pills.helpers.makeList("archiv/Ambience/ambience#.wav",25),
        hurt="archiv/Voicelines/voiceline1.wav",
    },
	

    type="ply",

    ThirdPersonBone = {
        'ValveBiped.Bip01_Neck1',
        10,
        0,
        5,
    },
    

    camera = {
        offset = Vector(0, 0, 75),
        dist=120,
    },
	
    jumpPower=0,
	
    health=250000,
	
	movePoseMode="xy",
		aim={
		xPose="aim_yaw",
		yPose="aim_pitch",
		nocrosshair = true
	},
	
	canAim=function(ply,ent)
		return ent.active
	end,
    
    zajcu37archiv_initialize=function(ply,ent,puppet)

    end,

    think_n_zajcu37archiv=function()

    end,

    initialize = function(ply, ent)
        if CLIENT then return end
    
        local voiceTimer = "PillVoiceLoop_" .. ent:EntIndex()
        local ambienceTimer = "PillAmbienceLoop_" .. ent:EntIndex()
        local dmgHookID = "PillHurtSound_" .. ent:EntIndex()
    
        timer.Create(voiceTimer, math.random(5, 12), 0, function()
            if not IsValid(ent) then
                timer.Remove(voiceTimer)
                return
            end
    
            if math.random(1, 100) <= 50 then
                ent:PillSound("voiceline")
            end
    
            timer.Adjust(voiceTimer, math.random(5, 12), 0)
        end)
    
        timer.Create(ambienceTimer, math.random(10, 40), 0, function()
            if not IsValid(ent) then
                timer.Remove(ambienceTimer)
                return
            end
    
            if math.random(1, 100) <= 50 then
                net.Start("ARCHIV_GlobalAmbience")
                net.Broadcast()
            end
    
            timer.Adjust(ambienceTimer, math.random(10, 40), 0)
        end)
    
        hook.Add("EntityTakeDamage", dmgHookID, function(target, dmginfo)
            if not IsValid(ent) then
                hook.Remove("EntityTakeDamage", dmgHookID)
                return
            end
    
            local owner = ent:GetPillUser()
            if not IsValid(owner) then return end
            if target ~= owner then return end
    
            if ent._NextHurtSound and ent._NextHurtSound > CurTime() then return end
            ent._NextHurtSound = CurTime() + 0.35
    
            ent:PillSound("hurt")
        end)
    
        ent:CallOnRemove("RemovePillTimers_" .. ent:EntIndex(), function()
            timer.Remove(voiceTimer)
            timer.Remove(ambienceTimer)
            hook.Remove("EntityTakeDamage", dmgHookID)
        end)
    end,

attack = {
    mode = 'trigger',
    func = function(ply, ent)
        local targetOrigin = ent:LocalToWorld(Vector(0, 0, 50))
local entity
if SherlockHNS then
    entity = SherlockHNS.FindVictim(ply, targetOrigin, 90, {
        filter = function(v)

            local trace = util.TraceLine({
                start = ent:EyePos(),
                endpos = v:EyePos(),
                filter = {ent, ply},
                mask = MASK_VISIBLE
            })
            return not trace.Hit
        end,
    })
else
for k, v in pairs(ents.FindInSphere(ent:LocalToWorld(Vector(0, 0, 50)), 130)) do
            if v:IsPlayer() or v:IsNextBot() or v:IsNPC() then
                if v == ent or v == ply then continue end

                if (v:IsPlayer() and v:Team() ~= TEAM_SPECTATOR) or ((v:IsNPC() or v:IsNextBot()) and v:Health() > 0) then
                    local trace = util.TraceLine({
                        start = ent:EyePos(),
                        endpos = v:EyePos(),
                        filter = {ent, ply},
                        mask = MASK_VISIBLE
                    })

                    if not trace.Hit then
                        entity = v
                        break
                    end
                end
            end
        end
end

if SherlockHNS and IsValid(entity) and entity:IsPlayer() then
            return pk_pills.playHNSJumpscare(ply, ent, entity, 2, {
                camera = "zajcu37archiv_jumpscare_gen",
                offset = 42,
                animation = "jumpscare",
                sound = "jumpscare",
                ownerCamera = "zajcu37archiv_jumpscare_gen",
            })
        end

        if not IsValid(entity) then return end

        local pill = ent:GetPuppet()

        if entity:IsPlayer() then
            entity:Freeze(true)
            entity:AddFlags(FL_NOTARGET)
            entity:DrawViewModel(false)
            entity:SetActiveWeapon(nil)

            net.Start('zajcu37archiv_jumpscare_gen')
            net.WriteEntity(pill)
            net.WriteBool(true)
            net.Send(entity)

            net.Start('zajcu37archiv_jumpscare_gen')
            net.WriteEntity(pill)
            net.WriteBool(true)
            net.Send(ply)
        else
            entity:NextThink(CurTime() + 1e9)
        end

        entity:SetPos(pill:GetPos() + pill:GetForward() * 42)

        ply:Freeze(true)
        ply:ConCommand("pk_pill_cl_thirdperson 0")

        ent:PillAnim('jumpscare')
        ent:PillSound('jumpscare')

        timer.Simple(2, function()
            if not (IsValid(entity) and IsValid(ent)) then return end
            
            ply:Freeze(false)
            ply:ConCommand("pk_pill_cl_thirdperson 1")

            if entity:IsPlayer() then
                entity:Kill(ply)

                net.Start('zajcu37archiv_jumpscare_gen')
                net.WriteEntity(pill)
                net.WriteBool(false)
                net.Send(entity)

                net.Start('zajcu37archiv_jumpscare_gen')
                net.WriteEntity(pill)
                net.WriteBool(false)
                net.Send(ply)

                entity:RemoveFlags(FL_NOTARGET)
                entity:Freeze(false)
                entity:DrawViewModel(true)
            else
                entity:NextThink(CurTime())
                entity:TakeDamage(1e9, ply)
            end
        end)

        timer.Simple(2.5, function()
            ent:PillSound('voiceline')
            ply.OnHold = false
            entity = nil -- clear after done
        end)
    end,
},

	
    --Right Click Attack Function
    attack2 = {
        mode = "trigger",
        func = function(ply, ent)
        end,
    },
    
    
    

noragdoll=true,
	
	-- R click function
   	reload=function(ply,ent)
       
    end,

	
    -- F Click function
    flashlight=function(ply,ent)

    end,
	
	-- Jump Attack Spacebar Function 
    jump=function(ply,ent)

    end,

    
}, function(form)
    -- The legacy damage branches are for Sandbox and NPCs.
    form.hnsKillAPI = true
    form.hnsAbilities = {
        { id = "attack", name = "Ataque", key = IN_ATTACK, OnUse = form.attack.func },
    }
    form.attack, form.attack2, form.reload = nil, nil, nil
end)

pk_pills.register("pill_archivinsect",{

    printName="Insect Chicken",
	
    model="models/kaleb/archivinsect/archivinsect.mdl",
	
	modelScale="1",

    noragdoll = true,
    muteSteps = true,
    _zajcu37archiv_pill_ds = true,
	
    anims={
        default={
            idle="idle",
			run="run",
            walk="walk",
			attack="kill",
			jumpscare="kill",
            crouch = "cidle",
            crouch_walk = "cwalk",
        },
    },
	
    moveSpeed={
        walk=65,
        run=470,
        ducked=65,
    },
	
    sounds={
        jumpscare="archiv/InsectChickenKill.wav",
        ambience=pk_pills.helpers.makeList("archiv/Ambience/ambience#.wav",25)
    },
	

    type="ply",

   ThirdPersonBone = {
        'ValveBiped_Bip01_Neck1',
        10,
        0,
        5,
    },

    camera = {
        offset = Vector(0, 0, 75),
        dist=120,
    },
	
    jumpPower=0,
	
    health=250000,
	
	movePoseMode="xy",
		aim={
		xPose="aim_yaw",
		yPose="aim_pitch",
		nocrosshair = true
	},
	
	canAim=function(ply,ent)
		return ent.active
	end,
    
    zajcu37archiv_initialize=function(ply,ent,puppet)

    end,

    think_n_zajcu37archiv=function()

    end,

    initialize = function(ply, ent)
        if CLIENT then return end
    
        local ambienceTimer = "PillAmbienceLoop_" .. ent:EntIndex()
    
        timer.Create(ambienceTimer, math.random(10, 40), 0, function()
            if not IsValid(ent) then
                timer.Remove(ambienceTimer)
                return
            end
    
            if math.random(1, 100) <= 50 then
                net.Start("ARCHIV_GlobalAmbience")
                net.Broadcast()
            end
    
            timer.Adjust(ambienceTimer, math.random(10, 40), 0)
        end)
    
    end,

attack = {
    mode = 'trigger',
    func = function(ply, ent)
        local targetOrigin = ent:LocalToWorld(Vector(0, 0, 50))
local entity
if SherlockHNS then
    entity = SherlockHNS.FindVictim(ply, targetOrigin, 90, {
        filter = function(v)

            local trace = util.TraceLine({
                start = ent:EyePos(),
                endpos = v:EyePos(),
                filter = {ent, ply},
                mask = MASK_VISIBLE
            })
            return not trace.Hit
        end,
    })
else
for k, v in pairs(ents.FindInSphere(ent:LocalToWorld(Vector(0, 0, 50)), 130)) do
            if v:IsPlayer() or v:IsNextBot() or v:IsNPC() then
                if v == ent or v == ply then continue end

                if (v:IsPlayer() and v:Team() ~= TEAM_SPECTATOR) or ((v:IsNPC() or v:IsNextBot()) and v:Health() > 0) then
                    local trace = util.TraceLine({
                        start = ent:EyePos(),
                        endpos = v:EyePos(),
                        filter = {ent, ply},
                        mask = MASK_VISIBLE
                    })

                    if not trace.Hit then
                        entity = v
                        break
                    end
                end
            end
        end
end

if SherlockHNS and IsValid(entity) and entity:IsPlayer() then
            return pk_pills.playHNSJumpscare(ply, ent, entity, 5.9, {
                camera = "zajcu37archiv_jumpscare_gen",
                offset = 30,
                animation = "jumpscare",
                sound = "jumpscare",
                ownerCamera = "zajcu37archiv_jumpscare_gen",
            })
        end

        if not IsValid(entity) then return end

        local pill = ent:GetPuppet()

        if entity:IsPlayer() then
            entity:Freeze(true)
            entity:AddFlags(FL_NOTARGET)
            entity:DrawViewModel(false)
            entity:SetActiveWeapon(nil)

            net.Start('zajcu37archiv_jumpscare_gen')
            net.WriteEntity(pill)
            net.WriteBool(true)
            net.Send(entity)

            net.Start('zajcu37archiv_jumpscare_gen')
            net.WriteEntity(pill)
            net.WriteBool(true)
            net.Send(ply)
        else
            entity:NextThink(CurTime() + 1e9)
        end

        entity:SetPos(pill:GetPos() + pill:GetForward() * 30)

        ply:Freeze(true)
        ply:ConCommand("pk_pill_cl_thirdperson 0")

        ent:PillAnim('jumpscare')
        ent:PillSound('jumpscare')

        timer.Simple(5.9, function()
            if not (IsValid(entity) and IsValid(ent)) then return end
            
            ply:Freeze(false)
            ply:ConCommand("pk_pill_cl_thirdperson 1")

            if entity:IsPlayer() then
                entity:Kill(ply)

                net.Start('zajcu37archiv_jumpscare_gen')
                net.WriteEntity(pill)
                net.WriteBool(false)
                net.Send(entity)

                net.Start('zajcu37archiv_jumpscare_gen')
                net.WriteEntity(pill)
                net.WriteBool(false)
                net.Send(ply)

                entity:RemoveFlags(FL_NOTARGET)
                entity:Freeze(false)
                entity:DrawViewModel(true)
            else
                entity:NextThink(CurTime())
                entity:TakeDamage(1e9, ply)
            end
        end)

        timer.Simple(7, function()
            ply.OnHold = false
            entity = nil -- clear after done
        end)
    end,
},

	
    --Right Click Attack Function
    attack2 = {
        mode = "trigger",
        func = function(ply, ent)
        end,
    },
    
    
    

noragdoll=true,
	
	-- R click function
   	reload=function(ply,ent)
       
    end,

	
    -- F Click function
    flashlight=function(ply,ent)

    end,
	
	-- Jump Attack Spacebar Function 
    jump=function(ply,ent)

    end,

    
}, function(form)
    -- The legacy damage branches are for Sandbox and NPCs.
    form.hnsKillAPI = true
    form.hnsAbilities = {
        { id = "attack", name = "Ataque", key = IN_ATTACK, OnUse = form.attack.func },
    }
    form.attack, form.attack2, form.reload = nil, nil, nil
end)
