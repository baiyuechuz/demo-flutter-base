import { BiSolidQuoteRight } from "react-icons/bi";
import CodeBlock from "./codeblock";
import type { ReactNode, ReactElement, HTMLAttributes } from "react";

type CodeProps = {
	children: ReactNode;
	className?: string;
} & HTMLAttributes<HTMLElement>;

type PreProps = {
	children: ReactElement & {
		props?: {
			className?: string;
		};
	};
};

// Enhanced Image component with size support
const CustomImage = ({
	src,
	alt,
	size,
	width,
	className = "",
	...props
}: {
	src: string;
	alt?: string;
	size?: string;
	width?: string;
	className?: string;
	[key: string]: any;
}) => {
	// Map common sizes to Tailwind classes
	const sizeMap: { [key: string]: string } = {
		"10%": "w-1/12",
		"20%": "w-1/5",
		"25%": "w-1/4",
		"30%": "w-2/6",
		"33%": "w-1/3",
		"40%": "w-2/5",
		"50%": "w-1/2",
		"60%": "w-3/5",
		"66%": "w-2/3",
		"70%": "w-7/12",
		"75%": "w-3/4",
		"80%": "w-4/5",
		"90%": "w-11/12",
		"100%": "w-full",
	};

	// Determine the width style
	let widthStyle = "w-full"; // default

	if (size) {
		// Check if it's a predefined percentage
		widthStyle = sizeMap[size] || widthStyle;
	} else if (width) {
		// Check if width is a predefined percentage
		widthStyle = sizeMap[width] || widthStyle;
	}

	// If no matching predefined size, use inline style for custom values
	const customStyle: React.CSSProperties = {};
	if (size && !sizeMap[size]) {
		customStyle.width = size;
		widthStyle = ""; // Don't use Tailwind class if using inline style
	} else if (width && !sizeMap[width]) {
		customStyle.width = width;
		widthStyle = ""; // Don't use Tailwind class if using inline style
	}

	return (
		<div className="flex justify-center my-6">
			<img
				src={src}
				alt={alt || ""}
				className={`${widthStyle} max-w-full h-auto rounded-lg drama-shadow ${className}`}
				style={customStyle}
				{...props}
			/>
		</div>
	);
};

// Enhanced YouTube video embed component supporting both videoId and url
function extractYouTubeId(url: string): string | null {
	// Support various YouTube URL formats
	const regex =
		/(?:youtube\.com\/(?:[^\/\n\s]+\/\S+\/|(?:v|e(?:mbed)?|shorts)\/|.*[?&]v=)|youtu\.be\/)([\w-]{11})/;
	const match = url.match(regex);
	return match ? match[1] : null;
}

const YouTube = ({
	videoId,
	url,
	...props
}: {
	videoId?: string;
	url?: string;
}) => {
	let id = videoId;
	if (!id && url) {
		id = extractYouTubeId(url) || undefined;
	}
	if (!id) {
		return <div className="text-red-500">Invalid YouTube video link</div>;
	}
	return (
		<div className="my-6 w-full aspect-video mx-auto rounded-lg overflow-hidden shadow-lg">
			<iframe
				src={`https://www.youtube.com/embed/${id}`}
				allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share"
				allowFullScreen
				className="w-full h-full"
				{...props}
			/>
		</div>
	);
};

export const mdxComponents = {
	h1: (props: any) => (
		<h1
			className="text-4xl font-bold my-6 first:mt-0 text-foreground"
			{...props}
		/>
	),
	h2: (props: any) => (
		<h2
			className="text-3xl font-semibold my-6 first:mt-0 text-foreground"
			{...props}
		/>
	),
	h3: (props: any) => (
		<h3 className="text-2xl font-medium my-6 text-foreground" {...props} />
	),
	h4: (props: any) => (
		<h4 className="text-xl font-medium my-6 text-foreground" {...props} />
	),
	p: (props: any) => (
		<p
			className="leading-8 text-left text-lg text-muted-foreground my-2"
			{...props}
		/>
	),
	ul: (props: any) => (
		<ul
			className="list-disc pl-8 text-left text-lg text-muted-foreground"
			{...props}
		/>
	),
	ol: (props: any) => (
		<ol
			className="list-decimal pl-8 mb-6 text-left text-lg text-muted-foreground"
			{...props}
		/>
	),
	li: (props: any) => <li className="mt-3 leading-8 text-left" {...props} />,
	a: (props: any) => (
		<a
			className="text-primary border-b border-indigo-400 hover:border-b-2 font-medium transition-colors duration-300"
			{...props}
		/>
	),
	blockquote: (props: any) => (
		<div className="relative overflow-hidden my-6">
			<blockquote
				className="border border-border pl-6 italic text-left text-lg bg-muted/20 rounded-lg leading-relaxed whitespace-pre-line overflow-x-auto"
				{...props}
			/>
			<BiSolidQuoteRight
				className="absolute -top-2 -right-2 text-gray-200 dark:text-gray-700/40 rotate-40"
				size={60}
			/>
		</div>
	),
	table: (props: any) => (
		<div className="overflow-x-auto my-6 rounded-md border border-border">
			<table
				className="w-full text-left bg-card border border-border table-fixed border-collapse rounded-md overflow-hidden"
				{...props}
			/>
		</div>
	),
	th: (props: any) => (
		<th
			className="border border-border px-6 py-4 bg-muted/50 font-semibold text-left text-lg"
			{...props}
		/>
	),
	td: (props: any) => (
		<td className="border border-border px-6 py-4 text-left" {...props} />
	),
	img: (props: any) => (
		<img {...props} className="rounded-lg w-full mx-auto mb-5 drama-shadow" />
	),
	Image: CustomImage, // Register the custom Image component for MDX
	YouTube, // Register the YouTube component for MDX
	Callout: ({ type = "info", children, ...props }: any) => (
		<div
			className={`py-3 px-5 rounded-md border text-left shadow-sm my-6 relative ${
				type === "warning"
					? "bg-yellow-50 border-yellow-200 dark:bg-yellow-900/20 dark:border-yellow-800"
					: type === "error"
						? "bg-red-50 border-red-200 dark:bg-red-900/20 dark:border-red-800"
						: type === "success"
							? "bg-green-50 border-green-200 dark:bg-green-900/20 dark:border-green-800"
							: "bg-blue-50 border-blue-200 dark:bg-blue-900/20 dark:border-blue-800"
			}`}
			{...props}
		>
			<div
				className={`h-[80%] w-[4px] absolute left-1.5 top-1/2 -translate-y-1/2 rounded-md ${
					type === "warning"
						? "bg-yellow-500 dark:bg-yellow-900/20"
						: type === "error"
							? "bg-red-500 dark:bg-red-900/20"
							: type === "success"
								? "bg-green-500 dark:bg-green-900/20"
								: "bg-blue-500 dark:bg-blue-900/20"
				}`}
			></div>
			<div className="text-lg leading-relaxed">{children}</div>
		</div>
	),
	code: ({ children, className, ...props }: CodeProps) => {
		if (className) {
			return <CodeBlock className={className}>{children}</CodeBlock>;
		}

		return (
			<code className={`px-2 pt-1 rounded text-sm font-mono border`} {...props}>
				{children}
			</code>
		);
	},
	pre: ({ children }: PreProps) => {
		return (
			<pre className="bg-[#111827]  dark:bg-[rgb(18,18,18)] backdrop-blur-lg px-4 rounded-lg shadow-xl my-4 py-1">
				{children}
			</pre>
		);
	},
	hr: (props: any) => (
		<hr className="my-8 border-t border-border dark:border-border" {...props} />
	),
};
