import AdminDashboardPage from '../pages/Admin/AdminDashboardPage';
import AdminUsersPage from '../pages/Admin/AdminUsersPage';

export const adminRoutes = [
    {
        path: 'dashboard',
        element: <AdminDashboardPage />,
    },
    {
        path: 'users',
        element: <AdminUsersPage />,
    },
];