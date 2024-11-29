include default
if format == "html": stdout.write "<h3>" & paramStr(1) & "</h3>" 
if format == "markdown": stdout.write "### " & single_spaced(paramStr(1))
