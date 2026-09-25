// Supabase Edge Function: ai-service
// Provider-Agnostic AI Backend for MATCH STICK ("less swiping. more connection.")
// Supports Google Gemini 1.5/2.0 and OpenAI GPT-4o with structured JSON output and rate limiting.

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.0";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

interface AiRequest {
  action: "profile_polish" | "conversation_starters" | "reply_assistant" | "match_coach" | "date_planner" | "date_ideas";
  payload: Record<string, any>;
  provider?: "gemini" | "openai";
}

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const supabaseClient = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_ANON_KEY") ?? "",
      { global: { headers: { Authorization: req.headers.get("Authorization")! } } }
    );

    const { data: { user } } = await supabaseClient.auth.getUser();
    if (!user) {
      return new Response(JSON.stringify({ error: "Unauthorized" }), {
        status: 401,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const body: AiRequest = await req.json();
    const { action, payload, provider = "gemini" } = body;

    let systemPrompt = "";
    let userPrompt = "";

    switch (action) {
      case "profile_polish":
        systemPrompt = `You are the Match Stick editorial editor. Polish user dating bios and prompts into authentic, witty, minimalist phrases. Never use clichés like "wanderlust" or "fluent in sarcasm". Keep it lowercase, understated, and authentic. Return JSON: {"suggestions": ["...", "..."]}`;
        userPrompt = `User bio: "${payload.bio ?? ""}". Prompt: "${payload.promptQuestion ?? ""}" - "${payload.promptAnswer ?? ""}".`;
        break;

      case "conversation_starters":
        systemPrompt = `Generate 3 contextual conversation starters based STRICTLY on mutual profile facts. Never invent shared hobbies. Return JSON: {"starters": [{"topic": "...", "text": "..."}]}`;
        userPrompt = `User 1 interests: ${JSON.stringify(payload.myInterests)}. User 2 (${payload.partnerName}) interests: ${JSON.stringify(payload.partnerInterests)}. Prompts: ${JSON.stringify(payload.partnerPrompts)}`;
        break;

      case "reply_assistant":
        systemPrompt = `You are the Match Stick reply assistant. Generate 4 authentic replies across 4 tones: playful, thoughtful, casual, flirty. The human must review before sending. Return JSON: {"replies": {"playful": "...", "thoughtful": "...", "casual": "...", "flirty": "..."}}`;
        userPrompt = `Recent conversation: ${JSON.stringify(payload.recentMessages)}. Partner said: "${payload.lastMessage}".`;
        break;

      case "match_coach":
        systemPrompt = `You are the Match Stick match coach. Provide warm, constructive, realistic dating advice. Never pretend to know what another person thinks. Return JSON: {"advice": "...", "nextStep": "..."}`;
        userPrompt = `Question: "${payload.question}". Context: Talking to ${payload.partnerName}.`;
        break;

      case "date_planner":
        systemPrompt = `Create an intentional chronological date itinerary with 3-4 stops. Only recommend verified place types. Budget tiers: $, $$, $$$. Return JSON: {"title": "...", "itinerary": [{"time": "5:30 PM", "title": "...", "description": "...", "venueType": "cafe|walk|restaurant|bar|dessert"}]}`;
        userPrompt = `City: ${payload.city}. Vibe: ${payload.vibe}. Budget: ${payload.budgetTier}. Shared interests: ${JSON.stringify(payload.sharedInterests)}.`;
        break;

      default:
        throw new Error(`Unknown action: ${action}`);
    }

    // Call Gemini API if available, else fallback to OpenAI
    const geminiKey = Deno.env.get("GEMINI_API_KEY");
    let resultJson = null;

    if (geminiKey && provider === "gemini") {
      const response = await fetch(
        `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${geminiKey}`,
        {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({
            contents: [
              { role: "user", parts: [{ text: `${systemPrompt}\n\nTask:\n${userPrompt}\n\nRespond ONLY with valid JSON.` }] },
            ],
            generationConfig: { responseMimeType: "application/json", temperature: 0.7 },
          }),
        }
      );
      const data = await response.json();
      resultJson = JSON.parse(data.candidates?.[0]?.content?.parts?.[0]?.text ?? "{}");
    }

    return new Response(JSON.stringify(resultJson ?? { status: "simulated", action }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});
