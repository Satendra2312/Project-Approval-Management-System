import React, { useState, useEffect, useRef, useMemo } from "react";
import { Nav, Button } from "react-bootstrap";
import { Link, useLocation } from "react-router-dom";
import {
    FaTachometerAlt, FaUser, FaChartBar, FaCog, FaChevronLeft, FaChevronRight, FaBars, FaTimes, FaLock, FaUsersCog, FaSignOutAlt
} from "react-icons/fa";
import styles from "./Sidebar.module.css";
import { useAuth } from "../../providers/AuthProvider";

const Sidebar = () => {
    const [isCollapsed, setIsCollapsed] = useState(localStorage.getItem("sidebarCollapsed") === "true");
    const [isOpenMobile, setIsOpenMobile] = useState(false);
    const sidebarRef = useRef(null);
    const overlayRef = useRef(null);
    const location = useLocation();
    const { isAuthenticated, isAdmin, logout } = useAuth();

    useEffect(() => {
        localStorage.setItem("sidebarCollapsed", isCollapsed);
    }, [isCollapsed]);

    useEffect(() => {
        setIsOpenMobile(false);
    }, [location]);

    const navItems = useMemo(() => [
        { path: "/", icon: <FaTachometerAlt className="me-2" />, text: "Dashboard", public: true },
        { path: "/admin/projects", icon: <FaChartBar className="me-2" />, text: "Projects", public: false, roles: ["admin", "user"] },
        { path: "/admin/users", icon: <FaUser className="me-2" />, text: "Users", public: false, roles: ["admin", "user"] },
        { path: "/admin/settings", icon: <FaCog className="me-2" />, text: "Settings", public: false, roles: ["admin", "user"] },
    ], []);

    const filteredNavItems = useMemo(() => {
        if (!isAuthenticated()) return navItems.filter(item => item.public);
        return isAdmin() ? navItems : navItems.filter(item => item.roles?.includes("user"));
    }, [isAuthenticated, isAdmin]);

    return (
        <>
            <Button variant="primary" className={`${styles.mobileToggleButton} d-md-none`} onClick={() => setIsOpenMobile(!isOpenMobile)}>
                {isOpenMobile ? <FaTimes /> : <FaBars />}
            </Button>

            <div ref={sidebarRef} className={`${styles.sidebar} ${isOpenMobile ? styles.openMobile : ""} ${isCollapsed ? styles.collapsed : ""}`}>
                <div className="d-flex align-items-center mb-3">
                    <Link to="/" className={`${styles.sidebarBrand} text-white text-decoration-none`}>
                        <FaTachometerAlt className="me-2" />
                        <span>Dashboard</span>
                    </Link>
                    <Button variant="link" className={`${styles.collapseButton} ms-auto text-white d-md-block d-none`} onClick={() => setIsCollapsed(!isCollapsed)}>
                        {isCollapsed ? <FaChevronRight /> : <FaChevronLeft />}
                    </Button>
                </div>
                <hr className="text-white" />

                <Nav className="flex-column">
                    {filteredNavItems.map((item) => {
                        const isActive = item.path === "/"
                            ? location.pathname === "/"
                            : location.pathname.startsWith(item.path);

                        return (
                            <Nav.Link key={item.path} as={Link} to={item.path} className={`${styles.navLink} ${isActive ? styles.active : ""}`}>
                                {item.icon}
                                <span className={styles.sidebarText}>{item.text}</span>
                            </Nav.Link>
                        );
                    })}
                </Nav>

                {/* Logout Button */}
                {isAuthenticated() && (
                    <Button variant="danger" className={`${styles.navLink} mt-auto`} onClick={logout}>
                        <FaSignOutAlt className="me-2" />
                        <span className={styles.sidebarText}>Logout</span>
                    </Button>
                )}
            </div>

            <div ref={overlayRef} className={`${styles.overlay} ${isOpenMobile ? styles.active : ""}`} onClick={() => setIsOpenMobile(false)} />
        </>
    );
};

export default Sidebar;
