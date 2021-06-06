import
  macros, macroutils,
  json, strformat

proc parse(exp: NimNode): NimNode =
  case exp.kind:
  of nnkInfix:
    var
      op = exp[0].strVal  # operator
      br1 = parse exp[1] # branch1
      br2 =
        if exp.len == 3: parse exp[2]
        else: newEmptyNode()

    case op:
    of "and", "or":
      op = "$" & op # $and , $or
      return quote: {
        `op`: [`br1`, `br2`]
      }
    of "<", "<=", ">=", ">", "==", "!=", "~=", "in", "notin", "is", "mod":
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

      of "~=":
        # TODO regex
        op = "$regex"

      of "in":
        # TODO assert following type is openArray or bracket
        op = "$in"
      of "notin":
        op = "$nin"

      of "is":
        op = "$type"

        let strRepr = br2.repr
        var temp =
          case strRepr:
          of "object": "object"
          of "array": "array"
          of "string": "string"
          of "number": "number"
          of "nil": "null"
          of "bool": "boolean"
          else: ""

        if temp != "":
          br2 = newStrLitNode temp

        #TODO assert that ident is stringy type

      of "mod":
        op = "$mod"

        if br2.kind == nnkBracket:
          doAssert br2.len == 2, "mod shoud be like [Divisor, Remainder]"

        #TODO: assert ident type is openarray

    doAssert br1.kind == nnkPrefix
    doAssert br1[0].strVal == "@"

    return superQuote: {
      `br1[1].strVal`: {
        `op`: `br2.parse`
      }
    }
  of nnkPrefix:
    let op = exp[0].strVal

    if op == "@": return exp
    elif op notin ["??", "?!"]: error fmt"prefix {op} is not defiend"

    let field = exp[1][1].strVal
    return quote: {
      `field`: {
        "$exists": `op` == "??"
      }
    }
  of nnkCall:
    var op = exp[0].strVal # operator

    # TODO:
    # $size AKA len
    # $not
    # $nor
    # $all
    # $elemMatch
    # $allMatch
    # $keyMapMatch
  of nnkPar:
    return exp[0].parse

  else:
    return exp

macro mango*(exp: untyped): JsonNode =
  doAssert exp.len == 1, "the query must be only one expession"

  superQuote: 
    %* {"selector": `exp[0].parse`}


#[ sample

  mango:
    query:
      @name == "hamid" and @year notin [1399]

    fields:
      ["name", "stars"]

    sort: ...
    skip: ...
    limit: ...

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

    fields: ["name", "stars"]

  }
]#

block test:
  # let bad_year = 1399
  var q = mango:
    # @name == "hamid" or @year != bad_year
    @artist == "mohammadAli" and (@genre notin ["pop", "rock"] or @artist == "iman khodaee")
    # @year mod [4,2]
    # ?? @genre or ?! @genre
    # @year is myStringVar
    # @year is bool
    # @a is array and (((@year == 1 or @hamid == 4)))
    # @year is number

  echo q.pretty
