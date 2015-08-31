module.exports =
  activate: (state) ->
    atom.commands.add 'atom-workspace', 'organize-imports:organize', => @organize()

  organize: ->
    editor = atom.workspace.getActivePaneItem()
    bufferRange = editor.getSelectedBufferRange()

    imports = editor.getLastSelection().getText().split('\n')

    return if ! imports

    regex = /^(?:import (.+) from\s*(?:'|")(.+)(?:'|"))/gm

    start = bufferRange.start.row
    end = bufferRange.end.row + 1

    organize = []

    for importStm in imports
      continue if not importStm.match regex

      [_, what, from] = regex.exec importStm

      organize.push [what, from]

    organize.sort compare

    organize = organize.map ([what, from]) -> "import #{what} from '#{from}'"

    editor.setTextInBufferRange(
      [[start, 0], [end, 0]],
      (organize.join '\n') + '\n'
    )

compare = (a, b) ->
  scoreA = scoreOf a[1]
  scoreB = scoreOf b[1]

  return scoreA - scoreB if scoreA isnt scoreB

  if a < b
    return -1

  if a == b
    return 0

  if a > b
    return 1

scoreOf = (path) ->
  return 3 if ! path

  if path[0] is '.'
    return (path.match /\.\./g).length

  return 1
