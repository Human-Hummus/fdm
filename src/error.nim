import system

when not defined(js):
  import terminal
proc fatal*(text: string) =
  when not defined(js):
    stderr.styledWriteLine(fgred, "ERROR: " & text, fgdefault)
  else:
    echo "ERROR:" & text
  quit 1

proc warn*(text: string) =
  when not defined(js):
    stderr.styledWriteLine(fgyellow, "Warning: " & text, fgdefault)
  else:
    echo "Warning: " & text

