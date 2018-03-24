import React, { Component } from 'react'
import ReactDOM from 'react-dom'
import cx from 'classnames'
import { findLastIndex } from 'ramda'

export default function run_demo(root, channel) {
  ReactDOM.render(<Demo channel={channel}/>, root)
}

const colors = {
  RED: 'RED',
  YELLOW: 'YELLOW',
}

const DEFAULT_GRID = [
  [undefined, undefined, undefined, undefined, undefined, undefined, undefined],
  [undefined, undefined, undefined, undefined, undefined, undefined, undefined],
  [undefined, undefined, undefined, undefined, undefined, undefined, undefined],
  [undefined, undefined, undefined, undefined, undefined, undefined, undefined],
  [undefined, colors.YELLOW, undefined, undefined, undefined, undefined, undefined],
  [undefined, colors.YELLOW, undefined, undefined, colors.RED, undefined, undefined],
]

class Demo extends Component {
  constructor(props) {
    super(props)
    this.channel = props.channel
    this.state = {
      loaded: false,
      turn: colors.RED,
      grid: DEFAULT_GRID,
      winner: undefined,
      role: colors.RED,
    }
    this.channel
      .join()
      .receive("ok", ({ game }) => {
        game['loaded'] = true
        this.setState(game)
      })
    this.selectColumn = this.selectColumn.bind(this)
  }

  selectColumn(columnIndex) {
    return () => {
      const { grid, turn } = this.state
      const rowIndex = findLastIndex(row => !row[columnIndex], grid)
      grid[rowIndex][columnIndex] = turn
      this.setState({ turn: turn === colors.RED ? colors.YELLOW : colors.RED })
    }
  }

  render() {
    const { loaded, grid, winner, role, turn } = this.state
    if (!loaded) return false
    return (
      <div>
        <div className="overview">
          {!!winner &&
            `Game over, ${role === winner ? 'you win' : 'the opponent wins'}!`
          }
          {!winner && (turn === role ? 'Your turn' : "Opponent's turn")}
        </div>
        <div className="grid">
          {grid.map((row, rowIndex) =>
            <div className="row" key={`row-${rowIndex}`}>
              {row.map((coin, columnIndex) =>
                <div
                  key={`coin-${columnIndex}-${rowIndex}`}
                  onClick={rowIndex === 0 && !coin ? this.selectColumn(columnIndex) : undefined}
                  className={cx(
                    'coin',
                    { 'is-selectable': rowIndex === 0 && !coin },
                    { 'is-yellow': coin === colors.YELLOW, 'is-red': coin === colors.RED }
                  )}
                />
              )}
            </div>
          )}
        </div>
      </div>
    )
  }
}
