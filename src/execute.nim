import parser, strutils, error

proc exec_function(input:seq[node], name:string, vars: seq[seq[string]], fncontents:seq[node]):(string, seq[seq[string]])

proc get_var(name:string, vars:seq[seq[string]]):string=
  var x = 0
  while x < vars.len:
    if vars[x][0] == name:
      return vars[x][1]
    x+=1
  return "null"

proc add_var(name:string, contents:string, vars:seq[seq[string]]):seq[seq[string]]=
  var
    x = 0
    output:seq[seq[string]] = @[]
  var found_var = false
  while x < vars.len:
    if vars[x][0] == name:
      output.add @[vars[x][0], contents]
      found_var = true
    else:
      output.add vars[x]
    x+=1
  if not found_var:
    output.add @[name,contents]
  return output



proc compile_text*(nodes:seq[node], vars: seq[seq[string]]):(string, seq[seq[string]])=
  var
    x = 0
    output = ""
    updated_vars = vars
  while x < nodes.len:
    if nodes[x].kind == nodetype.text:
      output.add nodes[x].value
    elif nodes[x].kind == nodetype.array_access:
      echo nodes[x]
      var got = compile_text(nodes[x].subvalues,updated_vars)
      var arr = got[0]
      updated_vars = got[1]
      got = compile_text(nodes[x].fncontents,updated_vars)
      updated_vars = got[1]
      echo got[0]
      var access = 0
      try:
        access = parseInt(got[0])
      except:
        fatal "illegal array access index"
      if access < 0:
        fatal "illegal array access index"
      if access >= arr.len:
        fatal "illegal array access index"
      output.add arr[access]
    elif nodes[x].kind == nodetype.function_call:
      if nodes[x].name == "if":
        if nodes[x].subvalues.len != 1:
          fatal "Illegal if statement"
        var (got, updated_vars) = compile_text(@[nodes[x].subvalues[0]], updated_vars)
        if got == "true":
          var got = compile_text(nodes[x].fncontents, updated_vars)
          output.add got[0]
          updated_vars = got[1];
      elif nodes[x].name == "eql":
        if nodes[x].subvalues.len != 2:
          fatal "illegal eql statement; got " & $nodes[x].subvalues.len & " arguments instead of 2"
        var got = compile_text(@[nodes[x].subvalues[0]], updated_vars) 
        var a = got[0]
        updated_vars = got[1]
        got = compile_text(@[nodes[x].subvalues[1]], updated_vars) 
        var b = got[0]
        updated_vars = got[1]

        if a == b:
          output.add "true"
        else:
          output.add "false"
      elif nodes[x].name == "is_defined":
        if nodes[x].subvalues.len != 1:
          fatal "illegal is_defined statement; got " & $nodes[x].subvalues.len & " arguments instead of 1"
        var got ="" 
        (got, updated_vars) = compile_text(@[nodes[x].subvalues[0]], updated_vars)
        if got != "null":
          output.add "false"
        else:
          output.add "true"
         
      elif nodes[x].name == "not":
        if nodes[x].subvalues.len != 1:
          fatal "illegal not statement; got " & $nodes[x].subvalues.len & " arguments instead of 1"
        var got = ""
        (got, updated_vars) = compile_text(@[nodes[x].subvalues[0]], updated_vars)
        if got != "true":
          output.add "false"
        else:
          output.add "true"
      else:
        var got = exec_function(nodes[x].subvalues, nodes[x].name, updated_vars, nodes[x].fncontents)
        output.add got[0]
        updated_vars = got[1]
    elif nodes[x].kind == nodetype.variable:
      output.add get_var(nodes[x].name, updated_vars)
    elif nodes[x].kind == nodetype.generic:
      var got = compile_text(nodes[x].subvalues, updated_vars)
      output.add got[0]
      updated_vars = got[1]
    elif nodes[x].kind == nodetype.variable_decleration:
      var got = compile_text(nodes[x].subvalues,updated_vars)
      updated_vars = got[1]
      updated_vars = add_var(nodes[x].name, got[0], updated_vars)
    x+=1
  return (output,vars)

proc exec_function(input:seq[node], name:string, vars: seq[seq[string]], fncontents:seq[node]):(string, seq[seq[string]])=
  var
    x = 0
    real_vars = vars
  while x < functions.len:
    if functions[x].name == name:
      var y = 0
      var vs =functions[x].value.split(";")
      while y < vs.len:
        if y == input.len:
          discard
        else:
          var got = compile_text(@[input[y]], real_vars)
          real_vars = got[1]
          real_vars.add @[vs[y], got[0]]
        y+=1
      var got = compile_text(fncontents, real_vars)
      real_vars = got[1]
      real_vars.add @["input", got[0]]
      var stuff = ""
      (stuff, real_vars) = compile_text(functions[x].subvalues, real_vars)
      return (stuff, real_vars)
    x+=1
  return ("null", real_vars)
