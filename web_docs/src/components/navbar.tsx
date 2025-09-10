import { ThemeToggle } from "@/components/theme-toggle";

export function Navbar() {
	return (
		<div className="fixed top-0 w-full py-1 flex items-center justify-between h-fit px-2 bg-white/15 dark:bg-black/10 backdrop-blur-sm border">
			<a className="text-xl cursor-pointer" href="/">
				Web Docs
			</a>
			<ThemeToggle />
		</div>
	);
}
