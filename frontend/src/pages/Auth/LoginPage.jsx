import React, { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { useAuth } from '../../hooks/useAuth';
import LoginForm from '../../components/auth/LoginForm';

const LoginPage = () => {
    const [error, setError] = useState('');
    const { login } = useAuth();
    const navigate = useNavigate();

    const handleLogin = async (credentials) => {
        try {
            await login(credentials);
        } catch (err) {
            setError('Invalid credentials');
        }
    };
    return (
        <div className="login-page">
            <h2>Login</h2>
            {error && <div className="error">{error}</div>}
            <LoginForm onSubmit={handleLogin} />
            <p>
                Don't have an account? <Link to="/register">Register</Link>
            </p>
        </div>
    );
};

export default LoginPage;