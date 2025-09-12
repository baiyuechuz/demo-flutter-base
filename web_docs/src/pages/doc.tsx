import { useState, useEffect } from "react";
import { SectionNav } from "@/components/doc/section-nav";
import { TableOfContents } from "@/components/doc/table-of-contents";
import { MDXRenderer } from "@/components/doc/mdx-renderer";
import { useActiveHeading } from "@/hooks/use-active-heading";
import { Navbar } from "@/components/navbar";
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
	const [sidebarOpen, setSidebarOpen] = useState(false);

	// Track active heading for TOC highlighting
	const activeHeading = useActiveHeading(tocItems.map((item) => item.id));

	// Auto-discover content files on mount
	useEffect(() => {
		const initializeContentFiles = async () => {
			setInitializing(true);
			const discoveredFiles = await discoverContentFiles();
			setContentFiles(discoveredFiles);

			// Check URL hash for section navigation
			const urlParams = new URLSearchParams(window.location.search);
			const sectionParam = urlParams.get('section');
			
			// Set the first available file as active if getting-started doesn't exist
			if (discoveredFiles.length > 0) {
				if (sectionParam && discoveredFiles.some(file => file.id === sectionParam)) {
					setActiveSection(sectionParam);
				} else {
					const hasGettingStarted = discoveredFiles.some(
						(file) => file.id === "getting-started",
					);
					if (!hasGettingStarted) {
						setActiveSection(discoveredFiles[0].id);
					}
				}
			}
			setInitializing(false);
		};

		initializeContentFiles();
	}, []);

	useEffect(() => {
		if (contentFiles.length === 0) return;

		const loadSectionContent = async () => {
			setLoading(true);
			// Clear TOC items immediately when switching sections
			setTocItems([]);
			
			const currentFile = contentFiles.find(
				(file) => file.id === activeSection,
			);
			if (currentFile) {
				const newContent = await loadContent(currentFile.file);
				setContent(newContent);
				// Extract TOC from the new content
				const newTocItems = extractTOC(newContent);
				setTocItems(newTocItems);
				
				// Handle URL hash navigation after content loads
				setTimeout(() => {
					const hash = window.location.hash.slice(1);
					if (hash && newTocItems.some(item => item.id === hash)) {
						const element = document.getElementById(hash);
						if (element) {
							element.scrollIntoView({ behavior: "smooth", block: "start" });
						}
					}
				}, 100);
			}
			setLoading(false);
		};

		loadSectionContent();
	}, [activeSection, contentFiles]);

	const handleSectionChange = (sectionId: string) => {
		setActiveSection(sectionId);
		// Update URL with section parameter and clear hash
		const url = new URL(window.location.href);
		url.searchParams.set('section', sectionId);
		url.hash = '';
		window.history.pushState(null, "", url.toString());
		setSidebarOpen(false);
		
		// Scroll to top when switching sections
		setTimeout(() => {
			window.scrollTo({ top: 0, behavior: 'smooth' });
		}, 100);
	};

	const toggleSidebar = () => {
		setSidebarOpen(!sidebarOpen);
	};

	if (initializing) {
		return (
			<div className="min-h-screen">
				<Navbar />
				<div className="pt-12 flex items-center justify-center h-64">
					<div className="text-muted-foreground">
						Discovering content files...
					</div>
				</div>
			</div>
		);
	}

	if (contentFiles.length === 0) {
		return (
			<div className="min-h-screen">
				<Navbar />
				<div className="pt-12 flex items-center justify-center h-64">
					<div className="text-muted-foreground">
						No content files found in /public/content/
					</div>
				</div>
			</div>
		);
	}

	return (
		<div className="min-h-screen">
			<Navbar onMenuClick={toggleSidebar} showMenuButton={true} hideBorder={sidebarOpen} />

			<div
				className="pt-12"
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
				{/* Mobile sidebar overlay */}
				{sidebarOpen && (
					<div
						className="fixed inset-0 bg-black/50 z-40 lg:hidden"
						onClick={() => setSidebarOpen(false)}
					/>
				)}

				<div className="flex h-[calc(100vh-3rem)]">
					<div
						className={`
						fixed lg:static inset-y-0 left-0 z-50 w-64 lg:w-48
						transform transition-transform duration-300 ease-in-out
						lg:transform-none lg:transition-none
						${sidebarOpen ? "translate-x-0" : "-translate-x-full"}
						lg:translate-x-0
						bg-background lg:bg-transparent
            lg:border-r border-border
					`}
					>
						<div className="pt-3 lg:pt-0">
							<SectionNav
								sections={contentFiles}
								activeSection={activeSection}
								onSectionChange={handleSectionChange}
							/>
						</div>
					</div>

					<main className="flex-1 overflow-y-auto min-w-0">
						<div className="container mx-auto px-4 sm:px-6 py-8 max-w-4xl">
							{loading ? (
								<div className="flex items-center justify-center h-64">
									<div className="text-muted-foreground">
										Loading content...
									</div>
								</div>
							) : (
								<MDXRenderer content={content} />
							)}
						</div>
					</main>

					<div className="hidden md:block w-64 border-l border-border">
						<TableOfContents items={tocItems} activeHeading={activeHeading} />
					</div>
				</div>
			</div>
		</div>
	);
}
