import React, { createContext, useState, useEffect, useContext } from 'react';
import { useNavigate } from 'react-router-dom';
import { authService } from '../services/authService';

export const AuthContext = createContext(null);

export const AuthProvider = ({ children }) => {
    const [user, setUser] = useState(null);
    const [loading, setLoading] = useState(true);
    const navigate = useNavigate();

    useEffect(() => {
        const fetchAuth = async () => {
            try {
                const response = await authService.getAuthenticatedUser();
                setUser(response.data);
            } catch (error) {
                console.error('Authentication check failed:', error.message);
                setUser(null);
            } finally {
                setLoading(false);
            }
        };

        fetchAuth();
    }, [navigate]);

    const login = async (credentials) => {
        setLoading(true);
        try {
            await authService.login(credentials);
            const response = await authService.getAuthenticatedUser();
            setUser(response.data);
            navigate(response.data.role === 'admin' ? '/admin/dashboard' : '/user/dashboard');
        } catch (error) {
            console.error('Login failed:', error.message);
            throw error;
        } finally {
            setLoading(false);
        }
    };

    const register = async (userData) => {
        setLoading(true);
        try {
            await authService.register(userData);
            const response = await authService.getAuthenticatedUser();
            setUser(response.data);
            navigate(response.data.role === 'admin' ? '/admin/dashboard' : '/user/dashboard');
        } catch (error) {
            console.error('Registration failed:', error.message);
            throw error;
        } finally {
            setLoading(false);
        }
    };

    const logout = async () => {
        setLoading(true);
        try {
            await authService.logout();
        } catch (error) {
            console.error('Logout failed:', error.message);
        } finally {
            setUser(null);
            navigate('/login');
            setLoading(false);
        }
    };

    const isAuthenticated = () => !!user;

    const isAdmin = () => user && user.role === 'admin';

    const contextValue = {
        user,
        loading,
        login,
        register,
        logout,
        isAuthenticated,
        isAdmin,
    };

    return (
        <AuthContext.Provider value={contextValue}>
            {loading ? <div>Loading...</div> : children}
        </AuthContext.Provider>
    );
};

export const useAuth = () => {
    const context = useContext(AuthContext);
    if (!context) {
        throw new Error('useAuth must be used within an AuthProvider');
    }
    return context;
};
