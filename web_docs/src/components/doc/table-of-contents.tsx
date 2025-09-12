import { cn } from "@/lib/utils";
import type { TOCItem } from "@/lib/content-loader";

interface TableOfContentsProps {
	items: TOCItem[];
	activeHeading?: string;
}

export function TableOfContents({
	items,
	activeHeading,
}: TableOfContentsProps) {
	const handleClick = (e: React.MouseEvent<HTMLAnchorElement>, id: string) => {
		e.preventDefault();

		// Log the active section for debugging
		console.log("TOC: Scrolling to section:", id);

		// Find the element with the matching ID
		const element = document.getElementById(id);
		if (element) {
			// Smooth scroll to the element
			element.scrollIntoView({
				behavior: "smooth",
				block: "start",
			});

			// Update the URL hash without triggering a page jump
			window.history.pushState(null, "", `#${id}`);
		}
	};

	return (
		<nav className="sticky top-12 h-[calc(100vh-4rem)] overflow-y-auto p-4">
			<h3 className="font-semibold text-sm text-muted-foreground mb-3 uppercase tracking-wide">
				On This Page
			</h3>
			<ul className="space-y-1">
				{items.map((item) => (
					<li key={item.id}>
						<a
							href={`#${item.id}`}
							onClick={(e) => handleClick(e, item.id)}
							className={cn(
								"block py-1 text-sm transition-colors hover:text-foreground relative",
								// Consistent font-weight to prevent width changes
								"font-medium",
								item.level === 1 && "text-sm",
								item.level === 2 && "pl-2 text-sm",
								item.level === 3 && "pl-4 text-xs",
								item.level === 4 && "pl-6 text-xs",
								activeHeading === item.id
									? "text-foreground"
									: "text-muted-foreground",
							)}
						>
							{/* Active indicator that doesn't affect text width */}
							{activeHeading === item.id && (
								<span className="absolute -left-2 top-1/2 -translate-y-1/2 w-0.5 h-4 bg-primary rounded-full" />
							)}
							<span
								className={cn(
									item.level === 2 && "ml-2",
									item.level === 3 && "ml-2",
								)}
							>
								{item.title}
							</span>
						</a>
					</li>
				))}
			</ul>
		</nav>
	);
}
