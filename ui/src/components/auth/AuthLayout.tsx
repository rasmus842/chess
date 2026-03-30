import type { ReactNode } from "react";

type AuthLayoutProps = {
  title: string;
  children: ReactNode;
};

export default function AuthLayout({ title, children }: AuthLayoutProps) {
  return (
    <section className="relative min-h-screen overflow-hidden bg-[#f4efe6] px-4 py-10 text-stone-900 sm:px-6 sm:py-14">
      <div className="pointer-events-none absolute inset-0 bg-[radial-gradient(circle_at_top,rgba(255,248,235,0.94),rgba(244,239,230,0.82)_38%,rgba(230,221,207,0.38)_100%)]" />
      <div className="pointer-events-none absolute inset-x-6 inset-y-8 rounded-[2rem] border border-white/40 bg-[linear-gradient(rgba(110,94,69,0.06)_1px,transparent_1px),linear-gradient(90deg,rgba(110,94,69,0.06)_1px,transparent_1px)] bg-[size:2.75rem_2.75rem] opacity-40 sm:inset-x-10" />

      <div className="relative mx-auto flex min-h-[calc(100vh-5rem)] max-w-xl items-center justify-center">
        <div className="w-full rounded-[2rem] border border-[#d9cbb5] bg-[rgba(255,251,245,0.88)] p-6 shadow-[0_30px_80px_rgba(58,44,26,0.12)] backdrop-blur sm:p-10">
          <div className="mx-auto max-w-md">
            <div className="mb-8 text-center">
              <h1 className="text-4xl tracking-tight text-[#20170f] [font-family:'Iowan_Old_Style','Palatino_Linotype','Book_Antiqua',serif] sm:text-[2.8rem]">
                {title}
              </h1>
            </div>

            {children}
          </div>
        </div>
      </div>
    </section>
  );
}
