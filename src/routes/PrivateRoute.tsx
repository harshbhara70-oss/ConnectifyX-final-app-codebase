import React from 'react';
import { Navigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';

export const PrivateRoute: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const { isAuthenticated, loading } = useAuth();

  // Show a premium loading spinner state while verifying JWT token
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

  // If authenticated, render component. Otherwise redirect to landing page
  if (isAuthenticated) {
    return <>{children}</>;
  }

  return <Navigate to="/" replace />;
};
