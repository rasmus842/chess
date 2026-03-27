import { Route, Routes } from "react-router-dom";
import Header from "./components/layout/Header";
import Footer from "./components/layout/Footer";
import Home from "./pages/Home";
import CreateNewGame from "./pages/CreateNewGame";
import GamePage from "./pages/GamePage";
import SignupPage from "./pages/auth/SignupPage";
import LoginPage from "./pages/auth/LoginPage";
import VerifyPage from "./pages/auth/VerifyPage";

export default function App() {
  return (
    <>
      <Header />
      <main>
        <Routes>
          <Route path="/" element={<Home />} />
          <Route path="/game/new" element={<CreateNewGame />} />
          <Route path="/game/:gameId" element={<GamePage />} />
          <Route path="/auth/signup" element={<SignupPage />} />
          <Route path="/auth/login" element={<LoginPage />} />
          <Route path="/auth/verify" element={<VerifyPage />} />
        </Routes>
      </main>
      <Footer />
    </>
  );
}
