-- part of lua-backup project
-- input interface

local Input = {}
local Input_mt = { __index = Input }

local function Input_create()
    local new_inst = {}   
    setmetatable( new_inst, Input_mt )
	new_inst.inputs = {}
    return new_inst
end

function Input:add(inp, pipename)
    if not pipeline then 
		log:warning("No pipeline defiend for '" .. inp:getName() .. "' default will be used")
	end
	
	self.inputs[#self.inputs + 1] = { 
		instance = inp, 
		pipeline = name,
	}
end

function Input:getInputCount()
	return #self.inputs
end

function Input:processAll()
	local i, v
	for i, v in ipairs(self.inputs) do
		backup:processInput(i, v)
	end
end

input = Input_create()

---------------------------------------------

InputInterface = {}
InputInterface_mt = { __index = InputInterface }

function InputInterface:init(config)
	config = config or { }
	self.static = backup:getInputStaticData(config.name)
	if config.name then
		self.name = config.name
	end
	self.config = config
end

function InputInterface:getName()
	if self.name then
		return self.name
	else
		return "Unnamed input"
	end
end

function InputInterface:getPaths()
    return nil;
end
