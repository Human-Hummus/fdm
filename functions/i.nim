include default
if format == "html":stdout.write "<em>" & paramStr(1) & "</em>" 
if format == "markdown":stdout.write "*" & paramStr(1) & "*"
