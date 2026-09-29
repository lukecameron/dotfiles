import { describe, expect, mock, test, tier } from 'claude-code/testing'

tier('user')

describe('register', () => {
  test('/pacman opens a pane that takes the keys and closes on Escape', async ($, on) => {
    const opened: { id: string; focus?: true; closeOnEscape?: true }[] = []
    mock.clock(on)
    on('session.start', ($, e) => ({ cwd: e.cwd }))
    on('command.register', ($, e) => ({ value: { command: e.name } }))
    on('ui.panes', () => ({ value: [] }))
    on('ui.invalidate', () => ({ value: undefined }))
    on('ui.open', ($, e) => {
      opened.push(e)
      return { value: { isPlaced: true } }
    })

    await $.session.start({ surface: 'terminal', isInteractive: true, cwd: '/work' })
    const { text } = await $.command.run({
      command: 'pacman',
      args: '',
      origin: { kind: 'composer' },
      presentation: { isFullscreen: true, columns: 120 },
    })

    expect(opened).toEqual([expect.objectContaining({ id: 'pacman', focus: true, closeOnEscape: true })])
    expect(text).toContain('Esc')
  })
})
