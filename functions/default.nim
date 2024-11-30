import std/os, strutils
include ../constants
include format
proc get_var*(var_name:string):string =
  var
    p = paramStr(2)
    x = 0
    content = ""
    name = ""
    on_name = true
  while x < p.len():
    if p[x] == '\\':
      x+=1
      content.add(p[x])
    elif p[x] == ':':
      on_name = false
    elif p[x] == '|':
      on_name=true
      if name == var_name:return content
      content = ""
      name = ""
    else:
      if on_name:name.add(p[x])
      else:content.add(p[x])
    x+=1
  return ""

proc get_param*(var_name:string):string =
  var
    p = paramStr(3)
    x = 0
    content = ""
    name = ""
    on_name = true
  while x < p.len():
    if p[x] == '\\':
      x+=1
      content.add(p[x])
    elif p[x] == ':':
      on_name = false
    elif p[x] == '|':
      on_name=true
      if name == var_name:return content
      content = ""
      name = ""
    else:
      if on_name:name.add(p[x])
      else:content.add(p[x])
    x+=1
  return ""

proc html_style():string =
  var toret = "style=\""
  for i in HTML_STYLE_TAGS:
    var p = get_param(i)
    if p != "":
      toret.add i & ":" & p & ";"
  toret.add "\""
  for i in HTML_TAGS:
    var p = get_param(i)
    if p != "":
      toret.add " " & i & "=\"" & p & "\" "
  return toret

proc single_spaced*(text:string): string =
  var o = "\t"

  for c in text.strip():
    if c in "\t\n ":
      if o[^1] != ' ':
        o.add " "
    else:
      o.add c
  return o.replace("\t", "")
proc parentdir(text:string):string =
  var tcopy = text.strip()
  while tcopy.len() > 0 and tcopy[^1] != '/':
    tcopy.delete(tcopy.len()-1..tcopy.len()-1)
  return tcopy

proc make_raw(text:string):string =
  var toret = ""
  for c in text:
    if c == '{' or c == ':' or c == '}':
      toret.add '\\'
    toret.add c
  return toret
