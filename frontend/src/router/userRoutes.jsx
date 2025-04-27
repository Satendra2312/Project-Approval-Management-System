import CreateProject from '../pages/User/CreateProject';
import ProfilePage from '../pages/User/ProfilePage';
import ProjectList from '../pages/User/ProjectList';
import UserDashboardPage from '../pages/User/UserDashboardPage';
import { Navigate } from 'react-router-dom';

export const userRoutes = [
    {
        path: '',
        element: <Navigate to="dashboard" replace />,
    },
    {
        path: 'dashboard',
        element: <UserDashboardPage />,
    },
    {
        path: 'projects',
        element: <ProjectList />,
    }
    ,
    {
        path: 'projects/create',
        element: <CreateProject />,
    }
    ,
    {
        path: 'profile',
        element: <ProfilePage />,
    }
];