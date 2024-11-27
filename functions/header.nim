include default
var title = get_var("title")
if title == "":title = "Untitled"

if format == "html": stdout.write "<!doctype HTML><html><head><title>"&title&"</title></head><body>" 
