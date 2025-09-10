import { Button } from "@/components/ui/button";

export default function Home() {
	return (
		<div
			className="flex flex-col items-center justify-center h-screen gap-4"
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
			<h1 className="text-4xl font-bold text-center">
				Welcome to the Web Docs!
			</h1>
			<p className="text-2xl font-medium text-muted-foreground text-center">
				This is a website demo for repositories
			</p>
			<a href="/doc">
				<Button>Get Started</Button>
			</a>
			<div className="fixed bottom-3 left-1/2 -translate-x-1/2 flex justify-center items-center flex-col gap-2 w-full">
				<span className="font-medium text-md">Made with by</span>
				<ul className="flex flex-wrap w-full justify-center items-center gap-2">
					<li className="border rounded-full py-0.5 px-3">Trần Đức Tài</li>
					<li className="border rounded-full py-0.5 px-3">Nguyễn Đình Thống</li>
					<li className="border rounded-full py-0.5 px-3">Lưu Phúc Khang</li>
					<li className="border rounded-full py-0.5 px-3">Dương Gia Bảo</li>
				</ul>
			</div>
		</div>
	);
}
