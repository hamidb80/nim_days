import macros,macroutils, json

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

proc parseMangoProc(exp: NimNode): NimNode =
  case exp.kind:
  of nnkInfix:
    var op = exp[0].strVal # operator
    var br1, br2: NimNode

    case op:
    of "and", "or":
      op = "$" & op # $and , $or
      br1 = parseMangoProc exp[1]
      br2 = parseMangoProc exp[2]

      return quote: {
        `op`: [`br1`, `br2`]
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
        
    let field = exp[1]
    assert field.kind == nnkPrefix
    assert field[0].strVal == "@"

    return superQuote: {
      `field[1].strVal`: {
        `op`: `exp[2].parseMangoProc`
      }
    }

  else:
    return exp
  
    # of "len":
    # of "regex":
    # of "??": # exists
    # of "!?": # not exists


macro parseMango*(exp: untyped): JsonNode=
  var selector: NimNode

  for s in exp:
    selector = parseMangoProc(s)

  quote:
    %* {"selector": `selector`}

let bad_year = 1399
var q = parseMango:
  # @name == "hamid" or @year != bad_year
  @artist == "mohammadAli" and @genre notin ["pop", "rock"] or @artist == "iman khodaee"

echo q.pretty

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
