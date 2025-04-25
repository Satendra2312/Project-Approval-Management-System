import React from 'react';
import { Navbar, Nav, Button, Dropdown, Badge } from 'react-bootstrap';
import { FaUserCircle, FaSignOutAlt, FaBell } from 'react-icons/fa';
import styles from './Navbar.module.css';
import { useAuth } from '../../providers/AuthProvider';

const Navigation = ({ toggleSidebar }) => {
    const { user, logout } = useAuth();

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
                    Project Approval Management System
                </Navbar.Brand>

                <Navbar.Toggle aria-controls="navbar-nav" className={styles.navbarToggle} />

                <Navbar.Collapse id="navbar-nav" className="justify-content-end">
                    <Nav className="align-items-center">
                        <Dropdown align="end">
                            <Dropdown.Toggle variant="link" id="dropdown-user" className={styles.dropdownToggle}>
                                <FaUserCircle className={styles.userIcon} />
                                <span className="d-none d-md-inline ms-1">{user?.name || "Guest"}</span>
                            </Dropdown.Toggle>
                            <Dropdown.Menu>
                                <Dropdown.Item disabled>
                                    <strong>{user?.name || "Guest"}</strong><br />
                                    <small>{user?.role || "Unknown Role"}</small>
                                </Dropdown.Item>
                                <Dropdown.Divider />
                                <Dropdown.Item href="/admin/profile">Profile</Dropdown.Item>
                                <Dropdown.Divider />
                                <Dropdown.Item onClick={logout}>
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
