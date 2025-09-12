// Content loading utilities
import { parseFrontmatter, type FrontmatterData } from "./frontmatter-parser";

export interface ContentFile {
	id: string;
	title: string;
	file: string;
	description?: string;
	order?: number;
	category?: string;
	frontmatter?: FrontmatterData;
}

export interface TOCItem {
	id: string;
	title: string;
	level: number;
}

// Function to load content from public/content folder
export async function loadContent(filename: string): Promise<string> {
	try {
		// Add cache busting parameter to force reload
		const cacheBuster = `?v=${Date.now()}`;
		const response = await fetch(`/content/${filename}${cacheBuster}`);
		if (!response.ok) {
			throw new Error(`Failed to load ${filename}`);
		}
		const rawContent = await response.text();
		const { content } = parseFrontmatter(rawContent);
		return content;
	} catch (error) {
		console.error(`Error loading content: ${filename}`, error);
		return `# Error\n\nFailed to load content: ${filename}`;
	}
}

// Function to load content with frontmatter
export async function loadContentWithFrontmatter(
	filename: string,
): Promise<{ content: string; frontmatter: FrontmatterData }> {
	try {
		// Add cache busting parameter to force reload
		const cacheBuster = `?v=${Date.now()}`;
		const response = await fetch(`/content/${filename}${cacheBuster}`);
		if (!response.ok) {
			throw new Error(`Failed to load ${filename}`);
		}
		const rawContent = await response.text();
		return parseFrontmatter(rawContent);
	} catch (error) {
		console.error(`Error loading content: ${filename}`, error);
		return {
			content: `# Error\n\nFailed to load content: ${filename}`,
			frontmatter: {},
		};
	}
}

// Function to extract table of contents from markdown content
export function extractTOC(content: string): TOCItem[] {
	const lines = content.split("\n");
	const tocItems: TOCItem[] = [];

	lines.forEach((line) => {
		const h1Match = line.match(/^# (.+)$/);
		const h2Match = line.match(/^## (.+)$/);
		const h3Match = line.match(/^### (.+)$/);
		const h4Match = line.match(/^#### (.+)$/);

		if (h1Match) {
			const title = h1Match[1];
			const id = title
				.toLowerCase()
				.replace(/[^a-z0-9]+/g, "-")
				.replace(/^-|-$/g, "");
			tocItems.push({ id, title, level: 1 });
		} else if (h2Match) {
			const title = h2Match[1];
			const id = title
				.toLowerCase()
				.replace(/[^a-z0-9]+/g, "-")
				.replace(/^-|-$/g, "");
			tocItems.push({ id, title, level: 2 });
		} else if (h3Match) {
			const title = h3Match[1];
			const id = title
				.toLowerCase()
				.replace(/[^a-z0-9]+/g, "-")
				.replace(/^-|-$/g, "");
			tocItems.push({ id, title, level: 3 });
		} else if (h4Match) {
			const title = h4Match[1];
			const id = title
				.toLowerCase()
				.replace(/[^a-z0-9]+/g, "-")
				.replace(/^-|-$/g, "");
			tocItems.push({ id, title, level: 4 });
		}
	});

	return tocItems;
}

// Auto-discover content files from public/content folder
export async function discoverContentFiles(): Promise<ContentFile[]> {
	// Since we can't directly read the filesystem in the browser,
	// we'll provide a default list but make it easy to extend
	// Only include files that actually exist in your public/content folder
	const defaultFiles = [
		"getting-started.md",
		"setup_supabase.md",
		"setup_firebase.md",
	];

	const contentFiles: ContentFile[] = [];

	for (const file of defaultFiles) {
		try {
			// First check if file exists with a HEAD request
			const cacheBuster = `?v=${Date.now()}`;
			const checkResponse = await fetch(`/content/${file}${cacheBuster}`, {
				method: "HEAD",
			});
			if (!checkResponse.ok) {
				console.warn(
					`Content file ${file} not found (${checkResponse.status}), skipping`,
				);
				continue;
			}

			// Load content with frontmatter to get metadata
			const { frontmatter } = await loadContentWithFrontmatter(file);

			const id = file.replace(".md", "");

			// Use frontmatter title if available, otherwise generate from filename
			const title =
				frontmatter.title ||
				id
					.split("-")
					.map((word) => word.charAt(0).toUpperCase() + word.slice(1))
					.join(" ");

			contentFiles.push({
				id,
				title,
				file,
				description: frontmatter.description,
				order: frontmatter.order,
				category: frontmatter.category,
				frontmatter,
			});
		} catch (error) {
			// File doesn't exist or other error, skip it
			console.warn(`Content file ${file} not accessible, skipping:`, error);
		}
	}

	// Sort by order if specified, otherwise by title
	contentFiles.sort((a, b) => {
		if (a.order !== undefined && b.order !== undefined) {
			return a.order - b.order;
		}
		if (a.order !== undefined) return -1;
		if (b.order !== undefined) return 1;
		return a.title.localeCompare(b.title);
	});

	return contentFiles;
}

// Generate heading IDs that match the TOC extraction
export function generateHeadingId(text: string): string {
	return text
		.toLowerCase()
		.replace(/[^a-z0-9]+/g, "-")
		.replace(/^-|-$/g, "");
}
