import parser, strutils, error

type
  variable* = object
    name*: string
    content*: string
    approx_content*: seq[node]


proc compile_text*(nodes: seq[node], vars: var seq[variable]): string
proc exec_function(input: node, vars: seq[variable]): string
proc get_var*(vars: var seq[variable], name: string): string =
  var x = 0
  while x < vars.len:
    if vars[x].name == name:
      if vars[x].approx_content.len == 0:
        return vars[x].content
      else:
        return compile_text(vars[x].approx_content, vars)
    x+=1
  return "null"

proc add_var*(vars: var seq[variable], name: string, content: string) =
  var x = 0
  var found_var = false
  while x < vars.len:
    if vars[x].name == name:
      vars[x].content = content
      vars[x].approx_content = @[]
      found_var = true
    x+=1
  if not found_var:
    vars.add variable(name: name, content: content)
proc add_var*(vars: var seq[variable], name: string, content: seq[node]) =
  var x = 0
  var found_var = false
  while x < vars.len:
    if vars[x].name == name:
      vars[x].approx_content = content
      vars[x].content = ""
      found_var = true
    x+=1
  if not found_var:
    vars.add variable(name: name, approx_content: content)

include functions

type if_stat = enum yes, no, nill

const max_iters = 1_000_000

proc compile_text*(nodes: seq[node], vars: var seq[variable]): string =
  var
    x = 0
    output = ""
    prev_if_statement: if_stat = if_stat.nill
  while x < nodes.len:
    var pos = nodes[x].pos
    if nodes[x].kind == nodetype.text:
      output.add nodes[x].value
    elif nodes[x].kind == nodetype.array_access:
      var arr = compile_text(nodes[x].subvalues, vars)
      var got = compile_text(nodes[x].fncontents, vars)
      var access = 0
      try:
        access = parseInt(got)
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

        got = compile_text(nodes[x].fnvars[0].content, vars)
        if got == "true":
          var got = compile_text(nodes[x].fncontents, vars)
          output.add got
          prev_if_statement = if_stat.yes
        else:
          prev_if_statement = if_stat.no
      elif nodes[x].name == "else":
        if nodes[x].fnvars.len != 0:
          warn "Else statement has arguments. These will be ignored. " & pos
        if prev_if_statement == if_stat.nill:
          fatal "Else statement not preceeded by if statement. " & pos
        if prev_if_statement == if_stat.no:
          got = compile_text(nodes[x].fncontents, vars)
          output.add got
        prev_if_statement = if_stat.nill

      elif nodes[x].name == "elif":
        if nodes[x].fnvars.len != 1:
          fatal "Elif statement doesn't have 1 argument. " & pos
        if prev_if_statement == if_stat.nill:
          fatal "Elif statement not preceeded by if statement. " & pos
        if prev_if_statement == if_stat.no:
          got = compile_text(nodes[x].fnvars[0].content, vars)
          if got == "true":
            got = compile_text(nodes[x].fncontents, vars)
            output.add got
            prev_if_statement = if_stat.yes
          else:
            prev_if_statement = if_stat.no
      elif nodes[x].name == "text":
        got = text(compile_text(nodes[x].fncontents, vars), vars)
        output.add got

      elif nodes[x].name == "eql":
        got = equals(nodes[x], vars)
        output.add got

      elif nodes[x].name == "sum":
        got = sum_function(nodes[x], vars)
        output.add got
      elif nodes[x].name == "table":
        got = table(nodes[x], vars)
        output.add got
      elif nodes[x].name == "list":
        got = list(nodes[x], vars)
        output.add got
      elif nodes[x].name == "fatal":
        got = compile_text(nodes[x].fnvars[0].content, vars)
        fatal got
      elif nodes[x].name == "and":
        got = and_function(nodes[x], vars)
        output.add got
      elif nodes[x].name == "is_defined":
        if nodes[x].fnvars.len != 1:
          fatal "illegal is_defined statement; got " & $nodes[x].fnvars.len &
              " arguments instead of 1 " & pos
        got = compile_text(nodes[x].fnvars[0].content, vars)
        if got == "null": output.add "false"
        else: output.add "true"

      elif nodes[x].name == "not":
        if nodes[x].fnvars.len != 1:
          fatal "illegal not statement; got " & $nodes[x].fnvars.len &
              " arguments instead of 1 " & pos
        got = compile_text(nodes[x].fnvars[0].content, vars)
        if got == "true":
          output.add "false"
        else:
          output.add "true"
      elif nodes[x].name == "len":
        if nodes[x].fnvars.len != 1:
          fatal "illegal not statement; got " & $nodes[x].fnvars.len &
              " arguments instead of 1 " & pos
        got = compile_text(nodes[x].fnvars[0].content, vars)
        output.add $got.len

      elif nodes[x].name == "while":
        if nodes[x].fnvars.len != 1:
          fatal "illegal while statement; got " & $nodes[x].fnvars.len & " arguments instead of 1"
        var iterations = 0
        while iterations < max_iters:
          got = compile_text(nodes[x].fnvars[0].content, vars)
          if got != "true":
            break
          got = compile_text(nodes[x].fncontents, vars)
          output.add got
          iterations+=1
        if iterations == max_iters:
          fatal "While loop exceeded maximum iteration number: " & $max_iters &
              " " & pos
      elif nodes[x].name == "print":
        if nodes[x].fnvars.len != 1:
          fatal "illegal while statement; got " & $nodes[x].fnvars.len &
              " arguments instead of 1 " & pos
        got = compile_text(nodes[x].fnvars[0].content, vars)
        echo got
      elif nodes[x].name == "or":
        got = or_function(nodes[x], vars)
        output.add got
      else:
        var got = exec_function(nodes[x], vars)             #doesn't modify vars
        output.add got
    elif nodes[x].kind == nodetype.variable:
      output.add vars.get_var nodes[x].name
    elif nodes[x].kind == nodetype.generic:
      var got = compile_text(nodes[x].subvalues, vars)
      output.add got
    elif nodes[x].kind == nodetype.variable_decleration:
      if not nodes[x].is_approx:
        var got = compile_text(nodes[x].subvalues, vars)
        vars.add_var(nodes[x].name, got)
      else:
        vars.add_var(nodes[x].name, nodes[x].subvalues)
    x+=1
  return output

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
        var got = compile_text(arg.content, updated_vars)
        updated_vars.add_var(arg.name, got)

    for arg in input.fnvars:
      if arg.name == "":
        if cur_unnamed_var >= current_function.fnvars.len:
          fatal "too many anonymous arguments " & input.pos
        var vname = current_function.fnvars[cur_unnamed_var].name
        if not current_function.fnvars[cur_unnamed_var].is_approx:
          var got = compile_text(arg.content, updated_vars)
          updated_vars.add_var(vname, got)
        else:
          updated_vars.add_var(vname, arg.content)
        cur_unnamed_var+=1
      else:
        var vname = arg.name
        var is_novel = -1
        var x = 0
        while x < current_function.fnvars.len:
          if current_function.fnvars[x].name == vname:
            is_novel = x
          x+=1
        if is_novel == -1 or (not current_function.fnvars[is_novel].is_approx):
          var got = compile_text(arg.content, updated_vars)
          updated_vars.add_var(vname, got)
        else:
          updated_vars.add_var(vname, arg.content)
    var got = compile_text(input.fncontents, updated_vars)
    updated_vars.add_var("input", got)

    got = compile_text(current_function.fncontents, updated_vars)
    return got
  return "null"
