
import getfenv, setfenv from require "moonscript.util"

-- all undefined Proper globals are automaticlly converted into lpeg.V
wrap_env = (debug, fn) ->
  import V, Cmt from require "lpeg"

  env = getfenv fn
  wrap_name = V

  if debug
    indent = 0
    indent_char = "  "

    iprint = (...) ->
      args = table.concat [tostring a for a in *{...}], ", "
      io.stderr\write "#{indent_char\rep(indent)}#{args}\n"

    wrap_name = (name) ->
      v = V name
      v = Cmt("", ->
        iprint "* " .. name
        indent += 1
        true
      ) * Cmt(v, (str, pos, ...) ->
        iprint name, true
        indent -= 1
        true, ...
      ) + Cmt("", ->
        iprint name, false
        indent -= 1
        false
      )

      v

  setfenv fn, setmetatable {}, {
    __index: (name) =>
      value = env[name]
      return value if value != nil

      if name\match"^[A-Z][A-Za-z0-9]*$"
        v = wrap_name name
        rawset @, name, v
        return v

      error "unknown variable referenced: #{name}"
  }

{ :wrap_env }
