compare = require './compare'

module.exports =
  activate: (state) ->
    atom.commands.add 'atom-workspace', 'organize-imports:organize', => @organize()

    # for now, based on eslint (it should be a package option or something like)
    try {
      semi = JSON.parse(fs.readFileSync(atom.project.getPaths()[0] + '/.eslintrc')).rules.semi

      @shouldUseSemicolon = semi[1] is 'always'
    } catch (e) {
      @shouldUseSemicolon = true
    }

  organize: ->
    editor = atom.workspace.getActivePaneItem()
    bufferRange = editor.getSelectedBufferRange()

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
      startRow = bufferRange.start.row
      endRow = bufferRange.end.row

      start = startRow
      end = endRow + 1

    imports = editor.getTextInBufferRange [[startRow, 0], [endRow + 1, 0]]
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

    semicolon = @shouldUseSemicolon

    organize = organize.map ([what, from]) -> "import #{what} from '#{from}'" + (';' if semicolon)

    editor.setTextInBufferRange(
      [[start, 0], [end, 0]],
      (organize.join '\n') + '\n'
    )
