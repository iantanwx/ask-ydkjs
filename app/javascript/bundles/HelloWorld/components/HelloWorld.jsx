import PropTypes from 'prop-types';
import React, { useState } from 'react';
import style from './HelloWorld.module.css';

const HelloWorld = (props) => {
  const [question, setQuestion] = useState(props.name);
  const ask = () => {
    fetch('/api/v1/question', { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ question }) });
  }
  return (
    <div>
      <h3>Hello, {name}!</h3>
      <hr />
      <form>
        <label className={style.bright} htmlFor="name">
          Say hello to:
          <input id="name" type="text" value={question} onChange={(e) => setQuestion(e.target.value)} />
        </label>
      </form>
      <button onClick={ask}>Ask</button>
    </div>
  );
};

HelloWorld.propTypes = {
  name: PropTypes.string.isRequired, // this is passed from the Rails view
};

export default HelloWorld;
