import React from 'react';
import { Navigate, Outlet } from 'react-router-dom';
import { useAuth } from '../hooks/useAuth';

export const UserGuard = () => {
    const { isAuthenticated, user, loading } = useAuth();

    if (loading) {
        return <div>Loading...</div>;
    }

    if (!isAuthenticated() || (user && user.role !== 'user')) {
        return <Navigate to="/unauthorized" />;
    }

    return <Outlet />;
};