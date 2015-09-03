scoreOf = require './scoreOf.coffee'

compare = (a, b) ->
  scoreA = scoreOf a...
  scoreB = scoreOf b...

  return scoreB - scoreA if scoreA isnt scoreB
  return a[1].localeCompare b[1]

module.exports = compare
