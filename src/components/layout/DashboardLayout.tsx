import React from 'react';
import { cn } from '../../lib/utils';
import { Navbar } from './Navbar';
import { Sidebar, type SidebarItem } from './Sidebar';

export interface DashboardLayoutProps extends React.HTMLAttributes<HTMLDivElement> {
  children?: React.ReactNode;
  sidebarItems?: SidebarItem[];
  portalLabel?: string;
  title?: string;
  subtitle?: string;
  actions?: React.ReactNode;
  profile?: React.ReactNode;
  footer?: React.ReactNode;
}

export const DashboardLayout: React.FC<DashboardLayoutProps> = ({
  children,
  className,
  sidebarItems = [],
  portalLabel = 'Dashboard',
  title = 'Dashboard',
  subtitle,
  actions,
  profile,
  footer,
  ...props
}) => {
  return (
    <div className={cn('dashboard-layout min-h-screen bg-slate-50', className)} {...props}>
      <div className="dashboard-shell min-h-screen">
        <Sidebar portalLabel={portalLabel} items={sidebarItems} footer={footer} />
        <div className="flex min-w-0 flex-1 flex-col">
          <Navbar title={title} subtitle={subtitle} actions={actions} profile={profile} />
          <main className="flex-1 overflow-y-auto p-4 sm:p-6 lg:p-8">
            {children}
          </main>
        </div>
      </div>
    </div>
  );
};
