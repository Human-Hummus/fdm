import std/[os, terminal, strutils, osproc]
include constants

var 
  args = os.commandLineParams()
  text = ""
  output = ""
  format = "html"
  x = 0

proc error(text:string) =
  stdout.styledWriteLine(fgRed, "Error: " & text)
  quit(1)

proc process_functions(text:string):string 

proc remove_bs(text:string):string =
  var 
    x = 0
    toret = ""
  while x < text.len():
    if text[x] == '\\' and x+1 != text.len():
      x+=1
    toret.add text[x]
    x+=1
  return toret



while x < args.len():
  let is_last = x+1 == args.len()
  case args[x]:
    of "-i", "--input":
      if is_last:error("-i/--input flag has no proceeding parameter")
      text.add "{import:" & args[x+1] & "}"
    of "-o", "--output":
      if is_last:error("-o/--output flag has no proceeding parameter")
      output = args[x+1]
    of "-f", "--format":
      if is_last:error("ERROR: -f/--format flag has no proceeding parameter")
      format = args[x+1]
  x+=1
if output == "":error("no output file provided")
if text == "":stdout.styledWriteLine(fgYellow, "WARNING: no input file provided; a blank output will be generated")

format = format.toLowerAscii()

var vars:seq[array[2, string]] = @[
    ["directory", "./"],
    ["format", format]]

writeFile(output, remove_bs(process_functions(text)))
proc add_var(name,content:string) =
  var x = 0
  while x < vars.len():
    if vars[x][0] == name:
      vars[x][1] = content
      return
    x+=1
  vars.add [name, content]
proc vars_as_str():string =
  var toret = ""
  for v in vars:
    toret.add v[0] & ":"
    for c in v[1]:
      if c in ":|":toret.add "\\"
      toret.add c
    toret.add "|"
  return toret
proc run_function(name,content:string):string =
  if DEBUG: echo name
  var function = FUNCTIONS_DIR & name
  if not fileExists(function):function = FUNCTIONS_DIR & format & "/" & name
  if not fileExists(function):error "no function \"" & name & "\""
  var output = execProcess(function, args=[content, vars_as_str()], options={poUsePath})
  if DEBUG: echo vars_as_str()
  if output.len()>0 and output[^1] == '\n':
    output.delete(output.len()-1, output.len()-1)
  if DEBUG: echo "output: " & output & "\n\n"
  return output

proc process_functions(text:string):string =
  var
    x = 0
    toret = ""
  while x < text.len():
    case text[x]
      of '\\':
        x+=1
        if x==text.len():error("text ends with '\\'")
        toret.add("\\" & text[x])
      of '{':
        x+=1
        var
          name = ""
          content = ""
          is_var = false
          depth = 1

        while text[x] notin ":=}":
          if text[x] notin "\\ ":name.add text[x]
          x+=1
          if x == text.len():error("text for function \"" & name & "\" terminates before name")

        if text[x] == ':':
          x+=1
        if text[x] == '=':
          x+=1
          is_var = true

        while x < text.len():
          if text[x] == '\\':
            x+=1
            if x == text.len():error("\\ at end of text")
            content.add "\\" & text[x]
          elif text[x] == '{':
            content.add "{"
            depth+=1
          elif text[x] == '}':
            depth-=1
            if depth == 0:
              x+=1
              break
            content.add "}"
          else:
            content.add text[x]
          x+=1

        content = process_functions(content)
        if is_var:
          if DEBUG: echo "is var"
          if DEBUG: echo name
          add_var(name, content)
        else:
          content = run_function(name, content)
          toret.add process_functions(content)
        x-=1
      else:
        toret.add text[x]
    x+=1
  return toret
