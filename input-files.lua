-- part of lua-backup project
-- direct file/folder input

Input_files = inheritsFrom(InputInterface)

function Input_files:new(config) 
	local inst = Input_files:create()
	inst:init(config)
	return inst
end

function Input_files:init(config) 
	self.name = "files"
	InputInterface.init(self, config)	
	if not self.static.repos then
		self.static.repos = { }
	end
end

function Input_files:log_info()
	return string.format("Input-Files(%s)", self:getName())
end

function Input_files:getPaths()
    return self.config.list;
end
