import UserLayout from '../layouts/UserLayout';
import UserDashboardPage from '../pages/User/UserDashboardPage';

export const userRoutes = [
    {
        path: '/user',
        element: <UserLayout />,
        children: [
            { path: 'dashboard', element: <UserDashboardPage /> },

        ],
    },
];