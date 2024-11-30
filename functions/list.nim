include default
var 
  text = paramStr(1).strip()
  litems:seq[string] = @[]
  curli = ""
  x = 0
while x < text.len():
  if x + 1 < text.len() and text[x] == '>' and text[x+1] == '>':
    curli = curli.strip()
    x+=2
    if curli == "":continue
    litems.add curli
    curli = ""
    continue
  if text[x] == '\\' and x+1 < text.len():
    x+=1
    curli.add "\\" & text[x]
    x+=1
    continue
  curli.add text[x]
  x+=1
curli = curli.strip()
if curli != "":
  litems.add curli




if format == "html":stdout.write "<ul "&html_style()&">"
for item in litems:
  if format == "markdown":
    stdout.write "\n\t- " & item.replace("\n", "\n\t")
  if format == "html":
    stdout.write "<li>" & item & "</li>"

if format == "html":stdout.write "</ul>"
