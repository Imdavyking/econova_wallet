import "./App.css";
import Router from "./router";
import { BrowserRouter } from "react-router-dom";
import { ToastContainer } from "react-toastify";

function App() {
  return (
    <>
      <ToastContainer />
      <BrowserRouter>
        <Router />
      </BrowserRouter>
    </>
  );
}

export default App;
