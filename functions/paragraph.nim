include default
      
if format == "html":stdout.write "<p style=\"text-indent:50px;\">"
stdout.write single_spaced(paramStr(1))
if format == "html":stdout.write "</p>"
