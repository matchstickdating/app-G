'use client';

import React, { useState } from 'react';
import { Header } from '@/components/Header';
import { AdminRole, MOCK_AI_ANALYTICS } from '@/lib/mockData';
import { 
  Sparkles, 
  Zap, 
  Cpu, 
  Activity, 
  ShieldCheck, 
  MessageSquare, 
  Calendar 
} from 'lucide-react';

export default function AiAnalyticsPage() {
  const [currentRole, setCurrentRole] = useState<AdminRole>('admin');

  return (
    <div className="flex-1 flex flex-col min-h-screen bg-[#101010]">
      <Header currentRole={currentRole} onRoleChange={setCurrentRole} />

      <div className="p-8 space-y-8 max-w-7xl mx-auto w-full">
        {/* Title */}
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-2xl font-bold text-white tracking-tight">AI Intelligence & Telemetry</h1>
            <p className="text-sm text-neutral-400 mt-1">
              Provider-agnostic inference metrics, token consumption, latency telemetry, and grounding compliance.
            </p>
          </div>
          <div className="flex items-center gap-2 bg-indigo-500/10 border border-indigo-500/20 text-indigo-400 px-3 py-1.5 rounded-lg text-xs font-medium">
            <Cpu className="w-4 h-4" />
            <span>Dual Router Active (Gemini + OpenAI)</span>
          </div>
        </div>

        {/* Top KPIs */}
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
          <div className="bg-[#161616] border border-neutral-800 rounded-2xl p-5 space-y-2">
            <div className="flex items-center justify-between text-neutral-400 text-xs font-medium">
              <span>Token Burn (Month)</span>
              <Sparkles className="w-4 h-4 text-indigo-400" />
            </div>
            <span className="text-2xl font-bold text-white">4.89M</span>
            <p className="text-[11px] text-neutral-500">92% within free/subsidized tier</p>
          </div>

          <div className="bg-[#161616] border border-neutral-800 rounded-2xl p-5 space-y-2">
            <div className="flex items-center justify-between text-neutral-400 text-xs font-medium">
              <span>Average Latency</span>
              <Zap className="w-4 h-4 text-amber-400" />
            </div>
            <span className="text-2xl font-bold text-white">{MOCK_AI_ANALYTICS.avgLatencyMs}ms</span>
            <p className="text-[11px] text-emerald-400 font-medium">-120ms from last release</p>
          </div>

          <div className="bg-[#161616] border border-neutral-800 rounded-2xl p-5 space-y-2">
            <div className="flex items-center justify-between text-neutral-400 text-xs font-medium">
              <span>Starters Synthesized</span>
              <MessageSquare className="w-4 h-4 text-[#FF5C5C]" />
            </div>
            <span className="text-2xl font-bold text-white">{MOCK_AI_ANALYTICS.startersGeneratedToday}</span>
            <p className="text-[11px] text-neutral-500">past 24 hours</p>
          </div>

          <div className="bg-[#161616] border border-neutral-800 rounded-2xl p-5 space-y-2">
            <div className="flex items-center justify-between text-neutral-400 text-xs font-medium">
              <span>Date Plans Generated</span>
              <Calendar className="w-4 h-4 text-emerald-400" />
            </div>
            <span className="text-2xl font-bold text-white">{MOCK_AI_ANALYTICS.datePlansCreatedToday}</span>
            <p className="text-[11px] text-neutral-500">past 24 hours</p>
          </div>
        </div>

        {/* Model Breakdown & Provider Routing */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
          {/* Provider Traffic Split */}
          <div className="bg-[#161616] border border-neutral-800 rounded-2xl p-6 space-y-6">
            <div>
              <h2 className="text-base font-semibold text-white">Provider Traffic Distribution</h2>
              <p className="text-xs text-neutral-400 mt-1">
                Inference router dynamically selects Google Gemini or OpenAI based on availability and query type.
              </p>
            </div>

            <div className="space-y-4">
              {MOCK_AI_ANALYTICS.modelBreakdown.map((item) => (
                <div key={item.model} className="space-y-2">
                  <div className="flex items-center justify-between text-xs">
                    <span className="font-semibold text-neutral-200">{item.model}</span>
                    <span className="text-neutral-400 font-mono">
                      {item.percentage}% ({item.requests.toLocaleString()} calls)
                    </span>
                  </div>
                  <div className="w-full bg-neutral-900 h-2.5 rounded-full overflow-hidden border border-neutral-800">
                    <div
                      className={`h-full rounded-full ${
                        item.model.includes('Gemini')
                          ? 'bg-indigo-500'
                          : item.model.includes('mini')
                          ? 'bg-emerald-500'
                          : 'bg-[#FF5C5C]'
                      }`}
                      style={{ width: `${item.percentage}%` }}
                    />
                  </div>
                </div>
              ))}
            </div>

            <div className="p-4 rounded-xl bg-neutral-900 border border-neutral-800 flex items-center justify-between text-xs text-neutral-400">
              <span>Fallback Health Status:</span>
              <span className="text-emerald-400 font-semibold flex items-center gap-1.5">
                <span className="w-2 h-2 rounded-full bg-emerald-500" />
                Automatic Failover Ready
              </span>
            </div>
          </div>

          {/* Ethics & Grounding Guardrails */}
          <div className="bg-[#161616] border border-neutral-800 rounded-2xl p-6 space-y-6 flex flex-col justify-between">
            <div>
              <h2 className="text-base font-semibold text-white">Editorial Grounding & Ethics Compliance</h2>
              <p className="text-xs text-neutral-400 mt-1">
                Strict boundary enforcement to preserve authentic human connection.
              </p>

              <div className="mt-6 space-y-3.5">
                <div className="p-4 rounded-xl bg-neutral-900 border border-neutral-800 flex items-start gap-3">
                  <ShieldCheck className="w-5 h-5 text-emerald-400 shrink-0 mt-0.5" />
                  <div>
                    <h3 className="text-xs font-semibold text-white">Strict Mutual Fact Grounding</h3>
                    <p className="text-xs text-neutral-400 mt-0.5">
                      Conversation starters are mathematically derived strictly from mutual profile facts. Zero fabricated shared interests.
                    </p>
                  </div>
                </div>

                <div className="p-4 rounded-xl bg-neutral-900 border border-neutral-800 flex items-start gap-3">
                  <ShieldCheck className="w-5 h-5 text-emerald-400 shrink-0 mt-0.5" />
                  <div>
                    <h3 className="text-xs font-semibold text-white">100% Human-In-The-Loop</h3>
                    <p className="text-xs text-neutral-400 mt-0.5">
                      No automated auto-messaging is permitted. Every suggestion must be reviewed and explicitly triggered by the user.
                    </p>
                  </div>
                </div>

                <div className="p-4 rounded-xl bg-neutral-900 border border-neutral-800 flex items-start gap-3">
                  <Activity className="w-5 h-5 text-indigo-400 shrink-0 mt-0.5" />
                  <div>
                    <h3 className="text-xs font-semibold text-white">Zero Cliché Voice Modulation</h3>
                    <p className="text-xs text-neutral-400 mt-0.5">
                      Editorial prompt constraints filter out algorithmic dating clichés (&ldquo;fluent in sarcasm&rdquo;, &ldquo;wanderlust&rdquo;).
                    </p>
                  </div>
                </div>
              </div>
            </div>

            <p className="text-[11px] text-neutral-500">
              Telemetry pipeline adheres to zero data retention for private model training.
            </p>
          </div>
        </div>
      </div>
    </div>
  );
}
