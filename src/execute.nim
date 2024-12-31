import parser, strutils, error
include functions

proc exec_function(input:seq[node], name:string, vars: seq[seq[string]], fncontents:seq[node]):(string, seq[seq[string]])

proc get_var(name:string, vars:seq[seq[string]]):string=
  var x = 0
  while x < vars.len:
    if vars[x][0] == name:
      return vars[x][1]
    x+=1
  return "null"

proc add_var*(name:string, contents:string, vars:seq[seq[string]]):seq[seq[string]]=
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


type if_stat = enum yes, no, nill

const max_iters = 10_000

proc compile_text*(nodes:seq[node], vars: seq[seq[string]]):(string, seq[seq[string]])=
  var
    x = 0
    output = ""
    updated_vars = vars
    prev_if_statement:if_stat = if_stat.nill
  while x < nodes.len:
    var pos = nodes[x].pos
    if nodes[x].kind == nodetype.text:
      output.add nodes[x].value
    elif nodes[x].kind == nodetype.array_access:
      var got = compile_text(nodes[x].subvalues,updated_vars)
      var arr = got[0]
      updated_vars = got[1]
      got = compile_text(nodes[x].fncontents,updated_vars)
      updated_vars = got[1]
      var access = 0
      try:
        access = parseInt(got[0])
      except:
        fatal "illegal array access index; NAN " & pos
      if access < 0:
        fatal "illegal array access index; less than 0 " & pos
      if access >= arr.len:
        fatal "illegal array access index; too high " & pos
      output.add arr[access]
    elif nodes[x].kind == nodetype.function_call:
      if nodes[x].name == "if":
        if nodes[x].subvalues.len != 1:
          fatal "Illegal if statement " & pos
        
        var got = ""
        (got, updated_vars) = compile_text(@[nodes[x].subvalues[0]], updated_vars)
        if got == "true":
          var got = compile_text(nodes[x].fncontents, updated_vars)
          output.add got[0]
          updated_vars = got[1]
          prev_if_statement = if_stat.yes
        else:
          prev_if_statement = if_stat.no
      elif nodes[x].name == "eql":
        if nodes[x].subvalues.len != 2:
          fatal "illegal eql statement; got " & $nodes[x].subvalues.len & " arguments instead of 2 " & pos
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
      elif nodes[x].name == "add":
        if nodes[x].subvalues.len != 2:
          fatal "illegal add statement; got " & $nodes[x].subvalues.len & " arguments instead of 2 " & pos
        var got = compile_text(@[nodes[x].subvalues[0]], updated_vars) 
        var a = got[0]
        updated_vars = got[1]
        got = compile_text(@[nodes[x].subvalues[1]], updated_vars) 
        var b = got[0]
        updated_vars = got[1]

        try:
          output.add $(parseInt(a) + parseInt(b))
        except:
          output.add "ERROR IN CALCULATION"

      elif nodes[x].name == "is_defined":
        if nodes[x].subvalues.len != 1:
          fatal "illegal is_defined statement; got " & $nodes[x].subvalues.len & " arguments instead of 1 " & pos
        var got ="" 
        (got, updated_vars) = compile_text(@[nodes[x].subvalues[0]], updated_vars)
        if got != "null":
          output.add "false"
        else:
          output.add "true"
         
      elif nodes[x].name == "not":
        if nodes[x].subvalues.len != 1:
          fatal "illegal not statement; got " & $nodes[x].subvalues.len & " arguments instead of 1 " & pos
        var got = ""
        (got, updated_vars) = compile_text(nodes[x].subvalues, updated_vars)
        if got == "true":
          output.add "false"
        else:
          output.add "true"
      elif nodes[x].name == "len":
        if nodes[x].subvalues.len != 1:
          fatal "illegal not statement; got " & $nodes[x].subvalues.len & " arguments instead of 1 " & pos
        var got = ""
        (got, updated_vars) = compile_text(nodes[x].subvalues, updated_vars)
        output.add $got.len

      elif nodes[x].name == "while":
        if nodes[x].subvalues.len != 1:
          fatal "illegal while statement; got " & $nodes[x].subvalues.len & " arguments instead of 1" 
        var iterations = 0
        while iterations < max_iters:
          #echo "iter" & $iterations
          var got = ""
          (got, updated_vars) = compile_text(nodes[x].subvalues, updated_vars)
          #echo got
          if got != "true":
            break
          (got, updated_vars) = compile_text(nodes[x].fncontents, updated_vars)
          output.add got
            
          iterations+=1
        if iterations == max_iters:
          fatal "While loop exceeded maximum iteration number: " & $max_iters & " " & pos
      elif nodes[x].name == "print":
        if nodes[x].subvalues.len != 1:
          fatal "illegal while statement; got " & $nodes[x].subvalues.len & " arguments instead of 1 "  & pos      
        var got = ""
        (got, updated_vars) = compile_text(nodes[x].subvalues, updated_vars)
        echo got
      elif nodes[x].name == "else":
        if nodes[x].subvalues.len != 0:
          warn "Else statement has arguments. These will be ignored. " & pos
        if prev_if_statement == if_stat.nill:
          fatal "Else statement not preceeded by if statement. " & pos
        if prev_if_statement == if_stat.no:
          var got = ""
          (got, updated_vars) = compile_text(nodes[x].fncontents, updated_vars)
          output.add got
        prev_if_statement = if_stat.nill
      elif nodes[x].name == "or":
        var got = ""
        (got, updated_vars) = or_function(nodes[x], updated_vars)
        output.add got
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
  return (output,updated_vars)

proc exec_function(input:seq[node], name:string, vars: seq[seq[string]], fncontents:seq[node]):(string, seq[seq[string]])=
  var
    x = 0
    real_vars = vars
  while x < functions.len:
    if functions[x].name == name:
      var y = 0
      var vs =functions[x].value.split(",")
      while y < vs.len:
        if y == input.len:
          discard
        else:
          var got = compile_text(@[input[y]], real_vars)
          real_vars = got[1]
          real_vars = add_var(vs[y], got[0], real_vars)
        y+=1
      var got = compile_text(fncontents, real_vars)
      real_vars = got[1]
      real_vars = add_var("input", got[0], real_vars)
      var stuff = ""
      (stuff, real_vars) = compile_text(functions[x].subvalues, real_vars)
      return (stuff, real_vars)
    x+=1
  return ("null", real_vars)
