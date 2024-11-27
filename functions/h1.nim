include default
if format == "html": stdout.write "<h1>" & paramStr(1) & "</h1>" 
if format == "markdown": stdout.write "# " & single_spaced(paramStr(1))
