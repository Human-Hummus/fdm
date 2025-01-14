#THIS IS INCLUDED IN EXECUTE.NIM

proc compile_text*(nodes: seq[node], vars: seq[variable]): (string, seq[variable])
proc get_var*(name: string, vars: seq[variable]): string

proc or_function*(input: node, vars: seq[variable]): (string, seq[variable]) =
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

proc equals*(input: node, vars: seq[variable]): (string, seq[variable]) =
  var
    updated_vars = vars
  if input.fnvars.len != 2:
    fatal "illegal eql statement; got " & $input.subvalues.len &
        " arguments instead of 2 " & input.pos
  var
    a = ""
    b = ""
  (a, updated_vars) = compile_text(input.fnvars[0].content, updated_vars)
  (b, updated_vars) = compile_text(input.fnvars[1].content, updated_vars)
  if a == b:
    return ("true", updated_vars)
  return ("false", updated_vars)
proc sum_function*(input: node, vars: seq[variable]): (string, seq[variable]) =
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

proc force_hyphenate(text: string): string =
  return text.replace(" ", "\\- ")
proc table*(input: node, vars: seq[variable]): (string, seq[variable]) =
  var
    format = get_var("format", vars)
    updated_vars = vars
    got = ""
    x = 0
    output = ""
    printed_table_header = false
    items = 0
  for row in input.fnvars:
    if row.content[0].fnvars.len > items:
      items = row.content[0].fnvars.len
  if format == "html":
    output.add "<table>"
  if format == "markdown":
    output.add "\n"
  if format == "latex":
    output.add "\\begin{tabular}{"
    var per_item_width = 1.0/float(items)
    for i in 0..items:
      output.add " p{" & $per_item_width & "\\linewidth} "
    output.add "}"
  for row_generic in input.fnvars:
    var completed = 0
    if format == "html":
      output.add "<tr>"
    if row_generic.content.len != 1 or row_generic.content[0].name != "row":
      warn "Skipping row " & input.pos
      continue
    var row = row_generic.content[0]
    for item in row.fnvars:
      completed+=1
      (got, updated_vars) = compile_text(item.content, updated_vars)
      if format == "html":
        output.add "<td>" & got & "</td>"
      if format == "markdown":
        output.add got & "|"
      if format == "latex":
        output.add ""&force_hyphenate(got)&"" & "&"
    while completed < items:
      completed += 1
      if format == "html":
        output.add "<td> </td>"
      if format == "markdown":
        output.add " |"
      if format == "latex":
        output.add " & "
    if format == "html":
      output.add "</tr>"
    if format == "markdown":
      if not printed_table_header:
        output.add "\n|"
        for item in 1..items:
          output.add "-|"
        printed_table_header = true
      output.add "\n"
    if format == "latex":
      output.add "\\\\\\hline "
  if format == "html":
    output.add "</table>"
  if format == "markdown":
    output.add "\n"
  if format == "latex":
    output.add "\\end{tabular}"
  return (output, updated_vars)
proc list*(input: node, vars: seq[variable]): (string, seq[variable]) =
  var
    format = get_var("format", vars)
    output = ""
    updated_vars = vars
    got = ""
  if format == "html":
    output.add "<ul>"
  if format == "markdown":
    output.add "\n"
  if format == "latex":
    output.add "\\begin{itemize}"
  for item in input.fnvars:
    (got, updated_vars) = compile_text(item.content, updated_vars)
    if format == "html":
      output.add "<li>" & got & "</li>"
    if format == "latex":
      output.add "\\item "
    if format == "markdown":
      output.add "- " & got.replace("\n", "\n\t") & "\n"
  if format == "html":
    output.add "</ul>"
  if format == "markdown":
    output.add "\n"
  if format == "latex":
    output.add "\\end{itemize}"
  return (output, updated_vars)

proc and_function*(input: node, vars: seq[variable]): (string, seq[variable]) =
  var updated_vars = vars
  for item in input.fnvars:
    var got = ""
    (got, updated_vars) = compile_text(item.content, updated_vars)
    if got != "true":
      return ("false", updated_vars)
  return ("true", updated_vars)
