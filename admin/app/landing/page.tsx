'use client';

import React, { useState } from 'react';
import Link from 'next/link';
import { 
  Flame, 
  ArrowRight, 
  ShieldCheck, 
  Sparkles, 
  Calendar, 
  Compass, 
  Heart, 
  Coffee, 
  CheckCircle2,
  Lock,
  ChevronRight,
  ExternalLink
} from 'lucide-react';

export default function LandingPage() {
  const [activeTab, setActiveTab] = useState<'discovery' | 'planner' | 'lounges'>('discovery');
  const [email, setEmail] = useState('');
  const [submitted, setSubmitted] = useState(false);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (email.trim()) {
      setSubmitted(true);
    }
  };

  return (
    <div className="min-h-screen bg-[#0E0E0E] text-[#F7F6F2] font-sans selection:bg-[#FF5C5C]/30 selection:text-white">
      {/* Floating Glassmorphism Navigation */}
      <header className="fixed top-5 inset-x-0 z-50 flex justify-center px-4">
        <nav className="max-w-5xl w-full backdrop-blur-md bg-[#161616]/80 border border-white/10 rounded-full px-6 py-3 flex items-center justify-between shadow-2xl">
          <div className="flex items-center gap-3">
            <div className="w-8 h-8 rounded-full bg-[#FF5C5C] flex items-center justify-center text-white shadow-sm shadow-[#FF5C5C]/40">
              <Flame className="w-4 h-4 fill-white" />
            </div>
            <span className="font-bold text-sm tracking-tight text-white uppercase">MATCH STICK</span>
          </div>

          <div className="hidden md:flex items-center gap-8 text-xs font-medium text-neutral-300">
            <a href="#philosophy" className="hover:text-white transition-colors">Philosophy</a>
            <a href="#experience" className="hover:text-white transition-colors">The App</a>
            <a href="#date-planner" className="hover:text-white transition-colors">Date Planner</a>
            <a href="#safety" className="hover:text-white transition-colors">Trust & Safety</a>
            <a href="#membership" className="hover:text-white transition-colors">Studio</a>
          </div>

          <div className="flex items-center gap-3">
            <Link
              href="/"
              className="text-xs font-medium text-neutral-400 hover:text-white hidden sm:block transition-colors"
            >
              Control Portal
            </Link>
            <a
              href="#download"
              className="px-4 py-2 rounded-full bg-[#FF5C5C] hover:bg-[#E84A4A] text-white text-xs font-semibold tracking-wide transition-all shadow-sm shadow-[#FF5C5C]/30"
            >
              Get Match Stick
            </a>
          </div>
        </nav>
      </header>

      {/* Hero Section */}
      <section className="relative pt-44 pb-24 px-6 max-w-6xl mx-auto text-center overflow-hidden">
        {/* Ambient Glow */}
        <div className="absolute top-1/4 left-1/2 -translate-x-1/2 -translate-y-1/2 w-96 h-96 bg-[#FF5C5C]/15 rounded-full blur-[120px] pointer-events-none" />

        <div className="inline-flex items-center gap-2 px-3.5 py-1.5 rounded-full bg-white/5 border border-white/10 text-xs font-mono text-neutral-300 mb-8 backdrop-blur-sm">
          <Sparkles className="w-3.5 h-3.5 text-[#FF5C5C]" />
          <span>INTENTIONAL DATING FOR MODERN CULTIVATORS</span>
        </div>

        <h1 className="text-5xl sm:text-7xl lg:text-8xl font-black tracking-tight text-white leading-[1.05] max-w-4xl mx-auto lowercase">
          less swiping. <br />
          <span className="text-transparent bg-clip-text bg-gradient-to-r from-white via-neutral-200 to-[#FF5C5C]">
            more connection.
          </span>
        </h1>

        <p className="mt-8 text-base sm:text-lg text-neutral-400 max-w-2xl mx-auto leading-relaxed">
          An unhurried dating platform engineered around authentic taste, contextual AI date curation, and genuine chemistry. No endless casino swiping. Just intentional connections.
        </p>

        {/* Early Access Form */}
        <div className="mt-10 max-w-md mx-auto" id="download">
          {submitted ? (
            <div className="p-4 rounded-2xl bg-emerald-500/10 border border-emerald-500/30 text-emerald-300 text-sm flex items-center justify-center gap-2">
              <CheckCircle2 className="w-4 h-4 text-emerald-400" />
              <span>You are on the VIP waitlist. We will notify you shortly.</span>
            </div>
          ) : (
            <form onSubmit={handleSubmit} className="flex flex-col sm:flex-row gap-2">
              <input
                type="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                placeholder="Enter your email for invite access..."
                required
                className="flex-1 bg-white/5 border border-white/15 px-4 py-3 rounded-full text-sm text-white placeholder:text-neutral-500 focus:outline-none focus:border-[#FF5C5C]"
              />
              <button
                type="submit"
                className="px-6 py-3 rounded-full bg-white text-black hover:bg-neutral-200 font-semibold text-sm transition-colors whitespace-nowrap"
              >
                Join Waitlist
              </button>
            </form>
          )}
          <span className="text-[11px] text-neutral-500 mt-3 block">
            Now testing in Tokyo, London, Paris, San Francisco & Chennai.
          </span>
        </div>
      </section>

      {/* Interactive App Showcase Window */}
      <section className="py-16 px-6 max-w-5xl mx-auto" id="experience">
        <div className="bg-[#151515] border border-white/10 rounded-3xl p-6 sm:p-10 shadow-2xl">
          {/* Switcher Bar */}
          <div className="flex items-center justify-center gap-2 mb-10">
            <button
              onClick={() => setActiveTab('discovery')}
              className={`px-4 py-2 rounded-full text-xs font-semibold transition-all ${
                activeTab === 'discovery'
                  ? 'bg-[#FF5C5C] text-white shadow-md'
                  : 'bg-white/5 text-neutral-400 hover:text-white'
              }`}
            >
              Intentional Discovery
            </button>
            <button
              onClick={() => setActiveTab('planner')}
              className={`px-4 py-2 rounded-full text-xs font-semibold transition-all ${
                activeTab === 'planner'
                  ? 'bg-[#FF5C5C] text-white shadow-md'
                  : 'bg-white/5 text-neutral-400 hover:text-white'
              }`}
            >
              AI Date Planner
            </button>
            <button
              onClick={() => setActiveTab('lounges')}
              className={`px-4 py-2 rounded-full text-xs font-semibold transition-all ${
                activeTab === 'lounges'
                  ? 'bg-[#FF5C5C] text-white shadow-md'
                  : 'bg-white/5 text-neutral-400 hover:text-white'
              }`}
            >
              Interest Lounges
            </button>
          </div>

          {/* Interactive Screen Preview */}
          <div className="max-w-md mx-auto aspect-[9/16] max-h-[640px] bg-[#1A1A1A] rounded-[40px] border-4 border-neutral-700/60 p-4 flex flex-col justify-between overflow-hidden shadow-2xl relative">
            {/* Notch */}
            <div className="w-28 h-5 bg-black rounded-full mx-auto mb-4" />

            {/* Screen Content by Active Tab */}
            {activeTab === 'discovery' && (
              <div className="flex-1 flex flex-col justify-between">
                <div className="relative aspect-[3/4] rounded-2xl overflow-hidden border border-white/10">
                  {/* eslint-disable-next-line @next/next/no-img-element */}
                  <img
                    src="https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=800"
                    alt="Elena"
                    className="w-full h-full object-cover"
                  />
                  <div className="absolute inset-0 bg-gradient-to-t from-black/80 via-transparent to-black/30 p-5 flex flex-col justify-between">
                    <div className="flex justify-between items-center">
                      <span className="px-2.5 py-1 rounded-full bg-black/60 backdrop-blur-md text-[10px] font-semibold text-emerald-400 border border-emerald-500/30">
                        94% chemistry
                      </span>
                      <span className="w-6 h-6 rounded-full bg-white/20 backdrop-blur-md flex items-center justify-center text-xs">
                        ✦
                      </span>
                    </div>

                    <div>
                      <h3 className="text-xl font-bold text-white">Elena, 25</h3>
                      <p className="text-xs text-neutral-300 mt-1 line-clamp-2">
                        documentary filmmaker. analog vinyl and finding quiet reading corners.
                      </p>
                      <div className="flex gap-1.5 mt-3">
                        <span className="px-2 py-0.5 rounded-md bg-white/15 text-[10px] font-medium text-neutral-200">
                          literature
                        </span>
                        <span className="px-2 py-0.5 rounded-md bg-white/15 text-[10px] font-medium text-neutral-200">
                          35mm film
                        </span>
                        <span className="px-2 py-0.5 rounded-md bg-white/15 text-[10px] font-medium text-neutral-200">
                          vinyl
                        </span>
                      </div>
                    </div>
                  </div>
                </div>

                <div className="flex items-center justify-center gap-6 py-4">
                  <div className="w-12 h-12 rounded-full border border-neutral-700 flex items-center justify-center text-neutral-400">
                    ✕
                  </div>
                  <div className="w-14 h-14 rounded-full bg-[#FF5C5C] flex items-center justify-center text-white shadow-lg shadow-[#FF5C5C]/40">
                    <Heart className="w-6 h-6 fill-white" />
                  </div>
                </div>
              </div>
            )}

            {activeTab === 'planner' && (
              <div className="flex-1 flex flex-col justify-between text-left p-2">
                <div>
                  <div className="flex items-center justify-between mb-4">
                    <span className="text-[11px] font-mono text-[#FF5C5C]">DATE ITINERARY</span>
                    <span className="text-[10px] px-2 py-0.5 rounded bg-white/10 text-neutral-300">
                      Cozy • $$
                    </span>
                  </div>
                  <h3 className="text-base font-bold text-white mb-1">an intentional evening in Shibuya</h3>
                  <p className="text-xs text-neutral-400 mb-4">
                    3 stops curated around vinyl records & quiet coffee.
                  </p>

                  <div className="space-y-3">
                    <div className="p-3 rounded-xl bg-white/5 border border-white/10 flex items-start gap-3">
                      <span className="text-xs font-mono text-neutral-400">5:30 PM</span>
                      <div>
                        <h4 className="text-xs font-semibold text-white">Fuglen Tokyo</h4>
                        <p className="text-[10px] text-neutral-400">pour-over coffee & conversation</p>
                      </div>
                    </div>
                    <div className="p-3 rounded-xl bg-white/5 border border-white/10 flex items-start gap-3">
                      <span className="text-xs font-mono text-neutral-400">6:45 PM</span>
                      <div>
                        <h4 className="text-xs font-semibold text-white">Yoyogi Park Promenade</h4>
                        <p className="text-[10px] text-neutral-400">relaxed golden hour stroll</p>
                      </div>
                    </div>
                    <div className="p-3 rounded-xl bg-white/5 border border-white/10 flex items-start gap-3">
                      <span className="text-xs font-mono text-neutral-400">7:45 PM</span>
                      <div>
                        <h4 className="text-xs font-semibold text-white">Lion Sound Listening Bar</h4>
                        <p className="text-[10px] text-neutral-400">vintage jazz & natural wine</p>
                      </div>
                    </div>
                  </div>
                </div>

                <button className="w-full py-2.5 rounded-xl bg-[#FF5C5C] text-white text-xs font-semibold mt-4">
                  Share Itinerary with Match
                </button>
              </div>
            )}

            {activeTab === 'lounges' && (
              <div className="flex-1 flex flex-col justify-between text-left p-2">
                <div>
                  <div className="p-3 rounded-xl bg-white/5 border border-white/10 mb-4 flex items-center gap-3">
                    <div className="w-9 h-9 rounded-lg bg-[#FF5C5C]/20 flex items-center justify-center text-[#FF5C5C]">
                      <Coffee className="w-5 h-5" />
                    </div>
                    <div>
                      <h4 className="text-xs font-bold text-white">specialty coffee & quiet reads</h4>
                      <p className="text-[10px] text-neutral-400">1,420 members • active lounge</p>
                    </div>
                  </div>

                  <div className="p-3.5 rounded-xl bg-neutral-900 border border-neutral-800 space-y-2">
                    <div className="flex items-center gap-2">
                      <div className="w-6 h-6 rounded-full bg-neutral-700" />
                      <span className="text-xs font-semibold text-white">Julian, 29</span>
                    </div>
                    <p className="text-xs text-neutral-300">
                      &ldquo;tried an Ethiopian natural process with notes of bergamot and wild jasmine this morning. quiet bliss.&rdquo;
                    </p>
                    <div className="flex items-center gap-4 text-[10px] text-neutral-500 pt-1">
                      <span>♥ 31 likes</span>
                      <span>💬 4 replies</span>
                    </div>
                  </div>
                </div>

                <button className="w-full py-2.5 rounded-xl bg-neutral-800 text-white text-xs font-semibold mt-4">
                  ✦ Share Observation
                </button>
              </div>
            )}
          </div>
        </div>
      </section>

      {/* Product Pillars / Philosophy */}
      <section className="py-24 px-6 max-w-6xl mx-auto" id="philosophy">
        <div className="text-center max-w-2xl mx-auto mb-16">
          <span className="text-xs font-mono text-[#FF5C5C] uppercase tracking-wider block mb-2">
            THE MATCH STICK DOCTRINE
          </span>
          <h2 className="text-3xl sm:text-4xl font-bold text-white tracking-tight">
            Why traditional dating apps are designed for burnout.
          </h2>
          <p className="text-sm text-neutral-400 mt-4 leading-relaxed">
            Mainstream platforms profit from your loneliness by keeping you trapped in an infinite swipe slot machine. Match Stick was constructed on opposite incentives.
          </p>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          <div className="bg-[#151515] border border-white/10 rounded-3xl p-8 space-y-4">
            <div className="w-10 h-10 rounded-2xl bg-white/5 border border-white/10 flex items-center justify-center text-white">
              <Compass className="w-5 h-5 text-[#FF5C5C]" />
            </div>
            <h3 className="text-lg font-bold text-white">20 Curated Matches Daily</h3>
            <p className="text-xs text-neutral-400 leading-relaxed">
              We cap discovery to 20 intentional profiles every 24 hours. No bottomless feeds. When you take time to read, real conversations start.
            </p>
          </div>

          <div className="bg-[#151515] border border-white/10 rounded-3xl p-8 space-y-4">
            <div className="w-10 h-10 rounded-2xl bg-white/5 border border-white/10 flex items-center justify-center text-white">
              <Calendar className="w-5 h-5 text-amber-400" />
            </div>
            <h3 className="text-lg font-bold text-white">AI Date Planning Engine</h3>
            <p className="text-xs text-neutral-400 leading-relaxed">
              We eliminate the &ldquo;what do you want to do?&rdquo; loop. Our dual-router intelligence synthesizes real-world, verified itineraries in seconds.
            </p>
          </div>

          <div className="bg-[#151515] border border-white/10 rounded-3xl p-8 space-y-4">
            <div className="w-10 h-10 rounded-2xl bg-white/5 border border-white/10 flex items-center justify-center text-white">
              <ShieldCheck className="w-5 h-5 text-emerald-400" />
            </div>
            <h3 className="text-lg font-bold text-white">Biometric Face Verification</h3>
            <p className="text-xs text-neutral-400 leading-relaxed">
              Zero fake accounts, bots, or commercial solicitations. Every verified member completes live gesture verification before receiving a trust badge.
            </p>
          </div>
        </div>
      </section>

      {/* Studio Membership Tier */}
      <section className="py-24 px-6 max-w-5xl mx-auto" id="membership">
        <div className="bg-gradient-to-b from-[#1C1616] to-[#121212] border border-[#FF5C5C]/30 rounded-3xl p-8 sm:p-12">
          <div className="flex flex-col md:flex-row items-start md:items-center justify-between gap-6 pb-8 border-b border-white/10">
            <div>
              <span className="text-xs font-mono uppercase tracking-widest text-[#FF5C5C] font-semibold">
                PREMIUM ENTITLEMENTS
              </span>
              <h2 className="text-3xl font-bold text-white mt-1">Match Stick Studio</h2>
              <p className="text-sm text-neutral-400 mt-2">
                Uncompromising clarity for intentional daters. Available monthly or annually.
              </p>
            </div>
            <div className="text-right">
              <span className="text-3xl font-black text-white">$7.49</span>
              <span className="text-xs text-neutral-400"> / month</span>
              <span className="block text-[11px] text-[#FF5C5C] font-medium">billed annually (save 50%)</span>
            </div>
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 py-8">
            <div className="flex items-center gap-3 text-xs text-neutral-300">
              <CheckCircle2 className="w-4 h-4 text-[#FF5C5C] shrink-0" />
              <span>Unblur all incoming likes instantly</span>
            </div>
            <div className="flex items-center gap-3 text-xs text-neutral-300">
              <CheckCircle2 className="w-4 h-4 text-[#FF5C5C] shrink-0" />
              <span>Unlimited discovery rewinds</span>
            </div>
            <div className="flex items-center gap-3 text-xs text-neutral-300">
              <CheckCircle2 className="w-4 h-4 text-[#FF5C5C] shrink-0" />
              <span>Uncapped multi-stop AI date itineraries</span>
            </div>
            <div className="flex items-center gap-3 text-xs text-neutral-300">
              <CheckCircle2 className="w-4 h-4 text-[#FF5C5C] shrink-0" />
              <span>Priority Match Coach & profile polish</span>
            </div>
          </div>

          <div className="flex flex-col sm:flex-row items-center justify-between gap-4 pt-6 border-t border-white/10">
            <span className="text-xs text-neutral-500">
              Cancel anytime. No lock-in contracts.
            </span>
            <a
              href="#download"
              className="px-6 py-3 rounded-full bg-[#FF5C5C] hover:bg-[#E84A4A] text-white text-xs font-semibold tracking-wide transition-all shadow-md shadow-[#FF5C5C]/20"
            >
              Start Studio Membership
            </a>
          </div>
        </div>
      </section>

      {/* Footer */}
      <footer className="py-16 px-6 border-t border-white/10 bg-[#0A0A0A] text-neutral-400 text-xs">
        <div className="max-w-6xl mx-auto flex flex-col md:flex-row items-center justify-between gap-6">
          <div className="flex items-center gap-3">
            <div className="w-6 h-6 rounded-full bg-[#FF5C5C] flex items-center justify-center text-white">
              <Flame className="w-3.5 h-3.5 fill-white" />
            </div>
            <span className="font-bold text-white text-sm">MATCH STICK</span>
            <span className="text-neutral-500">© 2026 Match Stick Inc. All rights reserved.</span>
          </div>

          <div className="flex items-center gap-6">
            <Link href="/" className="hover:text-white transition-colors">
              Admin Portal
            </Link>
            <a href="#safety" className="hover:text-white transition-colors">Safety Guidelines</a>
            <a href="#privacy" className="hover:text-white transition-colors">Privacy Policy</a>
            <a href="#terms" className="hover:text-white transition-colors">Terms of Service</a>
          </div>
        </div>
      </footer>
    </div>
  );
}
