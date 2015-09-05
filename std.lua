-- part of lua-backup project
-- standard definietions

pipelines:register("tar-gzip", {
	Stage_tar:new(),
	Stage_gzip:new(),
})

pipelines:register("tar", {
	Stage_tar:new(),
})
