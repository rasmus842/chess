import { NavLink, Route, Routes } from "react-router-dom";
import DemoApi from "./pages/DemoApi";
import Home from "./pages/Home";
import DemoSocket from "./pages/DemoSocket";

const navLinkClass = ({ isActive }: { isActive: boolean }) =>
  [
    "rounded-full px-4 py-2 text-sm font-semibold transition",
    isActive ? "bg-slate-900 text-white" : "text-slate-600 hover:bg-white/70 hover:text-slate-900",
  ].join(" ");

function App() {
  return (
    <div className="min-h-screen bg-[radial-gradient(ellipse_at_top,_var(--tw-gradient-stops))] from-amber-50 via-slate-50 to-emerald-50 text-slate-900">
      <div className="mx-auto flex min-h-screen max-w-5xl flex-col gap-10 px-6 py-10">
        <header className="flex flex-wrap items-center justify-between gap-4">
          <div className="flex items-center gap-3">
            <span className="h-3 w-3 rounded-full bg-emerald-500 shadow-sm shadow-emerald-300" />
            <div>
              <p className="text-sm font-semibold uppercase tracking-[0.2em] text-slate-500">
                React SPA Template
              </p>
              <p className="text-xs text-slate-400">Ready-to-clone UI foundation</p>
            </div>
          </div>
          <nav className="flex items-center gap-2 rounded-full border border-slate-200 bg-white/70 p-1 shadow-sm">
            <NavLink to="/" className={navLinkClass}>
              Home
            </NavLink>
            <NavLink to="/demo" className={navLinkClass}>
              Demo
            </NavLink>
          </nav>
        </header>

        <main className="flex-1 rounded-3xl border border-slate-200 bg-white/70 p-6 shadow-xl shadow-slate-200/60 backdrop-blur sm:p-10 animate-[fade-up_700ms_ease-out]">
          <Routes>
            <Route path="/" element={<Home />} />
            <Route path="/demo" element={<DemoApi />} />
            <Route path="/demo-socket" element={<DemoSocket />} />
          </Routes>
        </main>

        <footer className="flex flex-wrap items-center justify-between gap-3 text-xs text-slate-500">
          <p>Build with Vite, React, Tailwind, and TanStack Query.</p>
          <p>Update routes or data sources as your project grows.</p>
        </footer>
      </div>
    </div>
  );
}

export default App;
