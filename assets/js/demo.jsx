import React, { Component } from 'react'
import ReactDOM from 'react-dom'
import cx from 'classnames'

export default function run_demo(root, channel) {
  ReactDOM.render(<Demo channel={channel}/>, root)
}

const colors = {
  RED: 'RED',
  YELLOW: 'YELLOW',
}

class Demo extends Component {
  constructor(props) {
    super(props)
    this.channel = props.channel
    this.state = {
      loaded: false,
      turn: undefined,
      board: undefined,
      winner: undefined,
      role: undefined,
    }
    this.channel
      .join()
      .receive('ok', ({ game }) => {
        console.log(game)
        this.setState(Object.assign({}, game, { loaded: true }))
      })
    this.channel
      .on('update', game => console.log(game))
    this.selectColumn = this.selectColumn.bind(this)
  }

  selectColumn(columnIndex) {
    return () => {
      const { board, turn } = this.state
      this.channel.push('move', { column_index: columnIndex })
    }
  }

  render() {
    const { loaded, board, winner, role, turn } = this.state
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
          {board.map((row, rowIndex) =>
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
