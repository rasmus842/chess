export default function Home() {
  return (
    <section className="space-y-10">
      <div className="space-y-4">
        <p className="text-xs font-semibold uppercase tracking-[0.35em] text-emerald-700">
          React SPA Template
        </p>
        <h1 className="text-4xl font-semibold text-slate-900 sm:text-5xl">
          Start fast, ship clean UI
        </h1>
        <p className="max-w-2xl text-base text-slate-600 sm:text-lg">
          A barebones React SPA starter with routing, server state, and testing tools ready for your
          next UI project.
        </p>
      </div>
      <div className="grid gap-4 sm:grid-cols-2">
        <div className="rounded-2xl border border-slate-200 bg-white/80 p-5 shadow-sm shadow-slate-200/50">
          <h2 className="text-lg font-semibold text-slate-900">Routes</h2>
          <p className="mt-2 text-sm text-slate-600">
            Home and demo pages are wired with React Router.
          </p>
        </div>
        <div className="rounded-2xl border border-slate-200 bg-white/80 p-5 shadow-sm shadow-slate-200/50">
          <h2 className="text-lg font-semibold text-slate-900">Server State</h2>
          <p className="mt-2 text-sm text-slate-600">
            TanStack Query powers data fetching and caching.
          </p>
        </div>
        <div className="rounded-2xl border border-slate-200 bg-white/80 p-5 shadow-sm shadow-slate-200/50">
          <h2 className="text-lg font-semibold text-slate-900">Styling</h2>
          <p className="mt-2 text-sm text-slate-600">
            Tailwind CSS is configured with a minimal, intentional layout.
          </p>
        </div>
        <div className="rounded-2xl border border-slate-200 bg-white/80 p-5 shadow-sm shadow-slate-200/50">
          <h2 className="text-lg font-semibold text-slate-900">Testing</h2>
          <p className="mt-2 text-sm text-slate-600">
            Playwright and React Testing Library are ready when you are.
          </p>
        </div>
      </div>
    </section>
  );
}
