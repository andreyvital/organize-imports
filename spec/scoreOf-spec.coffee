scoreOf = require '../lib/scoreOf'

describe 'scoreOf', ->
  it 'returns 2 if `what` is a type (flow)', ->
    expect(scoreOf 'type {A, B, C}', '../ABC').toEqual 2
    expect(scoreOf 'type A', '../A').toEqual 2

  it 'returns 1 if `from` is a module', ->
    expect(scoreOf 'React', 'react/addons').toEqual 1
    expect(scoreOf '_', 'lodash').toEqual 1

  it 'returns 0 otherwise', ->
    expect(scoreOf '{doSomething, doSomethingElse}', '../utils').toEqual 0
    expect(scoreOf 'sprintf', '../utils/sprintf').toEqual 0
