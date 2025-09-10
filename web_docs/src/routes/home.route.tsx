import { lazy } from "react";
import MainLayout from "@/layouts/main-layout";

const HomePage = lazy(() => import("@/pages/home"));

export const homeRoute = {
	path: "/",
	element: <MainLayout />,
	children: [
		{
			index: true,
			element: <HomePage />,
		},
	],
};
