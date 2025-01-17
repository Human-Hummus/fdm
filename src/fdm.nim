import tokenize, times, parser, std/os, execute, error, strutils
when isMainModule:
  var
    filein = ""
    format = "html"
    fileout = ""
    x = 0
    args = commandLineParams()
    echotimes = false
  while x < args.len:
    case args[x]:
      of "-i", "--input":
        x+=1
        if not (x < args.len):
          fatal "Input not followed by argument"
        filein = args[x]

      of "-o", "--output":
        x+=1
        if not (x < args.len):
          fatal "Output not followed by argument"
        fileout = args[x]
      of "-f", "--format":
        x+=1
        if not (x < args.len):
          fatal "format not followed by argument"
        format = args[x]
      of "--bench":
        echotimes = true
    x+=1
  if filein.len < 1:
    fatal("No input file")
  if format in @["HTML", "html", "htm", "HTM"]:
    format = "html"
  elif format in @["MD", "md", "Markdown", "markdown"]:
    format = "markdown"
  elif format in @["tex", "latex", "ltx"]:
    format = "latex"
  else:
    fatal "Unknown format"
  if fileout.len < 1:
    fileout = "/dev/stdout"
  var starttime = epochTime()
  var tokens = tokenizer("@" & filein & ";", "head")
  var tokentime = epochTime()
  var parsed = parser(tokens)
  var parsetime = epochTime()
  var default_vars = @[execute.variable(name: "format", content: format)]
  var executed = compile_text(parsed, default_vars)
  var exectime = epochTime()
  if echotimes:
    echo "Tokenized in " & (tokentime - starttime).formatFloat(
        format = ffDecimal, precision = 4) & " seconds"
    echo "Parsed in " & (parsetime - tokentime).formatFloat(
        format = ffDecimal, precision = 4) & " seconds"
    echo "executed in " & (exectime - parsetime).formatFloat(
        format = ffDecimal, precision = 4) & " seconds"
  writeFile(fileout, executed) #missing propper error

