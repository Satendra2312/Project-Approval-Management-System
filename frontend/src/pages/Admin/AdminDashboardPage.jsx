import React from 'react';
import { useAuth } from '../../hooks/useAuth';

const AdminDashboardPage = () => {
    const { user, logout } = useAuth();

    return (
        <div className="admin-dashboard-page">
            <h2>Admin Dashboard</h2>
            {user && <p>Welcome, {user.name}!</p>}
            <button onClick={logout}>Logout</button>
        </div>
    );
};

export default AdminDashboardPage;