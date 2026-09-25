'use client';

import React, { useState } from 'react';
import { Search, Bell, Shield, CheckCircle2 } from 'lucide-react';
import { AdminRole } from '@/lib/mockData';

interface HeaderProps {
  currentRole: AdminRole;
  onRoleChange: (role: AdminRole) => void;
}

export function Header({ currentRole, onRoleChange }: HeaderProps) {
  const [search, setSearch] = useState('');

  return (
    <header className="h-16 bg-[#161616] border-b border-neutral-800/80 px-8 flex items-center justify-between text-neutral-200">
      {/* Search Bar */}
      <div className="relative w-80">
        <Search className="w-4 h-4 absolute left-3.5 top-1/2 -translate-y-1/2 text-neutral-500" />
        <input
          type="text"
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          placeholder="Search by user, email, report ID..."
          className="w-full bg-neutral-900 border border-neutral-800 text-sm text-neutral-200 pl-10 pr-4 py-1.5 rounded-xl placeholder:text-neutral-500 focus:outline-none focus:border-[#FF5C5C]/50 transition-colors"
        />
      </div>

      {/* Right Controls */}
      <div className="flex items-center gap-5">
        {/* System Health */}
        <div className="hidden lg:flex items-center gap-2 px-3 py-1 rounded-full bg-emerald-500/10 border border-emerald-500/20 text-emerald-400 text-xs font-medium">
          <CheckCircle2 className="w-3.5 h-3.5" />
          <span>Services Operational</span>
        </div>

        {/* RBAC Role Switcher */}
        <div className="flex items-center gap-2 bg-neutral-900 border border-neutral-800 rounded-xl px-3 py-1">
          <Shield className="w-3.5 h-3.5 text-[#FF5C5C]" />
          <span className="text-xs text-neutral-400">Role:</span>
          <select
            value={currentRole}
            onChange={(e) => onRoleChange(e.target.value as AdminRole)}
            className="bg-transparent text-xs font-semibold text-white focus:outline-none cursor-pointer"
          >
            <option value="super_admin" className="bg-neutral-900 text-white">Super Admin</option>
            <option value="admin" className="bg-neutral-900 text-white">Admin</option>
            <option value="moderator" className="bg-neutral-900 text-white">Moderator</option>
            <option value="support" className="bg-neutral-900 text-white">Support Specialist</option>
          </select>
        </div>

        {/* Notifications */}
        <button
          className="relative p-2 rounded-xl text-neutral-400 hover:text-white hover:bg-neutral-800 transition-colors"
          title="Notifications"
        >
          <Bell className="w-4 h-4" />
          <span className="absolute top-1.5 right-1.5 w-2 h-2 rounded-full bg-[#FF5C5C]" />
        </button>
      </div>
    </header>
  );
}
