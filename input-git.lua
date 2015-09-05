-- part of lua-backup project
-- git repositories input 

Input_git = inheritsFrom(InputInterface)

function Input_git:new(config) 
	local inst = Input_git:create()
	inst:init(config)
	return inst
end

function Input_git:init(config) 
	self.name = "git"
	InputInterface.init(self, config)	
	if not self.static.repos then
		self.static.repos = { }
	end
end

function Input_git:log_info()
	return string.format("Input-Git(%s)", self:getName())
end

function Input_git:process_repo(path)
	local states = nil
	local addstate = function(color, text)
		if states then
			states = states .. ", "
		else
			states = ""
		end
		states = states .. color .. text .. console.reset
	end
	
	local prvstate = self.static.repos[path]
	if not prvstate then
		prvstate = { }
		addstate(console.red, "new")
		self.static.repos[path] = prvstate
	end
	
	local result = nil
	
	local cmd = string.format("cd %s; git for-each-ref --sort=-committerdate refs/heads/ --format='%%(committerdate)' --count=1", path)
	local repoinfo = shell.linesOf(cmd)
	local repodate = repoinfo[1]
	
	if prvstate.changedate ~= repodate or luabackup.debug then
		addstate(console.yellow, "changed")
		if not luabackup.debug then
			prvstate.changedate = repodate
		end
		
		local name = ""
		
		local excluded_names = {
			["."] = true,
			[".."] = true,
		}
		
		for i in string.gmatch(path, "[^/]+") do
			if not excluded_names[i] and i:len() > 0 then
				local pos = i:find("%.")
				if pos == 1 then
					name = name .. i
				else
					if name:len() > 0 then
						name = name .. "."
					end
					name = name .. i
				end
			end
		end
		
		result = {
			path = path .. "/",
			name = name
		}
	else
		addstate(console.green, "unchanged")
	end
	
	log:info(self, "Repository status: ", path, " -> ", states)
	
	return result
end

function Input_git:getPaths()
	local findcmd = "find " .. self.config.root .. " | grep '.git$' ";
	log:info(self, "Scanning for repositories")
	
	local paths = shell.linesOf(findcmd)
	log:info(self, string.format("Found %d repositories", #paths))
	
	local i, v
	local changed = {}
	for i,v in ipairs(paths) do
		local repo = self:process_repo(v)
		if repo then
			changed[#changed + 1] = repo
		end		
	end
	
    return changed;
end
