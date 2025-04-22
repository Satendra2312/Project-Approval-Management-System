import React from 'react';
import { useAuth } from '../../hooks/useAuth';

const UserDashboardPage = () => {
    const { user, logout } = useAuth();

    return (
        <div className="user-dashboard-page">
            <h2>User Dashboard</h2>
            {user && <p>Welcome, {user.name}!</p>}
            <button onClick={logout}>Logout</button>
        </div>
    );
};

export default UserDashboardPage;