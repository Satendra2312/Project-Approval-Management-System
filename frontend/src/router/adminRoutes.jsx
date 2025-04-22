import AdminLayout from '../layouts/AdminLayout';
import AdminDashboardPage from '../pages/Admin/AdminDashboardPage';

export const adminRoutes = [
    {
        path: '/admin',
        element: <AdminLayout />,
        children: [
            { path: 'dashboard', element: <AdminDashboardPage /> },
        ],
    },
];