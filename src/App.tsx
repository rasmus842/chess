import { useState } from "react";
import reactLogo from "./assets/react.svg";
import viteLogo from "/vite.svg";

function App() {
  const [count, setCount] = useState(0);

  return (
    <div className="min-h-screen w-full bg-gradient-to-br from-slate-950 via-slate-900 to-slate-950 text-slate-100">
      <div className="mx-auto flex min-h-screen max-w-4xl flex-col items-center justify-center gap-6 px-6 py-12 text-center">
        <div className="flex items-center justify-center gap-6">
          <a
            href="https://vite.dev"
            target="_blank"
            className="transition hover:drop-shadow-[0_0_2em_#646cffaa]"
          >
            <img src={viteLogo} className="h-24 w-24 p-6" alt="Vite logo" />
          </a>
          <a
            href="https://react.dev"
            target="_blank"
            className="transition hover:drop-shadow-[0_0_2em_#61dafbaa]"
          >
            <img
              src={reactLogo}
              className="h-24 w-24 p-6 motion-safe:animate-spin"
              alt="React logo"
            />
          </a>
        </div>
        <h1 className="text-4xl font-semibold tracking-tight sm:text-5xl">Vite + React</h1>
        <div className="flex flex-col items-center gap-3 rounded-2xl border border-slate-800 bg-slate-900/60 px-6 py-5 shadow-lg shadow-slate-950/40">
          <button
            onClick={() => setCount((count) => count + 1)}
            className="rounded-lg border border-slate-700 bg-slate-950/60 px-4 py-2 text-sm font-semibold text-slate-100 transition hover:border-indigo-400 hover:text-indigo-100 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-indigo-400"
          >
            count is {count}
          </button>
          <p className="text-sm text-slate-300">
            Edit{" "}
            <code className="rounded bg-slate-950/70 px-2 py-0.5 text-slate-100">src/App.tsx</code>{" "}
            and save to test HMR
          </p>
        </div>
        <p className="text-sm text-slate-400">Click on the Vite and React logos to learn more</p>
      </div>
    </div>
  );
}

export default App;
