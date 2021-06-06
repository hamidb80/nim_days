import json
import mycouch

when isMainModule:
  let cdb = newCouchDBClient()
  cdb.login "admin", "admin"

  echo cdb.find("movie", %*{
    "selector": {
      "genre": {
        "$ne": "pop"
    }
  },
    "fields": ["_id", "_rev", "genre", "artist"]
  })

  echo cdb.getDoc("movie", "6bf1f1f7986d8c229f9c99bada003517")
