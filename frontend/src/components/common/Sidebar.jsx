import React, { useState, useEffect, useRef, useMemo, useCallback } from "react";
import { Nav, Button } from "react-bootstrap";
import { Link, useLocation } from "react-router-dom";
import { FaTachometerAlt, FaUser, FaChartBar, FaCog, FaChevronLeft, FaChevronRight, FaBars, FaTimes, FaSignOutAlt, FaCaretDown, FaCaretUp } from "react-icons/fa";
import classNames from 'classnames';
import { useAuth } from "../../providers/AuthProvider";
import styles from "./Sidebar.module.css";

const SubmenuItem = React.forwardRef(({ as: Component = 'div', to, children, isActive, depth = 1, hasChildren, isOpen, ...props }, ref) => {
    const isLink = to !== undefined;
    const NavComponent = isLink ? Link : Component;

    const itemClasses = classNames(
        styles.navLink,
        isActive ? styles.active : '',
        `ms-${depth * 2}`
    );

    return (
        <NavComponent ref={ref} to={to} className={itemClasses} {...props}>
            <span className={styles.sidebarText}>{depth > 1 && "- "}{children}</span>
            {hasChildren && (isOpen ? <FaCaretUp className={classNames(styles.icon, styles.rotateIcon)} /> : <FaCaretDown className={styles.icon} />)}
        </NavComponent>
    );
});

SubmenuItem.displayName = 'SubmenuItem';

const Sidebar = () => {
    const [isCollapsed, setIsCollapsed] = useState(localStorage.getItem("sidebarCollapsed") === "true");
    const [isOpenMobile, setIsOpenMobile] = useState(false);
    const sidebarRef = useRef(null);
    const overlayRef = useRef(null);
    const location = useLocation();
    const { isAuthenticated, isAdmin, logout } = useAuth();
    const [openSubmenus, setOpenSubmenus] = useState({});

    // Save collapsed state to localStorage
    useEffect(() => {
        localStorage.setItem("sidebarCollapsed", isCollapsed);
    }, [isCollapsed]);

    // Close mobile sidebar and reset submenus when location changes
    useEffect(() => {
        setIsOpenMobile(false);
        setOpenSubmenus({});
    }, [location]);

    // Function to toggle the submenu open/close state
    const toggleSubmenuClick = useCallback((base) => {
        setOpenSubmenus(prevState => ({
            ...prevState,
            [base]: !prevState[base],
        }));
    }, []);

    // Function to check if a submenu is currently open
    const isSubmenuOpen = useCallback((base) => openSubmenus[base] || false, [openSubmenus]);

    //  navigation items
    const navItems = useMemo(() => [
        { path: "/", icon: <FaTachometerAlt className="me-2" />, text: "Dashboard", public: true },
        {
            base: "projects",
            icon: <FaChartBar className="me-2" />,
            text: "Projects",
            public: false,
            roles: ["admin", "user"],
            children: [
                { base: "", text: "Project List", public: false, roles: ["admin", "user"] },
                { base: "create", text: "Create Project", public: false, roles: ["user"] },
            ],
        },
        /*  { base: "settings", icon: <FaCog className="me-2" />, text: "Settings", public: false, roles: ["admin", "user"] }, */
        { base: "profile", icon: <FaUser className="me-2" />, text: "Profile", public: false, roles: ["admin", "user"] },
    ], []);

    // Filter navigation items based on authentication and user role
    const filteredNavItems = useMemo(() => {
        if (!isAuthenticated()) return navItems.filter(item => item.public);
        return isAdmin() ? navItems : navItems.filter(item => item.roles?.includes("user") || item.public);
    }, [isAuthenticated, isAdmin, navItems]);

    //  user role prefix for URLs ( /admin/ or /user/)
    const userRolePrefix = isAdmin() ? "/admin/" : "/user/";

    // Function to recursively render submenu items
    const renderSubMenu = useCallback((items, parentBase, depth = 1) => {
        const isOpen = isSubmenuOpen(parentBase);

        return (
            <div className={classNames(styles.submenuWrapper, { [styles.submenuVisible]: isOpen, [styles.submenuHidden]: !isOpen })}>
                <Nav className="flex-column">
                    {items.filter(subItem => {
                        if (subItem.public) return true;
                        if (!isAuthenticated()) return false;
                        return isAdmin() ? subItem.roles?.includes("admin") : subItem.roles?.includes("user");
                    }).map(subItem => {
                        const subItemPath = `${userRolePrefix}${parentBase}/${subItem.base}`;
                        const subItemActive = location.pathname.startsWith(subItemPath);
                        const hasChildren = subItem.children && subItem.children.length > 0;

                        return (
                            <div key={subItemPath}>
                                <SubmenuItem
                                    to={hasChildren ? "#" : subItemPath}
                                    isActive={subItemActive}
                                    depth={depth}
                                    hasChildren={hasChildren}
                                    isOpen={isSubmenuOpen(subItem.base)}
                                    onClick={() => {
                                        if (!hasChildren) {
                                            // Handle navigation for leaf nodes if needed
                                        }
                                    }}
                                >
                                    {subItem.text}
                                </SubmenuItem>
                                {hasChildren && renderSubMenu(subItem.children, subItem.base, depth + 1)}
                            </div>
                        );
                    })}
                </Nav>
            </div>
        );
    }, [isSubmenuOpen, location.pathname, userRolePrefix, isAuthenticated, isAdmin]);

    return (
        <>
            <Button
                variant="primary"
                className={`${styles.mobileToggleButton} d-md-none`}
                onClick={() => setIsOpenMobile(!isOpenMobile)}
            >
                {isOpenMobile ? <FaTimes /> : <FaBars />}
            </Button>

            <div
                ref={sidebarRef}
                className={classNames(
                    styles.sidebar,
                    isOpenMobile ? styles.openMobile : "",
                    !isOpenMobile && isCollapsed ? styles.collapsed : ""
                )}
            >
                <div className="d-flex align-items-center mb-3">
                    <Link to="/" className={`${styles.sidebarBrand} text-white text-decoration-none`}>
                        <FaTachometerAlt className="me-2" />
                        <span>Dashboard</span>
                    </Link>
                    <Button
                        variant="link"
                        className={`${styles.collapseButton} ms-auto text-white d-md-block d-none`}
                        onClick={() => setIsCollapsed(!isCollapsed)}
                    >
                        {isCollapsed ? <FaChevronRight /> : <FaChevronLeft />}
                    </Button>
                </div>
                <hr className="text-white" />

                <Nav className="flex-column">
                    {filteredNavItems.map(item => {
                        const itemPath = item.path || (item.base ? `${userRolePrefix}${item.base}` : "/");
                        const hasChildren = item.children && item.children.length > 0;
                        const isActiveParent = location.pathname.startsWith(itemPath) && !location.pathname.includes(`${itemPath}/`);
                        const isActiveChild = hasChildren && item.children.some(subItem =>
                            location.pathname.startsWith(`${userRolePrefix}${item.base}/${subItem.base}`)
                        );
                        const isActive = isActiveParent || isActiveChild;
                        const isOpen = isSubmenuOpen(item.base);

                        // Explicitly handle the click to toggle the submenu
                        const handleParentClick = (e) => {
                            if (hasChildren) {
                                e.preventDefault();
                                toggleSubmenuClick(item.base);
                            }
                        };

                        return (
                            <div key={itemPath}>
                                <Nav.Link
                                    as={Link}
                                    to={hasChildren ? "#" : itemPath}
                                    className={classNames(styles.navLink, isActive ? styles.active : '')}
                                    onClick={handleParentClick}
                                >
                                    {item.icon}
                                    <span className={styles.sidebarText}>{item.text}</span>
                                    {hasChildren && (isOpen ? <FaCaretUp className={classNames(styles.icon, styles.rotateIcon)} /> : <FaCaretDown className={styles.icon} />)}
                                </Nav.Link>
                                {hasChildren && renderSubMenu(item.children, item.base)}
                            </div>
                        );
                    })}
                </Nav>

                {isAuthenticated() && (
                    <Button variant="danger" className={`${styles.navLink} mt-auto`} onClick={logout}>
                        <FaSignOutAlt className="me-2" />
                        <span className={styles.sidebarText}>Logout</span>
                    </Button>
                )}
            </div>

            <div
                ref={overlayRef}
                className={classNames(styles.overlay, isOpenMobile ? styles.active : "")}
                onClick={() => setIsOpenMobile(false)}
            />
        </>
    );
};

export default Sidebar;
