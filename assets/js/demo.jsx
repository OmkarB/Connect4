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

const Board = ({ board, selectColumn, turn, winner, role }) => (
  <div className="board">
    {board.map((row, rowIndex) =>
      <div className="row" key={`row-${rowIndex}`}>
        {row.map((coin, columnIndex) => {
          const selectable = turn === role && rowIndex === 0 && !coin
          return (
            <div
              key={`coin-${columnIndex}-${rowIndex}`}
              onClick={selectable ? selectColumn(columnIndex) : undefined}
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
)

const Message = ({ message }) => (
  <div className="message">
    {message.role}: {message.body}
  </div>
)

class Chatroom extends Component {
  constructor(props) {
    super(props)
    this.state = {
      body: '',
    }
    this.handleChange = this.handleChange.bind(this)
    this.handleSubmit = this.handleSubmit.bind(this)
  }

  handleSubmit(event) {
    if (event.keyCode !== 13) return
    const { channel } = this.props
    const { body } = this.state
    channel.push('msg', { body })
    this.setState({ body: '' })
  }

  handleChange(event) {
    this.setState({
      body: event.target.value,
    })
  }

  render() {
    const { messages } = this.props
    const { body } = this.state
    return (
      <div className="chatroom">
        <div className="messages">{messages.map(message => <Message message={message}/>)}</div>
        <input onChange={this.handleChange} onKeyDown={this.handleSubmit} value={body}/>
      </div>
    )
  }
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
      messages: undefined,
    }
    this.channel
      .join()
      .receive('ok', ({ messages, role, game }) => {
        this.setState({
          turn: game.turn,
          board: game.board,
          winner: game.winner,
          loaded: true,
          role,
          messages,
        })
      })
    this.channel.on('update_game', ({ game }) => this.setState(game))
    this.channel.on('update_messages', ({ messages }) => this.setState({ messages }))
    this.selectColumn = this.selectColumn.bind(this)
  }

  selectColumn(columnIndex) {
    return () => {
      const { board, turn } = this.state
      this.channel.push('move', { column_index: columnIndex })
    }
  }

  render() {
    const { messages, loaded, board, winner, role, turn } = this.state
    if (!loaded) return false
    return (
      <div>
        <div className="overview">
          {!!winner && `Game over, ${winner} wins!`}
          {role !== ROLE.SPECTATOR && !winner && (turn === role ? 'Your turn' : "Opponent's turn")}
        </div>
        <div className="game-container">
          <Board
            turn={turn}
            winner={winner}
            role={role}
            board={board}
            selectColumn={this.selectColumn}
          />
          <Chatroom channel={this.channel} messages={messages}/>
        </div>
      </div>
    )
  }
}
