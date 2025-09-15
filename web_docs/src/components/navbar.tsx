import { ThemeToggle } from "@/components/theme-toggle";
import { Button } from "@/components/ui/button";
import { Menu } from "lucide-react";

interface NavbarProps {
	onMenuClick?: () => void;
	showMenuButton?: boolean;
	hideBorder?: boolean;
}

export function Navbar({
	onMenuClick,
	showMenuButton = false,
	hideBorder = false,
}: NavbarProps) {
	return (
		<div
			className={`fixed top-0 w-full py-1 flex items-center justify-between h-fit px-2 bg-white/15 dark:bg-black/10 backdrop-blur-sm z-1 ${hideBorder ? "" : "border"}`}
		>
			<div className="flex items-center gap-2">
				{showMenuButton && (
					<Button
						variant="ghost"
						size="sm"
						onClick={onMenuClick}
						className="lg:hidden"
					>
						<Menu className="h-4 w-4" />
					</Button>
				)}
				<a className="text-xl cursor-pointer flex gap-1 items-center" href="/">
					<svg
						xmlns="http://www.w3.org/2000/svg"
						width="24"
						height="24"
						viewBox="0 0 24 24"
						fill="none"
						stroke="currentColor"
						stroke-width="2"
						stroke-linecap="round"
						stroke-linejoin="round"
						className="lucide lucide-book-icon lucide-book"
					>
						<path d="M4 19.5v-15A2.5 2.5 0 0 1 6.5 2H19a1 1 0 0 1 1 1v18a1 1 0 0 1-1 1H6.5a1 1 0 0 1 0-5H20" />
					</svg>
					Web Docs
				</a>
			</div>
			<ThemeToggle />
		</div>
	);
}
