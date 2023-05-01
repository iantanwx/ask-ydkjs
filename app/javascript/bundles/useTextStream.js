import { useState, useEffect, useRef } from "react";

const useTextStream = (text) => {
  const words = text.split(" ");
  const [currentText, setCurrentText] = useState("");
  const [wordIndex, setWordIndex] = useState(0);
  const activeText = useRef(text);

  useEffect(() => {
    setCurrentText("");
    setWordIndex(0);
    activeText.current = text;
  }, [text]);

  useEffect(() => {
    if (!text || !words.length) return;

    const updateWord = () => {
      if (activeText.current === text) {
        setCurrentText(
          (t) => `${t} ${words[wordIndex] ? words[wordIndex] : ""}`
        );
        if (wordIndex < words.length - 1) {
          setWordIndex((i) => i + 1);
        }
      }
    };

    const timerId = setTimeout(updateWord, Math.random() * 50 + 50);

    // Cleanup function to avoid the race condition
    return () => {
      clearTimeout(timerId);
    };
  }, [text, wordIndex]);

  return [currentText, wordIndex < words.length - 1];
};

export default useTextStream;
