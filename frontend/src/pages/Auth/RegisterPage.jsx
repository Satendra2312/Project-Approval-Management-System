import React, { useState, useCallback } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { useAuth } from '../../hooks/useAuth';
import RegisterForm from '../../components/auth/RegisterForm';
import { Container, Alert } from 'react-bootstrap';
import styles from './LoginPage.module.css';
import { Helmet } from 'react-helmet-async';

const RegisterPage = () => {
    const [registrationError, setRegistrationError] = useState('');
    const { register, loading } = useAuth();
    const navigate = useNavigate();

    const handleRegister = useCallback(async (userData) => {
        setRegistrationError('');
        try {
            await register(userData);
        } catch (error) {
            console.error('Registration failed:', error);
            setRegistrationError(error.message || 'Registration failed. Please try again.');
        }
    }, [register]);

    return (
        <Container fluid className={styles.loginContainer}>
            <Helmet>
                <title>Register - Project Approval Management System</title>
            </Helmet>
            <div className={styles.loginCard}>
                <div className={styles.imageSection}></div>
                <div className={styles.formSection}>
                    <div className={styles.logo}>
                        <div className={styles.logoIcon}></div>
                        <span className={styles.logoText}>Project Approval Management System</span>
                    </div>
                    <h2>Create a new account</h2>
                    {registrationError && <Alert variant="danger">{registrationError}</Alert>}
                    <RegisterForm onSubmit={handleRegister} loading={loading} />

                    <div className={styles.links}>
                        <p>Already have an account? <Link to="/login">Sign in here</Link></p>
                    </div>
                </div>
            </div>
        </Container>
    );
};

export default RegisterPage;