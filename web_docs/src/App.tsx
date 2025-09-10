import { ThemeProvider } from "@/components/theme-provider";
import { MDXProvider } from "@mdx-js/react";
import { Suspense } from "react";
import { RouterProvider } from "react-router-dom";
import { router } from "@/routes";

function App() {
	return (
		<MDXProvider>
			<ThemeProvider>
				<Suspense fallback={<div className="text-center">Loading...</div>}>
					<RouterProvider router={router} />
				</Suspense>
			</ThemeProvider>
		</MDXProvider>
	);
}

export default App;
