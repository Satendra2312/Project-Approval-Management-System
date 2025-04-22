import React from 'react';
import { Navigate, Outlet } from 'react-router-dom';
import { useAuth } from '../hooks/useAuth';

export const AdminGuard = () => {
    const { isAdmin, loading } = useAuth();

    if (loading) {
        return <div>Loading...</div>;
    }

    if (!isAdmin()) {
        return <Navigate to="/unauthorized" />;
    }

    return <Outlet />;
};