-- part of lua-backup project
-- pipeline

local Executor = {}
local Executor_mt = { __index = Executor }

local function Executor_create(stages, name)
    local new_inst = {}    
    setmetatable( new_inst, Executor_mt ) 
	new_inst.stages = stages
	new_inst.name = name
    return new_inst
end

function Executor:log_info()
	return string.format("Executor (stage %d out of %d)", self.stage_index, #self.stages)
end

function Executor:execute(files, fname)
	log:info("Executing pipeline ", self.name)
	local i, v
	for i,v in ipairs(self.stages) do
		self.stage_index = i
		log:info(self, "Processing ", v, "[files: " .. #files .. "]")
		files, fname = v:execute(files, fname)
	end

	return files, fname
end

-------------------------------------------------------------

local Pipelines = {}
local Pipelines_mt = { __index = Pipelines }

local function Pipelines_create()
    local new_inst = {}    
    setmetatable( new_inst, Pipelines_mt ) 
	
	new_inst.defaultPipeline = ""
	new_inst.pipelines = { }

    return new_inst
end

function Pipelines:log_info()
	return "Pipelines"
end

function Pipelines:register(name, stages)
	local n = self.pipelines[name]
	if n then
		log:error(self, "Overriding pipelines is forbidden (", name, ")")
		return
	end
	log:info(self, "Registered pipeline: " .. name)
	self.pipelines[name] = stages
end

function Pipelines:getDefaultPipeline()
	return self.defaultPipeline
end

function Pipelines:get(name)
	local n

	if name then
		n = self.pipelines[name]
		if n then
			return Executor_create(n, name); 
		end
		log:error(self, "There is no pipeline '", name, "', using default '", seld.defaultPipeline, "'")
		return nil
	end
	
	name = self.defaultPipeline
	n = self.pipelines[name]
	if not n then
		log:error(self, "There is no defaul pipeline '", name, "'")
		return nil
	end
	
	return Executor_create(n, name);
end

function Pipelines:setDefaultPipeline(name)
    self.defaultPipeline = name
	log:info(self, "Changed default pipeline to ", name)
end

pipelines = Pipelines_create()
