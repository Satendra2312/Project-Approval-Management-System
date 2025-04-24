import React from 'react';
import Navigation from '../components/common/Navigation';
import { Outlet } from 'react-router-dom';

const UserLayout = () => {
    return (
        <div className="user-layout">
            <Navigation role="user" />
            <div className="content">
                <Outlet />
            </div>
            <footer>User Footer</footer>
        </div>
    );
};

export default UserLayout;