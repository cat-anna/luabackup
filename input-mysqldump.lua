-- part of lua-backup project
-- mysql database input 

--mysqldump --hex-blob --order-by-primary --opt -c --triggers --dump-date --add-drop-database wikidb > /home/banshee/dump.mysql

Input_mysql = inheritsFrom(InputInterface)

function Input_mysql:new(config) 
	local inst = Input_mysql:create()
	inst:init(config)
	return inst
end

function Input_mysql:init(config) 
	self.name = "Mysql"
	InputInterface.init(self, config)	
	if not self.static.repos then
		self.static.repos = { }
	end
	if not config.databases then
		self.config.databases = { }
	end
	
	self.CmdConf = {
		["defaults-file"] = config.ConfigFile,
		"hex-blob",
		"order-by-primary",
		"opt",
		"c",
		"triggers",
		"dump-date",
		"add-drop-databas",
	}
end

function Input_mysql:log_info()
	return string.format("Input-Mysql(%s)", self:getName())
end

function Input_mysql:process_db(dbname)

	result = {
		pipecmd = shell.buildcmd("mysqldump", self.CmdConf, nil, dbname),
		name = dbname
	}
	
	return result
end


function Input_mysql:getPaths()	local i, v
	local dbdump = {}
	for i,v in ipairs(self.config.databases) do
		local db = self:process_db(v)
		if db then
			dbdump[#dbdump + 1] = repo
		end		
	end
	
    return dbdump;
end
