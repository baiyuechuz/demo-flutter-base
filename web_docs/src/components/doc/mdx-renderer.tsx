import React from "react";
import { mdxComponents } from "@/mdx/mdx";
import { generateHeadingId } from "@/lib/content-loader";

interface MDXRendererProps {
  content: string;
}

export function MDXRenderer({ content }: MDXRendererProps) {
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
            {text}
          </mdxComponents.h1>,
        );
      } else if (line.startsWith("## ")) {
        const text = line.slice(3);
        const id = generateHeadingId(text);
        elements.push(
          <mdxComponents.h2 key={i} id={id}>
            {text}
          </mdxComponents.h2>,
        );
      } else if (line.startsWith("### ")) {
        const text = line.slice(4);
        const id = generateHeadingId(text);
        elements.push(
          <mdxComponents.h3 key={i} id={id}>
            {text}
          </mdxComponents.h3>,
        );
      } else if (line.startsWith("> ")) {
        elements.push(
          <mdxComponents.blockquote key={i}>
            {line.slice(2)}
          </mdxComponents.blockquote>,
        );
      } else if (line.startsWith("| ")) {
        // Simple table handling - you'd want more robust parsing in production
        const isHeader = lines[i + 1]?.startsWith("|---");
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
                    <mdxComponents.th key={idx}>{header}</mdxComponents.th>
                  ))}
                </tr>
              </thead>
              <tbody>
                {rows.map((row, rowIdx) => (
                  <tr key={rowIdx}>
                    {row.map((cell, cellIdx) => (
                      <mdxComponents.td key={cellIdx}>{cell}</mdxComponents.td>
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
            <mdxComponents.li key={k}>{content}</mdxComponents.li>,
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
      } else if (line.includes("`") && !line.startsWith("```")) {
        // Inline code
        const parts = line.split("`");
        const rendered = parts.map((part, idx) =>
          idx % 2 === 1 ? (
            <mdxComponents.code key={idx}>{part}</mdxComponents.code>
          ) : (
            part
          ),
        );
        elements.push(<mdxComponents.p key={i}>{rendered}</mdxComponents.p>);
      } else if (line.trim()) {
        elements.push(<mdxComponents.p key={i}>{line}</mdxComponents.p>);
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