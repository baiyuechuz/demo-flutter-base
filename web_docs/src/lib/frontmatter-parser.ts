// Simple frontmatter parser for markdown files
export interface FrontmatterData {
  title?: string;
  description?: string;
  order?: number;
  category?: string;
  [key: string]: any;
}

export interface ParsedContent {
  frontmatter: FrontmatterData;
  content: string;
}

export function parseFrontmatter(rawContent: string): ParsedContent {
  const frontmatterRegex = /^---\s*\n([\s\S]*?)\n---\s*\n([\s\S]*)$/;
  const match = rawContent.match(frontmatterRegex);

  if (!match) {
    // No frontmatter found, return empty frontmatter and full content
    return {
      frontmatter: {},
      content: rawContent
    };
  }

  const [, frontmatterString, content] = match;
  const frontmatter = parseYamlLike(frontmatterString);

  return {
    frontmatter,
    content: content.trim()
  };
}

// Simple YAML-like parser for frontmatter
function parseYamlLike(yamlString: string): FrontmatterData {
  const result: FrontmatterData = {};
  const lines = yamlString.split('\n');

  for (const line of lines) {
    const trimmedLine = line.trim();
    if (!trimmedLine || trimmedLine.startsWith('#')) continue;

    const colonIndex = trimmedLine.indexOf(':');
    if (colonIndex === -1) continue;

    const key = trimmedLine.slice(0, colonIndex).trim();
    let value = trimmedLine.slice(colonIndex + 1).trim();

    // Remove quotes if present
    if ((value.startsWith('"') && value.endsWith('"')) || 
        (value.startsWith("'") && value.endsWith("'"))) {
      value = value.slice(1, -1);
    }

    // Try to parse as number
    if (/^\d+$/.test(value)) {
      result[key] = parseInt(value, 10);
    } else if (value === 'true') {
      result[key] = true;
    } else if (value === 'false') {
      result[key] = false;
    } else {
      result[key] = value;
    }
  }

  return result;
}