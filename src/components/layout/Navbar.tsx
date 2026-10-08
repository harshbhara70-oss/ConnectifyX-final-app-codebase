import React from 'react';
import { Bell, Search } from 'lucide-react';
import { cn } from '../../lib/utils';

export interface NavbarProps extends React.HTMLAttributes<HTMLElement> {
  title?: string;
  subtitle?: string;
  actions?: React.ReactNode;
  profile?: React.ReactNode;
}

export const Navbar: React.FC<NavbarProps> = ({ title = 'Dashboard', subtitle, actions, profile, className, ...props }) => {
  return (
    <nav className={cn('dashboard-navbar', className)} {...props}>
      <div>
        <h1>{title}</h1>
        {subtitle ? <p>{subtitle}</p> : null}
      </div>

      <div className="dashboard-navbar-actions">
        <div className="dashboard-search hidden md:flex" role="search">
          <Search className="h-4 w-4" />
          <span>Search</span>
          <kbd>/</kbd>
        </div>
        {actions}
        <button type="button" className="dashboard-icon-button" aria-label="Notifications">
          <Bell className="h-4 w-4" />
        </button>
        {profile}
      </div>
    </nav>
  );
};
