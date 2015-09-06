
luabackup = luabackup or { } 

if luabackup.incremental == nil then
	luabackup.incremental = false
end

require "luabackup/oo"
require "luabackup/shell-io"
require "luabackup/log"
require "luabackup/engine"
require "luabackup/input"
require "luabackup/input-git"
require "luabackup/input-files"
require "luabackup/output"
require "luabackup/output-fs"
require "luabackup/pipeline"
require "luabackup/stage"
require "luabackup/stage-tar"
require "luabackup/stage-gzip"
require "luabackup/stage-ccrypt"
require "luabackup/std"
