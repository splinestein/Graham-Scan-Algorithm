for x = 1, 50 do
	local random = Random.new()
	local z = random:NextNumber(-10, 10)
	local y = random:NextNumber(0, 20)
	
	task.wait(.05)
	local p = Instance.new("Part")
	p.Shape = "Ball"
	p.BrickColor = BrickColor.new("Really red")
	p.Position = Vector3.new(54, y, z)
	p.Anchored = true
	p.Size = Vector3.new(.4, .4, .4)
	p.Parent = workspace.Real
	
	local beam = Instance.new("Beam")
	local attach = Instance.new("Attachment")
	beam.Name = "Beam"
	beam.Parent = p
	attach.Parent = p
	attach.Name = "Attach"
	beam.Width0 = 0.5
	beam.Width1 = 0.5
	beam.Attachment0 = attach
	beam.FaceCamera = true
	beam.Color = ColorSequence.new(Color3.fromRGB(255, 0, 0),Color3.fromRGB(255, 0, 0))
end


local folder = workspace:FindFirstChild("Real")
local points = folder:GetChildren()

-- We start by calculating the lowest part in Y axis.
local getMinY = {workspace.Baseplate, math.huge}

for _, point in points do
	if point.Position.Y <= getMinY[2] then
		getMinY = {point, point.Position.Y}
	end
end

-- Next we want the angle of every part to the lowest part in Y axis.
local angleDictionary = {}
local p2 = getMinY[1].Position

for _, point in points do
	local p1 = point.Position
	local diff = p1 - p2
	local degrees = math.deg(math.atan2(diff.Y, diff.Z))

	table.insert(angleDictionary, {point, degrees})
end

-- Sort the angle dictionary from lowest angle to highest (nested).
table.sort(angleDictionary, function(a, b)
	return a[2] < b[2]
end)


-- Main logic.
local function ccw(p1, p2, p3)
	-- Video by Inside code. Convex hull: Jarvis march algorithm.

	local area = (p2.X - p1.X) * (p3.Y - p1.Y) - (p2.Y - p1.Y) * (p3.X - p1.X)
	
	if area > 0 then
		return "ccw"
	end
	
	if area < 0 then
		return "cw"
	end
	
	return "collinear"
end


local stack = {}
local start = 1
local allcw = false
local previousC = 3

-- Remake the table, we don't need angle data anymore.
local newPoints = {}

for _, nest in angleDictionary do
	table.insert(newPoints, nest[1])
end


for x = 1, 80 do
	for idx = start, #newPoints do
		-- Define the 3 points.
		local p1 = newPoints[idx]
		local p2 = newPoints[idx + 1] or newPoints[1]
		local p3 = newPoints[idx + 2] or newPoints[2]
		
		-- Making these into 2D vectors and they are using Z and Y.
		local aVec = Vector2.new(p1.Position.Z, p1.Position.Y) -- Origin point.
		local bVec = Vector2.new(p2.Position.Z, p2.Position.Y) -- Middle point.
		local cVec = Vector2.new(p3.Position.Z, p3.Position.Y) -- Last point.
		
		task.wait(.1)
		p1.Beam.Attachment1 = p2.Attach
		p2.Beam.Attachment1 = p3.Attach
		
		-- Calculate if points are counterclockwise, clockwise or collinear.
		local res = ccw(aVec, bVec, cVec)
		print(res, idx)
		
		if res == "ccw" then
			start += 1
			allcw = true
			
		end
		
		if res == "cw" then
			task.wait(.1)
			-- We want to pop out p2.
			table.remove(newPoints, table.find(newPoints, p2))
			p2.Beam:Destroy()
			start -= 1
			allcw = false
			break
		end
	end
	
	if allcw == true then
		-- Means the entire loop was correct.
		print(newPoints)
		for _, point in newPoints do
			local beam = Instance.new("Beam")
			local attach = Instance.new("Attachment")
			beam.Name = "Beam"
			beam.Parent = point
			attach.Parent = point
			attach.Name = "Attach"
			beam.Width0 = 0.5
			beam.Width1 = 0.5
			beam.Attachment0 = attach
			beam.FaceCamera = true
		end
		
		for idx, point in newPoints do
			point.Beam.Attachment1 = (newPoints[idx + 1] or newPoints[1]).Attach
		end
		
		break
	end
end
