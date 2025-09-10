// components/CodeBlock.jsx - Simple Shiki version with copy button
import { codeToHtml } from "shiki";
import { useEffect, useState } from "react";
import type { ReactNode } from "react";

type CodeBlockProps = {
	children: ReactNode;
	className?: string;
};

const CodeBlock = ({ children, className }: CodeBlockProps) => {
	const [html, setHtml] = useState<string>("");
	const [copied, setCopied] = useState(false);
	const language = className?.replace("language-", "") || "text";
	const code = typeof children === "string" ? children.trim() : "";

	useEffect(() => {
		codeToHtml(code, {
			lang: language,
			theme: "one-dark-pro",
		})
			.then(setHtml)
			.catch(() => {
				setHtml(
					`<pre class="bg-transparent text-white overflow-x-auto"><code>${code}</code></pre>`,
				);
			});
	}, [code, language]);

	const copyToClipboard = async () => {
		try {
			await navigator.clipboard.writeText(code);
			setCopied(true);
			setTimeout(() => setCopied(false), 2000);
		} catch (err) {
			console.error("Failed to copy:", err);
		}
	};

	return html ? (
		<div className="my-3 relative group">
			{/* Language Label */}
			<div className="absolute top-0 left-0 text-xs text-slate-300 z-10">
				{language.toUpperCase()}
			</div>

			{/* Copy Button */}
			<button
				onClick={copyToClipboard}
				className="absolute top-0 right-0 z-10 px-2 py-1 text-xs bg-[#111827]  dark:bg-[rgb(33,33,33)] text-slate-300 hover:text-white rounded-sm border border-slate-600/60 opacity-0 group-hover:opacity-100 transition-all duration-300 flex items-center gap-1"
				title="Copy code"
			>
				{copied ? (
					<>
						<svg className="w-3 h-3" fill="currentColor" viewBox="0 0 20 20">
							<path
								fillRule="evenodd"
								d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z"
								clipRule="evenodd"
							/>
						</svg>
						Copied!
					</>
				) : (
					<>
						<svg className="w-3 h-3" fill="currentColor" viewBox="0 0 20 20">
							<path d="M8 3a1 1 0 011-1h2a1 1 0 110 2H9a1 1 0 01-1-1z" />
							<path d="M6 3a2 2 0 00-2 2v11a2 2 0 002 2h8a2 2 0 002-2V5a2 2 0 00-2-2 3 3 0 01-3 3H9a3 3 0 01-3-3z" />
						</svg>
						Copy
					</>
				)}
			</button>

			{/* Code Block */}
			<div
				className="[&_pre]:!bg-transparent [&_pre]:font-mono [&_pre]:text-sm [&_pre]:relative [&_pre]:pt-6 [&_pre]:overflow-x-auto"
				dangerouslySetInnerHTML={{ __html: html }}
			/>
		</div>
	) : (
		<div className="my-3 relative">
			<div className="!bg-transparent rounded-lg animate-pulse">
				<div className="h-4 bg-transparent rounded w-3/4"></div>
			</div>
		</div>
	);
};

export default CodeBlock;
