import { useState, useEffect } from "react";
import { SectionNav } from "@/components/doc/section-nav";
import { TableOfContents } from "@/components/doc/table-of-contents";
import { MDXRenderer } from "@/components/doc/mdx-renderer";
import { useActiveHeading } from "@/hooks/use-active-heading";
import {
	loadContent,
	extractTOC,
	discoverContentFiles,
	type ContentFile,
	type TOCItem,
} from "@/lib/content-loader";

export default function Doc() {
	const [activeSection, setActiveSection] = useState("getting-started");
	const [content, setContent] = useState("");
	const [tocItems, setTocItems] = useState<TOCItem[]>([]);
	const [contentFiles, setContentFiles] = useState<ContentFile[]>([]);
	const [loading, setLoading] = useState(true);
	const [initializing, setInitializing] = useState(true);

	// Track active heading for TOC highlighting
	const activeHeading = useActiveHeading(tocItems.map((item) => item.id));

	// Auto-discover content files on mount
	useEffect(() => {
		const initializeContentFiles = async () => {
			setInitializing(true);
			const discoveredFiles = await discoverContentFiles();
			setContentFiles(discoveredFiles);

			// Set the first available file as active if getting-started doesn't exist
			if (discoveredFiles.length > 0) {
				const hasGettingStarted = discoveredFiles.some(
					(file) => file.id === "getting-started",
				);
				if (!hasGettingStarted) {
					setActiveSection(discoveredFiles[0].id);
				}
			}
			setInitializing(false);
		};

		initializeContentFiles();
	}, []);

	// Load content when active section changes
	useEffect(() => {
		if (contentFiles.length === 0) return;

		const loadSectionContent = async () => {
			setLoading(true);
			const currentFile = contentFiles.find(
				(file) => file.id === activeSection,
			);
			if (currentFile) {
				const newContent = await loadContent(currentFile.file);
				setContent(newContent);
				setTocItems(extractTOC(newContent));
			}
			setLoading(false);
		};

		loadSectionContent();
	}, [activeSection, contentFiles]);

	const handleSectionChange = (sectionId: string) => {
		setActiveSection(sectionId);
		// Clear the URL hash when switching sections
		window.history.pushState(null, "", window.location.pathname);
	};

	if (initializing) {
		return (
			<div className="min-h-screen pt-12">
				<div className="flex items-center justify-center h-64">
					<div className="text-muted-foreground">
						Discovering content files...
					</div>
				</div>
			</div>
		);
	}

	if (contentFiles.length === 0) {
		return (
			<div className="min-h-screen pt-12">
				<div className="flex items-center justify-center h-64">
					<div className="text-muted-foreground">
						No content files found in /public/content/
					</div>
				</div>
			</div>
		);
	}

	return (
		<div
			className="min-h-screen pt-12"
			style={{
				background: `
       radial-gradient(ellipse 110% 70% at 25% 80%, rgba(147, 51, 234, 0.12), transparent 55%),
       radial-gradient(ellipse 130% 60% at 75% 15%, rgba(59, 130, 246, 0.10), transparent 65%),
       radial-gradient(ellipse 80% 90% at 20% 30%, rgba(236, 72, 153, 0.14), transparent 50%),
       radial-gradient(ellipse 100% 40% at 60% 70%, rgba(16, 185, 129, 0.08), transparent 45%),
       transparent
     `,
			}}
		>
			<div className="grid grid-cols-[15%_70%_15%] h-[calc(100vh-4rem)]">
				<div>
					<SectionNav
						sections={contentFiles}
						activeSection={activeSection}
						onSectionChange={handleSectionChange}
					/>
				</div>

				<main className="overflow-y-auto">
					<div className="container mx-auto px-6 py-8 max-w-4xl">
						{loading ? (
							<div className="flex items-center justify-center h-64">
								<div className="text-muted-foreground">Loading content...</div>
							</div>
						) : (
							<MDXRenderer content={content} />
						)}
					</div>
				</main>

				<div>
					<TableOfContents items={tocItems} activeHeading={activeHeading} />
				</div>
			</div>
		</div>
	);
}
