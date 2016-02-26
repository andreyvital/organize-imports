recast = require 'recast'
babel = require 'babel-core'
scoreOf = require './scoreOf'

module.exports =
  activate: (state) ->
    atom.commands.add 'atom-workspace', 'organize-imports:organize', => @organize()

  organizeImports: (code) ->
    ast = recast.parse code, {
      esprima: babel
    }

    return if not ast.program

    imports = ast.program.body.filter (node) -> node.type is 'ImportDeclaration'

    imports.sort (a, b) ->
      sA = scoreOf a
      sB = scoreOf b

      return sB - sA if sA isnt sB
      return a.source.value.localeCompare b.source.value

    ast.program.body = ast.program.body.map (node) ->
      return imports.shift() if node.type is 'ImportDeclaration'
      node

    return recast.print(ast).code

  organize: ->
    editor = atom.workspace.getActivePaneItem()
    # bufferRange = editor.getSelectedBufferRange()

    # if bufferRange.start.isEqual(bufferRange.end)
    contents = editor.getText()
    editor.setText @organizeImports contents
    return

    # contents = editor.getTextInBufferRange [
    #   [bufferRange.start.row, 0],
    #   [bufferRange.end.row + 1, 0]
    # ]
    #
    # editor.setTextInBufferRange [[start, 0], [end, 0]], @organizeImports contents
    # return
