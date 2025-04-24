import React, { useState } from 'react';
import { Navbar, Nav, Form, Button, Dropdown, Badge } from 'react-bootstrap';
import { FaSearch, FaMoon, FaSun, FaUserCircle, FaSignOutAlt, FaBell } from 'react-icons/fa';
import styles from './Navbar.module.css';

const Navigation = ({ toggleSidebar }) => {
    const [isDarkMode, setIsDarkMode] = useState(false);

    const toggleTheme = () => {
        setIsDarkMode(!isDarkMode);
        document.body.classList.toggle('dark-mode');
    };

    return (
        <Navbar expand="lg" className={`${styles.navbar} shadow-sm`} sticky="top">
            <div className="container-fluid">
                <Button
                    variant="outline-primary"
                    className={`${styles.toggleButton} me-2 d-lg-none`}
                    onClick={toggleSidebar}
                    aria-label="Toggle Sidebar"
                >
                    <i className="bi bi-list"></i>
                </Button>

                <Navbar.Brand href="/" className={`${styles.brand}`}>
                    Dashboard
                </Navbar.Brand>
                <Navbar.Toggle aria-controls="navbar-nav" className={styles.navbarToggle} />

                <Navbar.Collapse id="navbar-nav" className="justify-content-end">
                    <Nav className="align-items-center">
                        <Button
                            variant="outline-secondary"
                            onClick={toggleTheme}
                            className={`${styles.themeButton} me-2`}
                            aria-label="Toggle Theme"
                        >
                            {isDarkMode ? <FaSun /> : <FaMoon />}
                        </Button>
                        <Dropdown align="end">
                            <Dropdown.Toggle variant="link" id="dropdown-user" className={styles.dropdownToggle}>
                                <FaUserCircle className={styles.userIcon} />
                                <span className="d-none d-md-inline ms-1">Admin</span>
                                <Badge bg="danger" className="ms-2">3</Badge>
                            </Dropdown.Toggle>
                            <Dropdown.Menu>
                                <Dropdown.Item href="/profile">Profile</Dropdown.Item>
                                <Dropdown.Item href="/notifications">
                                    <FaBell className="me-2" />
                                    Notifications <Badge bg="danger">3</Badge>
                                </Dropdown.Item>
                                <Dropdown.Divider />
                                <Dropdown.Item href="/logout">
                                    <FaSignOutAlt className="me-2" />
                                    Logout
                                </Dropdown.Item>
                            </Dropdown.Menu>
                        </Dropdown>
                    </Nav>
                </Navbar.Collapse>
            </div>
        </Navbar>
    );
};

export default Navigation;