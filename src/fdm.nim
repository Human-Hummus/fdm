import tokenize, parser, std/os, execute, error
when isMainModule:
  var 
    filein = ""
    format = "html"
    fileout = ""
    x = 0
    args = commandLineParams()
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
    x+=1
  if filein.len < 1:
    fatal("No input file")
  if format in @["HTML", "html", "htm", "HTM"]:
    format = "html"
  elif format in @["MD", "md", "Markdown", "markdown"]:
    format = "markdown"
  else:
    fatal "Unknown format"
  if fileout.len < 1:
    fileout = "/dev/stdout"
  var tokens = tokenizer("@" & filein & ";")
  var parsed =  parser(tokens)
  var (executed, _) = compile_text(parsed, @[@["format", format]])
  writeFile(fileout, executed) #missing propper error
