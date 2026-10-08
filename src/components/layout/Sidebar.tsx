import React from 'react';
import { ChevronRight, GraduationCap } from 'lucide-react';
import { cn } from '../../lib/utils';

export interface SidebarItem {
  title: string;
  icon: React.ComponentType<{ className?: string }>;
  active?: boolean;
  badge?: string | number;
  onClick?: () => void;
}

export interface SidebarProps extends React.HTMLAttributes<HTMLElement> {
  portalLabel?: string;
  items?: SidebarItem[];
  footer?: React.ReactNode;
}

export const Sidebar: React.FC<SidebarProps> = ({
  portalLabel = 'Dashboard',
  items = [],
  footer,
  className,
  ...props
}) => {
  return (
    <aside className={cn('dashboard-sidebar hidden lg:flex', className)} {...props}>
      <div className="dashboard-sidebar-brand">
        <div className="dashboard-brand-mark">
          <GraduationCap className="h-5 w-5" />
        </div>
        <div>
          <h2>C2C</h2>
          <p>{portalLabel}</p>
        </div>
      </div>

      <nav className="dashboard-sidebar-nav" aria-label={`${portalLabel} navigation`}>
        {items.map((item) => {
          const Icon = item.icon;

          return (
            <button
              key={item.title}
              type="button"
              onClick={item.onClick}
              className={cn('dashboard-nav-item', item.active && 'is-active')}
              aria-current={item.active ? 'page' : undefined}
            >
              <span className="dashboard-nav-label">
                <Icon className="h-4 w-4" />
                {item.title}
              </span>
              {item.badge ? <span className="dashboard-nav-badge">{item.badge}</span> : null}
              {item.active ? <ChevronRight className="dashboard-nav-chevron" /> : null}
            </button>
          );
        })}
      </nav>

      {footer ? <div className="dashboard-sidebar-footer">{footer}</div> : null}
    </aside>
  );
};
