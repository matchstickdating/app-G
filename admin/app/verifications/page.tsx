'use client';

import React, { useState } from 'react';
import { Header } from '@/components/Header';
import { 
  AdminRole, 
  MOCK_VERIFICATIONS, 
  VerificationRequest 
} from '@/lib/mockData';
import { 
  ShieldCheck, 
  Check, 
  X, 
  CheckCircle2, 
  AlertCircle 
} from 'lucide-react';

export default function VerificationsPage() {
  const [currentRole, setCurrentRole] = useState<AdminRole>('moderator');
  const [queue, setQueue] = useState<VerificationRequest[]>(MOCK_VERIFICATIONS);
  const [selectedId, setSelectedId] = useState<string>(queue[0]?.id ?? '');
  const [toastMessage, setToastMessage] = useState<string | null>(null);

  const selectedItem = queue.find((v) => v.id === selectedId) ?? queue[0];

  const handleApprove = (id: string) => {
    setQueue((prev) => prev.filter((v) => v.id !== id));
    setToastMessage('Verification approved. Official badge awarded to user.');
    setTimeout(() => setToastMessage(null), 3000);
  };

  const handleReject = (id: string) => {
    setQueue((prev) => prev.filter((v) => v.id !== id));
    setToastMessage('Verification rejected. User prompted to re-submit with clear pose.');
    setTimeout(() => setToastMessage(null), 3000);
  };

  return (
    <div className="flex-1 flex flex-col min-h-screen bg-[#101010]">
      <Header currentRole={currentRole} onRoleChange={setCurrentRole} />

      <div className="p-8 space-y-6 max-w-7xl mx-auto w-full">
        {/* Page Title */}
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-2xl font-bold text-white tracking-tight">Photo Verification Queue</h1>
            <p className="text-sm text-neutral-400 mt-1">
              Biometric pose verification review. Validate real identity against registered portfolio photos.
            </p>
          </div>
          <div className="flex items-center gap-2 bg-emerald-500/10 border border-emerald-500/20 text-emerald-400 px-3 py-1.5 rounded-lg text-xs font-medium">
            <ShieldCheck className="w-4 h-4" />
            <span>{queue.length} Pending Submissions</span>
          </div>
        </div>

        {/* Toast Notification */}
        {toastMessage && (
          <div className="bg-emerald-500/20 border border-emerald-500/40 text-emerald-300 px-4 py-2.5 rounded-xl text-sm flex items-center gap-2">
            <CheckCircle2 className="w-4 h-4" />
            <span>{toastMessage}</span>
          </div>
        )}

        {queue.length === 0 ? (
          <div className="bg-[#161616] border border-neutral-800 rounded-2xl p-16 text-center">
            <div className="w-12 h-12 rounded-full bg-emerald-500/10 text-emerald-400 mx-auto flex items-center justify-center mb-4">
              <Check className="w-6 h-6" />
            </div>
            <h2 className="text-base font-semibold text-white">All Submissions Processed</h2>
            <p className="text-sm text-neutral-400 mt-1">
              There are no pending photo verifications in the queue right now.
            </p>
          </div>
        ) : (
          <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
            {/* Queue List (Left Column) */}
            <div className="space-y-3">
              <h2 className="text-xs font-semibold text-neutral-400 uppercase tracking-wider px-1">
                Queue ({queue.length})
              </h2>
              {queue.map((req) => {
                const isSelected = req.id === selectedItem?.id;
                return (
                  <div
                    key={req.id}
                    onClick={() => setSelectedId(req.id)}
                    className={`p-4 rounded-2xl border cursor-pointer transition-all ${
                      isSelected
                        ? 'bg-[#1c1c1c] border-[#FF5C5C]/50 shadow-md'
                        : 'bg-[#161616] border-neutral-800/80 hover:border-neutral-700'
                    }`}
                  >
                    <div className="flex items-center gap-3">
                      {/* eslint-disable-next-line @next/next/no-img-element */}
                      <img
                        src={req.primaryPhotoUrl}
                        alt={req.userName}
                        className="w-10 h-10 rounded-full object-cover border border-neutral-800"
                      />
                      <div className="flex-1 min-w-0">
                        <div className="flex items-center justify-between">
                          <h3 className="text-sm font-semibold text-white truncate">{req.userName}</h3>
                          <span className="text-[10px] text-neutral-500">{req.submittedAt}</span>
                        </div>
                        <p className="text-xs text-neutral-400 truncate mt-0.5">
                          Pose: &ldquo;{req.requestedPose}&rdquo;
                        </p>
                      </div>
                    </div>
                  </div>
                );
              })}
            </div>

            {/* Inspection & Comparison Area (Right Column) */}
            {selectedItem && (
              <div className="lg:col-span-2 bg-[#161616] border border-neutral-800/80 rounded-2xl p-6 flex flex-col justify-between">
                <div>
                  {/* Subject Details Bar */}
                  <div className="flex items-center justify-between pb-6 border-b border-neutral-800">
                    <div>
                      <h2 className="text-lg font-bold text-white">
                        {selectedItem.userName}, {selectedItem.userAge}
                      </h2>
                      <p className="text-xs text-neutral-400 mt-0.5">
                        Submitted {selectedItem.submittedAt} • Requested Pose: &ldquo;{selectedItem.requestedPose}&rdquo;
                      </p>
                    </div>

                    <div className="flex items-center gap-2 px-3 py-1.5 rounded-xl bg-neutral-900 border border-neutral-800">
                      <span className="text-xs text-neutral-400">Match Confidence:</span>
                      <span className="text-xs font-bold text-emerald-400">
                        {(selectedItem.confidenceScore * 100).toFixed(0)}%
                      </span>
                    </div>
                  </div>

                  {/* Side-by-side Images */}
                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-6 my-6">
                    {/* Primary Profile Image */}
                    <div>
                      <div className="flex items-center justify-between mb-2">
                        <span className="text-xs font-medium text-neutral-400">Profile Primary Photo</span>
                        <span className="text-[10px] text-neutral-500 uppercase font-mono">Reference</span>
                      </div>
                      <div className="relative aspect-[3/4] rounded-2xl overflow-hidden border border-neutral-800 bg-neutral-900">
                        {/* eslint-disable-next-line @next/next/no-img-element */}
                        <img
                          src={selectedItem.primaryPhotoUrl}
                          alt="Primary Profile"
                          className="w-full h-full object-cover"
                        />
                      </div>
                    </div>

                    {/* Submitted Pose Selfie */}
                    <div>
                      <div className="flex items-center justify-between mb-2">
                        <span className="text-xs font-medium text-neutral-400">Biometric Verification Selfie</span>
                        <span className="text-[10px] text-[#FF5C5C] uppercase font-mono font-semibold">Live Capture</span>
                      </div>
                      <div className="relative aspect-[3/4] rounded-2xl overflow-hidden border-2 border-[#FF5C5C]/60 bg-neutral-900 shadow-md">
                        {/* eslint-disable-next-line @next/next/no-img-element */}
                        <img
                          src={selectedItem.selfieUrl}
                          alt="Verification Selfie"
                          className="w-full h-full object-cover"
                        />
                      </div>
                    </div>
                  </div>

                  {/* Verification Checklist */}
                  <div className="bg-neutral-900/60 border border-neutral-800 rounded-xl p-4 space-y-2">
                    <span className="text-xs font-semibold text-neutral-300 block mb-2">Operator Inspection Rules:</span>
                    <div className="flex items-center gap-2 text-xs text-neutral-400">
                      <CheckCircle2 className="w-3.5 h-3.5 text-emerald-400 shrink-0" />
                      <span>Facial structure and bone structure match reference profile photo</span>
                    </div>
                    <div className="flex items-center gap-2 text-xs text-neutral-400">
                      <CheckCircle2 className="w-3.5 h-3.5 text-emerald-400 shrink-0" />
                      <span>User followed requested gesture: &ldquo;{selectedItem.requestedPose}&rdquo;</span>
                    </div>
                    <div className="flex items-center gap-2 text-xs text-neutral-400">
                      <AlertCircle className="w-3.5 h-3.5 text-amber-400 shrink-0" />
                      <span>Confirm image is a live photo, not a pre-rendered or filtered photo</span>
                    </div>
                  </div>
                </div>

                {/* Bottom Actions */}
                <div className="flex items-center justify-end gap-3 pt-6 border-t border-neutral-800 mt-6">
                  <button
                    onClick={() => handleReject(selectedItem.id)}
                    className="flex items-center gap-2 px-5 py-2.5 rounded-xl border border-neutral-700 hover:bg-neutral-800 text-sm font-medium text-neutral-300 transition-colors"
                  >
                    <X className="w-4 h-4 text-rose-400" />
                    Reject Verification
                  </button>
                  <button
                    onClick={() => handleApprove(selectedItem.id)}
                    className="flex items-center gap-2 px-6 py-2.5 rounded-xl bg-emerald-600 hover:bg-emerald-500 text-sm font-medium text-white shadow-sm transition-colors"
                  >
                    <Check className="w-4 h-4" />
                    Approve & Award Badge
                  </button>
                </div>
              </div>
            )}
          </div>
        )}
      </div>
    </div>
  );
}
