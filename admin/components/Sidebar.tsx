'use client';

import React from 'react';
import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { 
  LayoutDashboard, 
  Users, 
  ShieldCheck, 
  AlertTriangle, 
  Sparkles,
  Flame,
  LogOut
} from 'lucide-react';

export function Sidebar() {
  const pathname = usePathname();

  const navItems = [
    { label: 'Overview', href: '/', icon: LayoutDashboard },
    { label: 'User Directory', href: '/users', icon: Users },
    { label: 'Photo Verification', href: '/verifications', icon: ShieldCheck, badge: 28 },
    { label: 'Safety & Reports', href: '/reports', icon: AlertTriangle, badge: 9, badgeVariant: 'danger' },
    { label: 'AI Telemetry', href: '/ai-analytics', icon: Sparkles },
    { label: 'Live Landing Page', href: '/landing', icon: LogOut },
  ];

  if (pathname === '/landing') {
    return null;
  }

  return (
    <aside className="w-64 h-screen bg-[#141414] text-neutral-300 flex flex-col border-r border-neutral-800/80 select-none">
      {/* Brand Header */}
      <div className="h-16 flex items-center px-6 border-b border-neutral-800/80 gap-3">
        <div className="w-9 h-9 rounded-xl overflow-hidden bg-neutral-900 border border-neutral-800 shadow-sm shadow-[#FF5C5C]/20 flex items-center justify-center">
          <img src="/match_spark_3d.png" alt="Match Stick" className="w-full h-full object-cover" />
        </div>
        <div>
          <span className="font-bold tracking-tight text-white text-base">MATCH STICK</span>
          <span className="block text-[10px] text-[#FF5C5C] uppercase tracking-wider font-semibold">Control Portal</span>
        </div>
      </div>

      {/* Navigation Links */}
      <nav className="flex-1 px-3 py-6 space-y-1">
        {navItems.map((item) => {
          const isActive = pathname === item.href;
          const Icon = item.icon;

          return (
            <Link
              key={item.href}
              href={item.href}
              className={`flex items-center justify-between px-3.5 py-2.5 rounded-xl text-sm font-medium transition-all ${
                isActive
                  ? 'bg-neutral-800 text-white shadow-sm'
                  : 'text-neutral-400 hover:text-white hover:bg-neutral-800/50'
              }`}
            >
              <div className="flex items-center gap-3">
                <Icon className={`w-4 h-4 ${isActive ? 'text-[#FF5C5C]' : 'text-neutral-400'}`} />
                <span>{item.label}</span>
              </div>

              {item.badge && (
                <span
                  className={`text-[11px] font-semibold px-2 py-0.5 rounded-full ${
                    item.badgeVariant === 'danger'
                      ? 'bg-rose-500/20 text-rose-400 border border-rose-500/30'
                      : 'bg-amber-500/20 text-amber-300 border border-amber-500/30'
                  }`}
                >
                  {item.badge}
                </span>
              )}
            </Link>
          );
        })}
      </nav>

      {/* Footer Info */}
      <div className="p-4 border-t border-neutral-800/80">
        <div className="flex items-center justify-between px-2 py-2 rounded-lg bg-neutral-900/60 border border-neutral-800">
          <div className="flex items-center gap-2.5">
            <div className="w-7 h-7 rounded-full bg-neutral-700 flex items-center justify-center text-xs text-white font-medium">
              SA
            </div>
            <div className="truncate">
              <p className="text-xs font-medium text-white truncate">Super Admin</p>
              <p className="text-[10px] text-neutral-500 truncate">admin@matchstick.app</p>
            </div>
          </div>
          <button title="Sign Out" className="text-neutral-500 hover:text-rose-400 transition-colors">
            <LogOut className="w-4 h-4" />
          </button>
        </div>
      </div>
    </aside>
  );
}
