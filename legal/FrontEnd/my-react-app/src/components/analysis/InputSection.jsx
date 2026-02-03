import React from "react";

/**
 * 입력 섹션 컴포넌트
 * - 사건 내용 입력 textarea
 * - 글자수 표시
 * 
 * Props:
 *   - value: 입력된 텍스트
 *   - onChange: 텍스트 변경 시 호출되는 함수
 *   - placeholder: placeholder 텍스트 (선택)
 */

export default function InputSection({ value, onChange, placeholder }) {
    const defaultPlaceholder = `사건의 구체적인 내용을 자유롭게 작성해주세요.
(예: 계약 일시, 당사자, 피해 금액, 현재 상황 등)`;

    return (
        <div className="bg-white rounded-[18px] shadow-[0_2px_8px_rgba(0,0,0,0.06)] overflow-hidden p-7 flex flex-col h-full">
            {/* 섹션 헤더 */}
            <div className="flex items-center gap-2.5 text-[17px] font-semibold text-slate-800 mb-4">
                <span className="text-xl text-blue-500">✏️</span>
                <span>사실관계 입력</span>
            </div>

            {/* 텍스트 입력창 */}
            <textarea
                className="
          w-full flex-1 min-h-[400px] p-4.5 
          border border-slate-200 rounded-xl 
          text-[15px] leading-relaxed resize-y bg-slate-50 
          transition-all 
          focus:outline-none focus:border-blue-400 focus:bg-white 
          focus:shadow-[0_0_0_3px_rgba(59,130,246,0.1)]
        "
                placeholder={placeholder || defaultPlaceholder}
                value={value}
                onChange={(e) => onChange(e.target.value)}
            />

            {/* 글자수 표시 */}
            <div className="flex justify-between items-center mt-3">
                <span className="text-xs text-slate-500">
                    {value.length}자 입력됨
                </span>
                {value.length < 50 && value.length > 0 && (
                    <span className="text-xs text-amber-500">
                        최소 50자 이상 입력해주세요
                    </span>
                )}
            </div>
        </div>
    );
}
