include default
var dir =  get_var("directory") & "/" & paramStr(1)
stdout.write  make_raw(readFile(dir))
