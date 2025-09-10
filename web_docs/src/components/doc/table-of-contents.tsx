import { cn } from "@/lib/utils";
import type { TOCItem } from "@/lib/content-loader";

interface TableOfContentsProps {
  items: TOCItem[];
  activeHeading?: string;
}

export function TableOfContents({ items, activeHeading }: TableOfContentsProps) {
  const handleClick = (e: React.MouseEvent<HTMLAnchorElement>, id: string) => {
    e.preventDefault();
    
    // Find the element with the matching ID
    const element = document.getElementById(id);
    if (element) {
      // Smooth scroll to the element
      element.scrollIntoView({ 
        behavior: 'smooth',
        block: 'start'
      });
      
      // Update the URL hash without triggering a page jump
      window.history.pushState(null, '', `#${id}`);
    }
  };

  return (
    <nav className="sticky top-16 h-[calc(100vh-4rem)] overflow-y-auto p-4 border-l border-border">
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
                "block py-1 text-sm transition-colors hover:text-foreground",
                item.level === 1 && "font-medium",
                item.level === 2 && "pl-2",
                item.level === 3 && "pl-4 text-xs",
                activeHeading === item.id
                  ? "text-foreground font-medium"
                  : "text-muted-foreground",
              )}
            >
              {item.title}
            </a>
          </li>
        ))}
      </ul>
    </nav>
  );
}