include default
if format == "html":stdout.write "<blockquote>" & paramStr(1) & "</blockquote>" 
if format == "markdown":
  var o = ">"
  for i in paramStr(1).strip():
    if i == '\n':o.add "\n>"
    else:o.add i
  stdout.write o
