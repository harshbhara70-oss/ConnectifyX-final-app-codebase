import React from 'react';
import { Navigate, Outlet } from 'react-router-dom';
import { useAuth } from '../../context/AuthContext';

export const ProtectedAdminRoute: React.FC = () => {
  const { currentUser } = useAuth();

  // Check if current logged-in user role is admin
  const isAuthUserAdmin =
    currentUser && currentUser.role && currentUser.role.toLowerCase() === 'admin';

  // Check if local storage admin token or active session exists
  const hasAdminSession =
    typeof window !== 'undefined' &&
    (Boolean(localStorage.getItem('c2c_admin_token')) ||
      localStorage.getItem('c2c_admin_session') === 'true');

  if (!isAuthUserAdmin && !hasAdminSession) {
    return <Navigate replace to="/admin/login" />;
  }

  return <Outlet />;
};

export default ProtectedAdminRoute;
