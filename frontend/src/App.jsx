import React from 'react';
import { Routes, Route, Navigate } from 'react-router-dom';
import { authRoutes } from './router/authRoutes';
import { AuthGuard } from './router/AuthGuard';
import { AdminGuard } from './router/AdminGuard';
import { UserGuard } from './router/UserGuard';
import { useAuth } from './providers/AuthProvider';
import { adminRoutes } from './router/adminRoutes';
import AdminLayout from './layouts/AdminLayout';
import UserLayout from './layouts/UserLayout';
import { userRoutes } from './router/userRoutes';


function App() {
  const { isAuthenticated, user } = useAuth();

  return (
    <>
      <Routes>
        {authRoutes.map((route) => (
          <Route key={route.path} path={route.path} element={route.element} />
        ))}

        <Route path="/admin/*" element={<AuthGuard allowedRoles={['admin']} />}>
          <Route element={<AdminGuard />}>
            <Route element={<AdminLayout />}>
              {
                adminRoutes.map((route) => (
                  <Route key={route.path} path={route.path} element={route.element} />
                ))}
            </Route>
          </Route>
        </Route>

        <Route path="/user/*" element={<AuthGuard allowedRoles={['user']} />}>
          <Route element={<UserGuard />} />
          <Route element={<UserLayout />}>
            {
              userRoutes.map((route) => (
                <Route key={route.path} path={route.path} element={route.element} />
              ))}
          </Route>
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
    </>
  );
}

export default App;