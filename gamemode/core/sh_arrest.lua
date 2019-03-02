function meta:SetHandsBehindBack(state)
	local L_UPPERARM = self:LookupBone("ValveBiped.Bip01_L_UpperArm")
	local R_UPPERARM = self:LookupBone("ValveBiped.Bip01_R_UpperArm")
	local L_FOREARM = self:LookupBone("ValveBiped.Bip01_L_Forearm")
	local R_FOREARM = self:LookupBone("ValveBiped.Bip01_R_Forearm")
	local L_HAND = self:LookupBone("ValveBiped.Bip01_L_Hand") 
	local R_HAND = self:LookupBone("ValveBiped.Bip01_R_Hand")
			
	if L_UPPERARM and R_UPPERARM and L_FOREARM and R_FOREARM and L_HAND and R_HAND then
		if state then
			if self:IsFemale() then
				self:ManipulateBoneAngles(L_UPPERARM, Angle(5, 5, 0))
				self:ManipulateBoneAngles(R_UPPERARM, Angle(-5, 10, 0))
				self:ManipulateBoneAngles(L_FOREARM, Angle(16, 5, 0))
				self:ManipulateBoneAngles(R_FOREARM, Angle(-16, 5, 0))         
				self:ManipulateBoneAngles(L_HAND, Angle(-25, -10, 0))
				self:ManipulateBoneAngles(R_HAND, Angle(25, -10, 0))
			else
				self:ManipulateBoneAngles(L_UPPERARM, Angle(5, 5, 0))
				self:ManipulateBoneAngles(R_UPPERARM, Angle(-5, 10, 0))
				self:ManipulateBoneAngles(L_FOREARM, Angle(25, 5, 0))
				self:ManipulateBoneAngles(R_FOREARM, Angle(-25, 5, 0))
				self:ManipulateBoneAngles(L_HAND, Angle(-25, -10, 0))                  
				self:ManipulateBoneAngles(R_HAND, Angle(25, -10, 0))           
			end
		else
			self:ManipulateBoneAngles(L_UPPERARM, Angle(0, 0, 0))
			self:ManipulateBoneAngles(R_UPPERARM, Angle(0, 0, 0))
			self:ManipulateBoneAngles(L_FOREARM, Angle(0, 0, 0))
			self:ManipulateBoneAngles(R_FOREARM, Angle(0, 0, 0))
			self:ManipulateBoneAngles(L_HAND, Angle(0, 0, 0))  
			self:ManipulateBoneAngles(R_HAND, Angle(0, 0, 0))  
		end
	end
end

function meta:CanArrest(arrested)
	if not arrested then return true end -- server can arrest anyone

	if not self:IsCP() then
		return false
	end

	if arrested:IsCP() then
		return false
	end

	return true
end

if SERVER then
	impulse.Arrest = impulse.Arrest or {}
	impulse.Arrest.Dragged = impulse.Arrest.Dragged or {}
	impulse.Arrest.Prison = impulse.Arrest.Prison or {}
	impulse.Arrest.DCRemember = impulse.Arrest.DCRemember or {}

	util.AddNetworkString("impulseSendJailInfo")

	function meta:Arrest()
		self.ArrestedWeapons = {}
		for v,k in pairs(self:GetWeapons()) do
			self.ArrestedWeapons[k:GetClass()] = true
		end

		self:StripWeapons()
		self:StripAmmo()
		self:SetRunSpeed(impulse.Config.WalkSpeed - 30)
		self:SetWalkSpeed(impulse.Config.WalkSpeed - 30)
		self:SetJumpPower(0)

		self:SetSyncVar(SYNC_ARRESTED, true, true)
	end

	function meta:UnArrest()
		self:SetSyncVar(SYNC_ARRESTED, false, true)

		if self.ArrestedWeapons then
			for v,k in pairs(self.ArrestedWeapons) do
				self:Give(v)
			end

			self.ArrestedWeapons = nil
		end

		self:SetRunSpeed(impulse.Config.JogSpeed)
		self:SetWalkSpeed(impulse.Config.WalkSpeed)
		self:SetJumpPower(160)
		self:StopDrag()
	end

	function meta:DragPlayer(ply)
		if self:CanArrest(ply) and ply:GetSyncVar(SYNC_ARRESTED, false) then
			ply.ArrestedDragger = self
			self.ArrestedDragging = ply
			impulse.Arrest.Dragged[ply] = true
			ply:Freeze(true)

			self:Say("/me starts dragging "..ply:Name()..".")
		end
	end

	function meta:StopDrag()
		impulse.Arrest.Dragged[self] = nil
		self:Freeze(false)

		local dragger = self.ArrestedDragger

		if IsValid(dragger) then
			dragger.ArrestedDragging = nil
		end
		self.ArrestedDragger = nil
	end

	function meta:SendJailInfo(time, jailData)
		net.Start("impulseSendJailInfo")
		net.WriteUInt(time, 16)
		
		if jailData then
			net.WriteBool(true)
			net.WriteTable(jailData)
		else
			net.WriteBool(false)
		end

		net.Send(self)
	end

	function meta:Jail(time, jailData)
		local doCellMates = false
		local pos
		local cellID

		if self.InJail then
			return
		end

		if table.Count(impulse.Arrest.Prison) >= table.Count(impulse.Config.PrisonCells) then
			doCellMates = true
		end

		for v,k in pairs(impulse.Config.PrisonCells) do
			local cellData = impulse.Arrest.Prison[v]
			
			if cellData and not doCellMates then -- if something is assigned to this cell
				continue
			end

			pos = k
			cellID = v

			if doCellMates then
				local cell = impulse.Arrest.Prison[v]
				cell[self:UserID()] = {
					inmate = self,
					jailData = jailData,
					duration = time
				} 

				break
			else
				impulse.Arrest.Prison[v] = {}
				impulse.Arrest.Prison[v][self:UserID()] = {
					inmate = self,
					jailData = jailData,
					duration = time
				}

				break
			end
		end

		if pos then
			self:SetPos(impulse.FindEmptyPos(pos, {self}, 150, 30, Vector(16, 16, 64)))
			self:SetEyeAngles(impulse.Config.PrisonAngle)
			self:Notify("You have been imprisoned for "..(time / 60).." minutes.")
			self:SendJailInfo(time, jailData)
			self.InJail = cellID

			timer.Create(self:UserID().."impulsePrison", time, 1, function()
				if IsValid(self) and self.InJail then
					self:UnJail()
				end
			end)
		end
	end
	
	function meta:UnJail()
		impulse.Arrest.Prison[self.InJail][self:UserID()] = nil
		self.InJail = nil

		self:Spawn()
		self:StopDrag()
		self:UnArrest()

		self:Notify("You have been released from prison as your setence has ended.")
	end
end