include default
if format == "markdown": stdout.write "**" & paramStr(1) & "**" 
if format == "html": stdout.write "<b>" & paramStr(1) & "</b>" 
