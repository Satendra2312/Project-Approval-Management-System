import AdminDashboardPage from '../pages/Admin/AdminDashboardPage';
import AdminUsersPage from '../pages/Admin/AdminUsersPage';
import ProfilePage from '../pages/Admin/ProfilePage';
import ProjectList from '../pages/Admin/ProjectList';
import { Navigate } from 'react-router-dom';

export const adminRoutes = [
    {
        path: '',
        element: <Navigate to="dashboard" replace />,
    },
    {
        path: 'dashboard',
        element: <AdminDashboardPage />,
    },
    {
        path: 'users',
        element: <AdminUsersPage />,
    },
    {
        path: 'projects',
        element: <ProjectList />,
    },
    {
        path: 'profile',
        element: <ProfilePage />,
    },
];
