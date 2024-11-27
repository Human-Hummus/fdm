include default
import std/base64
var dir =  get_var("directory") & "/"

var 
  image_path = ""
  image_width = ""
  on_image_width = true
for c in paramStr(1):
  if c == ':':
    if on_image_width:
      on_image_width = false
    else:
      image_path.add ':'
  else:
    if on_image_width:image_width.add c
    else:image_path.add c
if image_path == "":
  image_path=image_width
  image_width=""

if format == "html":
  stdout.write "<img "
  if image_width != "":
    stdout.write "width=" & image_width & " "
  
  if INCLUDE_IMAGES:
    stdout.write "src=\"data:image/" & image_path.split(".")[^1] & ";base64," & encode(readFile(dir&image_path)) & "\"" 
    
  else:
    stdout.write "src=\""&dir&image_path&"\""
  stdout.write " />"
if format == "markdown":
  stdout.write "![]("&dir&image_path&")"
