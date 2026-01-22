import { Link, NavLink } from "react-router-dom";

const navItems = [
  { to: "/boonjang", label: "분쟁유형", icon: "⚖️" },
  { to: "/law", label: "법적위험", icon: "⚠️" },
  { to: "/yusa", label: "유사판례", icon: "🔍" },
  { to: "/jogi", label: "조기위험", icon: "💡" },
];

export default function Header() {
  return (
    <header className="bg-white border-b border-gray-200">
      <div className="max-w-7xl mx-auto px-6">
        <div className="flex h-16 items-center gap-8">
          {/* 로고 영역 */}
          <Link
            to="/"
            className="flex items-center gap-2 hover:opacity-90 transition"
          >
            <div className="w-9 h-9 rounded-2xl bg-blue-600 flex items-center justify-center shadow-sm">
              <span className="text-xl text-white">⚖️</span>
            </div>
            <span className="text-xl font-semibold text-gray-900 tracking-tight">
              LegalRisk <span className="text-blue-600">AI</span>
            </span>
          </Link>

          {/* 네비게이션 영역 */}
          <nav className="flex-1 flex items-center gap-2 ml-6">
            {navItems.map((item) => (
              <NavLink
                key={item.to}
                to={item.to}
                className={({ isActive }) =>
                  [
                    "flex items-center gap-2 px-3 py-2 rounded-xl text-sm md:text-base",
                    "transition-colors",
                    isActive
                      ? "bg-blue-50 text-blue-700 font-semibold"
                      : "text-gray-600 hover:bg-gray-50 hover:text-gray-900",
                  ].join(" ")
                }
              >
                <span className="text-lg">{item.icon}</span>
                <span>{item.label}</span>
              </NavLink>
            ))}
          </nav>

          {/* 로그인/회원가입 영역 */}
          <div className="flex items-center gap-2">
            <Link
              to="/login"
              className="px-3 py-2 text-xs md:text-sm text-gray-600 rounded-md
                         hover:bg-gray-50 hover:text-blue-600 transition-colors"
            >
              로그인
            </Link>
            <Link
              to="/client/join"
              className="px-4 py-2 text-xs md:text-sm font-medium text-white
                         bg-blue-600 rounded-xl shadow-sm
                         hover:bg-blue-700 hover:shadow-md
                         active:scale-[0.98]
                         transition-transform transition-shadow transition-colors"
            >
              회원가입
            </Link>
          </div>
        </div>
      </div>
    </header>
  );
}
