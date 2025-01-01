import system, terminal
proc fatal*(text:string) =
  stderr.styledWriteLine(fgred, "ERROR: " & text, fgdefault)
  quit 1
  
proc warn*(text:string) =
  stderr.styledWriteLine(fgyellow, "warning: " & text, fgdefault)
  
