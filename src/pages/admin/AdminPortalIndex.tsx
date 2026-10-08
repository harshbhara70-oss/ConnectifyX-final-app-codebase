import React from 'react';
import { Navigate } from 'react-router-dom';
import { useAuth } from '../../context/AuthContext';
import { AdminLogin } from './AdminLogin';

export const AdminPortalIndex: React.FC = () => {
  const { currentUser } = useAuth();

  const isAuthUserAdmin = currentUser && currentUser.role && currentUser.role.toLowerCase() === 'admin';
  const hasAdminSession =
    typeof window !== 'undefined' &&
    (localStorage.getItem('c2c_admin_token') || localStorage.getItem('c2c_admin_session') === 'true');

  if (isAuthUserAdmin || hasAdminSession) {
    return <Navigate replace to="/admin/dashboard" />;
  }

  return <AdminLogin />;
};

export default AdminPortalIndex;
