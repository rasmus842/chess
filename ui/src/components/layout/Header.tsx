import { Link } from "react-router-dom";

export default function Header() {
  return (
    <header className="border-b border-slate-200 bg-white/80 px-4 py-3 backdrop-blur">
      <div className="mx-auto flex max-w-6xl items-center justify-between gap-4">
        <Link className="text-lg font-semibold tracking-tight text-slate-950" to="/">
          Chess UI
        </Link>
        <nav className="flex flex-wrap items-center gap-4 text-sm text-slate-600">
          <Link className="transition hover:text-slate-950" to="/game/new">
            New game
          </Link>
          <Link className="transition hover:text-slate-950" to="/auth/signup">
            Sign up
          </Link>
          <Link className="transition hover:text-slate-950" to="/auth/login">
            Login
          </Link>
          <Link className="transition hover:text-slate-950" to="/auth/verify">
            Verify
          </Link>
        </nav>
      </div>
    </header>
  );
}
