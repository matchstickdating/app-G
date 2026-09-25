'use client';

import React, { useState } from 'react';
import { Header } from '@/components/Header';
import { 
  AdminRole, 
  MOCK_REPORTS, 
  ModerationReport 
} from '@/lib/mockData';
import { 
  ShieldAlert, 
  Check, 
  AlertTriangle, 
  Clock, 
  UserX, 
  CheckCircle2 
} from 'lucide-react';

export default function ReportsPage() {
  const [currentRole, setCurrentRole] = useState<AdminRole>('admin');
  const [reports, setReports] = useState<ModerationReport[]>(MOCK_REPORTS);
  const [selectedId, setSelectedId] = useState<string>(reports[0]?.id ?? '');
  const [toastMessage, setToastMessage] = useState<string | null>(null);

  const selectedReport = reports.find((r) => r.id === selectedId) ?? reports[0];

  const handleAction = (id: string, actionName: string) => {
    setReports((prev) => prev.filter((r) => r.id !== id));
    setToastMessage(`Action completed: ${actionName}`);
    setTimeout(() => setToastMessage(null), 3000);
  };

  return (
    <div className="flex-1 flex flex-col min-h-screen bg-[#101010]">
      <Header currentRole={currentRole} onRoleChange={setCurrentRole} />

      <div className="p-8 space-y-6 max-w-7xl mx-auto w-full">
        {/* Page Title */}
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-2xl font-bold text-white tracking-tight">Trust & Safety Incident Triage</h1>
            <p className="text-sm text-neutral-400 mt-1">
              Review flagged accounts, harassment reports, and commercial scam solicitations.
            </p>
          </div>
          <div className="flex items-center gap-2 bg-rose-500/10 border border-rose-500/20 text-rose-400 px-3 py-1.5 rounded-lg text-xs font-medium">
            <ShieldAlert className="w-4 h-4" />
            <span>{reports.length} Incidents Open</span>
          </div>
        </div>

        {/* Toast */}
        {toastMessage && (
          <div className="bg-emerald-500/20 border border-emerald-500/40 text-emerald-300 px-4 py-2.5 rounded-xl text-sm flex items-center gap-2">
            <CheckCircle2 className="w-4 h-4" />
            <span>{toastMessage}</span>
          </div>
        )}

        {reports.length === 0 ? (
          <div className="bg-[#161616] border border-neutral-800 rounded-2xl p-16 text-center">
            <div className="w-12 h-12 rounded-full bg-emerald-500/10 text-emerald-400 mx-auto flex items-center justify-center mb-4">
              <Check className="w-6 h-6" />
            </div>
            <h2 className="text-base font-semibold text-white">All Reports Resolved</h2>
            <p className="text-sm text-neutral-400 mt-1">
              No outstanding safety or moderation incidents require attention.
            </p>
          </div>
        ) : (
          <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
            {/* Reports List */}
            <div className="space-y-3">
              <h2 className="text-xs font-semibold text-neutral-400 uppercase tracking-wider px-1">
                Active Reports ({reports.length})
              </h2>
              {reports.map((report) => {
                const isSelected = report.id === selectedReport?.id;
                return (
                  <div
                    key={report.id}
                    onClick={() => setSelectedId(report.id)}
                    className={`p-4 rounded-2xl border cursor-pointer transition-all ${
                      isSelected
                        ? 'bg-[#1c1c1c] border-[#FF5C5C]/50 shadow-md'
                        : 'bg-[#161616] border-neutral-800/80 hover:border-neutral-700'
                    }`}
                  >
                    <div className="flex items-center justify-between">
                      <span className="text-sm font-semibold text-white truncate">
                        {report.reportedName}
                      </span>
                      <span className="text-[10px] uppercase font-bold tracking-wider px-2 py-0.5 rounded-full bg-rose-500/20 text-rose-400 border border-rose-500/30">
                        {report.severity}
                      </span>
                    </div>
                    <p className="text-xs text-neutral-400 mt-1.5 line-clamp-2">
                      {report.details}
                    </p>
                    <div className="flex items-center gap-2 mt-3 text-[10px] text-neutral-500">
                      <Clock className="w-3 h-3" />
                      <span>{report.createdAt}</span>
                      <span>•</span>
                      <span>By {report.reporterName}</span>
                    </div>
                  </div>
                );
              })}
            </div>

            {/* Incident Details & Resolution */}
            {selectedReport && (
              <div className="lg:col-span-2 bg-[#161616] border border-neutral-800/80 rounded-2xl p-6 flex flex-col justify-between">
                <div>
                  <div className="flex items-center justify-between pb-6 border-b border-neutral-800">
                    <div>
                      <div className="flex items-center gap-3">
                        <h2 className="text-lg font-bold text-white">
                          Incident #{selectedReport.id}: {selectedReport.reportedName}
                        </h2>
                        <span className="text-xs font-semibold px-2.5 py-0.5 rounded-full bg-rose-500/15 text-rose-400 border border-rose-500/30 uppercase">
                          {selectedReport.category}
                        </span>
                      </div>
                      <p className="text-xs text-neutral-400 mt-1">
                        Reported by {selectedReport.reporterName} • {selectedReport.createdAt}
                      </p>
                    </div>
                  </div>

                  {/* Incident Summary */}
                  <div className="my-6 space-y-4">
                    <div>
                      <h3 className="text-xs font-semibold text-neutral-400 uppercase tracking-wider mb-2">
                        Reporter&rsquo;s Statement
                      </h3>
                      <div className="bg-neutral-900 border border-neutral-800 rounded-xl p-4 text-sm text-neutral-200 leading-relaxed">
                        &ldquo;{selectedReport.details}&rdquo;
                      </div>
                    </div>

                    {/* Auto-Isolation Notice */}
                    <div className="bg-amber-500/10 border border-amber-500/20 rounded-xl p-4 flex items-start gap-3">
                      <AlertTriangle className="w-5 h-5 text-amber-400 shrink-0 mt-0.5" />
                      <div className="text-xs text-amber-300 leading-relaxed">
                        <span className="font-semibold block mb-0.5">Automated Safety Protocol Active:</span>
                        This reported account has been automatically hidden from the discovery feed and prevented from initiating new matches pending operator review.
                      </div>
                    </div>
                  </div>
                </div>

                {/* Resolution Controls */}
                <div className="pt-6 border-t border-neutral-800 flex flex-wrap items-center justify-between gap-3">
                  <button
                    onClick={() => handleAction(selectedReport.id, 'Dismissed as false report')}
                    className="px-4 py-2.5 rounded-xl border border-neutral-700 hover:bg-neutral-800 text-xs font-medium text-neutral-300 transition-colors"
                  >
                    Dismiss Report
                  </button>

                  <div className="flex items-center gap-2">
                    <button
                      onClick={() => handleAction(selectedReport.id, 'Formal warning sent to user')}
                      className="px-4 py-2.5 rounded-xl bg-amber-500/10 hover:bg-amber-500/20 border border-amber-500/30 text-amber-300 text-xs font-semibold transition-colors"
                    >
                      Issue Warning
                    </button>
                    <button
                      onClick={() => handleAction(selectedReport.id, 'Account suspended for 7 days')}
                      className="px-4 py-2.5 rounded-xl bg-neutral-800 hover:bg-neutral-700 text-neutral-200 text-xs font-semibold transition-colors"
                    >
                      Suspend (7 Days)
                    </button>
                    <button
                      onClick={() => handleAction(selectedReport.id, 'Account permanently banned')}
                      className="flex items-center gap-1.5 px-5 py-2.5 rounded-xl bg-rose-600 hover:bg-rose-500 text-white text-xs font-semibold shadow-sm transition-colors"
                    >
                      <UserX className="w-3.5 h-3.5" />
                      Permanent Ban
                    </button>
                  </div>
                </div>
              </div>
            )}
          </div>
        )}
      </div>
    </div>
  );
}
