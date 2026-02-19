import { Route, Routes } from "react-router-dom";
import Home from "./pages/Home";
import CreateNewGame from "./pages/CreateNewGame";
import GamePage from "./pages/GamePage";

function App() {
  return (
    <>
      <header>Header</header>
      <main>
        <Routes>
          <Route path="/" element={<Home />} />
          <Route path="/game/new" element={<CreateNewGame />} />
          <Route path="/game/:gameId" element={<GamePage />} />
        </Routes>
      </main>
      <footer>Footer</footer>
    </>
  );
}

export default App;
