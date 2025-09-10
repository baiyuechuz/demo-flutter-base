import { cn } from "@/lib/utils";
import type { ContentFile } from "@/lib/content-loader";

interface SectionNavProps {
	sections: ContentFile[];
	activeSection: string;
	onSectionChange: (sectionId: string) => void;
}

export function SectionNav({
	sections,
	activeSection,
	onSectionChange,
}: SectionNavProps) {
	// Group sections by category if available
	const groupedSections = sections.reduce(
		(acc, section) => {
			const category = section.category || "General";
			if (!acc[category]) {
				acc[category] = [];
			}
			acc[category].push(section);
			return acc;
		},
		{} as Record<string, ContentFile[]>,
	);

	const categories = Object.keys(groupedSections);
	const hasCategories =
		categories.length > 1 ||
		(categories.length === 1 && categories[0] !== "General");

	return (
		<nav className="sticky top-12 h-[calc(100vh-4rem)] overflow-y-auto p-4">
			<h3 className="font-semibold mb-3 uppercase tracking-wide">Sections</h3>

			{hasCategories ? (
				// Render sections grouped by category
				<div className="space-y-4">
					{categories.map((category) => (
						<div key={category}>
							{category !== "General" && (
								<h4 className="font-medium text-xs mb-2 uppercase tracking-wide">
									{category}
								</h4>
							)}
							<ul className="space-y-1">
								{groupedSections[category].map((section) => (
									<li key={section.id}>
										<button
											onClick={() => onSectionChange(section.id)}
											className={cn(
												"w-full text-left block px-2 py-1 text-sm rounded-md transition-colors  hover:text-green-500",
												activeSection === section.id
													? "text-green-500 font-medium"
													: "text-muted-foreground",
											)}
											title={section.description}
										>
											<div className="flex flex-col">
												<span>{section.title}</span>
												{section.description && (
													<span className="text-xs text-accent-foreground/80 mt-0.5">
														{section.description}
													</span>
												)}
											</div>
										</button>
									</li>
								))}
							</ul>
						</div>
					))}
				</div>
			) : (
				// Render sections without categories
				<ul className="space-y-1">
					{sections.map((section) => (
						<li key={section.id}>
							<button
								onClick={() => onSectionChange(section.id)}
								className={cn(
									"w-full text-left block px-2 py-1 text-sm rounded-md transition-colors hover:bg-accent hover:text-accent-foreground",
									activeSection === section.id
										? "bg-accent text-accent-foreground font-medium"
										: "text-muted-foreground",
								)}
								title={section.description}
							>
								<div className="flex flex-col">
									<span>{section.title}</span>
									{section.description && (
										<span className="text-xs text-muted-foreground/70 mt-0.5">
											{section.description}
										</span>
									)}
								</div>
							</button>
						</li>
					))}
				</ul>
			)}
		</nav>
	);
}

