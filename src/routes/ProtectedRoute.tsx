import React from 'react';
import { Navigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';

interface ProtectedRouteProps {
  children: React.ReactNode;
  allowedRoles?: ('student' | 'mentor' | 'college' | 'recruiter' | 'admin' | string)[];
}

export const ProtectedRoute: React.FC<ProtectedRouteProps> = ({ children, allowedRoles }) => {
  const { currentUser, isAuthenticated, loading } = useAuth();

  // Session Lifecycle Check: Prevent flash of unauthenticated states
  if (loading) {
    return (
      <div className="flex h-screen w-screen items-center justify-center bg-slate-50">
        <div className="flex flex-col items-center gap-3">
          <div className="h-10 w-10 animate-spin rounded-full border-4 border-blue-500 border-t-transparent"></div>
          <p className="text-sm font-bold text-slate-500">Verifying session security...</p>
        </div>
      </div>
    );
  }

  // Redirect to landing page if not signed in
  if (!isAuthenticated || !currentUser) {
    return <Navigate to="/" replace />;
  }

  // Role validation checks: Bounce users back if they lack the allowed role permissions
  if (allowedRoles && !allowedRoles.some(r => r.toLowerCase() === currentUser.role.toLowerCase())) {
    return <Navigate to="/" replace />;
  }

  return <>{children}</>;
};
