import strutils, sequtils, error, strformat

type
  tokentype* = enum
    text, id, function_call, equals, variable, paren, semi, curly, bracket
  token* = object
    kind*:tokentype
    value*:string

proc tokenizer*(input:string):seq[token] =
  var
    x = 0
    output:seq[token] = @[]
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
      output = concat(output, tokenizer(readFile(buffer)));
    elif input[x] in IdentChars:
      var buffer = ""
      while x < input.len and input[x] in IdentChars:
        buffer.add input[x]
        x+=1
      output.add token(kind:tokentype.id,value:buffer)
      x-=1
    elif input[x] in "()":
      output.add token(kind:tokentype.paren,value: $input[x])
    elif input[x] in "{}":
      output.add token(kind:tokentype.curly,value: $input[x])
    elif input[x] in "[]":
      output.add token(kind:tokentype.bracket,value: $input[x])
    elif input[x] == ';':
      output.add token(kind:tokentype.semi,value:";")
    elif input[x] == '$':
      output.add token(kind:tokentype.variable,value:"$")    
    elif input[x] == '=':
      output.add token(kind:tokentype.equals,value:"=")    
    elif input[x] == '`':
      x+=1 
      var buffer = ""
      while x < input.len and input[x] != '`':
        if input[x] == '\\':
          x+=1
          if x == input.len:
            fatal "Unterminated string"
          if input[x] == 'n':
            buffer.add '\n'
          else:
            buffer.add input[x]
        else:
          buffer.add input[x]
        x+=1
      if x == input.len:
        fatal "Unterminated string"
      output.add token(kind:tokentype.text,value:buffer)
    x+=1;
  return output
