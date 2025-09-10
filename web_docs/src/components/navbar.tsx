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
				<a className="text-xl cursor-pointer" href="/">
					Web Docs
				</a>
			</div>
			<ThemeToggle />
		</div>
	);
}
