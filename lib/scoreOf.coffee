scoreOf = (what, from) ->
  return 2 if (what.slice 0, 4) is 'type'
  return 1 if from[0] isnt '.'
  return 0

module.exports = scoreOf
