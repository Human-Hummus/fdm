include default

var dir =  get_var("directory") & "/" & paramStr(1)
stdout.write "{directory=" & parentdir(dir) & "}" & readFile(dir) & "{directory=" & get_var("directory") & "}"
