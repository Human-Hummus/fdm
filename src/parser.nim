import strutils, sequtils, tokenize, os, error
type
  nodetype* = enum
    function, text, function_call, generic, variable, variable_decleration
  node* = object
    kind*:nodetype
    name*:string
    value*:string
    subvalues*:seq[node]
    fncontents*:seq[node]
    

proc error*(text:string)=
  echo "ERROR: " & text
  quit(1)

var functions*:seq[node] = @[]

proc parser*(input:seq[token]):seq[node] = 
  var 
    x = 0
    output:seq[node]
  while x < input.len:
    if input[x].kind == tokentype.text:
      output.add node(kind:nodetype.text, value:input[x].value)
    elif input[x].kind == tokentype.variable:
      #MISSING CHECK
      x+=1
      if x+1 < input.len and input[x+1].kind == tokentype.equals:
        var name = input[x].value
        x+=2#missing check
        var 
          buffer:seq[token] = @[]
          depth = 0
        while x< input.len and not (depth == 0 and input[x].kind == tokentype.semi):
          echo input[x]
          if input[x].kind in @[tokentype.paren, tokentype.bracket]:
            if input[x].value in "{(":
              depth+=1
            else:
              depth-=1
          buffer.add input[x]
          x+=1
        if depth != 0 or x == input.len:
          error("unterminated variable decleration") 
        output.add node(kind:nodetype.variable_decleration, name:name, subvalues:parser(buffer))
        x-=1
      else:
        output.add node(kind:nodetype.variable, name:input[x].value)
      
    elif input[x].kind == tokentype.id:
      if input[x].value == "func":
        x+=2#MISSING CHECK
        var 
          args =""
          name = input[x-1].value
          contents:seq[token] = @[]
          depth = 1;
        x+=1 #MISSING CHECK
        while input[x].kind != tokentype.paren: # MISSING CHECK
          args.add input[x].value
          x+=1
        x+=2 #MISSING CHECK
        while x < input.len and depth > 0: #MISSING CHECK
          if input[x].kind == tokentype.bracket:
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
          error("Function not terminated")
        functions.add node(kind:nodetype.function,value:args,name:name,subvalues:parser(contents))
        x-=1
      else:
        if x+1 < input.len and input[x+1].kind in @[tokentype.paren,tokentype.bracket] and input[x+1].value in "({":
          
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
              elif depth == 1 and input[x].kind == tokentype.semi:
                args.add node(kind:nodetype.generic, subvalues:parser(buffer))
                buffer = @[]
              else:
                buffer.add input[x]
              x+=1
            args.add node(kind:nodetype.generic, subvalues:parser(buffer))
            if depth != 0:
              error("illegal function call")
          depth = 1
          buffer = @[]
          if x < input.len and input[x].kind == tokentype.bracket and input[x].value == "{":#MISSING CHECK
            x+=1
            while depth > 0:
              if input[x].kind == tokentype.bracket:
                if input[x].value == "{":
                  depth+=1
                if input[x].value == "}":
                  depth-=1
                if depth > 0:
                  buffer.add input[x]
              else:
                buffer.add input[x]
              x+=1
            contents = @[node(kind:nodetype.generic, subvalues:parser(buffer))]
          output.add node(kind:function_call, name:name, subvalues:args, fncontents:contents)
          x-=1
        else:
          output.add node(kind:nodetype.text, value:input[x].value)
    x+=1
  return output
