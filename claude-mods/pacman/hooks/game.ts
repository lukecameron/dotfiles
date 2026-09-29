// Pac-Man over the transcript rows on screen. The board is the visible text,
// one cell per character: pacman eats every character he crosses, the ghosts
// chase him, and there are no walls, so the conversation itself is the maze.
// Pure state and rules; register.tsx turns transcript renders into sites and
// draws the result.

export type Dir = 'up' | 'down' | 'left' | 'right'

// One transcript message as the board holds it: its rows as cells, and which
// of those rows the screen shows now.
export type Site = {
  id: string
  seq: number
  cells: string[][]
  first: number
  last: number
}

export type Pos = { site: string; row: number; col: number }

export type Ghost = { pos: Pos; color: string }

export type Game = {
  width: number
  sites: Site[]
  pac: Pos
  dir: Dir
  want: Dir
  ghosts: Ghost[]
  score: number
  lives: number
  tick: number
  // ticks left before the ghosts start moving, after a start or a lost life
  grace: number
  state: 'playing' | 'won' | 'over'
}

const GRACE_TICKS = 18
const GHOST_COLORS = ['red', 'magenta', 'cyan', '#ffb852'] as const
const EMOJI = /\p{Extended_Pictographic}|\p{Regional_Indicator}|[\u{1100}-\u{115F}\u{2E80}-\u{A4CF}\u{AC00}-\u{D7A3}\u{F900}-\u{FAFF}\u{FE30}-\u{FE4F}\u{FF00}-\u{FF60}\u{FFE0}-\u{FFE6}]/u

// Word-wraps `text` to `width` cells, the first row after `lead` and the rest
// after spaces of the same width, one cell per character. Wide characters
// become `*` so every character is exactly one cell.
export function wrap(text: string, width: number, lead: string): string[][] {
  const rows: string[][] = []
  const indent = ' '.repeat([...lead].length)
  const room = Math.max(8, width - indent.length)
  for (const paragraph of text.replace(/\t/g, '  ').split('\n')) {
    const chars = [...paragraph].map(c => (EMOJI.test(c) ? '*' : c))
    if (chars.length === 0) {
      rows.push([])
      continue
    }
    let start = 0
    while (start < chars.length) {
      let end = Math.min(start + room, chars.length)
      if (end < chars.length) {
        const space = chars.lastIndexOf(' ', end)
        if (space > start) end = space
      }
      rows.push(chars.slice(start, end))
      start = end
      while (chars[start] === ' ') start++
    }
  }
  return rows.map((row, i) => [...(i === 0 ? lead : indent)].concat(row))
}

// A message's rows at exactly the height the engine laid it out at, so
// drawing the board over it moves nothing on screen: the blank row the engine
// draws above most messages (`spaced`), then the text, cut or padded to
// `height` rows.
export function siteCells(text: string, width: number, lead: string, height: number, spaced: boolean): string[][] {
  const rows = [...(spaced ? [[]] : []), ...wrap(text, width, lead)].slice(0, height)
  while (rows.length < height) rows.push([])
  return rows
}

// Every visible row, top to bottom: which site and which of its rows.
export function visibleRows(game: Game): { site: string; row: number }[] {
  const rows: { site: string; row: number }[] = []
  for (const site of game.sites) {
    for (let row = Math.max(0, site.first); row <= Math.min(site.last, site.cells.length - 1); row++) {
      rows.push({ site: site.id, row })
    }
  }
  return rows
}

function rowIndex(rows: { site: string; row: number }[], pos: Pos): number {
  return rows.findIndex(r => r.site === pos.site && r.row === pos.row)
}

// The visible row nearest to where `pos` was, so a scroll that takes a
// sprite's row off screen puts it on the closest row still shown.
function settle(game: Game, rows: { site: string; row: number }[], pos: Pos): Pos {
  if (rows.length === 0) return pos
  if (rowIndex(rows, pos) >= 0) return pos
  const order = game.sites.map(s => s.id)
  const at = order.indexOf(pos.site)
  const before = rows.filter(r => order.indexOf(r.site) < at || (r.site === pos.site && r.row < pos.row))
  const pick = before[before.length - 1] ?? rows[0]
  return pick ? { ...pick, col: pos.col } : pos
}

export function step(from: Pos, dir: Dir, rows: { site: string; row: number }[], width: number): Pos {
  if (dir === 'left') return { ...from, col: (from.col - 1 + width) % width }
  if (dir === 'right') return { ...from, col: (from.col + 1) % width }
  const i = rowIndex(rows, from)
  const next = i < 0 ? undefined : rows[i + (dir === 'up' ? -1 : 1)]
  return next ? { ...next, col: from.col } : from
}

function eat(game: Game, pos: Pos): boolean {
  const row = game.sites.find(s => s.id === pos.site)?.cells[pos.row]
  const c = row?.[pos.col]
  if (!row || c === undefined || c === ' ') return false
  row[pos.col] = ' '
  return true
}

export function foodLeft(game: Game): number {
  let left = 0
  for (const r of visibleRows(game)) {
    const row = game.sites.find(s => s.id === r.site)?.cells[r.row] ?? []
    for (const c of row) if (c !== ' ') left++
  }
  return left
}

// Where the sprites begin: pacman low in the middle, a ghost in each corner
// of the top two thirds. `rows` is never empty here.
function starts(game: Game, rows: { site: string; row: number }[]): { pac: Pos; ghosts: Ghost[] } {
  const w = game.width
  const at = (i: number, col: number): Pos => {
    const r = rows[Math.max(0, Math.min(rows.length - 1, i))] ?? { site: '', row: 0 }
    return { site: r.site, row: r.row, col }
  }
  const bottom = rows.length - 1
  return {
    pac: at(Math.floor(bottom * 0.75), Math.floor(w / 2)),
    ghosts: [
      at(0, 1),
      at(0, w - 2),
      at(Math.floor(bottom / 3), 1),
      at(Math.floor(bottom / 3), w - 2),
    ].map((pos, i) => ({ pos, color: GHOST_COLORS[i % GHOST_COLORS.length] ?? 'red' })),
  }
}

export function newGame(sites: Site[], width: number): Game {
  const game: Game = {
    width,
    sites,
    pac: { site: '', row: 0, col: 0 },
    dir: 'left',
    want: 'left',
    ghosts: [],
    score: 0,
    lives: 3,
    tick: 0,
    grace: GRACE_TICKS,
    state: 'playing',
  }
  const rows = visibleRows(game)
  if (rows.length === 0) {
    game.state = 'won'
    return game
  }
  Object.assign(game, starts(game, rows))
  eat(game, game.pac)
  return game
}

const distance = (rows: { site: string; row: number }[], a: Pos, b: Pos): number =>
  Math.abs(rowIndex(rows, a) - rowIndex(rows, b)) * 2 + Math.abs(a.col - b.col)

// Cells are about twice as tall as they are wide, so a sprite moves up or
// down on every other tick to cross the screen at one speed in both axes.
const moves = (dir: Dir, tick: number): boolean => (dir === 'left' || dir === 'right' ? true : tick % 2 === 0)

// A ghost heads for pacman one axis at a time and wanders one move in four,
// at two thirds of his speed, so he can outrun them in a straight line.
function chase(rows: { site: string; row: number }[], ghost: Ghost, target: Pos, width: number, random: () => number): Pos {
  const dirs: Dir[] = ['up', 'down', 'left', 'right']
  const wander = dirs[Math.floor(random() * dirs.length)]
  if (random() < 0.25 && wander) return step(ghost.pos, wander, rows, width)
  let best = ghost.pos
  let bestDistance = distance(rows, ghost.pos, target)
  for (const dir of dirs) {
    const next = step(ghost.pos, dir, rows, width)
    const d = distance(rows, next, target)
    if (d < bestDistance) {
      best = next
      bestDistance = d
    }
  }
  return best
}

const same = (a: Pos, b: Pos): boolean => a.site === b.site && a.row === b.row && a.col === b.col

// One frame: pacman turns to the wanted direction and moves, eating what he
// lands on; the ghosts move; a ghost on pacman costs a life and resets the
// sprites; an empty screen wins.
export function tick(game: Game, random: () => number = Math.random): Game {
  if (game.state !== 'playing') return game
  const rows = visibleRows(game)
  if (rows.length === 0) return game
  game.tick++
  game.pac = settle(game, rows, game.pac)
  for (const ghost of game.ghosts) ghost.pos = settle(game, rows, ghost.pos)
  game.dir = game.want
  if (moves(game.dir, game.tick)) {
    game.pac = step(game.pac, game.dir, rows, game.width)
    if (eat(game, game.pac)) game.score++
  }
  const caught = () => game.ghosts.some(g => same(g.pos, game.pac))
  if (game.grace > 0) game.grace--
  else if (!caught() && game.tick % 3 !== 0) {
    for (const ghost of game.ghosts) {
      const next = chase(rows, ghost, game.pac, game.width, random)
      const dir: Dir = next.row !== ghost.pos.row || next.site !== ghost.pos.site ? 'up' : 'left'
      if (moves(dir, game.tick)) ghost.pos = next
    }
  }
  if (caught()) {
    game.lives--
    if (game.lives <= 0) {
      game.state = 'over'
      return game
    }
    Object.assign(game, starts(game, rows), { grace: GRACE_TICKS })
  }
  if (foodLeft(game) === 0) game.state = 'won'
  return game
}

