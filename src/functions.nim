#THIS IS INCLUDED IN EXECUTE.NIM

proc compile_text*(nodes:seq[node], vars: seq[seq[string]]):(string, seq[seq[string]])
proc get_var*(name:string, vars:seq[seq[string]]):string

proc or_function*(input:node, vars:seq[seq[string]]):(string, seq[seq[string]])=
  var 
    updated_vars = vars
  if input.fncontents.len != 0:
    warn "or function has function contents. These will be ignored. " & input.pos
  for item in input.fnvars:
    var got = ""
    (got, updated_vars) = compile_text(item.content, updated_vars)
    if got == "true":
      return ("true", updated_vars)
  return ("false", updated_vars)

proc equals*(input:node, vars:seq[seq[string]]):(string, seq[seq[string]])=
  var
    updated_vars = vars
  if input.fnvars.len != 2:
    fatal "illegal eql statement; got " & $input.subvalues.len & " arguments instead of 2 " & input.pos
  var 
    a = ""
    b = ""
  (a, updated_vars) = compile_text(input.fnvars[0].content, updated_vars) 
  (b, updated_vars) = compile_text(input.fnvars[1].content, updated_vars) 
  if a == b:
    return ("true", updated_vars)
  return ("false", updated_vars)
proc sum_function*(input:node, vars:seq[seq[string]]):(string, seq[seq[string]])=
  var 
    updated_vars = vars
    total = 0
  for item in input.fnvars:
    var got = ""
    (got, updated_vars) = compile_text(item.content, updated_vars)
    try:
      total+=parseInt(got)
    except:
      return ("ERROR", updated_vars)
  return ($total, updated_vars)
proc table*(input:node,vars:seq[seq[string]]):(string,seq[seq[string]])=
  var
    format = get_var("format", vars)
    updated_vars = vars
    got = ""
    x = 0
    output = ""
    printed_table_header = false
  if format == "html":
    output.add "<table>"
  if format == "markdown":
    output.add "\n"
  for row_generic in input.fnvars:
    var items = 0
    if format == "html":
      output.add "<tr>"
    if row_generic.content.len != 1 or row_generic.content[0].name != "row":
      warn "Skipping row " & input.pos
      continue
    var row = row_generic.content[0]
    for item in row.fnvars:
      items+=1
      (got, updated_vars) = compile_text(item.content, updated_vars)
      if format == "html":
        output.add "<td>" & got & "</td>"
      if format == "markdown":
        output.add got & "|"
    if format == "html":
      output.add "</tr>"
    if format == "markdown":
      if not printed_table_header:
        output.add "\n|"
        for item in 1..items:
          output.add "-|"
        printed_table_header = true
      output.add "\n"
  if format == "html":
    output.add "</table>"
  if format == "markdown":
    output.add "\n"
  return (output, updated_vars)
proc list*(input:node,vars:seq[seq[string]]):(string,seq[seq[string]])=
  var
    format = get_var("format", vars)
    output = ""
    updated_vars = vars
    got = ""
  if format == "html":
    output.add "<ul>"
  if format == "markdown":
    output.add "\n"
  for item in input.fnvars:
    (got, updated_vars) = compile_text(item.content, updated_vars)
    if format == "html":
      output.add "<li>" & got & "</li>"
    if format == "markdown":
      output.add "- " & got.replace("\n","\n\t") & "\n"
  if format == "html":
    output.add "</ul>"
  if format == "markdown":
    output.add "\n"
  return (output, updated_vars)
    
proc and_function*(input:node,vars:seq[seq[string]]):(string,seq[seq[string]])=
  var updated_vars = vars
  for item in input.fnvars:
    var got = ""
    (got, updated_vars) = compile_text(item.content, updated_vars)
    if got != "true":
      return ("false", updated_vars)
  return ("true", updated_vars)
