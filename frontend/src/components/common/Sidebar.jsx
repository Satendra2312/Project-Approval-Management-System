import React, { useState, useEffect, useRef } from 'react';
import { Nav, Button } from 'react-bootstrap';
import { Link, useLocation } from 'react-router-dom';
import {
    FaTachometerAlt,
    FaUser,
    FaChartBar,
    FaCog,
    FaChevronLeft,
    FaChevronRight,
    FaBars,
    FaTimes,
    FaLock,
    FaUsersCog,
} from 'react-icons/fa';
import styles from './Sidebar.module.css';
import { useAuth } from '../../providers/AuthProvider'

const Sidebar = () => {
    const [isCollapsed, setIsCollapsed] = useState(() => {
        return localStorage.getItem('sidebarCollapsed') === 'true';
    });
    const [isOpenMobile, setIsOpenMobile] = useState(false);
    const sidebarRef = useRef(null);
    const overlayRef = useRef(null);
    const location = useLocation();
    const { isAuthenticated, isAdmin } = useAuth();

    // Save collapsed state to localStorage
    useEffect(() => {
        localStorage.setItem('sidebarCollapsed', isCollapsed);
    }, [isCollapsed]);

    // Close mobile sidebar when route changes
    useEffect(() => {
        setIsOpenMobile(false);
    }, [location]);

    // Function to toggle the collapse state
    const toggleCollapse = () => {
        setIsCollapsed(!isCollapsed);
    };

    // Function to toggle the mobile sidebar
    const toggleMobileSidebar = () => {
        setIsOpenMobile(!isOpenMobile);
    };

    // Handle clicks outside the mobile sidebar to close it
    const handleOutsideClick = (event) => {
        if (
            isOpenMobile &&
            sidebarRef.current &&
            !sidebarRef.current.contains(event.target) &&
            overlayRef.current &&
            overlayRef.current.contains(event.target)
        ) {
            setIsOpenMobile(false);
        }
    };

    // Add and remove the event listener for outside clicks
    useEffect(() => {
        document.addEventListener('mousedown', handleOutsideClick);
        return () => {
            document.removeEventListener('mousedown', handleOutsideClick);
        };
    }, [isOpenMobile]);

    const navItems = [
        { path: '/', icon: <FaTachometerAlt className="me-2" />, text: 'Dashboard', public: true },
        { path: '/users', icon: <FaUser className="me-2" />, text: 'Users', public: false, roles: ['admin', 'user'] },
        { path: '/analytics', icon: <FaChartBar className="me-2" />, text: 'Analytics', public: false, roles: ['admin'] },
        { path: '/settings', icon: <FaCog className="me-2" />, text: 'Settings', public: false, roles: ['admin', 'user'] },
        { path: '/auth', icon: <FaLock className="me-2" />, text: 'Authentication', public: true },
        { path: '/admin/users', icon: <FaUsersCog className="me-2" />, text: 'Admin Users', public: false, roles: ['admin'] },
    ];

    const getNavItems = () => {
        if (!isAuthenticated()) {
            return navItems.filter(item => item.public);
        }

        if (isAdmin()) {
            return navItems;
        }
        return navItems.filter(item => !item.public && item.roles?.includes('user'));
    }

    const filteredNavItems = getNavItems();

    return (
        <>
            {/* Mobile Toggle Button */}
            <Button
                variant="primary"
                className={`${styles.mobileToggleButton} d-md-none`}
                onClick={toggleMobileSidebar}
                aria-label="Toggle Mobile Sidebar" >
                {isOpenMobile ? <FaTimes /> : <FaBars />}
            </Button>

            {/* Sidebar */}
            <div
                ref={sidebarRef}
                className={`${styles.sidebar} flex-column flex-shrink-0 p-3 ${isOpenMobile ? styles.openMobile : ''
                    } ${isCollapsed ? styles.collapsed : ''} d-flex flex-column`}
            >
                <div className="d-flex align-items-center mb-3">
                    <Link
                        to="/"
                        className={`${styles.sidebarBrand} d-flex align-items-center text-white text-decoration-none`}
                    >
                        <FaTachometerAlt className="me-2" />
                        <span>Dashboard</span>
                    </Link>
                    <Button
                        variant="link"
                        className={`${styles.collapseButton} ms-auto text-white d-md-block d-none`}
                        onClick={toggleCollapse}
                        aria-label="Toggle Sidebar Collapse"
                    >
                        <i className={`bi ${isCollapsed ? 'bi-arrow-right' : 'bi-arrow-left'}`}></i>
                    </Button>
                </div>
                <hr className="text-white" />
                <Nav className="flex-column">
                    {filteredNavItems.map((item) => (
                        <Nav.Link
                            key={item.path}
                            as={Link}
                            to={item.path}
                            className={`${styles.navLink} ${location.pathname === item.path ? styles.active : ''}`}
                        >
                            {item.icon}
                            <span className={styles.sidebarText}>{item.text}</span>
                        </Nav.Link>
                    ))}
                </Nav>

                {/* Advanced Collapse Toggle for Small Screens */}
                <div className={`${styles.collapseToggleMobile} d-md-none mt-auto`}>
                    <Button
                        variant="outline-light"
                        size="sm"
                        className="w-100"
                        onClick={toggleCollapse}
                        aria-label="Toggle Collapse"
                    >
                        {isCollapsed ? <FaChevronRight /> : <FaChevronLeft />}
                        <span className="ms-2">{isCollapsed ? 'Expand' : 'Collapse'}</span>
                    </Button>
                </div>
            </div>

            {/* Overlay for Mobile */}
            <div
                ref={overlayRef}
                className={`${styles.overlay} ${isOpenMobile ? styles.active : ''}`}
                onClick={toggleMobileSidebar}
            ></div>
        </>
    );
};

export default Sidebar;

