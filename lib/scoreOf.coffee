scoreOf = (node) ->
  return 3 if node.importKind && node.importKind is 'type'
  return 2 if node.specifiers.length is 0
  return 1 if node.source.value[0] isnt '.'
  return 0

module.exports = scoreOf
