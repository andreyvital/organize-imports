module.exports =
  activate: (state) ->
    atom.commands.add 'atom-workspace', 'organize-imports:organize', => @organize()

  organize: ->
    editor = atom.workspace.getActivePaneItem()
    bufferRange = editor.getSelectedBufferRange()

    startRow = bufferRange.start.row
    endRow = bufferRange.end.row

    entireFile = bufferRange.start.isEqual(bufferRange.end)

    startsWithImportRegex = /^(?:\bimport\b(?:.+))/

    if entireFile
      lines = editor.getText().split '\n'

      start = -1
      end = lines.length

      for line, i in lines
        if start is -1 and line.match startsWithImportRegex
          start = i

        if start isnt -1 and line and not line.match startsWithImportRegex
          end = i - 1
          break

      startRow = start
      endRow = end

    if not entireFile
      start = bufferRange.start.row
      end = bufferRange.end.row + 1

    imports = editor.getTextInBufferRange [[startRow - 1, 0], [endRow + 1, 0]]
    imports = imports.split('\n').filter (stm) -> stm.length
    imports = imports.filter (stm) -> startsWithImportRegex.test stm

    # imports = editor.getLastSelection().getText().split('\n').filter (stm) -> stm.length

    return if imports.length is 0

    regex = /^(?:import (.+) from\s*(?:'|")(.+)(?:'|"))/gm

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

  return scoreB - scoreA if scoreA isnt scoreB
  return a[1].localeCompare b[1]

scoreOf = (what, from) ->
  # flow type `import type {...}`
  return 2 if (what.slice 0, 4) == 'type'

  # module
  return 1 if from[0] isnt '.'

  return 0
