#THIS IS INCLUDED IN EXECUTE.NIM
proc compile_text*(nodes:seq[node], vars: seq[seq[string]]):(string, seq[seq[string]])

proc or_function*(input:node, vars:seq[seq[string]]):(string, seq[seq[string]])=
  var 
    x = 0
    updated_vars = vars  
  if input.fncontents.len != 0:
    warn "or function has function contents. These will be ignored. " & input.pos
  while x < input.subvalues.len:
    var got = ""
    (got, updated_vars) = compile_text(@[input.subvalues[x]], updated_vars)
    if got == "true":
      return ("true", updated_vars)
    x+=1
  return ("false", updated_vars)
