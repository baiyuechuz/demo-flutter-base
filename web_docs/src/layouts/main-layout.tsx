import { Outlet } from "react-router-dom";
import { Navbar } from "@/components/navbar";
import { useLocation } from "react-router-dom";

export default function MainLayout() {
	const location = useLocation();
	const isDocPage = location.pathname.startsWith('/doc');

	return (
		<div className="relative">
			{!isDocPage && <Navbar />}
			<Outlet />
		</div>
	);
}
