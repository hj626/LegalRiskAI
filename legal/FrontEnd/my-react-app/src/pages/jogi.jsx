import { Link } from "react-router-dom";
import { useState } from "react";

export default function Jogi() {
  const [jogiInput, setJogiInput] = useState("");
  const [jogiWinrate, setJogiWinrate] = useState(""); 
  const [msg, setMsg] = useState("");

  const saveJogi = async () => {
    if (!jogiInput.trim()) {
      setMsg("내용을 입력하세요.");
      return;
    }

    if (!jogiWinrate) {
      setMsg("승소 확률을 입력하세요.");
      return;
    }

    try {
      const res = await fetch("/api/jogi/save", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          jogi_input: jogiInput,
          jogi_winrate: Number(jogiWinrate), 
        }),
      });

      if (!res.ok) throw new Error();

      const jogiCode = await res.json();
      setMsg(`저장 완료! jogi_code = ${jogiCode}`);
      setJogiInput("");
      setJogiWinrate("");
    } catch {
      setMsg("저장 실패");
    }
  };

  return (
    <div style={{ padding: 24, maxWidth: 600 }}>
      <h2>조기위험</h2>

      {/* 사건 내용 */}
      <textarea
        value={jogiInput}
        onChange={(e) => setJogiInput(e.target.value)}
        rows={8}
        placeholder="사건 내용을 입력하세요..."
        style={{ width: "100%", padding: 12 }}
      />

      {/* 승소 확률 */}
      <input
        type="number"
        value={jogiWinrate}
        onChange={(e) => setJogiWinrate(e.target.value)}
        placeholder="승소 확률 (%)"
        min="0"
        max="100"
        style={{ width: "100%", padding: 12, marginTop: 12 }}
      />

      <div style={{ marginTop: 12 }}>
        <button onClick={saveJogi}>저장</button>
        <span style={{ marginLeft: 12 }}>
	      <a href="/">홈으로</a>
        </span>
      </div>

      {msg && <p style={{ marginTop: 12 }}>{msg}</p>}
    </div>
  );
}
