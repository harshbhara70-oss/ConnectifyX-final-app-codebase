import React from 'react';
import { cn } from '../../lib/utils';

export type CardProps = React.HTMLAttributes<HTMLDivElement>;

export const Card: React.FC<CardProps> = ({ children, className, ...props }) => {
  return (
    <div
      className={cn(
        'rounded-2xl border border-[#e9ddff] bg-white p-5 shadow-sm transition-all duration-200',
        'hover:border-[#d5b5ff] hover:shadow-[0_12px_30px_rgba(94,23,235,0.12)]',
        className
      )}
      {...props}
    >
      {children}
    </div>
  );
};
