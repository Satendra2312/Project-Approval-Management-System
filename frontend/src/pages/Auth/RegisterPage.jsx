import React, { useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { useAuth } from '../../hooks/useAuth';
import RegisterForm from '../../components/auth/RegisterForm';

const RegisterPage = () => {
    const [error, setError] = useState('');
    const { register } = useAuth();
    const navigate = useNavigate();

    const handleRegister = async (userData) => {
        try {
            await register(userData);
            // Navigation handled in AuthProvider
        } catch (err) {
            setError('Registration failed');
        }
    };

    return (
        <div className="register-page">
            <h2>Register</h2>
            {error && <div className="error">{error}</div>}
            <RegisterForm onSubmit={handleRegister} />
            <p>
                Already have an account? <Link to="/login">Login</Link>
            </p>
        </div>
    );
};

export default RegisterPage;