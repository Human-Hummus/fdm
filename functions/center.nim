include default
if format == "html": stdout.write "<div style=\"text-align: center;\">" & paramStr(1) & "</div>" 
if format == "markdown":stdout.write paramStr(1)
