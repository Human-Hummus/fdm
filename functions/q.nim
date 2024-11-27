include default
if format == "html": stdout.write "<q>" & paramStr(1) & "</q>" 
if format == "markdown": stdout.write "“" & paramStr(1) & "”" 
