import { lazy } from "react";
import MainLayout from "@/layouts/main-layout";

const DocPage = lazy(() => import("@/pages/doc"));

export const docRoute = {
	path: "/doc",
	element: <MainLayout />,
	children: [
		{
			index: true,
			element: <DocPage />,
		},
	],
};
