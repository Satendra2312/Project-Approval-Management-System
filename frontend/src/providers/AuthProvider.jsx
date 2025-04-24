import React, { createContext, useState, useEffect, useContext, memo, useCallback, useMemo } from 'react';
import { useNavigate } from 'react-router-dom';
import { toast, ToastContainer } from 'react-toastify';
import { authService } from '../services/authService';

export const AuthContext = createContext(null);

const AuthProviderComponent = ({ children }) => {
    const [user, setUser] = useState(null);
    const [loading, setLoading] = useState(true);
    const navigate = useNavigate();

    // useEffect 
    useEffect(() => {
        const fetchAuth = async () => {
            const storedToken = localStorage.getItem('authToken');
            console.log('Get Token Local:', storedToken);
            if (storedToken) {
                try {
                    const response = await authService.getAuthenticatedUser();
                    console.log('Authentication:', response);
                    setUser(response.data.user);
                } catch (error) {
                    console.error('Authentication Error:', error);
                    toast.error('Authentication failed. Please login again.');
                    localStorage.removeItem('authToken');
                    setUser(null);
                } finally {
                    setLoading(false);
                }
            } else {
                setLoading(false);
            }
        };
        fetchAuth();
        console.log(fetchAuth());
    }, [navigate]);

    // useCallback 
    const login = useCallback(async (credentials) => {
        setLoading(true);
        try {
            const result = await authService.login(credentials);
            if (!result.success) {
                toast.error(result.message);
                console.log('Error Login:', result.message);
            } else {
                setUser(result.data.user);
                toast.success(result.message);
                console.log('Success Login:', result.message);
                localStorage.setItem('authToken', result.data.token);
                navigate(result.data.user.role === 'admin' ? '/admin/dashboard' : '/user/dashboard');
            }
        } catch (error) {
            console.error("Login Error", error);
            toast.error("Login failed");
        }
        finally {
            setLoading(false);
        }
    }, [authService, navigate, setUser, toast]);

    const register = useCallback(async (userData) => {
        setLoading(true);
        try {
            const result = await authService.register(userData);
            if (!result.success) {
                toast.error(result.message);
            } else {
                setUser(result.data.user);
                toast.success(result.message);
                localStorage.setItem('authToken', result.data.token);
                navigate(result.data.user.role === 'admin' ? '/admin/dashboard' : '/user/dashboard');
            }
        } catch (error) {
            console.error("Register Error", error);
            toast.error("Registration Failed");
        }
        finally {
            setLoading(false);
        }
    }, [authService, navigate, setUser, toast]);

    const logout = useCallback(async () => {
        setLoading(true);
        try {
            const result = await authService.logout();
            toast.info(result.message);
            localStorage.removeItem('authToken');
            setUser(null);
            navigate('/login');
        } catch (error) {
            console.error("Logout Error", error);
            toast.error("Logout Failed");
        }
        finally {
            setLoading(false);
        }
    }, [authService, navigate, setUser, toast]);

    // useMemo 
    const isAuthenticated = useMemo(() => () => !!user, [user]);
    const isAdmin = useMemo(() => () => user?.role === 'admin', [user]);

    // contextValue 
    const contextValue = useMemo(() => ({
        user,
        loading,
        login,
        register,
        logout,
        isAuthenticated,
        isAdmin,
    }), [user, loading, login, register, logout, isAuthenticated, isAdmin]);

    return (
        <AuthContext.Provider value={contextValue}>
            <ToastContainer position="top-right" autoClose={3000} />
            {loading ? <div>Loading...</div> : children}
        </AuthContext.Provider>
    );
};

// AuthProvider
export const AuthProvider = memo(AuthProviderComponent);

// useAuth 
export const useAuth = () => {
    const context = useContext(AuthContext);
    if (!context) {
        throw new Error('useAuth must be used within an AuthProvider');
    }
    return context;
};
