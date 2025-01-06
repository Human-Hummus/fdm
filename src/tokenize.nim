import strutils, sequtils, error, strformat
include standard #include the FDM standard lib 

type
  tokentype* = enum
    text, id, function_call, equals, variable, paren, comma, curly, bracket, semi
  token* = object
    kind*:tokentype
    value*:string
    pos*:string

proc get_path(filename:string):string=
  var x = filename.len-1
  while x > 0 and filename[x] != '/':
    x-=1
  if filename[x] == '/':
    return filename[0..x]
  return ""

proc tokenizer*(input, filename:string):seq[token] =
  var
    x = 0
    output:seq[token] = @[]
    line_number = 1
  while x < input.len():
    if input[x] == '@':
      x += 1
      if not (x < input.len):
        fatal "@ not followed by filename."
      var buffer = ""
      while x < input.len and input[x] != ';':
        buffer.add input[x]
        x+=1
      if not (x < input.len):
        fatal fmt"'@{buffer}' not followed by semicolon"
      var filecontents = ""
      if buffer == "std":
        filecontents = stdlib
      else:
        filecontents = readFile(get_path(filename) & buffer)
      output = concat(output, tokenizer(filecontents, buffer));
    elif input[x] in IdentChars:
      var buffer = ""
      while x < input.len and input[x] in IdentChars:
        buffer.add input[x]
        x+=1
      output.add token(kind:tokentype.id,value:buffer, pos:filename & ":" & $line_number)
      x-=1
    elif input[x] in "()":
      output.add token(kind:tokentype.paren,value: $input[x], pos:filename & ":" & $line_number)
    elif input[x] in "{}":
      output.add token(kind:tokentype.curly,value: $input[x], pos:filename & ":" & $line_number)
    elif input[x] in "[]":
      output.add token(kind:tokentype.bracket,value: $input[x], pos:filename & ":" & $line_number)
    elif input[x] == ';':
      output.add token(kind:tokentype.semi,value:";", pos:filename & ":" & $line_number)
    elif input[x] == ',':
      output.add token(kind:tokentype.comma,value:",", pos:filename & ":" & $line_number)

    elif input[x] == '$':
      output.add token(kind:tokentype.variable,value:"$", pos:filename & ":" & $line_number)
    elif input[x] == '=':
      output.add token(kind:tokentype.equals,value:"=", pos:filename & ":" & $line_number)
    elif input[x] == '`':
      var starts_at = filename & ":" & $line_number
      x+=1 
      var buffer = ""
      while x < input.len and input[x] != '`':
        if input[x] == '\\':
          x+=1
          if x == input.len:
            fatal "Unterminated string"
          if input[x] == 'n':
            buffer.add '\n'
          elif input[x] == 't':
            buffer.add '\t'
          else:
            if input[x] == '\n':
              line_number+=1
            buffer.add input[x]
        else:
          buffer.add input[x]
        x+=1
      if x == input.len:
        fatal "Unterminated string " & starts_at
      output.add token(kind:tokentype.text,value:buffer, pos:filename & ":" & $line_number)
    elif input[x] == '"':
      var starts_at = filename & ":" & $line_number
      x+=1 
      var buffer = ""
      while x < input.len and input[x] != '"':
        if input[x] == '\\':
          x+=1
          if x == input.len:
            fatal "Unterminated string"
          if input[x] == 'n':
            buffer.add '\n'
          elif input[x] == 't':
            buffer.add '\t'
          else:
            if input[x] == '\n':
              line_number+=1
            buffer.add input[x]
        else:
          buffer.add input[x]
        x+=1
      if x == input.len:
        fatal "Unterminated string " & starts_at
      output.add token(kind:tokentype.text,value:buffer, pos:filename & ":" & $line_number)

    elif input[x] == '\n':
      line_number+=1
    x+=1;
  return output
