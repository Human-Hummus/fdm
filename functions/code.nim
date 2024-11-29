include default
if format == "markdown": stdout.write "`" & paramStr(1) & "`"
if format == "html": stdout.write "<code>" & paramStr(1) & "</code>" 
