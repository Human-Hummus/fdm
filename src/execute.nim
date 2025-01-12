import parser, strutils, error

type
  variable* = object
    name*: string
    content*: string

include functions

proc exec_function(input: node, vars: seq[variable]): string
proc get_var*(name: string, vars: seq[variable]): string =
  var x = 0
  while x < vars.len:
    if vars[x].name == name:
      return vars[x].content
    x+=1
  return "null"

proc add_var*(name: string, content: string, vars: seq[variable]): seq[variable] =
  var
    x = 0
    output: seq[variable] = @[]
  var found_var = false
  while x < vars.len:
    if vars[x].name == name:
      output.add variable(name: vars[x].name, content: content)
      found_var = true
    else:
      output.add vars[x]
    x+=1
  if not found_var:
    output.add variable(name: name, content: content)
  return output


type if_stat = enum yes, no, nill

const max_iters = 1_000_000

proc compile_text*(nodes: seq[node], vars: seq[variable]): (string, seq[variable]) =
  var
    x = 0
    output = ""
    updated_vars = vars
    prev_if_statement: if_stat = if_stat.nill
  while x < nodes.len:
    var pos = nodes[x].pos
    if nodes[x].kind == nodetype.text:
      output.add nodes[x].value
    elif nodes[x].kind == nodetype.array_access:
      var got = compile_text(nodes[x].subvalues, updated_vars)
      var arr = got[0]
      updated_vars = got[1]
      got = compile_text(nodes[x].fncontents, updated_vars)
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
      var got = ""
      if nodes[x].name == "if":
        if nodes[x].fnvars.len != 1:
          fatal "Illegal if statement " & pos

        (got, updated_vars) = compile_text(nodes[x].fnvars[0].content, updated_vars)
        if got == "true":
          var got = compile_text(nodes[x].fncontents, updated_vars)
          output.add got[0]
          updated_vars = got[1]
          prev_if_statement = if_stat.yes
        else:
          prev_if_statement = if_stat.no
      elif nodes[x].name == "else":
        if nodes[x].fnvars.len != 0:
          warn "Else statement has arguments. These will be ignored. " & pos
        if prev_if_statement == if_stat.nill:
          fatal "Else statement not preceeded by if statement. " & pos
        if prev_if_statement == if_stat.no:
          (got, updated_vars) = compile_text(nodes[x].fncontents, updated_vars)
          output.add got
        prev_if_statement = if_stat.nill

      elif nodes[x].name == "elif":
        if nodes[x].fnvars.len != 1:
          fatal "Elif statement doesn't have 1 argument. " & pos
        if prev_if_statement == if_stat.nill:
          fatal "Elif statement not preceeded by if statement. " & pos
        if prev_if_statement == if_stat.no:
          (got, updated_vars) = compile_text(nodes[x].fnvars[0].content, updated_vars)
          if got == "true":
            (got, updated_vars) = compile_text(nodes[x].fncontents, updated_vars)
            output.add got
            prev_if_statement = if_stat.yes
          else:
            prev_if_statement = if_stat.no

      elif nodes[x].name == "eql":
        (got, updated_vars) = equals(nodes[x], updated_vars)
        output.add got

      elif nodes[x].name == "sum":
        (got, updated_vars) = sum_function(nodes[x], updated_vars)
        output.add got
      elif nodes[x].name == "table":
        (got, updated_vars) = table(nodes[x], updated_vars)
        output.add got
      elif nodes[x].name == "list":
        (got, updated_vars) = list(nodes[x], updated_vars)
        output.add got
      elif nodes[x].name == "fatal":
        (got, updated_vars) = compile_text(nodes[x].fnvars[0].content, updated_vars)
        fatal got
      elif nodes[x].name == "and":
        (got, updated_vars) = and_function(nodes[x], updated_vars)
        output.add got
      elif nodes[x].name == "is_defined":
        if nodes[x].fnvars.len != 1:
          fatal "illegal is_defined statement; got " & $nodes[x].fnvars.len &
              " arguments instead of 1 " & pos
        (got, updated_vars) = compile_text(nodes[x].fnvars[0].content, updated_vars)
        if got == "null": output.add "false"
        else: output.add "true"

      elif nodes[x].name == "not":
        if nodes[x].fnvars.len != 1:
          fatal "illegal not statement; got " & $nodes[x].fnvars.len &
              " arguments instead of 1 " & pos
        (got, updated_vars) = compile_text(nodes[x].fnvars[0].content, updated_vars)
        if got == "true":
          output.add "false"
        else:
          output.add "true"
      elif nodes[x].name == "len":
        if nodes[x].fnvars.len != 1:
          fatal "illegal not statement; got " & $nodes[x].fnvars.len &
              " arguments instead of 1 " & pos
        (got, updated_vars) = compile_text(nodes[x].fnvars[0].content, updated_vars)
        output.add $got.len

      elif nodes[x].name == "while":
        if nodes[x].fnvars.len != 1:
          fatal "illegal while statement; got " & $nodes[x].fnvars.len & " arguments instead of 1"
        var iterations = 0
        while iterations < max_iters:
          (got, updated_vars) = compile_text(nodes[x].fnvars[0].content, updated_vars)
          if got != "true":
            break
          (got, updated_vars) = compile_text(nodes[x].fncontents, updated_vars)
          output.add got
          iterations+=1
        if iterations == max_iters:
          fatal "While loop exceeded maximum iteration number: " & $max_iters &
              " " & pos
      elif nodes[x].name == "print":
        if nodes[x].fnvars.len != 1:
          fatal "illegal while statement; got " & $nodes[x].fnvars.len &
              " arguments instead of 1 " & pos
        (got, updated_vars) = compile_text(nodes[x].fnvars[0].content, updated_vars)
        echo got
      elif nodes[x].name == "or":
        (got, updated_vars) = or_function(nodes[x], updated_vars)
        output.add got
      else:
        var got = exec_function(nodes[x], updated_vars)
        output.add got
    elif nodes[x].kind == nodetype.variable:
      output.add get_var(nodes[x].name, updated_vars)
    elif nodes[x].kind == nodetype.generic:
      var got = compile_text(nodes[x].subvalues, updated_vars)
      output.add got[0]
      updated_vars = got[1]
    elif nodes[x].kind == nodetype.variable_decleration:
      var got = compile_text(nodes[x].subvalues, updated_vars)
      updated_vars = got[1]
      updated_vars = add_var(nodes[x].name, got[0], updated_vars)
    x+=1
  return (output, updated_vars)

proc exec_function(input: node, vars: seq[variable]): string =
  var
    updated_vars = vars
    contents: seq[node] = @[]
    cur_unnamed_var = 0
  for current_function in functions:
    if current_function.name != input.name:
      continue
    for arg in current_function.fnvars:
      if arg.content.len > 0:
        var got = ""
        (got, updated_vars) = compile_text(arg.content, updated_vars)
        updated_vars = add_var(arg.name, got, updated_vars)

    for arg in input.fnvars:
      if arg.name == "":
        if cur_unnamed_var >= current_function.fnvars.len:
          fatal "too many anonymous arguments " & input.pos
        var vname = current_function.fnvars[cur_unnamed_var].name
        var got = ""
        (got, updated_vars) = compile_text(arg.content, updated_vars)
        updated_vars = add_var(vname, got, updated_vars)
        cur_unnamed_var+=1
      else:
        var vname = arg.name
        var got = ""
        (got, updated_vars) = compile_text(arg.content, updated_vars)
        updated_vars = add_var(vname, got, updated_vars)
    var got = ""
    (got, updated_vars) = compile_text(input.fncontents, updated_vars)
    updated_vars = add_var("input", got, updated_vars)

    (got, _) = compile_text(current_function.fncontents, updated_vars)
    return got
  return "null"
