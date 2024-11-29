include default
var 
  table:seq[seq[string]] = @[]
  x = 0
  text = paramStr(1)
  currow:seq[string] = @[]
  cur = ""
while x < text.len():
  if text[x] == '\\' and x+1 < text.len():
    if text[x+1] == '|' or text[x+1] == '\n':
      cur.add text[x+1]
      x+=1
    else:
      cur.add '\\'
  elif text[x] == '|':
    currow.add cur.strip()
    cur = ""
  elif text[x] == '\n':
    cur = cur.strip()
    if cur != "":
      currow.add cur
      cur = ""
    if currow.len() > 0:
      table.add currow
    currow = @[]
  else:
    cur.add text[x]
  x+=1
cur = cur.strip()
if cur != "":
  currow.add cur
if currow.len() > 0:
  table.add currow

var max_len = 0
for i in table:
  if i.len() > max_len:max_len = i.len()
x = 0
while x < table.len():
  var y = 0
  while y<max_len:
    if y>= table[x].len():
      table[x].add ""
    y+=1
  x+=1

cur = ""

if format == "markdown":
  for row in table:
    cur.add "|"
    for item in row:
      for char in item:
        if char == '|' or char == '\n':
          cur.add '\\'
        cur.add char
    cur.add '\n'
if format == "html":
  cur.add "<table>"
  for row in table:
    cur.add "<tr>"
    for item in row:
      cur.add "<td>"
      cur.add item
      cur.add "</td>"
    cur.add "</tr>"
  cur.add "</table>"
stdout.write cur
