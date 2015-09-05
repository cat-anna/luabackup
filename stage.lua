-- part of lua-backup project
-- pipeline stage interface

Stage = {}
Stage_mt = { __index = Stage }

function Stage:init(config)
	config = config or { }
	self.config = config
	if config.name then
		self.name = config.name
	end
end

function Stage:log_info()
	return "stage " .. self:getName()
end

function Stage:getName()
	if self.name then
		return self.name
	else
		return "Unnamed stage"
	end
end

function Stage:execute(files, fname)
	return files, fname
end
