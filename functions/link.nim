include default

var
  text = ""
  link = ""
  on_link = true
  skip_next = false
for c in paramStr(1):
  if on_link:
    if c == '\\':
      skip_next = true
      continue
    if skip_next:
      link.add c
    if c == '|':
      on_link = false
    else:
      link.add c
  else:
    text.add c
text = text.strip()
link = link.strip()
if text == "":
  text = link

if format == "html":
  stdout.write "<a href=\"" & link & "\">"&text&"</a>"
if format == "markdown":
  stdout.write "[" & text & "](" & link & ")"
