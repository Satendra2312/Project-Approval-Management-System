import React, { createContext, useState, useEffect, useContext, memo, useCallback, useMemo } from 'react';
import { useNavigate } from 'react-router-dom';
import { toast, ToastContainer } from 'react-toastify';
import { authService } from '../services/authService';

export const AuthContext = createContext(null);

const AuthProviderComponent = ({ children }) => {
    const [user, setUser] = useState(null);
    const [loading, setLoading] = useState(true);
    const navigate = useNavigate();

    useEffect(() => {
        const fetchAuth = async () => {
            setLoading(true);
            const storedToken = localStorage.getItem('authToken');

            if (storedToken) {
                try {
                    const response = await authService.getAuthenticatedUser();
                    setUser(response.data.user);
                } catch (error) {
                    toast.error('Authentication failed. Please login again.');
                    localStorage.removeItem('authToken');
                    setUser(null);
                }
            }
            setLoading(false);
        };

        fetchAuth();
    }, []);

    const handleAuthProcess = useCallback(async (authFunction, credentials) => {
        try {
            const result = await authFunction(credentials);
            if (!result.success) throw new Error(result.message || 'Authentication failed');

            setUser(result.data.user);
            localStorage.setItem('authToken', result.data.token);
            navigate(result.data.user.role === 'admin' ? '/admin/dashboard' : '/user/dashboard');
            toast.success(result.message || 'Login successful');
        } catch (error) {
            console.log('login error:', error)
            toast.error(error.message || 'Authentication failed');
        }
    }, [navigate]);

    const login = useCallback(
        (credentials) => handleAuthProcess(authService.login, credentials),
        [handleAuthProcess]
    );

    const register = useCallback(
        (userData) => handleAuthProcess(authService.register, userData),
        [handleAuthProcess]
    );

    const logout = useCallback(async () => {
        try {
            await authService.logout();
            localStorage.removeItem('authToken');
            setUser(null);
            navigate('/login');
            toast.info('Logged out successfully');
        } catch (error) {
            toast.error('Logout failed');
        }
    }, [navigate]);

    const contextValue = useMemo(() => ({
        user,
        loading,
        login,
        register,
        logout,
        isAuthenticated: () => !!user,
        isAdmin: () => user?.role === 'admin',
    }), [user, loading, login, register, logout]);

    return (
        <AuthContext.Provider value={contextValue}>
            <ToastContainer position="top-right" autoClose={3000} />
            {loading ? (
                <div className="loading-screen">
                    <div className="spinner"></div>
                    <p>Loading, please wait...</p>
                </div>
            ) : (
                children
            )}
        </AuthContext.Provider>
    );
};

// AuthProvider
export const AuthProvider = memo(AuthProviderComponent);

// useAuth Hook
export const useAuth = () => {
    const context = useContext(AuthContext);
    if (!context) {
        throw new Error('useAuth must be used within an AuthProvider');
    }
    return context;
};
