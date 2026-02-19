import { useState } from "react";
import type { FormEvent } from "react";
import { useNavigate } from "react-router-dom";

export default function CreateNewGame() {
  const navigate = useNavigate();
  const [white, setWhite] = useState("");
  const [black, setBlack] = useState("");
  const [error, setError] = useState<string | null>(null);
  const [isSubmitting, setIsSubmitting] = useState(false);

  const handleSubmit = async (event: FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    setError(null);
    setIsSubmitting(true);

    try {
      const response = await fetch("/api/game", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({ white, black }),
      });

      if (!response.ok) {
        const payload = await response.json().catch(() => null);
        const message =
          payload?.error || payload?.message || `Request failed with status ${response.status}`;
        throw new Error(message);
      }

      const payload = await response.json();
      if (!payload?.game_id) {
        throw new Error("Missing game id in response");
      }

      navigate(`/game/${payload.game_id}`);
    } catch (submissionError) {
      const message =
        submissionError instanceof Error ? submissionError.message : "Failed to create game";
      setError(message);
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <section className="p-6 max-w-xl mx-auto">
      <h1 className="text-3xl font-bold mb-6">Create new game</h1>
      <form className="space-y-4" onSubmit={handleSubmit}>
        <label className="block">
          <span className="block text-sm font-medium">White player</span>
          <input
            className="mt-1 w-full rounded border border-gray-300 px-3 py-2"
            type="text"
            value={white}
            onChange={(event) => setWhite(event.target.value)}
            required
          />
        </label>
        <label className="block">
          <span className="block text-sm font-medium">Black player</span>
          <input
            className="mt-1 w-full rounded border border-gray-300 px-3 py-2"
            type="text"
            value={black}
            onChange={(event) => setBlack(event.target.value)}
            required
          />
        </label>
        {error ? <p className="text-sm text-red-600">{error}</p> : null}
        <button
          className="rounded bg-black px-4 py-2 text-white disabled:opacity-60"
          type="submit"
          disabled={isSubmitting}
        >
          {isSubmitting ? "Creating..." : "Create game"}
        </button>
      </form>
    </section>
  );
}
