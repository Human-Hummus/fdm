include default
import std/osproc
var
  past_dir = false
  content = ""
  dir =  get_var("directory")
if dir[^1] != '/':dir.add '/'

for c in paramStr(1):
  if c == ':':
    if past_dir:
      content.add c
    else:
      past_dir = true
  else:
    if past_dir:
      content.add c
    else:
      dir.add c

if not fileExists(dir):
  stdout.write "NO FUNCTION EXISTS: " & dir
  stderr.write "NO FUNCTION EXISTS: " & dir
  quit(0)

let output = execProcess(dir, args=[content, paramStr(2)], options={poUsePath})
stdout.write output
