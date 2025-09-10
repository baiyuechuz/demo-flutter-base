import { createBrowserRouter } from "react-router-dom";
import { homeRoute } from "./home.route";
import { docRoute } from "./doc.route";

export const routes = [homeRoute, docRoute];

export const router = createBrowserRouter(routes);
