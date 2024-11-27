include default
var
  x = 0
  toret = ""
  is_italic = false
  is_bold = false
  text = paramStr(1)
while x < text[x].len():
  if text[x] == '\\':
    toret.add text[x]
    x+=1
    if not x < text.len():toret.add text[x]
  elif text[x] == '*' or text[x] == '_':
    if x+1 < text.len() and text[x+1] == '_' or text[x+1] == '*':
      if is_bold:
        is_bold = false

  x+=1
