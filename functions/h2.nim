include default
if format == "html": stdout.write "<h2>" & paramStr(1) & "</h2>" 
if format == "markdown": stdout.write "## " & single_spaced(paramStr(1))
