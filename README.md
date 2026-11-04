# VYBE
Discord-inspired mobile-friendly web chat prototype.

## Setup
1. Create a Supabase project.
2. Run `schema.sql` in its SQL Editor.
3. In `index.html`, replace `SUPABASE_URL_HERE` and `SUPABASE_ANON_KEY_HERE` with your project URL and **publishable/anon** key (never a service-role key).
4. Deploy `index.html` on GitHub Pages or another HTTPS host. For GitHub Pages: Settings > Pages > Deploy from branch > main / root.
5. Create accounts for participants, then invite their existing email addresses to rooms.

## Current scope
Real account sign-in, persisted rooms, private messages, and browser camera/microphone permissions. Video/voice calling is an **experimental peer-to-peer prototype** using Supabase Broadcast signaling and public STUN. It is not production-ready: group calls, reliable call negotiation, TURN relay, ringing, push notifications, moderation, abuse protection, and full server/channel management still need work. Calls may fail on restrictive networks. Use HTTPS for camera access.

## Security note
Review RLS policies before public launch. The invite function resolves existing email addresses and should be redesigned with rate limiting and abuse prevention before opening registration broadly.
