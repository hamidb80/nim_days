import macros, json

#[
Infix
  Ident "and"
  Infix
    Ident "=="
    Prefix
      Ident "@"
      Ident "name"
    StrLit "hamid"
  Infix
    Ident "notin"
    Prefix
      Ident "@"
      Ident "year"
    Bracket
      IntLit 1399
]#

proc parseMangoProc(exp: NimNode): JsonNode =
  case exp.kind:
  of nnkInfix:
    var op = exp[0].strVal # operator

    case op:
    of "and", "or":
      op = "$" & op # $and , $or
      var br1, br2: JsonNode # operator

      br1 = parseMangoProc exp[1]
      br2 = parseMangoProc exp[2]

      return %* {
        op: [br1, br2]
      }
    of "<", "<=", ">=", ">", "==", "!=", "in", "notin", "is", "mod":
      case op:
      of "<":
        op = "$lt"
      of "<=":
        op = "$lte"
      of ">=":
        op = "$gte"
      of ">":
        op = "$gt"
      of "==":
        op = "$eq"
      of "!=":
        op = "$ne"

      of "in":
        op = "$in"
      of "notin":
        op = "$nin"

      of "is":
        op = "$is"

      of "mod":
        op = "$mod"

    return %* {
      exp[1].parseMangoProc.getStr: {
        op: exp[2].parseMangoProc
      }
    }

  of nnkPrefix:
    assert exp[0].strVal == "@"
    return newJString exp[1].strVal

  of nnkStrLit:
    return newJString exp.strVal
  of nnkIntLit:
    return newJInt exp.intVal
  of nnkFloatLit:
    return newJFloat exp.floatVal
  
  # of nnkBracket:
  #   return newJArray exp.s

  else:
    raise

  return %* {}
    # of "len":
    # of "regex":
    # of "??": # exists
    # of "!?": # not exists


macro parseMango*(exp: untyped): untyped=
  var selector: JsonNode

  for s in exp:
    echo parseMangoProc(s).pretty
    # selector = parseMangoProc(s)

  quote:
    %* {"selector": `selector`}

let bad_year = 1399
parseMango:
#   @name == "hamid" and @year notin [1399]
  @name == "hamid" or @year != 1399
  # @name == "hamid" or @year != bad_year

#[
  parseMango:
    query:
      @name == "hamid" and @year notin [1399] 
  
    fields: ["name", "stars", ...]

  -------------------------------------

  {
    "selector" : {
      "$and": {
        "name": {
          "$eq": "hamid"
        },
        "year": {
          "$nin": [1399]
        }
      } 
    },

    fields: ["name", "stars", ...]

  }

]#
