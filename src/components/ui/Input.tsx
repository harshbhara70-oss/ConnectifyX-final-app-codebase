import React from 'react';
import { cn } from '../../lib/utils';

export interface InputProps extends React.InputHTMLAttributes<HTMLInputElement> {
  error?: boolean;
  containerClassName?: string;
}

export const Input = React.forwardRef<HTMLInputElement, InputProps>(
  ({ className, containerClassName, error = false, disabled = false, ...props }, ref) => {
    return (
      <div className={cn('w-full', containerClassName)}>
        <input
          ref={ref}
          disabled={disabled}
          className={cn(
            'h-10 w-full rounded-xl border px-3.5 text-sm shadow-sm transition',
            'placeholder:text-slate-400 hover:border-slate-300',
            'focus:outline-none focus:ring-2 focus:ring-slate-950/10',
            error
              ? 'border-rose-400 bg-rose-50 text-rose-900 focus:border-rose-500 focus:ring-rose-500/20'
              : 'border-slate-200 bg-white text-slate-900 focus:border-slate-400',
            disabled && 'cursor-not-allowed bg-slate-50 text-slate-400',
            className
          )}
          {...props}
        />
      </div>
    );
  }
);

Input.displayName = 'Input';
