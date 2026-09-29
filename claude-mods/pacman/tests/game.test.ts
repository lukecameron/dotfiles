import { describe, expect, test, tier } from 'claude-code/testing'

import { foodLeft, newGame, siteCells, step, tick, visibleRows, wrap, type Game, type Site } from '../hooks/game'

tier('user')

const site = (id: string, lines: string[], first = 0, last = lines.length - 1): Site => ({
  id,
  seq: 0,
  cells: lines.map(line => [...line]),
  first,
  last,
})

// always the same move, so ghosts go straight for pacman and never wander
const steady = () => 0.99

const cells = (game: Game, row: number): string[] => game.sites[0]?.cells[row] ?? []
const firstGhost = (game: Game) => game.ghosts[0]?.pos

describe('wrap', () => {
  test('breaks at spaces and indents continuation rows under the lead', () => {
    const rows = wrap('one two three four', 12, '⏺ ').map(r => r.join(''))
    expect(rows).toEqual(['⏺ one two', '  three four'])
  })

  test('keeps blank lines and turns wide characters into one cell', () => {
    const rows = wrap('a\n\n🍎b', 20, '').map(r => r.join(''))
    expect(rows).toEqual(['a', '', '*b'])
  })
})

describe('siteCells', () => {
  test('matches the height the engine laid the message out at', () => {
    expect(siteCells('one two three four', 12, '⏺ ', 2, true).map(r => r.join(''))).toEqual(['', '⏺ one two'])
    expect(siteCells('short', 20, '', 4, true)).toHaveLength(4)
  })

  test('draws no spacer row where the engine draws none', () => {
    expect(siteCells('done', 20, '  ⎿  ', 1, false).map(r => r.join(''))).toEqual(['  ⎿  done'])
  })
})

describe('visibleRows', () => {
  test('lists only the rows each message has on screen, in transcript order', () => {
    const game = { sites: [site('a', ['a0', 'a1', 'a2'], 1, 2), site('b', ['b0', 'b1'], 0, 0)] } as Game
    expect(visibleRows(game)).toEqual([
      { site: 'a', row: 1 },
      { site: 'a', row: 2 },
      { site: 'b', row: 0 },
    ])
  })
})

describe('step', () => {
  const rows = [
    { site: 'a', row: 0 },
    { site: 'b', row: 0 },
  ]

  test('wraps around the left and right edges', () => {
    expect(step({ site: 'a', row: 0, col: 0 }, 'left', rows, 10).col).toBe(9)
    expect(step({ site: 'a', row: 0, col: 9 }, 'right', rows, 10).col).toBe(0)
  })

  test('crosses from one message to the next and stops at the top and bottom', () => {
    expect(step({ site: 'a', row: 0, col: 3 }, 'down', rows, 10)).toEqual({ site: 'b', row: 0, col: 3 })
    expect(step({ site: 'a', row: 0, col: 3 }, 'up', rows, 10)).toEqual({ site: 'a', row: 0, col: 3 })
    expect(step({ site: 'b', row: 0, col: 3 }, 'down', rows, 10)).toEqual({ site: 'b', row: 0, col: 3 })
  })
})

describe('tick', () => {
  const board = () => newGame([site('m', ['          ', 'abcdefghij', '          ', '          '])], 10)

  test('pacman eats the characters he crosses and scores one each', () => {
    const game = board()
    game.ghosts = []
    game.pac = { site: 'm', row: 1, col: 5 }
    cells(game, 1)[5] = ' '
    const before = foodLeft(game)
    game.want = 'left'
    tick(game)
    tick(game)
    expect(game.score).toBe(2)
    expect(foodLeft(game)).toBe(before - 2)
    expect(cells(game, 1).join('')).toBe('abc   ghij')
  })

  test('moves up and down on every other tick', () => {
    const game = board()
    game.ghosts = []
    game.pac = { site: 'm', row: 3, col: 0 }
    game.want = 'up'
    tick(game)
    expect(game.pac.row).toBe(3)
    tick(game)
    expect(game.pac.row).toBe(2)
  })

  test('the ghosts wait out the grace period, then a catch costs a life and resets', () => {
    const game = board()
    game.pac = { site: 'm', row: 0, col: 0 }
    game.want = 'right'
    game.ghosts = [{ pos: { site: 'm', row: 0, col: 3 }, color: 'red' }]
    game.grace = 1
    tick(game, steady)
    expect(firstGhost(game)?.col).toBe(3)
    for (let i = 0; i < 4 && game.lives === 3; i++) tick(game, steady)
    expect(game.lives).toBe(2)
    expect(game.grace).toBeGreaterThan(0)
  })

  test('the last life lost ends the game', () => {
    const game = board()
    game.lives = 1
    game.grace = 0
    game.pac = { site: 'm', row: 0, col: 0 }
    game.ghosts = [{ pos: { site: 'm', row: 0, col: 1 }, color: 'red' }]
    game.want = 'right'
    tick(game, steady)
    expect(game.state).toBe('over')
  })

  test('eating the last character on screen wins', () => {
    const game = newGame([site('m', ['  x '])], 4)
    game.ghosts = []
    game.pac = { site: 'm', row: 0, col: 1 }
    game.want = 'right'
    tick(game)
    expect(game.state).toBe('won')
  })

  test('a scroll that takes pacman off screen puts him on the nearest row still shown', () => {
    const game = newGame([site('a', ['a0', 'a1']), site('b', ['b0 ', 'b1 '])], 3)
    game.ghosts = []
    game.pac = { site: 'b', row: 1, col: 2 }
    const b = game.sites[1]
    if (b) b.last = 0
    game.want = 'left'
    tick(game)
    expect(game.pac.site).toBe('b')
    expect(game.pac.row).toBe(0)
  })
})
