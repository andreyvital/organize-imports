module.exports =
  activate: (state) ->
    atom.commands.add 'atom-workspace', 'organize-imports:organize', => @organize()

  organize: ->
    editor = atom.workspace.getActivePaneItem()
    bufferRange = editor.getSelectedBufferRange()

    imports = editor.getLastSelection().getText().split('\n').filter (stm) -> stm.length

    return if imports.length is 0

    regex = /^(?:import (.+) from\s*(?:'|")(.+)(?:'|"))/gm

    start = bufferRange.start.row
    end = bufferRange.end.row + 1

    organize = []

    for importStm in imports
      continue if not importStm.match regex

      [_, what, from] = regex.exec importStm

      organize.push [what, from]

    organize.sort compare

    organize = organize.map ([what, from]) -> "import #{what} from '#{from}';"

    editor.setTextInBufferRange(
      [[start, 0], [end, 0]],
      (organize.join '\n') + '\n'
    )

compare = (a, b) ->
  scoreA = scoreOf a...
  scoreB = scoreOf b...

  return 1 if scoreA > scoreB
  return -1 if scoreA < scoreB
  return 0

scoreOf = (what, from) ->
  return -2 if (what.slice 0, 4) == 'type'

  return -1 if from[0] isnt '.'

  if from[0] is '.'
    match = (from.match /\.\./g)

    return match.length if match
    return 0 if ! match

  return 1
