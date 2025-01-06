import strutils, tokenize, error
type
  nodetype* = enum
    function, text, function_call, generic, variable, variable_decleration, array_access
  node* = object
    kind*:nodetype
    name*:string
    value*:string
    subvalues*:seq[node]
    fnvars*:seq[variable_dec]
    fncontents*:seq[node]
    pos*:string
  variable_dec* = object
    name*:string
    content*:seq[node]


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
        x+=1
        if x >= input.len or input[x].kind != id:
          fatal "func should be followed by identifier " & pos
        var name = input[x].value
        x+=1
        if x >= input.len or input[x].kind != tokentype.paren or input[x].value != "(":
          fatal "function name should be followed by opening parenthesis " & pos
        x+=1
        var 
          depth = 0
          var_name = ""
          var_buffer:seq[token] = @[]
          args:seq[variable_dec] = @[]
          fncontent:seq[token] = @[]
        while x < input.len and not (depth == 0 and input[x].kind == paren and input[x].value == ")"):
          if depth == 0 and input[x].kind == tokentype.comma:
            if var_name == "":
              if var_buffer.len != 1:
                fatal "illegal function variable " & pos
              var_name = var_buffer[0].value
              var_buffer = @[]
            args.add variable_dec(name:var_name, content:parser(var_buffer))
            var_buffer = @[]
            var_name = ""
            x+=1
            continue
          if input[x].kind == equals:
            if var_name != "":
              fatal "illegal variable; double assignment " & pos
            if var_buffer.len != 1:
              fatal "Illegal variable; name isn't one token" & pos
            var_name = var_buffer[0].value
            var_buffer = @[]
            x+=1
            continue
          if input[x].kind == paren:
            if input[x].value == "(":
              depth+=1
            else:
              depth-=1
          var_buffer.add input[x]
          x+=1
        if var_name == "" and var_buffer.len > 0:
          var_name = var_buffer[0].value
          var_buffer = @[]
        if var_name != "":
          args.add variable_dec(name:var_name, content:parser(var_buffer))
        depth = 1
        if x >= input.len or input[x].kind != paren:
          fatal "Illegal function decleration, " & pos
        x+=1
        if x >= input.len or input[x].kind != curly:
          fatal "Illegal function decleration " & pos
        x+=1
        while x < input.len and depth > 0:
          if input[x].kind == curly:
            if input[x].value == "{":
              depth+=1
            else:
              depth-=1
            if depth != 0:
              fncontent.add input[x]
          else:
            fncontent.add input[x]
          x+=1
        x-=1
        if input[x].value != "}":
          fatal "illegal function; unterminated " & pos
        functions.add node(kind:function, name:name, fnvars:args, fncontents:parser(fncontent), pos:pos)
      else:
        if x+1 < input.len and input[x+1].kind in @[paren,curly] and input[x+1].value in "({":
          var
            name = input[x].value
            args:seq[variable_dec] = @[]
            arg_buffer:seq[token] = @[]
            fncontents:seq[token] = @[]
            arg_name = ""
            depth = 0
          x+=1
          if input[x].kind == tokentype.paren:
            x+=1
            while x < input.len and not (input[x].kind == tokentype.paren and input[x].value == ")" and depth == 0):
              if input[x].kind == tokentype.equals and depth==0:
                arg_name = arg_buffer[0].value
                arg_buffer = @[]
                x+=1
                continue
              if input[x].kind == tokentype.comma and depth == 0:
                args.add variable_dec(name:arg_name, content:parser(arg_buffer))
                arg_name = ""
                arg_buffer = @[]
                x+=1
                continue
              if input[x].kind == tokentype.paren:
                if input[x].value == ")":
                  depth-=1
                else:
                  depth+=1
              arg_buffer.add input[x]
              x+=1
            if not (x < input.len):
              fatal "unterminated function call " & pos
            if arg_name == "" and arg_buffer.len > 0:
              args.add variable_dec(name: "", content:parser(arg_buffer))
            if arg_name != "":
              args.add variable_dec(name:arg_name, content:parser(arg_buffer))
            x+=1
          arg_buffer = @[]
          depth = 1
          if x < input.len and input[x].kind == tokentype.curly and input[x].value == "{":
            x+=1
            while x < input.len and depth > 0:
              if input[x].kind == tokentype.curly:
                if input[x].value == "{":
                  depth+=1
                else:
                  depth-=1
              if depth > 0:
                fncontents.add input[x]
              x+=1
          
          output.add node(kind:nodetype.function_call, name:name, fnvars:args, fncontents:parser(fncontents), pos:pos)
          x-=1
        else:
          output.add node(kind:nodetype.text, value:input[x].value, pos:pos)
    x+=1
  return output
