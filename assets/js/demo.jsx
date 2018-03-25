import React, { Component } from 'react'
import ReactDOM from 'react-dom'
import cx from 'classnames'

export default function run_demo(root, channel) {
  ReactDOM.render(<Demo channel={channel}/>, root)
}

const COLOR = {
  RED: 'red',
  YELLOW: 'yellow',
}

const ROLE = {
  RED: COLOR.RED,
  YELLOW: COLOR.YELLOW,
  SPECTATOR: 'spectator',
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
      .receive('ok', ({ role, game }) => {
        this.setState({
          turn: game.turn,
          board: game.board,
          winner: game.winner,
          loaded: true,
          role,
        })
      })
    this.channel.on('update', ({ game }) => this.setState(game))
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
          {!!winner && `Game over, ${winner} wins!`}
          {role !== ROLE.SPECTATOR && !winner && (turn === role ? 'Your turn' : "Opponent's turn")}
        </div>
        <div className="board-container">
          <div className="board">
            {board.map((row, rowIndex) =>
              <div className="row" key={`row-${rowIndex}`}>
                {row.map((coin, columnIndex) => {
                  const selectable = turn === role && rowIndex === 0 && !coin
                  return (
                    <div
                      key={`coin-${columnIndex}-${rowIndex}`}
                      onClick={selectable ? this.selectColumn(columnIndex) : undefined}
                      className={cx(
                        'coin',
                        { 'is-selectable': selectable },
                        { 'is-yellow': coin === COLOR.YELLOW, 'is-red': coin === COLOR.RED }
                      )}
                    />
                  )
                })}
              </div>
            )}
          </div>
        </div>
      </div>
    )
  }
}
