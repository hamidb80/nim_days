import std/[json, httpcore]
import jester

template resp*(code: HttpCode, content: JsonNode): untyped =
  resp(code, $content, contentType = "application/json")
