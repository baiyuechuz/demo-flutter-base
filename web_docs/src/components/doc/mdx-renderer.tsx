import React from "react";
import { mdxComponents } from "@/mdx/mdx";
import { generateHeadingId } from "@/lib/content-loader";

interface MDXRendererProps {
  content: string;
}

export function MDXRenderer({ content }: MDXRendererProps) {
  // Function to parse inline markdown formatting
  const parseInlineFormatting = (text: string): React.ReactNode[] => {
    const parts: React.ReactNode[] = [];
    let currentIndex = 0;
    
    // Regular expressions for different formatting
    const patterns = [
      { regex: /\*\*(.*?)\*\*/g, component: 'strong' }, // Bold
      { regex: /\*(.*?)\*/g, component: 'em' }, // Italic
      { regex: /`(.*?)`/g, component: 'code' }, // Inline code
    ];
    
    // Find all matches and their positions
    const matches: Array<{ start: number; end: number; content: string; type: string }> = [];
    
    patterns.forEach(({ regex, component }) => {
      let match;
      const tempRegex = new RegExp(regex.source, regex.flags);
      while ((match = tempRegex.exec(text)) !== null) {
        matches.push({
          start: match.index,
          end: match.index + match[0].length,
          content: match[1],
          type: component
        });
      }
    });
    
    // Sort matches by start position
    matches.sort((a, b) => a.start - b.start);
    
    // Remove overlapping matches (keep the first one)
    const filteredMatches = matches.filter((match, index) => {
      for (let i = 0; i < index; i++) {
        const prevMatch = matches[i];
        if (match.start < prevMatch.end) {
          return false;
        }
      }
      return true;
    });
    
    let partIndex = 0;
    filteredMatches.forEach((match) => {
      // Add text before the match
      if (currentIndex < match.start) {
        parts.push(text.slice(currentIndex, match.start));
      }
      
      // Add the formatted content
      if (match.type === 'strong') {
        parts.push(<strong key={partIndex++}>{match.content}</strong>);
      } else if (match.type === 'em') {
        parts.push(<em key={partIndex++}>{match.content}</em>);
      } else if (match.type === 'code') {
        parts.push(<mdxComponents.code key={partIndex++}>{match.content}</mdxComponents.code>);
      }
      
      currentIndex = match.end;
    });
    
    // Add remaining text
    if (currentIndex < text.length) {
      parts.push(text.slice(currentIndex));
    }
    
    return parts.length > 0 ? parts : [text];
  };

  // Enhanced MDX-like renderer with proper heading IDs for TOC navigation
  const renderContent = (content: string) => {
    const lines = content.split("\n");
    const elements: React.ReactElement[] = [];
    let currentElement = "";
    let inCodeBlock = false;
    let codeLanguage = "";

    for (let i = 0; i < lines.length; i++) {
      const line = lines[i];

      if (line.startsWith("```")) {
        if (inCodeBlock) {
          // End code block
          elements.push(
            <mdxComponents.pre key={i}>
              <mdxComponents.code className={`language-${codeLanguage}`}>
                {currentElement}
              </mdxComponents.code>
            </mdxComponents.pre>,
          );
          currentElement = "";
          inCodeBlock = false;
          codeLanguage = "";
        } else {
          // Start code block
          inCodeBlock = true;
          codeLanguage = line.slice(3);
        }
        continue;
      }

      if (inCodeBlock) {
        currentElement += line + "\n";
        continue;
      }

      if (line.startsWith("# ")) {
        const text = line.slice(2);
        const id = generateHeadingId(text);
        elements.push(
          <mdxComponents.h1 key={i} id={id}>
            {parseInlineFormatting(text)}
          </mdxComponents.h1>,
        );
      } else if (line.startsWith("## ")) {
        const text = line.slice(3);
        const id = generateHeadingId(text);
        elements.push(
          <mdxComponents.h2 key={i} id={id}>
            {parseInlineFormatting(text)}
          </mdxComponents.h2>,
        );
      } else if (line.startsWith("### ")) {
        const text = line.slice(4);
        const id = generateHeadingId(text);
        elements.push(
          <mdxComponents.h3 key={i} id={id}>
            {parseInlineFormatting(text)}
          </mdxComponents.h3>,
        );
      } else if (line.startsWith("#### ")) {
        const text = line.slice(5);
        const id = generateHeadingId(text);
        elements.push(
          <mdxComponents.h4 key={i} id={id}>
            {parseInlineFormatting(text)}
          </mdxComponents.h4>,
        );
      } else if (line.startsWith("> ")) {
        elements.push(
          <mdxComponents.blockquote key={i}>
            {parseInlineFormatting(line.slice(2))}
          </mdxComponents.blockquote>,
        );
      } else if (line.startsWith("| ")) {
        // Simple table handling - you'd want more robust parsing in production
        const nextLine = lines[i + 1];
        const isHeader = nextLine && nextLine.startsWith("|") && 
          (nextLine.includes("---") || nextLine.includes(":-") || nextLine.includes("-:"));
        if (isHeader) {
          const headers = line
            .split("|")
            .slice(1, -1)
            .map((h) => h.trim());
          const rows = [];
          let j = i + 2;
          while (j < lines.length && lines[j].startsWith("| ")) {
            rows.push(
              lines[j]
                .split("|")
                .slice(1, -1)
                .map((c) => c.trim()),
            );
            j++;
          }
          elements.push(
            <mdxComponents.table key={i}>
              <thead>
                <tr>
                  {headers.map((header, idx) => (
                    <mdxComponents.th key={idx}>{parseInlineFormatting(header)}</mdxComponents.th>
                  ))}
                </tr>
              </thead>
              <tbody>
                {rows.map((row, rowIdx) => (
                  <tr key={rowIdx}>
                    {row.map((cell, cellIdx) => (
                      <mdxComponents.td key={cellIdx}>{parseInlineFormatting(cell)}</mdxComponents.td>
                    ))}
                  </tr>
                ))}
              </tbody>
            </mdxComponents.table>,
          );
          i = j - 1;
        }
      } else if (line.match(/^\d+\. /) || line.startsWith("- ")) {
        // Handle lists - collect consecutive list items
        const isOrdered = line.match(/^\d+\. /);
        const listItems = [];
        let k = i;

        while (
          k < lines.length &&
          ((isOrdered && lines[k].match(/^\d+\. /)) ||
            (!isOrdered && lines[k].startsWith("- ")))
        ) {
          const content = isOrdered
            ? lines[k].replace(/^\d+\. /, "")
            : lines[k].slice(2);
          listItems.push(
            <mdxComponents.li key={k}>{parseInlineFormatting(content)}</mdxComponents.li>,
          );
          k++;
        }

        if (isOrdered) {
          elements.push(
            <mdxComponents.ol key={i}>{listItems}</mdxComponents.ol>,
          );
        } else {
          elements.push(
            <mdxComponents.ul key={i}>{listItems}</mdxComponents.ul>,
          );
        }
        i = k - 1;
      } else if (line.trim()) {
        elements.push(<mdxComponents.p key={i}>{parseInlineFormatting(line)}</mdxComponents.p>);
      }
    }

    return elements;
  };

  return (
    <div className="prose prose-slate dark:prose-invert max-w-none">
      {renderContent(content)}
    </div>
  );
}