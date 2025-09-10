import { ThemeToggle } from "@/components/theme-toggle";

export function Navbar() {
	return (
		<div className="fixed top-0 w-full py-1 flex items-center justify-between h-fit px-2 bg-background border">
			<div>
				<h1 className="text-xl">Web Docs</h1>
			</div>
			<ThemeToggle />
		</div>
	);
}
