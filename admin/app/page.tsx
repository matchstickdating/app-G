'use client';

import React, { useState } from 'react';
import Link from 'next/link';
import { Header } from '@/components/Header';
import { 
  Users, 
  Heart, 
  Calendar, 
  ShieldAlert, 
  ShieldCheck, 
  Sparkles,
  TrendingUp,
  ArrowUpRight,
  CheckCircle,
  XCircle
} from 'lucide-react';
import { 
  AdminRole, 
  INITIAL_METRICS, 
  MOCK_VERIFICATIONS, 
  MOCK_REPORTS 
} from '@/lib/mockData';

export default function DashboardOverview() {
  const [currentRole, setCurrentRole] = useState<AdminRole>('super_admin');
  const [verifications, setVerifications] = useState(MOCK_VERIFICATIONS);
  const [reports, setReports] = useState(MOCK_REPORTS);

  const handleApproveVerification = (id: string) => {
    setVerifications(prev => prev.filter(v => v.id !== id));
  };

  const handleDismissReport = (id: string) => {
    setReports(prev => prev.filter(r => r.id !== id));
  };

  return (
    <div className="flex-1 flex flex-col min-h-screen bg-[#101010]">
      <Header currentRole={currentRole} onRoleChange={setCurrentRole} />

      <div className="p-8 space-y-8 max-w-7xl mx-auto w-full">
        {/* Welcome Header */}
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-2xl font-bold text-white tracking-tight">Mission Control</h1>
            <p className="text-sm text-neutral-400 mt-1">
              Real-time platform telemetry, trust operations, and system health.
            </p>
          </div>
          <div className="flex items-center gap-2 text-xs font-mono text-neutral-400 bg-neutral-900 border border-neutral-800 px-3 py-1.5 rounded-lg">
            <span>LIVE ENVIRONMENT</span>
            <span className="w-2 h-2 rounded-full bg-emerald-500 animate-pulse" />
          </div>
        </div>

        {/* Metric Cards Grid */}
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-6 gap-4">
          {/* Active Members */}
          <div className="bg-[#161616] border border-neutral-800/80 rounded-2xl p-5 space-y-3">
            <div className="flex items-center justify-between text-neutral-400">
              <span className="text-xs font-medium">Active Members</span>
              <Users className="w-4 h-4 text-neutral-400" />
            </div>
            <div className="flex items-baseline justify-between">
              <span className="text-2xl font-bold text-white">
                {INITIAL_METRICS.activeMembers.toLocaleString()}
              </span>
              <span className="text-xs font-medium text-emerald-400 flex items-center">
                <TrendingUp className="w-3 h-3 mr-0.5" />
                +{INITIAL_METRICS.growthPercent}%
              </span>
            </div>
          </div>

          {/* Matches Made */}
          <div className="bg-[#161616] border border-neutral-800/80 rounded-2xl p-5 space-y-3">
            <div className="flex items-center justify-between text-neutral-400">
              <span className="text-xs font-medium">Mutual Matches</span>
              <Heart className="w-4 h-4 text-[#FF5C5C]" />
            </div>
            <div className="flex items-baseline justify-between">
              <span className="text-2xl font-bold text-white">
                {INITIAL_METRICS.matchesMade.toLocaleString()}
              </span>
              <span className="text-xs text-neutral-500">past 30d</span>
            </div>
          </div>

          {/* Date Plans Curated */}
          <div className="bg-[#161616] border border-neutral-800/80 rounded-2xl p-5 space-y-3">
            <div className="flex items-center justify-between text-neutral-400">
              <span className="text-xs font-medium">Dates Planned</span>
              <Calendar className="w-4 h-4 text-amber-400" />
            </div>
            <div className="flex items-baseline justify-between">
              <span className="text-2xl font-bold text-white">
                {INITIAL_METRICS.datePlansCurated.toLocaleString()}
              </span>
              <span className="text-xs text-neutral-500">64% converted</span>
            </div>
          </div>

          {/* Pending Verifications */}
          <div className="bg-[#161616] border border-neutral-800/80 rounded-2xl p-5 space-y-3">
            <div className="flex items-center justify-between text-neutral-400">
              <span className="text-xs font-medium">Verifications</span>
              <ShieldCheck className="w-4 h-4 text-emerald-400" />
            </div>
            <div className="flex items-baseline justify-between">
              <span className="text-2xl font-bold text-white">{verifications.length}</span>
              <span className="text-xs text-amber-400 font-medium">needs review</span>
            </div>
          </div>

          {/* Open Reports */}
          <div className="bg-[#161616] border border-neutral-800/80 rounded-2xl p-5 space-y-3">
            <div className="flex items-center justify-between text-neutral-400">
              <span className="text-xs font-medium">Open Reports</span>
              <ShieldAlert className="w-4 h-4 text-rose-400" />
            </div>
            <div className="flex items-baseline justify-between">
              <span className="text-2xl font-bold text-white">{reports.length}</span>
              <span className="text-xs text-rose-400 font-medium">urgent triage</span>
            </div>
          </div>

          {/* AI Tokens */}
          <div className="bg-[#161616] border border-neutral-800/80 rounded-2xl p-5 space-y-3">
            <div className="flex items-center justify-between text-neutral-400">
              <span className="text-xs font-medium">AI Tokens (24h)</span>
              <Sparkles className="w-4 h-4 text-indigo-400" />
            </div>
            <div className="flex items-baseline justify-between">
              <span className="text-2xl font-bold text-white">184.5k</span>
              <span className="text-xs text-neutral-500">640ms avg</span>
            </div>
          </div>
        </div>

        {/* Triage Grid */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
          {/* Priority Verifications Queue */}
          <div className="bg-[#161616] border border-neutral-800/80 rounded-2xl p-6 flex flex-col justify-between">
            <div>
              <div className="flex items-center justify-between mb-5">
                <div className="flex items-center gap-2.5">
                  <ShieldCheck className="w-5 h-5 text-emerald-400" />
                  <h2 className="text-base font-semibold text-white">Pending Photo Verifications</h2>
                </div>
                <Link
                  href="/verifications"
                  className="text-xs font-medium text-neutral-400 hover:text-white flex items-center gap-1 transition-colors"
                >
                  View All ({verifications.length})
                  <ArrowUpRight className="w-3.5 h-3.5" />
                </Link>
              </div>

              {verifications.length === 0 ? (
                <div className="py-12 text-center text-sm text-neutral-500">
                  Verification queue is completely clear.
                </div>
              ) : (
                <div className="space-y-3.5">
                  {verifications.slice(0, 2).map((item) => (
                    <div
                      key={item.id}
                      className="p-4 rounded-xl bg-neutral-900 border border-neutral-800 flex items-center justify-between"
                    >
                      <div className="flex items-center gap-4">
                        <div className="flex -space-x-3">
                          {/* eslint-disable-next-line @next/next/no-img-element */}
                          <img
                            src={item.primaryPhotoUrl}
                            alt="Primary"
                            className="w-11 h-11 rounded-full object-cover border-2 border-neutral-900"
                          />
                          {/* eslint-disable-next-line @next/next/no-img-element */}
                          <img
                            src={item.selfieUrl}
                            alt="Selfie"
                            className="w-11 h-11 rounded-full object-cover border-2 border-[#FF5C5C]"
                          />
                        </div>
                        <div>
                          <h3 className="text-sm font-semibold text-white">
                            {item.userName}, {item.userAge}
                          </h3>
                          <p className="text-xs text-neutral-400 mt-0.5">
                            Pose: &ldquo;{item.requestedPose}&rdquo; • {(item.confidenceScore * 100).toFixed(0)}% match
                          </p>
                        </div>
                      </div>

                      <div className="flex items-center gap-2">
                        <button
                          onClick={() => handleApproveVerification(item.id)}
                          className="p-2 rounded-lg bg-emerald-500/10 hover:bg-emerald-500/20 text-emerald-400 transition-colors"
                          title="Approve Badge"
                        >
                          <CheckCircle className="w-4 h-4" />
                        </button>
                        <button
                          onClick={() => handleApproveVerification(item.id)}
                          className="p-2 rounded-lg bg-rose-500/10 hover:bg-rose-500/20 text-rose-400 transition-colors"
                          title="Reject"
                        >
                          <XCircle className="w-4 h-4" />
                        </button>
                      </div>
                    </div>
                  ))}
                </div>
              )}
            </div>

            <p className="text-[11px] text-neutral-500 mt-4">
              AI biometric confidence threshold is currently calibrated to 85%.
            </p>
          </div>

          {/* Urgent Safety Reports */}
          <div className="bg-[#161616] border border-neutral-800/80 rounded-2xl p-6 flex flex-col justify-between">
            <div>
              <div className="flex items-center justify-between mb-5">
                <div className="flex items-center gap-2.5">
                  <ShieldAlert className="w-5 h-5 text-rose-400" />
                  <h2 className="text-base font-semibold text-white">Incident & Safety Triage</h2>
                </div>
                <Link
                  href="/reports"
                  className="text-xs font-medium text-neutral-400 hover:text-white flex items-center gap-1 transition-colors"
                >
                  View All ({reports.length})
                  <ArrowUpRight className="w-3.5 h-3.5" />
                </Link>
              </div>

              {reports.length === 0 ? (
                <div className="py-12 text-center text-sm text-neutral-500">
                  No pending incident reports.
                </div>
              ) : (
                <div className="space-y-3.5">
                  {reports.map((report) => (
                    <div
                      key={report.id}
                      className="p-4 rounded-xl bg-neutral-900 border border-neutral-800 flex items-start justify-between gap-4"
                    >
                      <div>
                        <div className="flex items-center gap-2">
                          <span className="text-xs font-semibold text-white">{report.reportedName}</span>
                          <span className="text-[10px] uppercase font-bold tracking-wider px-2 py-0.5 rounded-full bg-rose-500/20 text-rose-400 border border-rose-500/30">
                            {report.category}
                          </span>
                        </div>
                        <p className="text-xs text-neutral-400 mt-1 line-clamp-2">
                          {report.details}
                        </p>
                        <span className="text-[10px] text-neutral-500 mt-2 block">
                          Reported by {report.reporterName} • {report.createdAt}
                        </span>
                      </div>

                      <button
                        onClick={() => handleDismissReport(report.id)}
                        className="px-3 py-1.5 rounded-lg bg-neutral-800 hover:bg-neutral-700 text-xs text-white font-medium whitespace-nowrap transition-colors"
                      >
                        Resolve
                      </button>
                    </div>
                  ))}
                </div>
              )}
            </div>

            <p className="text-[11px] text-neutral-500 mt-4">
              All reported profiles are auto-isolated until reviewed by trust operations.
            </p>
          </div>
        </div>
      </div>
    </div>
  );
}
