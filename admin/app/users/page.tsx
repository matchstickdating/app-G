'use client';

import React, { useState } from 'react';
import { Header } from '@/components/Header';
import { 
  AdminRole, 
  MOCK_USERS, 
  ManagedUser 
} from '@/lib/mockData';
import { 
  Search, 
  ShieldCheck, 
  Sparkles, 
  MoreVertical,
  CheckCircle,
  Ban
} from 'lucide-react';

export default function UsersPage() {
  const [currentRole, setCurrentRole] = useState<AdminRole>('super_admin');
  const [users, setUsers] = useState<ManagedUser[]>(MOCK_USERS);
  const [searchQuery, setSearchQuery] = useState('');
  const [tierFilter, setTierFilter] = useState<'all' | 'free' | 'studio'>('all');
  const [statusFilter, setStatusFilter] = useState<'all' | 'active' | 'suspended'>('all');

  const filteredUsers = users.filter((user) => {
    const matchesSearch =
      user.displayName.toLowerCase().includes(searchQuery.toLowerCase()) ||
      user.email.toLowerCase().includes(searchQuery.toLowerCase()) ||
      user.city.toLowerCase().includes(searchQuery.toLowerCase());

    const matchesTier = tierFilter === 'all' || user.tier === tierFilter;
    const matchesStatus = statusFilter === 'all' || user.status === statusFilter;

    return matchesSearch && matchesTier && matchesStatus;
  });

  const toggleStudio = (userId: string) => {
    setUsers((prev) =>
      prev.map((u) => {
        if (u.id === userId) {
          return { ...u, tier: u.tier === 'studio' ? 'free' : 'studio' };
        }
        return u;
      })
    );
  };

  const toggleStatus = (userId: string) => {
    setUsers((prev) =>
      prev.map((u) => {
        if (u.id === userId) {
          return {
            ...u,
            status: u.status === 'active' ? 'suspended' : 'active',
          };
        }
        return u;
      })
    );
  };

  return (
    <div className="flex-1 flex flex-col min-h-screen bg-[#101010]">
      <Header currentRole={currentRole} onRoleChange={setCurrentRole} />

      <div className="p-8 space-y-6 max-w-7xl mx-auto w-full">
        {/* Page Header */}
        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
          <div>
            <h1 className="text-2xl font-bold text-white tracking-tight">User Directory</h1>
            <p className="text-sm text-neutral-400 mt-1">
              Browse members, manage studio entitlements, review verification state, and enforce trust policies.
            </p>
          </div>
          <span className="text-xs font-mono text-neutral-400 bg-neutral-900 border border-neutral-800 px-3 py-1.5 rounded-lg w-fit">
            Total Members: {users.length}
          </span>
        </div>

        {/* Filters Bar */}
        <div className="flex flex-wrap items-center justify-between gap-4 bg-[#161616] p-4 rounded-2xl border border-neutral-800">
          <div className="relative flex-1 min-w-[240px] max-w-md">
            <Search className="w-4 h-4 absolute left-3.5 top-1/2 -translate-y-1/2 text-neutral-500" />
            <input
              type="text"
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              placeholder="Filter by name, email, or city..."
              className="w-full bg-neutral-900 border border-neutral-800 text-sm text-neutral-200 pl-10 pr-4 py-2 rounded-xl placeholder:text-neutral-500 focus:outline-none focus:border-[#FF5C5C]/50"
            />
          </div>

          <div className="flex items-center gap-3">
            {/* Tier Filter */}
            <select
              value={tierFilter}
              onChange={(e) => setTierFilter(e.target.value as any)}
              className="bg-neutral-900 border border-neutral-800 text-xs font-medium text-neutral-300 px-3 py-2 rounded-xl focus:outline-none"
            >
              <option value="all">All Tiers</option>
              <option value="studio">Studio Members</option>
              <option value="free">Standard Members</option>
            </select>

            {/* Status Filter */}
            <select
              value={statusFilter}
              onChange={(e) => setStatusFilter(e.target.value as any)}
              className="bg-neutral-900 border border-neutral-800 text-xs font-medium text-neutral-300 px-3 py-2 rounded-xl focus:outline-none"
            >
              <option value="all">All Statuses</option>
              <option value="active">Active Only</option>
              <option value="suspended">Suspended Only</option>
            </select>
          </div>
        </div>

        {/* Users Table */}
        <div className="bg-[#161616] border border-neutral-800/80 rounded-2xl overflow-hidden">
          <table className="w-full text-left border-collapse">
            <thead>
              <tr className="border-b border-neutral-800 text-[11px] font-semibold text-neutral-400 uppercase tracking-wider bg-neutral-900/40">
                <th className="py-3.5 px-6">Member</th>
                <th className="py-3.5 px-6">Location</th>
                <th className="py-3.5 px-6">Tier</th>
                <th className="py-3.5 px-6">Matches</th>
                <th className="py-3.5 px-6">Status</th>
                <th className="py-3.5 px-6 text-right">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-neutral-800/60 text-sm">
              {filteredUsers.length === 0 ? (
                <tr>
                  <td colSpan={6} className="py-12 text-center text-neutral-500">
                    No members match the selected criteria.
                  </td>
                </tr>
              ) : (
                filteredUsers.map((user) => (
                  <tr key={user.id} className="hover:bg-neutral-900/30 transition-colors">
                    {/* User Identity */}
                    <td className="py-4 px-6">
                      <div className="flex items-center gap-3.5">
                        {/* eslint-disable-next-line @next/next/no-img-element */}
                        <img
                          src={user.avatarUrl}
                          alt={user.displayName}
                          className="w-10 h-10 rounded-full object-cover border border-neutral-800"
                        />
                        <div>
                          <div className="flex items-center gap-1.5">
                            <span className="font-semibold text-white">{user.displayName}</span>
                            <span className="text-xs text-neutral-500">({user.age})</span>
                            {user.isVerified && (
                              <span title="Photo Verified">
                                <ShieldCheck className="w-3.5 h-3.5 text-emerald-400" />
                              </span>
                            )}
                          </div>
                          <span className="text-xs text-neutral-400 block">{user.email}</span>
                        </div>
                      </div>
                    </td>

                    {/* Location */}
                    <td className="py-4 px-6 text-neutral-300 text-xs">
                      {user.city}, {user.country}
                    </td>

                    {/* Tier */}
                    <td className="py-4 px-6">
                      {user.tier === 'studio' ? (
                        <span className="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full text-xs font-semibold bg-[#FF5C5C]/15 text-[#FF5C5C] border border-[#FF5C5C]/30">
                          <Sparkles className="w-3 h-3" />
                          Studio
                        </span>
                      ) : (
                        <span className="text-xs text-neutral-400">Standard</span>
                      )}
                    </td>

                    {/* Matches */}
                    <td className="py-4 px-6 text-neutral-300 text-xs font-mono">
                      {user.matchesCount}
                    </td>

                    {/* Status */}
                    <td className="py-4 px-6">
                      <span
                        className={`inline-block px-2.5 py-0.5 rounded-full text-xs font-medium capitalize ${
                          user.status === 'active'
                            ? 'bg-emerald-500/10 text-emerald-400 border border-emerald-500/20'
                            : 'bg-rose-500/10 text-rose-400 border border-rose-500/20'
                        }`}
                      >
                        {user.status}
                      </span>
                    </td>

                    {/* Actions */}
                    <td className="py-4 px-6 text-right">
                      <div className="flex items-center justify-end gap-2">
                        <button
                          onClick={() => toggleStudio(user.id)}
                          title={user.tier === 'studio' ? 'Revoke Studio' : 'Grant Studio'}
                          className="px-2.5 py-1 rounded-lg text-xs font-medium bg-neutral-800 hover:bg-neutral-700 text-neutral-200 transition-colors"
                        >
                          {user.tier === 'studio' ? 'Revoke Studio' : 'Grant Studio'}
                        </button>
                        <button
                          onClick={() => toggleStatus(user.id)}
                          title={user.status === 'active' ? 'Suspend User' : 'Reactivate User'}
                          className={`p-1.5 rounded-lg text-xs transition-colors ${
                            user.status === 'active'
                              ? 'bg-rose-500/10 hover:bg-rose-500/20 text-rose-400'
                              : 'bg-emerald-500/10 hover:bg-emerald-500/20 text-emerald-400'
                          }`}
                        >
                          {user.status === 'active' ? <Ban className="w-4 h-4" /> : <CheckCircle className="w-4 h-4" />}
                        </button>
                      </div>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
