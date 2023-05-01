import { useState, useEffect } from "react";

const useTextStream = (text) => {
  const words = text.split(" ");
  const [currentText, setCurrentText] = useState("");
  const [wordIndex, setWordIndex] = useState(0);

  useEffect(() => {
    setCurrentText("");
    setWordIndex(0);
  }, [text]);

  useEffect(() => {
    if (!text || !words.length) return;
    setCurrentText((t) => `${t} ${words[wordIndex] ? words[wordIndex] : ""}`);
    if (wordIndex < words.length - 1) {
      setTimeout(() => {
        setWordIndex((i) => i + 1);
      }, Math.random() * 50 + 50);
    }
  }, [text, wordIndex]);

  return [currentText, wordIndex < words.length - 1];
};

export default useTextStream;
