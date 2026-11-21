
hook.Add("OnEntityCreated", "zajcu37archivt_initialize_gem_2", function(ent)
    timer.Simple(0.01, function()
        if !IsValid(ent) then return end
        if ent:GetClass() ~= "pill_ent_costume" then return end


        if ent.formTable then
            local PuppetEntity = ent:GetPuppet()
            local entityply = ent:GetPillUser()

            if ent.formTable.zajcu37archiv_initialize then
                ent.formTable:zajcu37archiv_initialize(entityply, ent, PuppetEntity)
                 hook.Add("PlayerFootstep", "DisableFootstepID_OM:".. ent:EntIndex(), function(ply) if entityply == ply then return true end end)

                    ent:CallOnRemove("RemoveHook_OM"..ent:EntIndex(), function()
                        hook.Remove("PlayerFootstep", "DisableFootstepID_OM:".. ent:EntIndex())
                    end)

                local self = ent
                ent.Think = function()
                    local ply = self:GetPillUser()
                    local puppet = self:GetPuppet()
                    if not IsValid(puppet) or not IsValid(ply) then return end
                    local vel = ply:GetVelocity():Length()

                    if SERVER then
                        --Anims
                        local anims = table.Copy(self.formTable.anims.default or {})
                        table.Merge(anims, (IsValid(ply:GetActiveWeapon()) and self.formTable.anims[ply:GetActiveWeapon():GetHoldType()]) or (self.forceAnimSet and self.formTable.anims[self.forceAnimSet]) or {})
                        local anim
                        --local useSeqVel=true
                        local overrideRate

                        if (not self.anim or not anims[self.anim]) then
                            self.animFreeze = nil
                            self.animStart = nil
                        end

                        if self.animFreeze and not self.plyFrozen then
                            ply:SetWalkSpeed(ply:GetWalkSpeed() / 2)
                            ply:SetRunSpeed(ply:GetWalkSpeed() / 2)
                            self.plyFrozen = true
                        elseif not self.animFreeze and self.plyFrozen then
                            local speed = self.formTable.moveSpeed or {}
                            ply:SetWalkSpeed(speed.walk or 200)
                            ply:SetRunSpeed(speed.run or speed.walk or 500)
                            self.plyFrozen = nil
                        end

                        if self.anim and anims[self.anim] then
                            anim = anims[self.anim]
                            overrideRate = anims[self.anim .. "_rate"] or 1
                            local cycle = puppet:GetCycle()

                            if not self.animStart then
                                if cycle == 1 or (self.animCycle and self.animCycle > cycle) or (string.lower(anim) ~= string.lower(puppet:GetSequenceName(puppet:GetSequence()))) then
                                    self.anim = nil
                                    self.animCycle = nil

                                    if self.animFreeze then
                                        self.animFreeze = nil
                                    end
                                elseif self.animCycle then
                                    self.animCycle = cycle
                                end
                            end
                        elseif self.tickAnim and anims[self.tickAnim] then
                            anim = anims[self.tickAnim]
                            overrideRate = anims[self.tickAnim .. "_rate"] or 1
                            self.tickAnim = nil
                        elseif self.burrowed then
                            anim = anims["burrow_loop"]
                        elseif ply:WaterLevel() > 2 then
                            anim = anims["swim"] or anims["glide"] or anims["idle"]
                        elseif ply:IsOnGround() then
                            if ply:Crouching() then
                                if vel > ply:GetCrouchedWalkSpeed() / 4 then
                                    anim = anims["crouch_walk"] or anims["crouch"] or anims["walk"] or anims["idle"]
                                else
                                    anim = anims["crouch"] or anims["idle"]
                                end
                            else
                                if vel > (ply:GetWalkSpeed() + ply:GetRunSpeed()) / 2 then
                                    anim = anims["run"] or anims["walk"] or anims["idle"]
                                elseif vel > ply:GetWalkSpeed() / 4 then
                                    anim = anims["walk"] or anims["idle"]
                                else
                                    anim = anims["idle"]
                                end
                            end
                        else
                            anim = anims["glide"] or anims["idle"]
                        end

                        if anim == anims["idle"] or anim == anims["crouch"] then
                            overrideRate = 1
                        end

                        if (anim and puppet:GetSequence() ~= puppet:LookupSequence(anim)) or self.animStart or (self.formTable.autoRestartAnims and puppet:GetCycle() == 1) then
                            puppet:ResetSequence(puppet:LookupSequence(anim))
                            puppet:SetCycle(0)
                            self.animCycle = 0
                        end

                        self.animStart = nil
                        local seq_vel = puppet:GetSequenceGroundSpeed(puppet:GetSequence())

                        --if true then
                        if self.formTable.movePoseMode ~= "xy" and self.formTable.movePoseMode ~= "xy-bot" and not overrideRate then
                            local rate = overrideRate or vel / seq_vel

                            --goofy limitation (floods console with errors if above 12!)
                            if rate > 12 then
                                rate = 12
                            end

                            puppet:SetPlaybackRate(rate)
                        else
                            --puppet:SetPlaybackRate(1)
                        end

                        --print(puppet:GetCycle())
                        if self.formTable.movePoseMode then
                            --
                            if self.formTable.movePoseMode == "yaw" then
                                local move_dir = puppet:WorldToLocalAngles(ply:GetVelocity():Angle())
                                puppet:SetPoseParameter("move_yaw", move_dir.y)
                            elseif self.formTable.movePoseMode == "xy" then
                                if not overrideRate then
                                    local localvel = ply:WorldToLocal(ply:GetPos() + ply:GetVelocity())
                                    local maxdim = math.Max(math.abs(localvel.x), math.abs(localvel.y))
                                    local clampedvel = maxdim == 0 and Vector(0, 0, 0) or localvel / maxdim
                                    puppet:SetPoseParameter("move_x", clampedvel.x)
                                    puppet:SetPoseParameter("move_y", -clampedvel.y)
                                    seq_vel = puppet:GetSequenceGroundSpeed(puppet:GetSequence())

                                    if seq_vel ~= 0 then
                                        puppet:SetPoseParameter("move_x", math.Clamp(localvel.x / seq_vel, -.99, .99))
                                        puppet:SetPoseParameter("move_y", math.Clamp(-localvel.y / seq_vel, -.99, .99))
                                    end
                                    --print(puppet:GetPlaybackRate())
                                else
                                    puppet:SetPoseParameter("move_x", 0)
                                    puppet:SetPoseParameter("move_y", 0)
                                end
                            elseif self.formTable.movePoseMode == "xy-bot" then
                                if not overrideRate then
                                    local localvel = ply:WorldToLocal(ply:GetPos() + ply:GetVelocity())
                                    local maxdim = math.Max(math.abs(localvel.x), math.abs(localvel.y))
                                    local clampedvel = maxdim == 0 and Vector(0, 0, 0) or localvel / maxdim
                                    local move_dir = puppet:WorldToLocalAngles(ply:GetVelocity():Angle())
                                    puppet:SetPoseParameter("move_x", clampedvel.x)
                                    puppet:SetPoseParameter("move_y", -clampedvel.y)
                                    puppet:SetPoseParameter("move_yaw", move_dir.y)
                                    puppet:SetPoseParameter("move_scale", 1)
                                    seq_vel = puppet:GetSequenceGroundSpeed(puppet:GetSequence())

                                    if seq_vel ~= 0 then
                                        puppet:SetPoseParameter("move_x", math.Clamp(localvel.x / seq_vel, -.99, .99))
                                        puppet:SetPoseParameter("move_y", math.Clamp(-localvel.y / seq_vel, -.99, .99))
                                        puppet:SetPoseParameter("move_scale", math.Clamp(localvel:Length() / seq_vel, -.99, .99))
                                    end
                                    --print(puppet:GetPlaybackRate())
                                else
                                    puppet:SetPoseParameter("move_x", 0)
                                    puppet:SetPoseParameter("move_y", 0)
                                    puppet:SetPoseParameter("move_yaw", 0)
                                    puppet:SetPoseParameter("move_scale", 0)
                                end
                            end
                        end

                        --Aimage
                        if self.formTable.aim then
                            if self.formTable.aim.xPose then
                                local yaw = math.AngleDifference(ply:EyeAngles().y, self:GetAngles().y)

                                if self.formTable.aim.xInvert then
                                    yaw = -yaw
                                end

                                puppet:SetPoseParameter(self.formTable.aim.xPose, yaw)
                            end

                            if self.formTable.aim.yPose then
                                local pitch = math.AngleDifference(ply:EyeAngles().p, self:GetAngles().p)

                                if self.formTable.aim.yInvert then
                                    pitch = -pitch
                                end

                                puppet:SetPoseParameter(self.formTable.aim.yPose, pitch)
                            end
                        end

                        --gliding and landing
                        if not ply:IsOnGround() and ply:WaterLevel() == 0 and self.formTable.glideThink then
                            self.formTable.glideThink(ply, self)
                        end

                        if not ply:IsOnGround() and not self.touchingWater and ply:WaterLevel() > 0 and self.formTable.land then
                            self.formTable.land(ply, self)
                        end

                        --water death
                        self.touchingWater = ply:WaterLevel() > 1

                        if (self.formTable.damageFromWater and self.touchingWater) then
                            if self.formTable.damageFromWater == -1 then
                                --self:PillDie()
                                ply:Kill()
                            else
                                ply:TakeDamage(self.formTable.damageFromWater)
                                --TODO APPLY DAMAGE
                            end
                        end

                        --tick attack
                        if ply:KeyDown(IN_ATTACK) and self.formTable.attack and self.formTable.attack.mode == "tick" then
                            self.formTable.attack.func(ply, self, self.formTable.attack)
                        end

                        if ply:KeyDown(IN_ATTACK2) and self.formTable.attack2 and self.formTable.attack2.mode == "tick" then
                            self.formTable.attack2.func(ply, self, self.formTable.attack2)
                        end

                        --auto attack
                        if ply:KeyDown(IN_ATTACK) and self.formTable.attack and self.formTable.attack.mode == "auto" then
                            if not self.formTable.aim then
                                self:PillLoopSound("attack")
                            else
                                self:PillLoopStop("attack")
                            end

                            if (not self.lastAttack or (self.formTable.attack.interval or self.formTable.attack.delay) < CurTime() - self.lastAttack) then
                                self.formTable.attack.func(ply, self, self.formTable.attack)
                                self.lastAttack = CurTime()
                            end
                        else
                            self:PillLoopStop("attack")
                        end

                        if ply:KeyDown(IN_ATTACK2) and self.formTable.attack2 and self.formTable.attack2.mode == "auto" then
                            if not self.formTable.aim then
                                self:PillLoopSound("attack2")
                            else
                                self:PillLoopStop("attack2")
                            end

                            if not self.lastAttack2 or (self.formTable.attack2.interval or self.formTable.attack2.delay) < CurTime() - self.lastAttack2 then
                                self.formTable.attack2.func(ply, self, self.formTable.attack2)
                                self.lastAttack2 = CurTime()
                            end
                        else
                            self:PillLoopStop("attack2")
                        end

                        --charge
                        if self:GetChargeTime() ~= 0 then
                            if ply:OnGround() then
                                local charge = self.formTable.charge
                                local angs = ply:EyeAngles()
                                self:PillAnimTick("charge_loop")
                                local hit_ent = ply:TraceHullAttack(ply:EyePos(), ply:EyePos() + angs:Forward() * 100, Vector(-20, -20, -20), Vector(20, 20, 20), charge.dmg, DMG_CRUSH, 1, true)

                                if IsValid(hit_ent) then
                                    self:PillAnim("charge_hit", true)
                                    --self:PillGesture("charge_hit")
                                    self:PillSound("charge_hit")
                                    self:SetChargeTime(0)
                                    self:PillLoopStop("charge")
                                end
                            else
                                self:SetChargeTime(0)
                                self:PillLoopStop("charge")
                            end
                        end

                        --Cloak
                        if self.formTable.cloak then
                            local cloak = self.formTable.cloak

                            if self.iscloaked then
                                local cloakamt = self:GetCloakLeft()

                                if cloakamt ~= -1 then
                                    cloakamt = cloakamt - FrameTime()

                                    if cloakamt < 0 then
                                        cloakamt = 0
                                        self:ToggleCloak()
                                    end

                                    self:SetCloakLeft(cloakamt)
                                end
                            else
                                local cloakamt = self:GetCloakLeft()

                                if cloakmt ~= -1 and cloakamt < cloak.max then
                                    cloakamt = cloakamt + FrameTime() * cloak.rechargeRate

                                    if cloakamt > cloak.max then
                                        cloakamt = cloak.max
                                    end

                                    self:SetCloakLeft(cloakamt)
                                end
                            end

                            local color = self:GetPuppet():GetColor()

                            if self.iscloaked then
                                if color.a > 0 then
                                    color.a = color.a - 5
                                    self:GetPuppet():SetColor(color)
                                end
                            else
                                if color.a < 255 then
                                    color.a = color.a + 5
                                    self:GetPuppet():SetColor(color)
                                end
                            end

                            --PrintTable(color)
                            if IsValid(self.wepmdl) and self.wepmdl:GetColor().a ~= color.a then
                                self.wepmdl:SetColor(color)
                            end
                        end

                        --if !IsValid(ply) then self:NextThink(CurTime()) return true end
                        --wepon-no longer SO hackey
                        if not self.formTable.hideWeapons then
                            local realWep = self:GetPillUser():GetActiveWeapon()

                            --&&self:GetPillUser()!=ply or pk_pills.var_thirdperson:GetBool()) then
                            if IsValid(realWep) and realWep:GetModel() ~= "" then
                                --hiding the real thing [BROKEN]
                                --[[if realWep:GetRenderMode()!=RENDERMODE_NONE then
                                    realWep:SetRenderMode(RENDERMODE_NONE)
                                end]]
                                if realWep.pill_attachment then
                                    if IsValid(self.wepmdl) then
                                        self.wepmdl:Remove()
                                    end

                                    self.wepmdl = ents.Create("pill_attachment_wep")
                                    self.wepmdl:SetParent(self:GetPuppet())
                                    self.wepmdl:SetModel(realWep:GetModel())
                                    self.wepmdl.attachment = realWep.pill_attachment
                                    self.wepmdl:Spawn()

                                    if realWep.pill_offset then
                                        self.wepmdl:SetWepOffset(realWep.pill_offset)
                                    end

                                    if realWep.pill_angle then
                                        self.wepmdl:SetWepAng(realWep.pill_angle)
                                    end

                                    realWep.pill_proxy = self.wepmdl
                                elseif not IsValid(self.wepmdl) then
                                    self.wepmdl = ents.Create("pill_attachment_wep")
                                    self.wepmdl:SetParent(self:GetPuppet())
                                    self.wepmdl:SetModel(realWep:GetModel())
                                    self.wepmdl:Spawn()
                                    realWep.pill_proxy = self.wepmdl
                                elseif self.wepmdl:GetModel() ~= realWep:GetModel() then
                                    self.wepmdl:SetModel(realWep:GetModel())
                                end
                            elseif IsValid(self.wepmdl) then
                                self.wepmdl:Remove()
                            end
                        end
                    else
                        self:SetNWBool('clientsideshould', not pk_pills.convars.cl_thirdperson:GetBool())

                        if self:GetPillUser() ~= LocalPlayer() or true then
                            puppet:SetNoDraw(false)
                        end

                        local realWep = self:GetPillUser():GetActiveWeapon()

                        if IsValid(realWep) and realWep:GetModel() ~= "" and not realWep:GetNoDraw() then
                            realWep:SetNoDraw(true)
                        end
                    end

                    --Align pos and angles with player
                    if SERVER then
                        puppet:SetPos(ply:GetPos())
                        self:SetAngles(ply:GetAngles())
                    else
                        puppet:SetRenderOrigin(ply:GetPos())
                    end

                    if vel > 0 or math.abs(math.AngleDifference(puppet:GetAngles().y, ply:EyeAngles().y)) > 350 or self:GetNWBool('clientsideshould') then
                        local angs = ply:EyeAngles()
                        angs.p = 0

                        if SERVER then
                            puppet:SetAngles(angs)
                        else
                            --puppet:SetAngles(angs)
                            puppet:SetRenderAngles(angs)
                        end
                    end

                    self:NextThink(CurTime())

                    return true
                end


            else
            end
        end

        if ent.formTable.HandleAnimEvent_g_rac then
            print(1)
            local PuppetEntity = ent:GetPuppet()
            local entityply = ent:GetPillUser()

            if IsValid(PuppetEntity) then
                print(2)
                function PuppetEntity:AcceptInput(inputName, activator, caller, data)
                    ent.formTable.HandleAnimEvent_g_rac(entityply, ent, inputName)
                    return true
                end
            end
        else
            print(0)
        end
    end)
end)

hook.Add("Think", "TrackPillCostumes_zajcu37archiv", function()
    for _, ent in ipairs(ents.FindByClass("pill_ent_costume")) do
        if !IsValid(ent) then continue end
        local ply = ent:GetPillUser()
        local puppet = ent:GetPuppet()

        if not IsValid(puppet) or not IsValid(ply) then continue end

        if ent.formTable.think_n_zajcu37archiv then
            ent.formTable.think_n_zajcu37archiv(ply, ent)
        end
    end
end)



if SERVER then
    AddCSLuaFile()
    util.AddNetworkString('zajcu37archiv_jumpscare_gen')
    util.AddNetworkString("ARCHIV_GlobalAmbience")

else

    hook.Remove("CalcView", "momo_calcview")

    hook.Add("CalcView", "momo_calcview", function(ply, pos, ang, fov)
        local ent = pk_pills.getMappedEnt(LocalPlayer())

        if IsValid(ent) and ply:GetViewEntity() == ply then
            local startpos

            if ent.formTable.type == "phys" then
                startpos = ent:LocalToWorld(ent.formTable.camera and ent.formTable.camera.offset or Vector(0, 0, 0))
            else
                startpos = pos
            end

            if pk_pills.convars.cl_thirdperson:GetBool() then

                if ent.formTable.ThirdPersonBone then

                    if IsValid(ent:GetPuppet()) then
                        local bonename = ent.formTable.ThirdPersonBone[1]
                        local boneID = ent:GetPuppet():LookupBone(bonename)
                        local bonePos, boneAng = ent:GetPuppet():GetBonePosition(boneID)

                        local dist

                        if ent.formTable.type == "phys" and ent.formTable.camera and ent.formTable.camera.distFromSize then
                            dist = ent:BoundingRadius() * 5
                        else
                            dist = ent.formTable.camera and ent.formTable.camera.dist or 100
                        end
                        local startpos = bonePos + LocalPlayer():GetForward() * (ent.formTable.ThirdPersonBone[2]) + LocalPlayer():GetUp() * (ent.formTable.ThirdPersonBone[4])+ LocalPlayer():GetRight() * (ent.formTable.ThirdPersonBone[3])
                        local underslung = ent.formTable.camera and ent.formTable.camera.underslung
                        local offset = LocalToWorld(Vector(-dist, 0, underslung and -dist / 5 or dist / 5), Angle(0, 0, 0), Vector(0, 0, 0), ang)

                        local tr = util.TraceHull({
                            start = startpos,
                            endpos = startpos + offset,
                            filter = ent.camTraceFilter,
                            mins = Vector(-5, -5, -5),
                            maxs = Vector(5, 5, 5),
                            mask = MASK_VISIBLE
                        })

                        local view = {}
                        view.origin = tr.HitPos
                        view.angles = ang
                        view.fov = fov
                        view.drawviewer = true

                        return view
                    end
                end

                local dist

                if ent.formTable.type == "phys" and ent.formTable.camera and ent.formTable.camera.distFromSize then
                    dist = ent:BoundingRadius() * 5
                else
                    dist = ent.formTable.camera and ent.formTable.camera.dist or 100
                end

                local underslung = ent.formTable.camera and ent.formTable.camera.underslung
                local offset = LocalToWorld(Vector(-dist, 0, underslung and -dist / 5 or dist / 5), Angle(0, 0, 0), Vector(0, 0, 0), ang)

                local tr = util.TraceHull({
                    start = startpos,
                    endpos = startpos + offset,
                    filter = ent.camTraceFilter,
                    mins = Vector(-5, -5, -5),
                    maxs = Vector(5, 5, 5),
                    mask = MASK_VISIBLE
                })

                local view = {}
                view.origin = tr.HitPos
                view.angles = ang
                view.fov = fov
                view.drawviewer = true

                return view
            else
                if ent.formTable.FirstPersonBone then
                    if IsValid(ent:GetPuppet()) then
                        local bonename = ent.formTable.FirstPersonBone[1]
                        local boneID = ent:GetPuppet():LookupBone(bonename)
                        local bonePos, boneAng = ent:GetPuppet():GetBonePosition(boneID)
                        local view = {}
                        view.origin = bonePos + LocalPlayer():GetForward() * (ent.formTable.FirstPersonBone[2]) + LocalPlayer():GetUp() * (ent.formTable.FirstPersonBone[4])+ LocalPlayer():GetRight() * (ent.formTable.FirstPersonBone[3])
                        view.angles = ang
                        view.fov = fov
                        view.drawviewer = false
                        return view
                    end
                end
            end
        end
    end)


    


    hook.Add("SetupPlayerVisibility", "VisibilityHandler_v2", function()
        local ply = LocalPlayer()

        local pillentity = ply.pk_pill_ent
        if IsValid(pillentity) then
            if ( pillentity:GetNWInt('Swallhaks', 0) >= CurTime() ) then

                for _, ent in ipairs(ents.GetAll()) do
                    if IsValid(ent) then
                        if ent:IsPlayer() or ent:IsNPC() or ent:IsNextBot() then
                            AddOriginToPVS(plr:GetPos())
                        end
                    end
                end
            end
        end
    end)

    hook.Add( "PreDrawHalos", "zajcu37archivseason_v2", function()
        local ply = LocalPlayer()

        local pillentity = ply.pk_pill_ent
        if IsValid(pillentity) then
            if ( pillentity:GetNWInt('Swallhaks', 0) >= CurTime() ) then
                local entities = {}

                for _, ent in ipairs(ents.GetAll()) do
                    if IsValid(ent) then
                        if ent:IsPlayer() or ent:IsNPC() or ent:IsNextBot() then
                            if ent == ply then continue end 
                            if ent == pillentity then continue end 
                            if ent:IsPlayer() and ent:Team() == TEAM_SPECTATOR then continue end

                            if ent:GetColor().a <= 30 then continue end
                            if ent:GetClass() == "pill_puppet" then continue end

                            table.insert(entities, ent)
                            
                        end
                    end
                end

                local alpha = 0
                local endTime = pillentity:GetNWInt('Swallhaks', 0) 

                if endTime > CurTime() then
                    local totalDuration = 10
                    local startTime = endTime - totalDuration
                    local fadeDuration = 1
                    if CurTime() < startTime + fadeDuration then
                        alpha = Lerp((CurTime() - startTime) / fadeDuration, 0, 155)
                    elseif CurTime() > endTime - fadeDuration then
                        alpha = Lerp((endTime - CurTime()) / fadeDuration, 0, 155)
                    else
                        alpha = 155
                    end
                end

                halo.Add(entities, Color(alpha,0,alpha), 5, 5, 50, true, true)
            end
        end
    end )


    net.Receive('zajcu37archiv_jumpscare_gen', function()
        local ent = net.ReadEntity()
        local state = net.ReadBool()
        local startTime = CurTime()

        local hookID = "zajcu37archiv_jumpscare_" .. LocalPlayer():SteamID()

        --print(state)

        if not state then
            hook.Remove('CalcView', hookID)
        else
            hook.Add('CalcView', hookID, function(ply, pos, angles, fov)
                if not IsValid(ply) or not ply:Alive() or !IsValid(ent) then
                    hook.Remove('CalcView', hookID)
                    if IsValid(ply) then
                        ply:RemoveFlags(FL_NOTARGET)
                        ply:Freeze(false)
                        ply:DrawViewModel(true)
                    end
                    return
                end

                local cam = ent:GetAttachment(ent:LookupAttachment('camera'))

                ply:AddFlags(FL_NOTARGET)
                ply:Freeze(true)
                ply:DrawViewModel(false)

                local lerpFactor = math.Clamp((CurTime() - startTime) / (0.7/3), 0, 1)
                
                local targetFOV = 75

                local orgiginlerpto = LerpVector(lerpFactor, pos, cam.Pos)
                local angleslerpto = LerpAngle(lerpFactor, angles, cam.Ang)
                local interpolatedFOV = Lerp(lerpFactor, fov, targetFOV)

                local view = {
                    origin = orgiginlerpto,
                    angles = angleslerpto,
                    fov = interpolatedFOV,
                    drawviewer = false
                }
                return view
            end)
        end
    end)
end

local function AdvancedPillSound(SoundData, ent)
    if IsValid(ent) then
        SoundData = SoundData or {}
        SoundData.stringe = SoundData.stringe or {}
        SoundData.soundLevel = SoundData.soundLevel or 75
        SoundData.pitchPercent = SoundData.pitchPercent or 100
        SoundData.volume = SoundData.volume or 1
        SoundData.channel = SoundData.channel or CHAN_AUTO
        SoundData.soundFlags = SoundData.soundFlags or 0
        SoundData.dsp = SoundData.dsp or 0
        SoundData.filter = SoundData.filter or nil

        local chosenSound = SoundData.stringe

        if istable(SoundData.stringe) then
            local index = math.random(1, #SoundData.stringe)
            chosenSound = SoundData.stringe[index]
        end

        ent:EmitSound(
            chosenSound,
            SoundData.soundLevel,
            SoundData.pitchPercent,
            SoundData.volume,
            SoundData.channel,
            SoundData.soundFlags,
            SoundData.dsp,
            SoundData.filter
        )
    end
    return true
end


local function zajcu37archivjackietien_jumpscare(ply, ent, duration, customanimstuff)
    if not ent.IsInJumpscare then ent.IsInJumpscare = 0 end
    if ent.IsInJumpscare >= CurTime() then return end
    if not ent.IsInJumpscareCooldown then ent.IsInJumpscareCooldown = 0 end
    if ent.IsInJumpscareCooldown >= CurTime() then return end

    local jumpscare_entity = nil

    for _, ent2 in pairs(ents.FindInSphere(ent:LocalToWorld(Vector(0, 0, 50)), 90)) do
        if (ent2:IsPlayer() or ent2:IsNextBot() or ent2:IsNPC()) and ent2:Health() >= 0.1 then
            if ent2 == ply then continue end
            if ent2:IsPlayer() and ent2:Team() == TEAM_SPECTATOR then continue end

            if IsValid(ent2) then
                jumpscare_entity = ent2
                break
            end
        end
    end

    if jumpscare_entity ~= nil then
        
        ent.JuumpscareStart = CurTime()

        ent.jumpscare_entity = jumpscare_entity
        ent.entitylastpos = jumpscare_entity:GetPos()
        ent.entitylastang = jumpscare_entity:GetAngles()

        local targetAngle = (ply:GetPos() - jumpscare_entity:GetPos()):Angle()

        targetAngle.p = 0
        targetAngle.r = 0

        ply:SetNWInt("DisableMovement_jumpscare_pill_zajcu37archiv", duration+CurTime())
        jumpscare_entity:SetNWInt("DisableMovement_jumpscare_pill_zajcu37archiv", duration+CurTime())

        ent.IsInJumpscare = CurTime() + duration

        local puppet = ent:GetPuppet()

        if jumpscare_entity:IsPlayer() then
            net.Start('zajcu37archiv_jumpscare_gen')
            net.WriteEntity(puppet)
            net.WriteBool(true)
            net.Send(jumpscare_entity)
        else
            jumpscare_entity:NextThink(duration+0.1+CurTime())
        end
        
        jumpscare_entity:AddFlags(FL_NOTARGET)

        ent:CallOnRemove("zajcu37archivJumpscare"..ent:EntIndex(), function()
            if !IsValid(jumpscare_entity) then return end

            jumpscare_entity:RemoveFlags(FL_NOTARGET)
            ent.jumpscare_entity = nil

            if jumpscare_entity:IsPlayer() then
                net.Start('zajcu37archiv_jumpscare_gen')
                net.WriteEntity(puppet)
                net.WriteBool(false)
                net.Send(jumpscare_entity)
            else
                jumpscare_entity:NextThink(CurTime())
            end
            jumpscare_entity:SetPos(ent.entitylastpos)
            jumpscare_entity:SetAngles(ent.entitylastang)
            jumpscare_entity:SetNWInt("DisableMovement_jumpscare_pill_zajcu37archiv", CurTime())
        end)

        customanimstuff()
    end
end

hook.Add("SetupMove", "DisablePlayerMovement_zajcu37archiv", function(ply, mv, cmd)
    if ply:GetNWInt("DisableMovement_jumpscare_pill_zajcu37archiv") >= CurTime() then
        mv:SetForwardSpeed(0)
        mv:SetSideSpeed(0)
        mv:SetUpSpeed(0)
        mv:SetButtons(0)
    end
end)

-- ===============================
-- Pill Voiceline Helpers
-- ===============================

local function StartPillVoicelines(ent, ply, minDelay, maxDelay)
    if not IsValid(ent) or not IsValid(ply) then return end

    minDelay = minDelay or 4
    maxDelay = maxDelay or 8

    local timerName = "PillVoiceline_" .. ply:SteamID64()

    timer.Create(timerName, math.random(minDelay, maxDelay), 0, function()
        if not IsValid(ent) or not IsValid(ply) then
            timer.Remove(timerName)
            return
        end

        if not ply.OnHold then
            timer.Remove(timerName)
            return
        end

        ent:PillSound("voiceline")
        timer.Adjust(timerName, math.random(minDelay, maxDelay), 0)
    end)
end


pk_pills.packStart("Zajcu37 Archiv Pill Pack","Zajcu37 Archiv Pill Pack","materials/icon/archivicon.png")

pk_pills.register("pill_archivredfreddy",{

    printName="Blood Bear",
	
    model="models/kaleb/archivredfreddy/archivredfreddy.mdl",
	
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
        jumpscare="archiv/RedFreddyKill.wav",
        ambience=pk_pills.helpers.makeList("archiv/Ambience/ambience#.wav",25)
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
        local entity -- make it local to avoid persisting between attacks

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

    
})

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
        local entity -- make it local to avoid persisting between attacks

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

    
})

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
        local entity -- make it local to avoid persisting between attacks

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

    
})
