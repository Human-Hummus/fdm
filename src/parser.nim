import strutils, tokenize, error
type
  nodetype* = enum
    function, text, function_call, generic, variable, variable_decleration, array_access
  node* = object
    kind*:nodetype
    name*:string
    value*:string
    subvalues*:seq[node]
    fncontents*:seq[node]
    pos*:string
    
var functions*:seq[node] = @[]

proc parser*(input:seq[token]):seq[node] = 
  var 
    x = 0
    output:seq[node]
  while x < input.len:
    var pos = input[x].pos
    if input[x].kind == tokentype.text:
      output.add node(kind:nodetype.text, value:input[x].value)
    elif input[x].kind == tokentype.bracket:
      if input[x].value == "]":
        fatal "Closing bracket before opening bracket " & pos
      if x == 0:
        fatal "Opening bracket at beginning of file " & pos
      if output.len < 1:
        fatal "Opening bracket not preceeded by a token " & pos 
      var 
        preval = output[^1]
        post_tokens:seq[token] = @[]
        depth = 1
      output = output[0..output.len-2]
      x+=1
      while x < input.len and depth > 0:
        if input[x].kind == tokentype.bracket:
          if input[x].value == "[":
            depth+=1
          else:
            depth-=1
          if depth > 0:
            post_tokens.add input[x]
            x+=1;
        else:
          post_tokens.add input[x]
          x+=1;
      if x == input.len:
        fatal "Unterminated array access " & pos
      output.add node(kind:nodetype.array_access, subvalues: @[preval], fncontents:parser(post_tokens), pos:pos)
      
    elif input[x].kind == tokentype.variable:
      x+=1
      if not (x < input.len):
        fatal "$ followed by EOF; should be followed by identifier " & pos
      if x+1 < input.len and input[x+1].kind == tokentype.equals:
        var name = input[x].value
        x+=2
        if not (x < input.len):
          fatal "incomplete variable decleration; EOF " & pos
        var 
          buffer:seq[token] = @[]
          depth = 0
        while x < input.len and not (depth == 0 and input[x].kind == tokentype.semi):
          if input[x].kind in @[tokentype.paren, tokentype.curly]:
            if input[x].value in "{(":
              depth+=1
            else:
              depth-=1
          buffer.add input[x]
          x+=1
        if depth != 0 or x == input.len:
          fatal "unterminated variable decleration starting at " & pos 
        output.add node(kind:nodetype.variable_decleration, name:name, subvalues:parser(buffer), pos:pos)
        x-=1
      else:
        output.add node(kind:nodetype.variable, name:input[x].value, pos:pos)
      
    elif input[x].kind == tokentype.id:
      if input[x].value == "func":
        x+=2
        if not (x < input.len):
          fatal "incomplete function decleration; EOF " & pos
        var 
          args =""
          name = input[x-1].value
          contents:seq[token] = @[]
          depth = 1;
        x+=1 #MISSING CHECK
        while x < input.len and input[x].kind != tokentype.paren:
          args.add input[x].value
          x+=1
        x+=2 
        while x < input.len and depth > 0: #MISSING CHECK
          if input[x].kind == tokentype.curly:
            if input[x].value == "{":
              depth+=1
            else:
              depth-=1
            if depth > 0:
              contents.add input[x]
          else:
            contents.add input[x]
          x+=1
        if depth!=0:
          fatal "Function not terminated " & pos
        functions.add node(kind:nodetype.function,value:args,name:name,subvalues:parser(contents), pos:pos)
        x-=1
      else:
        if x+1 < input.len and input[x+1].kind in @[tokentype.paren,tokentype.curly] and input[x+1].value in "({":
          var
            name = input[x].value
            depth = 1
            args: seq[node] = @[]
            contents:seq[node] = @[] 
            buffer:seq[token] = @[]
          x+=1
          if input[x].kind == tokentype.paren:
            x+=1
            while x < input.len and depth > 0: #MISSING CHECK
              if input[x].kind == tokentype.paren:
                if input[x].value == "(":
                  depth+=1
                else:
                  depth-=1
                if depth > 0:
                  buffer.add input[x]
              elif depth == 1 and input[x].kind == tokentype.comma:
                args.add node(kind:nodetype.generic, subvalues:parser(buffer))
                buffer = @[]
              else:
                buffer.add input[x]
              x+=1
            args.add node(kind:nodetype.generic, subvalues:parser(buffer))
            if depth != 0:
              fatal "illegal function call " & pos
          depth = 1
          buffer = @[]
          if x < input.len and input[x].kind == tokentype.curly and input[x].value == "{":#MISSING CHECK
            x+=1
            while depth > 0:
              if input[x].kind == tokentype.curly:
                if input[x].value == "{":
                  depth+=1
                if input[x].value == "}":
                  depth-=1
                if depth > 0:
                  buffer.add input[x]
              else:
                buffer.add input[x]
              x+=1
            contents = @[node(kind:nodetype.generic, subvalues:parser(buffer), pos:pos)]
          output.add node(kind:function_call, name:name, subvalues:args, fncontents:contents, pos:pos)
          x-=1
        else:
          output.add node(kind:nodetype.text, value:input[x].value, pos:pos)
    x+=1
  return output
