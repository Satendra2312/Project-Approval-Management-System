import React from 'react';
import Navigation from '../components/common/Navigation'; // Example navigation
import { Outlet } from 'react-router-dom';

const UserLayout = () => {
    return (
        <div className="user-layout">
            <Navigation role="user" />
            <div className="content">
                <Outlet /> {/* This is where the user dashboard page will render */}
            </div>
            <footer>User Footer</footer>
        </div>
    );
};

export default UserLayout;