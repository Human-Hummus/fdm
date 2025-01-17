#THIS IS INCLUDED IN EXECUTE.NIM

proc or_function*(input: node, vars: var seq[variable]): string =
  if input.fncontents.len != 0:
    warn "or function has function contents. These will be ignored. " & input.pos
  for item in input.fnvars:
    var got = ""
    got = compile_text(item.content, vars)
    if got == "true":
      return "true"
  return "false"

proc equals*(input: node, vars: var seq[variable]): string =
  if input.fnvars.len != 2:
    fatal "illegal eql statement; got " & $input.subvalues.len &
        " arguments instead of 2 " & input.pos
  var
    a = compile_text(input.fnvars[0].content, vars)
    b = compile_text(input.fnvars[1].content, vars)
  if a == b:
    return "true"
  return "false"
proc sum_function*(input: node, vars: var seq[variable]): string =
  var total = 0
  for item in input.fnvars:
    var got = compile_text(item.content, vars)
    try:
      total+=parseInt(got)
    except:
      return "ERROR"
  return $total

proc force_hyphenate(text: string): string =
  return text.replace(" ", "\\- ")
proc table*(input: node, vars: var seq[variable]): string =
  var
    format = vars.get_var("format")
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
      got = compile_text(item.content, vars)
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
  return output
proc list*(input: node, vars: var seq[variable]): string =
  var
    format = vars.get_var("format")
    output = ""
    got = ""
  if format == "html":
    output.add "<ul style=\"margin-left:5%;\">"
  if format == "markdown":
    output.add "\n"
  if format == "latex":
    output.add "\\begin{itemize}"
  for item in input.fnvars:
    got = compile_text(item.content, vars)
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
  return output

proc and_function*(input: node, vars: var seq[variable]): string =
  for item in input.fnvars:
    var got = compile_text(item.content, vars)
    if got != "true":
      return "false"
  return "true"
