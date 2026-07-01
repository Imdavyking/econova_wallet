import "./App.css";
import "./utils/polyfill";
import Router from "./router";
import { BrowserRouter } from "react-router-dom";
import { ToastContainer } from "react-toastify";
import NavHeader from "./components/NavHeader";

function App() {
  return (
    <>
      <ToastContainer />
      <BrowserRouter>
        <NavHeader />
        <Router />
      </BrowserRouter>
    </>
  );
}

export default App;
