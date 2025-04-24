import React, { useState, useEffect } from 'react';
import Navigation from '../components/common/Navigation';
import Sidebar from '../components/common/Sidebar';
import { Outlet } from 'react-router-dom';
import styles from './AdminLayout.module.css';

const AdminLayout = () => {
    const [isSidebarOpen, setIsSidebarOpen] = useState(window.innerWidth >= 992);

    useEffect(() => {
        const handleResize = () => {
            setIsSidebarOpen(window.innerWidth >= 992);
        };

        window.addEventListener('resize', handleResize);

        return () => {
            window.removeEventListener('resize', handleResize);
        };
    }, []);

    const toggleSidebar = () => setIsSidebarOpen(!isSidebarOpen);

    return (
        <div className={`${styles.container} ${isSidebarOpen ? styles.sidebarOpen : ''}`}>
            <Sidebar isOpen={isSidebarOpen} toggleSidebar={toggleSidebar} />
            <div className={styles.mainContent}>
                <Navigation toggleSidebar={toggleSidebar} />
                <main className={`${styles.content} p-3 p-md-4`}>
                    <Outlet />
                </main>
            </div>
        </div>
    );
};

export default AdminLayout;