include default

var dir = get_var("directory").strip()
if dir[^1] != '/':
  dir.add '/'
dir.add paramStr(1)
stdout.write "{directory=" & parentdir(dir) & "}" & readFile(dir) & "{directory=" & get_var("directory") & "}"
