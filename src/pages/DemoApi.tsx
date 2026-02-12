import { useQuery } from "@tanstack/react-query";
import PhoenixChannelDemo from "../components/PhoenixChannelDemo";

type DemoTodo = {
  userId: number;
  id: number;
  title: string;
  completed: boolean;
};

const demoEndpoint = "https://jsonplaceholder.typicode.com/todos/1";

const fetchDemoTodo = async (): Promise<DemoTodo> => {
  const response = await fetch(demoEndpoint);

  if (!response.ok) {
    throw new Error(`Request failed (${response.status})`);
  }

  return response.json();
};

export default function DemoApi() {
  const { data, error, isLoading, isFetching, refetch } = useQuery({
    queryKey: ["demo", "todo"],
    queryFn: fetchDemoTodo,
  });

  const errorMessage = error instanceof Error ? error.message : "Unknown error";

  return (
    <section className="space-y-10">
      <header className="space-y-3">
        <p className="text-xs font-semibold uppercase tracking-[0.35em] text-emerald-700">Demo</p>
        <h1 className="text-3xl font-semibold text-slate-900 sm:text-4xl">
          TanStack Query in action
        </h1>
        <p className="max-w-2xl text-sm text-slate-600 sm:text-base">
          This page fetches server data via TanStack Query. Swap the endpoint later with your real
          API.
        </p>
      </header>

      <div className="rounded-2xl border border-slate-200 bg-white/90 p-6 shadow-sm shadow-slate-200/60">
        <div className="flex flex-wrap items-center justify-between gap-4">
          <div className="space-y-1">
            <p className="text-sm font-medium text-slate-700">Endpoint</p>
            <p className="text-sm text-slate-500">{demoEndpoint}</p>
          </div>
          <button
            type="button"
            onClick={() => refetch()}
            className="rounded-full border border-emerald-200 bg-emerald-50 px-4 py-2 text-sm font-semibold text-emerald-700 transition hover:border-emerald-300 hover:bg-emerald-100"
          >
            Refresh
          </button>
        </div>

        <div className="mt-6 grid gap-4 sm:grid-cols-2">
          <div className="rounded-xl border border-slate-200 bg-slate-50/80 p-4">
            <p className="text-xs font-semibold uppercase tracking-[0.2em] text-slate-500">
              Query Status
            </p>
            <div className="mt-3 flex flex-wrap gap-2">
              <span className="rounded-full bg-slate-900 px-3 py-1 text-xs font-semibold text-white">
                {isLoading ? "Loading" : "Ready"}
              </span>
              <span className="rounded-full bg-slate-100 px-3 py-1 text-xs font-semibold text-slate-600">
                {isFetching ? "Fetching" : "Idle"}
              </span>
              {error ? (
                <span className="rounded-full bg-rose-100 px-3 py-1 text-xs font-semibold text-rose-700">
                  Error
                </span>
              ) : null}
            </div>
            {error ? <p className="mt-3 text-xs text-rose-600">{errorMessage}</p> : null}
          </div>

          <div className="rounded-xl border border-slate-200 bg-slate-50/80 p-4">
            <p className="text-xs font-semibold uppercase tracking-[0.2em] text-slate-500">
              Response Snapshot
            </p>
            <dl className="mt-3 space-y-2 text-sm text-slate-700">
              <div className="flex items-center justify-between gap-4">
                <dt className="text-slate-500">Title</dt>
                <dd className="font-semibold text-slate-900">{data?.title ?? "-"}</dd>
              </div>
              <div className="flex items-center justify-between gap-4">
                <dt className="text-slate-500">Completed</dt>
                <dd className="font-semibold text-slate-900">
                  {data ? (data.completed ? "Yes" : "No") : "-"}
                </dd>
              </div>
              <div className="flex items-center justify-between gap-4">
                <dt className="text-slate-500">User</dt>
                <dd className="font-semibold text-slate-900">{data?.userId ?? "-"}</dd>
              </div>
            </dl>
          </div>
        </div>
      </div>

      <PhoenixChannelDemo />
    </section>
  );
}
