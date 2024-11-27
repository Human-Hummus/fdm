include default

stdout.write("{header}")
var
  title = get_var("title")
  date = get_var("date")
  instructor = get_var("instructor")
  class = get_var("class")
  author = get_var("author")
if title != "":echo "{center:{h1:" & title & "}}" & "{newline}"
if author != "":echo author & "{newline}"
if instructor != "":echo instructor & "{newline}"
if class != "":echo class & "{newline}"
if date != "":echo date & "{newline}"


stdout.write "{spacing=2.0}{set_space: " & paramStr(1) & "}{footer}"
