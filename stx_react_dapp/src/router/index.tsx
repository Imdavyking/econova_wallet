import { useRoutes } from "react-router-dom";
import Demo from "../demo";

function Router() {
  const routes = [
    {
      path: "/",
      element: <Demo />,
    },
  ];
  return useRoutes(routes);
}

export default Router;
