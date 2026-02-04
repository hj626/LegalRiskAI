// 탭스에게 넘겨줄 결과를 주는곳

import { Link } from "react-router-dom";
import { useState } from "react";

export default function Jogi() {
  const [jogiInput, setJogiInput] = useState("");
  const [jogiOutput, setJogiOutput] = useState("");
  const [jogiWinrate, setJogiWinrate] = useState(""); 
  const [jogiMark, setJogiMark] = useState(0);
  const [msg, setMsg] = useState("");
  const [loading, setLoading] = useState(false); // 로딩 상태 추가


   // 🔥 AI 분석 함수 추가 (새로 추가된 부분)
  const analyzeAI = async () => {
    if (!jogiInput.trim()) {
      setMsg("사연을 입력하세요.");
      return;
    }

    setLoading(true);
    setMsg("AI 분석 중...");

    try {
      const res = await fetch("/api/ai/analyze", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ caseText: jogiInput }),
      });

      if (!res.ok) throw new Error();

      const result = await res.json();
      
      // 결과를 자동으로 채워넣기
      setJogiWinrate(result.winRate || "");
      setJogiOutput(
        `AI 분석 결과\n\n` +
        `승소율: ${result.winRate}%\n` +
        `형량: ${result.sentence || '해당없음'}\n` +
        `벌금: ${result.fine || '해당없음'}\n` +
        `위험도: ${result.risk || '해당없음'}\n\n` +
        `피드백: ${result.feedback || ''}`
      );
      
      setMsg("AI 분석 완료!");
    } catch {
      setMsg("AI 분석 실패");
    } finally {
      setLoading(false);
    }
  };





// 기존함수
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
          jogi_output: jogiOutput,
          jogi_mark: jogiMark,
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

        {/* 🔥 AI 분석 버튼 추가 (한 줄만 추가) */}
      <button onClick={analyzeAI} disabled={loading} style={{ width: "100%", marginTop: 8 }}>
        {loading ? "분석 중..." : "AI 분석"}
      </button>


      {/* 분석 결과 */}
        <textarea
        value={jogiOutput}
        onChange={(e) => setJogiOutput(e.target.value)}
        rows={8}
        placeholder="AI 분석 결과..."
        style={{ width: "100%", padding: 12, marginTop: 8 }}
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

      <label style={{ display: "block", marginTop: 8 }}>
        <input
          type="checkbox"
          checked={jogiMark === 1}
          onChange={(e) => setJogiMark(e.target.checked ? 1 : 0)}
        />
        즐겨찾기
      </label>

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
