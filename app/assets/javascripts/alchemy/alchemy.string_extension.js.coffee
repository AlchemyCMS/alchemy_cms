String::beginsWith = (t, i) ->
  if i is false
    t is @substring(0, t.length)
  else
    t.toLowerCase() is @substring(0, t.length).toLowerCase()

String::endsWith = (t, i) ->
  if i is false
    t is @substring(@length - t.length)
  else
    t.toLowerCase() is @substring(@length - t.length).toLowerCase()
