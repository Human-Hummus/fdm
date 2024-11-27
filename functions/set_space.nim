include default
if format == "html":
  if get_var("spacing") != "":stdout.write "<div style=\"line-height:"&get_var("spacing")&";\">" & paramStr(1) & "</div>"
  else:stdout.write paramStr(1)
if format == "markdown":
  stdout.write paramStr(1)

