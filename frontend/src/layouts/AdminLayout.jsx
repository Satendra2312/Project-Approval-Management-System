import React from 'react';
import Navigation from '../components/common/Navigation'; // Example navigation
import { Outlet } from 'react-router-dom';

const AdminLayout = () => {
    return (
        <div className="admin-layout">
            <Navigation role="admin" />
            <div className="content">
                <Outlet /> {/* This is where the admin dashboard page will render */}
            </div>
            <footer>Admin Footer</footer>
        </div>
    );
};

export default AdminLayout;