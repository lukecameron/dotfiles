/* @jsx h */
import type { Register, RenderInput, RenderNode } from 'claude-code'
import { newGame, siteCells, tick, type Dir, type Game, type Site } from './game'

// /pacman: Pac-Man played over the conversation on screen. Every transcript
// row the screen shows becomes the board, drawn in place of the message, and
// pacman eats it character by character while the ghosts chase him. A small
// pane holds the keyboard (WASD or hjkl), so Escape closes the game without
// reaching the prompt, where it would interrupt Claude. Closing it draws the
// transcript as it was; the stored conversation is never touched.

const PANE = 'pacman'
const FRAME_MS = 110

// What the transcript last reported of each message: the render input, the
// order it first appeared in (messages never reorder, so first appearance is
// top to bottom), and which of its rows are on screen.
type OnScreen = { first: number; last: number; of: number }
type Seen = { e: RenderInput; seq: number; onScreen: OnScreen | null }
const seen = new Map<string, Seen>()
let seq = 0

let game: Game | undefined
let pending = false
let timer: { cancel: () => void } | undefined
// the transcript's width as last drawn, and frames left until it counts as
// settled: opening the pane narrows the transcript, and the board is built
// only once every message has re-laid out at the new width
let columns = 0
let unsettled = 0
const SETTLE_FRAMES = 3

const TRANSCRIPT = new Set(['UserMessage', 'AssistantMessage', 'ToolUse', 'ToolResult', 'ToolGroup', 'CommandOutput', 'TurnDuration', 'InfoNotice'])

function brief(value: unknown): string {
  if (value === undefined || value === null) return ''
  if (typeof value === 'string') return value
  if (typeof value === 'object') {
    const first = Object.values(value as Record<string, unknown>).find(v => typeof v === 'string')
    if (typeof first === 'string') return first
  }
  return JSON.stringify(value)
}

function firstLine(value: unknown): string {
  return brief(value).split('\n').find(line => line.trim() !== '') ?? ''
}

function plain(markdown: string): string {
  return markdown
    .replace(/```[^\n]*\n?/g, '')
    .replace(/^#{1,6}\s+/gm, '')
    .replace(/\*\*|__|`/g, '')
    .replace(/\[([^\]]+)\]\([^)]+\)/g, '$1')
}

// What a message's rows read as on the board: the text the engine draws for
// it, in a plain form close to the engine's own layout.
function textOf(e: RenderInput): { lead: string; text: string; spaced?: false } | undefined {
  const p = e.props as Record<string, unknown>
  switch (e.component) {
    case 'UserMessage':
      return { lead: '❯ ', text: String(p.text ?? '') }
    case 'AssistantMessage':
      return { lead: p.isFirstOfReply ? '⏺ ' : '  ', text: plain(String(p.text ?? '')) }
    case 'ToolUse': {
      const call = `${p.tool}(${firstLine(p.input)})`
      const out = firstLine(p.output)
      return { lead: '⏺ ', text: out ? `${call}\n  ⎿  ${out}` : call }
    }
    case 'ToolResult':
      return { lead: '  ⎿  ', text: firstLine(p.output), spaced: false }
    case 'ToolGroup': {
      const calls = (p.calls as { tool: string; input: unknown }[]) ?? []
      return { lead: '⏺ ', text: calls.map(c => `${c.tool}(${firstLine(c.input)})`).join('\n') }
    }
    case 'CommandOutput':
      return { lead: '  ⎿  ', text: String(p.text ?? ''), spaced: false }
    case 'TurnDuration':
      return { lead: '✻ ', text: `${p.word} for ${Math.round(Number(p.durationMs ?? 0) / 1000)}s` }
    case 'InfoNotice':
      return { lead: '⏺ ', text: String(p.text ?? '') }
  }
  return undefined
}

// The board: every message with rows on screen, in transcript order, as
// cells at the transcript's width (less its gutter and scrollbar, and the
// extra cell some terminals give the ⏺ bullet).
function buildGame(width: number): Game {
  const sites: Site[] = []
  for (const [id, s] of [...seen].sort((a, b) => a[1].seq - b[1].seq)) {
    if (!s.onScreen) continue
    const body = textOf(s.e)
    if (!body) continue
    const cells = siteCells(body.text, width, body.lead, s.onScreen.of, body.spaced !== false)
    sites.push({ id, seq: s.seq, cells, first: s.onScreen.first, last: s.onScreen.last })
  }
  return newGame(sites, width)
}

const PAC: Record<Dir, string> = { right: 'ᗧ', left: 'ᗤ', up: 'ᗢ', down: 'ᗜ' }

function stop() {
  timer?.cancel()
  timer = undefined
  game = undefined
  pending = false
}

export const register: Register = on => {
  on('session.start', async ($, e, next) => {
    const r = await next(e)
    await $.command.register({
      name: 'pacman',
      description: 'Play Pac-Man over the conversation on screen; Esc puts it back',
      immediate: true,
    }).catch(err => $.ui.log(`pacman: /pacman not registered: ${err}`))
    // a resumed session may bring the pane back without a game behind it
    if ((await $.ui.panes()).some(p => p.id === PANE)) await $.ui.close({ id: PANE })
    return r
  })

  on('command.run', { command: 'pacman' }, async ($, e) => {
    if (!e.presentation.isFullscreen && e.presentation.columns < 20) return { text: 'pacman needs a wider terminal' }
    stop()
    pending = true
    await $.ui.open({ id: PANE, title: 'pacman', focus: true, closeOnEscape: true, holdToasts: true, rows: 4, columns: 26 })
    // the frame clock builds the board on its first tick, once the transcript
    // has reported which rows it shows at the width the pane leaves it
    unsettled = SETTLE_FRAMES
    timer = $.clock.every(FRAME_MS, () => {
      if (unsettled > 0) {
        unsettled--
        return
      }
      if (pending) {
        pending = false
        game = buildGame(Math.max(20, columns - 4))
      } else if (game && game.state === 'playing') tick(game)
      $.ui.invalidate('ui.render')
    })
    $.ui.invalidate('ui.render')
    return { text: 'WASD or hjkl to move · Esc puts the conversation back' }
  })

  on('ui.close', { id: PANE }, async ($, e, next) => {
    stop()
    $.ui.invalidate('ui.render')
    return next(e)
  })

  on('ui.render', { component: 'Pane' }, async ($, e, next) => {
    if (e.requestId !== PANE || e.surface !== 'terminal') return next(e)
    const { Box, Button, Text } = await $.ui.resolve(e)
    const turn = (dir: Dir) => () => {
      if (game) game.want = dir
    }
    const keys: [string, Dir, string][] = [
      ['w', 'up', '↑'], ['a', 'left', '←'], ['s', 'down', '↓'], ['d', 'right', '→'],
      ['k', 'up', '↑'], ['h', 'left', '←'], ['j', 'down', '↓'], ['l', 'right', '→'],
    ]
    const status =
      !game ? 'ready'
      : game.state === 'won' ? `you ate it all! score ${game.score}`
      : game.state === 'over' ? `game over · score ${game.score}`
      : `score ${game.score} · ${'ᗧ'.repeat(game.lives)}`
    return (
      <Box flexDirection="column">
        <Text color="yellow" bold wrap="truncate-end">{`ᗧ ${status}`}</Text>
        <Box flexDirection="row" columnGap={1}>
          {keys.slice(0, 4).map(([key, dir, arrow]) => <Button key={`key:${key}`} label={arrow} hotkey={key} plain onPress={turn(dir)} />)}
        </Box>
        <Box flexDirection="row" columnGap={1}>
          {keys.slice(4).map(([key, dir, arrow]) => <Button key={`key:${key}`} label={arrow} hotkey={key} plain onPress={turn(dir)} />)}
        </Box>
        <Text dimColor wrap="truncate-end">{e.props.isFocused ? 'Esc: back to the chat' : 'click here to steer'}</Text>
      </Box>
    )
  })

  on('ui.render', async ($, e, next) => {
    if (!TRANSCRIPT.has(e.component) || e.surface !== 'terminal') return next(e)
    const onScreen = (e.props as { onScreen?: OnScreen | null }).onScreen ?? null
    const known = seen.get(e.requestId)
    seen.set(e.requestId, { e, seq: known?.seq ?? ++seq, onScreen })

    const width = e.viewport?.columns ?? 80
    if (width !== columns) {
      columns = width
      unsettled = SETTLE_FRAMES
      // a resize mid-game lays the board out anew at the new width
      if (game) {
        game = undefined
        pending = timer !== undefined
      }
    }
    const site = game?.sites.find(s => s.id === e.requestId)
    if (!game || !site) return next(e)
    if (onScreen) {
      site.first = onScreen.first
      site.last = onScreen.last
    } else {
      site.first = 1
      site.last = 0
    }

    const { Box, Text } = await $.ui.resolve(e)
    const chomp = game.tick % 4 < 2
    const rows = site.cells.map((cells, row) => {
      const line = cells.slice(0, game!.width)
      const marks = new Map<number, [string, string]>()
      for (const ghost of game!.ghosts) {
        if (ghost.pos.site === site.id && ghost.pos.row === row) marks.set(ghost.pos.col, ['ᗣ', ghost.color])
      }
      if (game!.pac.site === site.id && game!.pac.row === row && game!.state !== 'over') {
        marks.set(game!.pac.col, [chomp ? PAC[game!.dir] : '●', 'yellow'])
      }
      if (marks.size === 0) return <Text key={`r${row}`} wrap="truncate-end">{line.join('') || ' '}</Text>
      while (line.length <= Math.max(...marks.keys())) line.push(' ')
      const runs: RenderNode[] = []
      let from = 0
      for (const col of [...marks.keys()].sort((a, b) => a - b)) {
        if (col > from) runs.push(line.slice(from, col).join(''))
        const [glyph, color] = marks.get(col)!
        runs.push(<Text key={`m${col}`} color={color} bold>{glyph}</Text>)
        from = col + 1
      }
      if (from < line.length) runs.push(line.slice(from).join(''))
      return <Text key={`r${row}`} wrap="truncate-end">{runs}</Text>
    })
    return <Box flexDirection="column">{rows}</Box>
  })
}
