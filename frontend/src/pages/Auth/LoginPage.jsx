import React, { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { useAuth } from '../../hooks/useAuth';
import LoginForm from '../../components/auth/LoginForm';
import { Container, Alert, Spinner } from 'react-bootstrap';
import styles from './LoginPage.module.css';

const LoginPage = () => {
    const [error, setError] = useState('');
    const { login } = useAuth();
    const navigate = useNavigate();

    const handleLogin = async (credentials) => {
        setError('');
        try {
            await login(credentials);
        } catch (err) {
            setError(err);
        }
    };

    return (
        <Container fluid className={styles.loginContainer}>
            <div className={styles.loginCard}>
                <div className={styles.imageSection}></div>
                <div className={styles.formSection}>
                    <div className={styles.logo}>
                        <div className={styles.logoIcon}></div>
                        <span className={styles.logoText}>Project Approval Management System</span>
                    </div>
                    <h2>Sign in to your account</h2>
                    {error && <Alert variant="danger">{error}</Alert>}
                    <LoginForm onSubmit={handleLogin} />
                    <div className={styles.links}>
                        <p><Link to="#">Forgot password?</Link></p>
                        <p>Don't have an account? <Link to="/register">Register here</Link></p>
                    </div>
                </div>
            </div>
        </Container>
    );
};

export default LoginPage;