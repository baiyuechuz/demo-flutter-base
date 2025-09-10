import { useState, useEffect } from "react";

export function useActiveHeading(headingIds: string[]) {
  const [activeHeading, setActiveHeading] = useState<string>("");

  useEffect(() => {
    if (headingIds.length === 0) return;

    const observer = new IntersectionObserver(
      (entries) => {
        // Find the heading that's most visible
        const visibleHeadings = entries
          .filter((entry) => entry.isIntersecting)
          .map((entry) => entry.target.id);

        if (visibleHeadings.length > 0) {
          // Use the first visible heading
          setActiveHeading(visibleHeadings[0]);
        }
      },
      {
        rootMargin: "-80px 0px -80% 0px", // Trigger when heading is near the top
        threshold: 0,
      }
    );

    // Observe all headings
    headingIds.forEach((id) => {
      const element = document.getElementById(id);
      if (element) {
        observer.observe(element);
      }
    });

    return () => {
      observer.disconnect();
    };
  }, [headingIds]);

  return activeHeading;
}