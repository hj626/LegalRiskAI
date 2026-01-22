import { Link } from "react-router-dom";
import { useState } from "react";

export default function Yusa() {
  const [yusaInput, setYusaInput] = useState("");
  const [yusaMark, setYusaMark] = useState(0);
  const [msg, setMsg] = useState("");

  const saveYusa = async () => {
    if (!yusaInput.trim()) {
      setMsg("내용을 입력하세요.");
      return;
    }

    try {
      const res = await fetch("/api/yusa/save", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          yusa_input: yusaInput,
          yusa_mark: yusaMark,
        }),
      });

      if (!res.ok) throw new Error();

      const yusaCode = await res.json();
      setMsg(`저장 완료! yusa_code = ${yusaCode}`);
      setYusaInput("");
      setYusaMark(0);
    } catch {
      setMsg("저장 실패");
    }
  };

  return (
    <div style={{ padding: 24, maxWidth: 600 }}>
      <h2>유사위험</h2>

      <textarea
        value={yusaInput}
        onChange={(e) => setYusaInput(e.target.value)}
        rows={8}
        placeholder="사건 내용을 입력하세요..."
        style={{ width: "100%", padding: 12 }}
      />

      <label style={{ display: "block", marginTop: 8 }}>
        <input
          type="checkbox"
          checked={yusaMark === 1}
          onChange={(e) => setYusaMark(e.target.checked ? 1 : 0)}
        />
        즐겨찾기
      </label>

      <div style={{ marginTop: 12 }}>
        <button onClick={saveYusa}>저장</button>
        <span style={{ marginLeft: 12 }}>
	      <a href="/">홈으로</a>
        </span>
      </div>

      {msg && <p style={{ marginTop: 12 }}>{msg}</p>}
    </div>
  );
}