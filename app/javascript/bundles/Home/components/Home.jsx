import PropTypes from "prop-types";
import React, { useState } from "react";
import YDKJS from "../components/ydkjs.jpeg";
import useTextStream from "../../useTextStream";

const questions = [
  "What is function scope in JavaScript?",
  "What is variable hoisting?",
  "What is the difference between == and ===?",
  "What is the difference between null and undefined?",
  "What is a callback?",
  "What is the event loop?",
  "What is the Object type?",
  "What is prototype inheritance?",
  "What is `this`?",
  "What is the difference between call and apply?",
];

const Home = (props) => {
  const [question, setQuestion] = useState(props.question);
  const [answer, setAnswer] = useState("");
  const [loading, setLoading] = useState(false);
  const [streamedAnswer, isStreaming] = useTextStream(answer);

  const ask = async (question) => {
    setLoading(true);
    const res = await fetch("/api/v1/question", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ question }),
    });
    const data = await res.json();
    setAnswer(data.answer);
    setLoading(false);
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    ask(question);
  };

  const handleRandom = async (e) => {
    e.preventDefault();
    const randomQuestion =
      questions[Math.floor(Math.random() * questions.length)];
    setQuestion(randomQuestion);
    ask(randomQuestion);
  };

  return (
    <div className="container mx-auto flex flex-col items-center justify-center">
      <div className="flex justify-center items-center mb-8">
        <img className="w-1/4" src={YDKJS} />
      </div>
      <h1 className="font-bold text-4xl mb-8">Ask YDKJS</h1>
      <div className="max-w-4xl">
        <p className=" text-slate-600">
          You Don't Know JS (YDKJS) is an open source series of books by Kyle
          Simpson that dive deep into fundamental concepts in JavaScript. It
          taught me a lot of what I knew and still know as a self-taught
          developer. This application allows you to ask all six books questions
          in natural language!
        </p>
        <div className="py-8 w-4xl">
          <form className="flex flex-row w-full">
            <textarea
              id="name"
              type="text"
              className="block min-h-[80px] w-full rounded-md border-0 py-1.5 text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 placeholder:text-gray-400 focus:ring-2 focus:ring-inset focus:ring-indigo-600 sm:text-sm sm:leading-6"
              value={question}
              onChange={(e) => setQuestion(e.target.value)}
            />
          </form>
        </div>
      </div>
      {loading && (
        <div className="max-w-4xl">
          <p className="text-slate-600">Asking Kyle...</p>
        </div>
      )}
      {!loading && !!streamedAnswer && (
        <div className="max-w-4xl">
          <p className="text-slate-600">
            <span className="font-bold font-mono">Answer: </span> {streamedAnswer}
          </p>
        </div>
      )}
      {!loading && !isStreaming ? (
        <div className="mt-6 flex items-center justify-end gap-x-6">
          <button
            type="submit"
            onClick={handleSubmit}
            className="rounded-md bg-indigo-600 px-3 py-2 text-sm font-semibold text-white shadow-sm hover:bg-indigo-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600"
          >
            Ask question
          </button>
          <button
            onClick={handleRandom}
            type="button"
            className="text-sm font-semibold leading-6 text-gray-900"
          >
            I'm feeling lucky
          </button>
        </div>
      ) : null}
    </div>
  );
};

Home.propTypes = {
  question: PropTypes.string.isRequired, // this is passed from the Rails view
};

export default Home;
