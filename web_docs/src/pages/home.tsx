import { Button } from "@/components/ui/button";

export default function Home() {
	return (
		<div className="flex flex-col items-center justify-center h-screen gap-4">
			<h1 className="text-4xl font-bold">Welcome to the Web Docs!</h1>
			<p className="text-2xl font-medium text-muted-foreground">
				This is a website demo for repositories
			</p>
			<a href="/doc">
				<Button>Get Started</Button>
			</a>
		</div>
	);
}
