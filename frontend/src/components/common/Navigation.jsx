import React from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { useAuth } from '../../hooks/useAuth';
import { Navbar, Nav, Button } from 'react-bootstrap';

const Navigation = ({ role }) => {
    const { isAuthenticated, logout, isAdmin } = useAuth();
    const navigate = useNavigate();

    const handleLogout = () => {
        logout();
        navigate('/login');
    };

    return (
        <Navbar bg="light" expand="lg">
            <Navbar.Brand as={Link} to="/">
                My App
            </Navbar.Brand>
            <Navbar.Toggle aria-controls="basic-navbar-nav" />
            <Navbar.Collapse id="basic-navbar-nav">
                <Nav className="me-auto">
                    {isAuthenticated() && role === 'admin' && (
                        <Nav.Link as={Link} to="/admin/dashboard">
                            Dashboard
                        </Nav.Link>
                    )}
                    {isAuthenticated() && role === 'user' && (
                        <Nav.Link as={Link} to="/user/dashboard">
                            Dashboard
                        </Nav.Link>
                    )}
                    {!isAuthenticated() && (
                        <>
                            <Nav.Link as={Link} to="/login">
                                Login
                            </Nav.Link>
                            <Nav.Link as={Link} to="/register">
                                Register
                            </Nav.Link>
                        </>
                    )}
                </Nav>
                {isAuthenticated() && (
                    <Button variant="outline-danger" onClick={handleLogout}>
                        Logout
                    </Button>
                )}
            </Navbar.Collapse>
        </Navbar>
    );
};

export default Navigation;