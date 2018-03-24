import React from 'react'
import ReactDOM from 'react-dom'
import { Button } from 'reactstrap'
import _ from 'lodash/fp'

export default function run_demo(root, channel) {
  ReactDOM.render(<Demo channel={channel}/>, root)
}

class Demo extends React.Component {
  constructor(props) {
    super(props)
    this.channel = props.channel
    this.state = {
      loaded: false,
      clicks: undefined,
      letters: undefined,
      completed: undefined,
      checkIndex: undefined,
      confirmIndex: undefined,
    }
    this.channel
      .join()
      .receive("ok", ({ game }) => {
        game['loaded'] = true
        this.setState(game)
      })
    this.toggle = this.toggle.bind(this)
    this.afterToggle = this.afterToggle.bind(this)
    this.reset = this.reset.bind(this)
  }

  reset() {
    this.channel
      .push('reset')
      .receive('ok', ({ game }) => this.setState(game))
  }

  afterToggle() {
    const { confirmIndex, checkIndex, letters, completed } = this.state
    if (!_.isNil(confirmIndex) && !_.isNil(checkIndex)) {
      const interval = setInterval(() => {
        this.channel
          .push('clear_indices')
          .receive('ok', ({ game }) => this.setState(game))
      }, 1000)
      setTimeout(() => clearInterval(interval), 1000)
    }
  }

  toggle(i) {
    const { clicks, confirmIndex, checkIndex } = this.state
    this.channel
      .push('toggle', { index: i })
      .receive('ok', ({ game }) => this.setState(game, this.afterToggle))
  }

  render() {
    const { letters, clicks, completed, checkIndex, confirmIndex, loaded } = this.state
    if (!loaded) return false
    return (
      <div className="memory-game">
        <div>clicks {clicks}</div>
        <Button onClick={this.reset}>Reset</Button>
        <div className="memory-game-grid">
          {this.state.letters.map((letter, i) =>
            <Side
              letter={letter}
              key={i}
              i={i}
              visible={checkIndex === i || confirmIndex === i}
              completed={completed.includes(letter)}
              toggle={this.toggle}
            />
          )}
        </div>
      </div>
    )
  }
}

function Side(props) {
  const { visible, completed, i, letter, toggle } = props
  return (
    <div className="memory-game-tile">
      {visible
        ? letter
        : completed
          ? 'complete'
          : <Button onClick={() => toggle(i)}>Click Me</Button>
      }
    </div>
  )
}
