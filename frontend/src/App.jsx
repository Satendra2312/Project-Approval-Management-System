import React from 'react';
import { Routes, Route, Navigate } from 'react-router-dom';
import { authRoutes } from './router/authRoutes';
import { userRoutes } from './router/userRoutes';
import { adminRoutes } from './router/adminRoutes';
import { AuthGuard } from './router/AuthGuard';
import { AdminGuard } from './router/AdminGuard';
import { UserGuard } from './router/UserGuard';
import { useAuth } from './providers/AuthProvider';

function App() {
  const { isAuthenticated, user, loading } = useAuth();

  if (loading) {
    return <div>Loading...</div>;
  }
  return (
    <Routes>
      {authRoutes.map((route) => (
        <Route key={route.path} path={route.path} element={route.element} />
      ))}

      <Route path="/admin/*" element={<AuthGuard allowedRoles={['admin']} />}>
        <Route path="*" element={<AdminGuard />} />
      </Route>

      <Route path="/user/*" element={<AuthGuard allowedRoles={['user']} />}>
        <Route path="*" element={<UserGuard />} />
      </Route>

      <Route
        path="/"
        element={
          isAuthenticated() ? (
            user?.role === 'admin' ? (
              <Navigate to="/admin/dashboard" replace />
            ) : user?.role === 'user' ? (
              <Navigate to="/user/dashboard" replace />
            ) : (
              <div>Default Page for Unknown Role</div>
            )
          ) : (
            <Navigate to="/login" replace />
          )
        }
      />
    </Routes>
  );
}

export default App;