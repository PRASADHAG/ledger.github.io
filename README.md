# Ledger — Personal Finance Tracker

A responsive personal finance dashboard for THB and INR accounts, with optional Supabase authentication and cloud storage.

## Features

- Dashboard with combined THB equivalent balance, monthly income, expenses, net cash flow, cash-flow chart, and recent transactions
- Multiple THB and INR accounts with opening balances
- Income and expense records with categories, notes, dates, search, and filters
- Adjustable INR to THB conversion rate
- JSON data export
- Responsive desktop and mobile website
- Supabase email/password sign-in, per-user database access, and row-level security

## Configure the cloud backend

1. Create a Supabase project.
2. In the project's SQL Editor, run all of [`supabase-schema.sql`](supabase-schema.sql). It creates the accounts, transactions, and preferences tables and enables row-level security so users can only access their own records.
3. In Supabase Project Settings, copy the **Project URL** and the browser-safe **anon/publishable key**. Put them in `supabase-config.js`:

   ```js
   window.LEDGER_SUPABASE_CONFIG = {
     url: 'https://YOUR_PROJECT.supabase.co',
     anonKey: 'YOUR_PUBLIC_ANON_OR_PUBLISHABLE_KEY'
   };
   ```

   The browser key is public by design; row-level security protects the records. **Never place a service-role key in this file.**
4. In Supabase Authentication settings, enable email/password sign-in and set the site URL and allowed redirect URLs to your local or hosted website address. If email confirmation is enabled, new users must confirm their email before signing in.
5. Publish the project root on a static web host (for example, Cloudflare Pages, Netlify, or GitHub Pages). No build command is needed. Use HTTPS for the live site.

After configuration, the site requires sign-in and stores records in Supabase. Any Android client can use this same project and tables with Supabase authentication, so both clients see the same account and transaction data.

## Local preview and existing sample data

Without Supabase values, opening `index.html` uses browser local storage and sample entries for preview. With Supabase configured, each new user starts with an empty cloud ledger. Existing local preview data is not automatically migrated; export it from the browser before switching, then add the records to the cloud ledger.

## Android app

The current deliverable is the cloud-ready website and database setup. The Android app can use the same Supabase project and security policies. Its native interface and Android build are a separate next step; no Android project has been created yet.
