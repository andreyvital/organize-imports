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
  scoreA = scoreOf a...
  scoreB = scoreOf b...

  return scoreA - scoreB if scoreA isnt scoreB

  if a < b
    return -1

  if a == b
    return 0

  if a > b
    return 1

scoreOf = (what, from) ->
  return 3 if ! from or ! what

  return 0 if ((what.slice 0, 4) == 'type')

  if from[0] is '.'
    match = (from.match /\.\./g)

    return match.length if match
    return 2 if ! match

  return 1
