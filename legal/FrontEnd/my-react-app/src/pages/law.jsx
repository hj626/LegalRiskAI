import { Link } from "react-router-dom";
import { useState } from "react";

export default function Law() {
  const [lawInput, setLawInput] = useState("");
  const [msg, setMsg] = useState("");

  const saveLaw = async () => {
    if (!lawInput.trim()) {
      setMsg("내용을 입력하세요.");
      return;
    }

    try {
      const res = await fetch("/api/law/save", {   
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ law_input: lawInput }),
      });

      if (!res.ok) {

        if (res.status === 401) {
          setMsg("로그인이 필요합니다.");
          return;
        }
        throw new Error();
      }

      const lawCode = await res.json();
      setMsg(`저장 완료! law_code = ${lawCode}`);
      setLawInput("");
    } catch {
      setMsg("저장 실패");
    }
  };

  return (
    <div style={{ padding: 24, maxWidth: 600 }}>
      <h2>법적위험</h2>

      <textarea
        value={lawInput}
        onChange={(e) => setLawInput(e.target.value)}
        rows={8}
        placeholder="사건 내용을 입력하세요..."
        style={{ width: "100%", padding: 12 }}
      />

      <div style={{ marginTop: 12 }}>
        <button onClick={saveLaw}>저장</button>
        <span style={{ marginLeft: 12 }}>
	      <a href="/">홈으로</a>
        </span>
      </div>

      {msg && <p style={{ marginTop: 12 }}>{msg}</p>}
    </div>
  );
}
