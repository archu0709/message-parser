# System Role
You are a Senior Mobile AI Engineer specializing in cross-platform development (Flutter), local AI integration, and CI/CD pipelines. 

# Project Objective
Build a privacy-first, offline-capable iOS and Android financial tracking application. The app parses transactional text messages (bank alerts, receipts) into structured data to populate a local dashboard.

---

# User Flow

## 1. Onboarding Flow

### Screen 1 — Welcome
- App name + tagline: "Your transactions, parsed privately"
- CTA: **Get Started**

### Screen 2 — Platform Setup (branched)
**Android:**
- Request `RECEIVE_SMS` permission
- Show confirmation: "We'll auto-parse incoming bank messages"
- Toggle: Enable background SMS parsing (default ON)

**iOS:**
- Walk-through: How to use the Share Extension (animated GIF)
- Clipboard auto-detection opt-in toggle
- CTA: **Try it — copy a bank message and come back**

### Screen 3 — Parser Engine Choice
- Option A: **Regex only** (fast, offline, limited coverage)
- Option B: **Remote AI (BYOK)** — paste OpenAI or Anthropic key
- Option C: **Local AI** — download quantized model (~1.5 GB)
- Note: Can be changed later in Settings

### Screen 4 — Backup (Optional)
- "Protect your data — set up Supabase backup"
- Fields: Supabase URL + Anon Key
- Skip link → goes to dashboard (can set up later in Settings)

### Screen 5 — Seed Data (Optional)
- "Already have transactions? Paste a few messages to get started"
- Free-text area → runs through parser immediately
- Or: **Go to Dashboard** (empty state with illustrated placeholder)

---

## 2. Daily Usage Flow

### Entry Points
| Platform | Trigger | Action |
|----------|---------|--------|
| Android | Incoming SMS | Auto-parsed in background, notification shown |
| iOS | User copies message text | Clipboard prompt appears on next app open |
| iOS | Share Extension | Message sent directly to parser from Messages app |
| Both | Manual entry | "+ Add" button in dashboard |

### Parse → Review → Save
1. **Parsing screen** — shows raw text + parsed fields side-by-side
2. If confidence is high → auto-save, toast notification
3. If any field is ambiguous → **Review card** shown (see Edit Flow below)
4. Saved → reflected in dashboard immediately

---

## 3. Dashboard

### Layout
```
[Tab Bar: Overview | Wealth | Accounts | Cards | People | History]
```

### Tab 1 — Overview (Monthly Summary)
```
Month selector  ←  April 2026  →

┌─────────────────────────────────────┐
│  TOTAL SPEND           ₹ 42,300     │
│  TOTAL INCOME          ₹ 85,000     │
│  NET                   ₹ +42,700    │
└─────────────────────────────────────┘

── By Type ─────────────────────────────
  Debit (bank transfers out)   ₹ 18,400
  Credit (money received)      ₹ 85,000
  Credit Card charges          ₹ 15,200
  UPI / Bank Transfer out      ₹  8,700

── Category Breakdown (bar chart) ──────
  Essentials
    Food            ██████   ₹ 8,200
    Groceries       █████    ₹ 6,400
    Fuel            ███      ₹ 3,100
  Bills
    Phone/Internet  ██       ₹ 1,800
    Insurance       ██       ₹ 2,200
    Subscriptions   █        ₹  900
  Lifestyle
    Beauty          ██       ₹ 1,500
    Hotel           █        ₹  800
    Movies          █        ₹  600
  Loans
    Home Loan EMI   ████████ ₹ 22,000
    Loan Prepay     ███      ₹ 8,000
  Income
    Salary          +        ₹ 85,000
    Dividends       +        ₹  2,400
  ...
```

### Tab 2 — Wealth (Net Worth Snapshot)

A read-only snapshot of where all your money sits right now. Balances are manually entered or updated from parsed messages (e.g. "Available balance: ₹1,23,456").

```
NET WORTH                       ₹ 28,46,200
  ┌──────────────────────────────────────────┐
  │  Liquid (bank accounts)     ₹  3,21,400  │
  │  Investments                ₹ 24,80,000  │
  │  Credit Card dues           − ₹  55,200  │
  └──────────────────────────────────────────┘

── Bank Accounts ───────────────────────────
  HDFC Savings  ••4521          ₹ 1,84,200
  SBI Current   ••8834          ₹ 1,37,200
                         Total  ₹ 3,21,400

── Investments ─────────────────────────────
  Zerodha                       ₹ 18,40,000
    Equity holdings   ₹ 14,20,000
    Mutual funds      ₹  4,20,000
  Vested                        ₹  6,40,000
    US stocks         ₹  6,40,000
  [+ Add investment account]
                         Total  ₹ 24,80,000

── Credit Card Dues ────────────────────────
  HDFC Regalia  ••7712         − ₹  38,400
  Axis Flipkart ••3301         − ₹  16,800
                         Total − ₹  55,200
```

- Balances are **user-entered** (app cannot read brokerage APIs) — tap any row to edit
- A small "Last updated" timestamp sits under each balance
- Investment accounts support sub-holdings (equity / MF / US stocks) that sum to the account total
- Net Worth = Bank total + Investment total − Credit Card dues

### Tab 3 — Accounts
Groups transactions by **bank account** (parsed from sender / message body).
```
HDFC Savings ••4521
  Balance indicator (from messages, not live)
  This month: −₹ 12,400 spend  / +₹ 85,000 received
  [View transactions]

SBI Current ••8834
  This month: −₹ 6,000
  [View transactions]
```
Each account drills down to a filtered transaction list.

### Tab 4 — Cards
Groups transactions by **credit card** with utilization detail.

```
HDFC Regalia ••7712
  Limit          ₹ 5,00,000
  Used           ₹   38,400   ████░░░░░░  7.7%
  Available      ₹ 4,61,600
  Payment due    15 Apr 2026
  [View transactions]

Axis Flipkart ••3301
  Limit          ₹ 2,00,000
  Used           ₹   16,800   ██░░░░░░░░  8.4%
  Available      ₹ 1,83,200
  [View transactions]
```

Each card drills down to:
- **Charges** (type = credit_card_charge) — filterable by category
- **Payments** (type = credit_card_payment) — what was paid off
- **Running balance** — cumulative line chart across billing cycles
- Limit and due date are user-entered fields on the card record

### Tab 5 — People (Peer-to-Peer Ledger)

Tracks money given to or received from individuals — splits, loans to friends, rent shares, etc.

```
YOU ARE OWED                        ₹ 12,400
YOU OWE                             ₹  3,200

── People ──────────────────────────────────
  Rahul Sharma                    owes ₹ 8,000
    Last: sent ₹ 8,000 · Mar 28
    [Settle up]  [View history]

  Priya Nair                      owes ₹ 4,400
    Last: sent ₹ 2,200 · Apr 1
    [Settle up]  [View history]

  Amit Kumar             you owe − ₹ 3,200
    Last: received ₹ 3,200 · Apr 3
    [Settle up]  [View history]

  [+ Add person]
```

#### Person Detail Screen
```
← Rahul Sharma              [Edit name]

NET: Rahul owes you  ₹ 8,000

── Activity ────────────────────────────────
  Apr 02  You paid Rahul's share       +₹ 4,000
          Dinner split · HDFC ••4521
  Mar 28  You sent ₹ 4,000             +₹ 4,000
          NEFT · SBI ••8834
  Mar 10  Rahul paid you back         −₹ 5,000
          [Settled]

  [+ Log transaction]
```

#### Log Transaction (bottom sheet)
```
  Direction   [I paid them ▾]  /  [They paid me]
  Amount      [____________]
  Linked tx   [Select from history ▾]   (optional)
  Note        [____________]
              [Cancel]   [Save]
```

- **Linking**: a People transaction can optionally point to an existing `Transactions` record (e.g. the UPI debit that funded the split)
- **Settle up**: records a zero-note settlement entry, marks the running balance as cleared
- People are not auto-detected — user creates them manually and assigns transactions

### Tab 6 — History (All Transactions)
Filterable flat list, newest first.

**Filter bar:**
```
[All ▾] [Type ▾] [Account ▾] [Date range ▾] [🔍 Search]
```

**Type filter options:** All · Debit · Credit · Credit Card charge · Credit Card payment · Bank Transfer

Each row:
```
[Icon]  Swiggy                     −₹ 480
        HDFC ••4521 · UPI · Apr 3
```
Tap row → Transaction Detail / Edit screen

---

## 4. Transaction Detail & Edit Flow

### View Mode
```
← Back                        [Edit ✏]

Amount:      ₹ 480
Type:        Debit
Method:      UPI
Merchant:    Swiggy
Account:     HDFC ••4521
Date:        3 Apr 2026, 2:14 PM
Category:    Food & Dining
Parse status: parsed_regex ✓

── Raw Message ──────────────────────────
"Rs.480.00 debited from A/c ••4521 to
 VPA swiggy@icici on 03-04-26."
```

### Edit Mode (tap Edit ✏)
All fields become editable inline:
- Amount (number field)
- Type (dropdown: Debit / Credit / Credit Card charge / Credit Card payment / Bank Transfer)
- Method (dropdown: UPI / NEFT / IMPS / RTGS / Card / Cash / Other)
- Merchant (text)
- Account / Card (dropdown — existing parsed accounts + "Add new")
- Date & Time (date-time picker)
- Category (grouped dropdown, built from live `Categories` table):
  - Groups and items reflect user's current list including renames and additions
  - "+ Manage categories" shortcut at bottom → opens Category Management screen
- Notes (free text)

**Actions:**
- **Save** → updates DB, re-runs dashboard tallies
- **Delete** → confirmation dialog → soft-delete (recoverable from History for 30 days)
- **Re-parse** → sends raw_text back through parser engine

---

## 5. Category Management Flow

Accessible from **Settings → Manage Categories**.

### List View
```
Manage Categories                    [+ Add]

── Essentials ──────────────────────────────
  [fork.knife]  Food               ··· ▾
  [fuelpump]    Fuel               ··· ▾
  [cart]        Groceries          ··· ▾

── Bills ───────────────────────────────────
  [wifi]        Phone / Internet   ··· ▾
  ...

── User Created ────────────────────────────
  [tag]         Side Business      ··· ▾  [delete]
```

Tap `···` on any row → context menu:
- **Rename** → inline text field, save on confirm
- **Move to group** → group picker sheet
- **Delete** (user-created only; system categories show this option greyed out)

### Add Category Sheet (bottom sheet)
```
Category Name    [____________]
Group            [Essentials ▾]
Icon             [icon grid picker]
              [Cancel]  [Save]
```

### Delete Confirmation Dialog
```
Delete "Side Business"?

All X transactions in this category will be
moved to Uncategorized.

[Cancel]  [Delete & Reassign]
```

### Rename — zero DB cost
Only the `Categories.name` column updates. All transactions keep their `category_slug` unchanged, so no transaction rows are touched.

---

## 6. Empty & Error States

| State | Screen shows |
|-------|-------------|
| No transactions yet | Illustrated empty state + "Add your first" CTA |
| Parse failed | Red banner on transaction with "Needs review" badge |
| LLM key invalid | Settings nudge toast |
| Backup failed | Settings badge indicator |

---

# Platform Constraints (CRITICAL)
This app is targeting both iOS and Android, which requires a bifurcated approach to the input layer.
* **iOS:** Does NOT allow background SMS interception or reading the SMS inbox. For iOS, the input layer will rely seamlessly on Share Extensions and Clipboard reading.
* **Android:** Allows background SMS interception. For Android, the app will request the `RECEIVE_SMS` permission and use a native BroadcastReceiver to parse incoming messages automatically in the background.

---

# Architecture & Tech Stack
1. Framework: Flutter (Dart)
2. Local Database: SQLite (sqflite) for storing transactions
3. Secret Storage: `flutter_secure_storage` for BYOK API keys
4. Local LLM Runtime: MLC-LLM (or MediaPipe) bindings for Flutter
5. Cloud Backup: Supabase Storage (`supabase_flutter`) for encrypted database backups
6. CI/CD: GitHub Actions (generating unsigned `.ipa` for iOS sideloading and `.apk` for Android testing)

---

# Data Model

## Transactions
| Column | Type | Notes |
|--------|------|-------|
| id | INTEGER PK | |
| raw_text | TEXT | Original message |
| amount | REAL | |
| currency | TEXT | |
| merchant | TEXT | |
| type | TEXT | debit \| credit \| credit_card_charge \| credit_card_payment \| bank_transfer |
| method | TEXT | upi \| neft \| imps \| rtgs \| card \| cash \| other |
| account_id | INTEGER FK | → Accounts |
| card_id | INTEGER FK | → Cards (nullable) |
| date | DATETIME | |
| category_slug | TEXT FK | → Categories.slug (stable across renames) |
| notes | TEXT | |
| status | TEXT | parsed_regex \| parsed_llm \| failed \| needs_review |
| deleted_at | DATETIME | Soft delete — null = active |

## Accounts
| Column | Type | Notes |
|--------|------|-------|
| id | INTEGER PK | |
| name | TEXT | User label |
| bank_name | TEXT | |
| last4 | TEXT | |
| type | TEXT | savings \| current \| wallet |

## Cards
| Column | Type | Notes |
|--------|------|-------|
| id | INTEGER PK | |
| issuer | TEXT | |
| last4 | TEXT | |
| name | TEXT | User label |
| credit_limit | REAL | User-entered limit |
| billing_due_day | INTEGER | Day of month payment is due (1–31) |

## InvestmentAccounts
| Column | Type | Notes |
|--------|------|-------|
| id | INTEGER PK | |
| name | TEXT | e.g. "Zerodha", "Vested", "Groww" |
| type | TEXT | brokerage \| mf \| us_stocks \| crypto \| other |
| total_value | REAL | User-entered current total value |
| last_updated | DATETIME | When user last edited the balance |
| sort_order | INTEGER | Display order in Wealth tab |

## InvestmentHoldings
Sub-breakdown within an investment account (optional, user-entered).

| Column | Type | Notes |
|--------|------|-------|
| id | INTEGER PK | |
| account_id | INTEGER FK | → InvestmentAccounts |
| label | TEXT | e.g. "Equity", "Mutual Funds", "US Stocks" |
| value | REAL | |
| last_updated | DATETIME | |

## People
| Column | Type | Notes |
|--------|------|-------|
| id | INTEGER PK | |
| name | TEXT | User-entered display name |
| phone | TEXT | Optional, for future contact linking |
| created_at | DATETIME | |

## PeopleTransactions
| Column | Type | Notes |
|--------|------|-------|
| id | INTEGER PK | |
| person_id | INTEGER FK | → People |
| direction | TEXT | i_paid_them \| they_paid_me |
| amount | REAL | Always positive |
| note | TEXT | |
| linked_tx_id | INTEGER FK | → Transactions.id (nullable) |
| is_settlement | INTEGER | 1 = marks a balance clear |
| date | DATETIME | |

## CategoryMonthly (time-series aggregate)
Pre-aggregated monthly totals per category. Zero-value rows are always written so
time-series charts never have gaps — every (year, month, category) triple always exists.

| Column | Type | Notes |
|--------|------|-------|
| id | INTEGER PK | |
| year | INTEGER | e.g. 2026 |
| month | INTEGER | 1–12 |
| category_slug | TEXT FK | → Categories.slug |
| total_debit | REAL | Sum of outgoing transactions |
| total_credit | REAL | Sum of incoming transactions |
| tx_count | INTEGER | Number of transactions |

Rebuilt on every transaction insert/update/delete via a DB trigger or repo call.
Enables O(1) dashboard queries and YTD rollups without scanning the full Transactions table.

## Categories (user-managed table)

Categories are no longer a hardcoded enum — they live in the DB so users can add, rename, and delete them.
Built-in categories are seeded on first launch and carry `is_system = 1` to prevent accidental deletion.

| Column | Type | Notes |
|--------|------|-------|
| id | INTEGER PK | |
| name | TEXT UNIQUE | Display name, user-editable |
| slug | TEXT UNIQUE | Stable internal key (e.g. `food`, `loan_emi`) — never changes on rename |
| group_name | TEXT | Essentials \| Bills \| Lifestyle \| Loans \| Income \| Other |
| icon | TEXT | Icon identifier (SF Symbol / Material icon name) |
| is_system | INTEGER | 1 = seeded built-in, 0 = user-created |
| sort_order | INTEGER | Display order within group |
| deleted_at | DATETIME | Soft delete — null = active |

**Rename rule:** updating `name` only; `slug` is immutable so existing transactions and `CategoryMonthly` rows are unaffected.

**Delete rule:** system categories (`is_system = 1`) cannot be deleted. Deleting a user category re-assigns all its transactions to `uncategorized` before soft-deleting the row.

**`Transactions.category`** stores the `slug`, not the display name, so renames are zero-cost — no transaction rows need updating.

## Built-in Seed Categories

```
Group: Essentials
  slug: food             name: Food             icon: fork.knife
  slug: fuel             name: Fuel             icon: fuelpump
  slug: groceries        name: Groceries        icon: cart

Group: Bills
  slug: phone_internet   name: Phone / Internet icon: wifi
  slug: insurance        name: Insurance        icon: shield
  slug: subscriptions    name: Subscriptions    icon: repeat

Group: Lifestyle
  slug: beauty           name: Beauty           icon: sparkles
  slug: hotel            name: Hotel            icon: bed.double
  slug: movies           name: Movies           icon: film

Group: Loans
  slug: loan_emi         name: Home Loan EMI    icon: house
  slug: loan_prepayment  name: Loan Prepayment  icon: arrow.down.circle

Group: Income
  slug: salary           name: Salary           icon: banknote
  slug: dividends        name: Dividends        icon: chart.line.uptrend.xyaxis
  slug: other_income     name: Other Income     icon: plus.circle

Group: Other
  slug: uncategorized    name: Uncategorized    icon: questionmark.circle  (system, non-deletable)
```

---

# Folder Structure

```
message_parser/
├── android/
│   └── app/src/main/kotlin/.../
│       ├── MainActivity.kt
│       └── SmsReceiver.kt              # BroadcastReceiver for background SMS
│
├── ios/
│   ├── Runner/
│   └── ShareExtension/                 # iOS Share Extension target
│       ├── ShareViewController.swift
│       └── Info.plist
│
├── lib/
│   ├── main.dart
│   │
│   ├── core/
│   │   ├── constants.dart              # App-wide constants, full category taxonomy enum
│   ├── category_seeder.dart        # Writes zero-value CategoryMonthly rows at month init
│   │   ├── database/
│   │   │   ├── database_helper.dart    # SQLite init, migrations
│   │   │   └── repositories/
│   │   │       ├── transaction_repo.dart
│   │   │       ├── account_repo.dart
│   │   │       ├── card_repo.dart
│   │   │       ├── category_repo.dart      # CRUD + reassign-on-delete logic
│   │   │       ├── investment_repo.dart    # InvestmentAccounts + Holdings CRUD
│   │   │       └── people_repo.dart        # People + PeopleTransactions, balance calc
│   │   └── services/
│   │       ├── backup_service.dart     # Supabase encrypt + upload
│   │       └── clipboard_service.dart  # iOS clipboard watcher
│   │
│   ├── features/
│   │   ├── onboarding/
│   │   │   ├── screens/
│   │   │   │   ├── welcome_screen.dart
│   │   │   │   ├── platform_setup_screen.dart
│   │   │   │   ├── engine_choice_screen.dart
│   │   │   │   ├── backup_setup_screen.dart
│   │   │   │   └── seed_data_screen.dart
│   │   │   └── onboarding_router.dart
│   │   │
│   │   ├── dashboard/
│   │   │   ├── screens/
│   │   │   │   └── dashboard_screen.dart   # Tab controller
│   │   │   └── tabs/
│   │   │       ├── overview_tab.dart
│   │   │       ├── wealth_tab.dart
│   │   │       ├── accounts_tab.dart
│   │   │       ├── cards_tab.dart
│   │   │       ├── people_tab.dart
│   │   │       └── history_tab.dart
│   │   │
│   │   ├── transactions/
│   │   │   ├── screens/
│   │   │   │   ├── transaction_detail_screen.dart
│   │   │   │   └── transaction_edit_screen.dart
│   │   │   └── widgets/
│   │   │       ├── transaction_row.dart
│   │   │       └── parse_review_card.dart
│   │   │
│   │   ├── parser/
│   │   │   ├── triage_engine.dart          # Routes regex vs LLM
│   │   │   ├── regex_parser.dart           # Fast-path patterns
│   │   │   └── llm/
│   │   │       ├── llm_provider.dart       # Abstract interface
│   │   │       ├── openai_provider.dart
│   │   │       ├── anthropic_provider.dart
│   │   │       └── local_slm_provider.dart
│   │   │
│   │   ├── wealth/
│   │   │   ├── screens/
│   │   │   │   └── investment_account_screen.dart  # Add/edit investment account + holdings
│   │   │   └── widgets/
│   │   │       ├── net_worth_card.dart
│   │   │       ├── investment_account_tile.dart
│   │   │       └── holding_row.dart
│   │   │
│   │   ├── people/
│   │   │   ├── screens/
│   │   │   │   └── person_detail_screen.dart
│   │   │   └── widgets/
│   │   │       ├── person_tile.dart
│   │   │       └── log_transaction_sheet.dart   # Bottom sheet: direction/amount/link/note
│   │   │
│   │   ├── categories/
│   │   │   ├── screens/
│   │   │   │   └── category_management_screen.dart
│   │   │   └── widgets/
│   │   │       ├── category_list_tile.dart   # Row with rename/move/delete context menu
│   │   │       ├── add_category_sheet.dart   # Bottom sheet: name + group + icon
│   │   │       └── delete_category_dialog.dart
│   │   │
│   │   └── settings/
│   │       ├── screens/
│   │       │   └── settings_screen.dart
│   │       └── widgets/
│   │           ├── engine_selector.dart
│   │           └── backup_credentials_form.dart
│   │
│   └── shared/
│       ├── models/
│       │   ├── transaction.dart
│       │   ├── account.dart
│       │   ├── card.dart
│       │   ├── category.dart
│       │   ├── investment_account.dart
│       │   ├── investment_holding.dart
│       │   ├── person.dart
│       │   └── people_transaction.dart
│       └── widgets/
│           ├── empty_state.dart
│           └── month_selector.dart
│
├── test/
│   ├── parser/
│   │   ├── regex_parser_test.dart
│   │   └── triage_engine_test.dart
│   └── repositories/
│       └── transaction_repo_test.dart
│
├── .github/
│   └── workflows/
│       ├── ios-build.yml
│       └── android-build.yml
│
└── pubspec.yaml
```

---

# Component Breakdown & Implementation Plan

Please implement the following modules step-by-step. Ask for my confirmation before moving to the next module.

## Module 0: Proof of Concept — Read & Display Messages

**Goal:** Bare minimum app that proves we can access messages on both platforms. No parsing, no DB, no AI. Just show the messages exist and can be read.

### What to build
A single-screen Flutter app with two platform branches:

**Android**
- Request `READ_SMS` permission at launch (using `permission_handler`)
- Read the SMS inbox via the `telephony` plugin
- Display a grouped list: one row per sender, showing sender name/number and message count
- Tap a sender → flat list of their raw message bodies, newest first
- Counter at top: "X senders · Y total messages"

**iOS**
- Cannot read the SMS inbox — instead show a **paste area** on launch
- User pastes one or more messages (multi-line accepted)
- App splits by blank line, counts distinct blocks, and lists them
- Same layout as Android: count header + scrollable list of raw message previews
- Banner at top: "On iOS, paste messages below. Android reads them automatically."

### Screen layout (both platforms)
```
┌──────────────────────────────────────┐
│  Messages  (Android: 312 · 28 senders│
│            iOS: paste area)          │
├──────────────────────────────────────┤
│  [Android only: permission banner    │
│   if READ_SMS not yet granted]       │
├──────────────────────────────────────┤
│  HDFC Bank             84 messages   │
│  SBI Alerts            61 messages   │
│  Axis Bank             43 messages   │
│  VM-ICICIB             38 messages   │
│  ...                                 │
└──────────────────────────────────────┘
```

### Acceptance criteria
- [ ] Android: app reads real SMS inbox, groups by sender, shows correct counts
- [ ] iOS: paste area splits and counts message blocks correctly
- [ ] Tapping a sender shows raw message list
- [ ] No crashes on permission denial (show "Permission required" empty state)
- [ ] Runs on a physical device or simulator for both platforms

### Files to create
```
lib/
├── main.dart                         # MaterialApp, routes
└── features/
    └── poc/
        ├── poc_screen.dart           # Root screen — platform branch
        ├── sender_list.dart          # Grouped sender rows (Android)
        ├── message_list.dart         # Flat message list on tap
        └── ios_paste_area.dart       # iOS paste + split + count
```

### Key packages
- `permission_handler` — runtime permission request
- `telephony` — Android SMS inbox read
- No DB, no parsing, no LLM — this module is read-only display only

---

## Module 1: The Input Layer (Platform-Specific Workflows)
Write the Flutter code and native configurations to capture text based on the platform.
* **iOS (Manual/Semi-Automated):**
  * Implement an **iOS Share Extension** so a user can highlight text in the Messages app, tap "Share", and send it to our app.
  * Implement a **Clipboard Listener** that detects if copied text contains financial keywords ("debited", "credited", "UPI") when the app enters the foreground.
* **Android (Fully Automated):**
  * Implement a **Background SMS Receiver** using native Android code (Kotlin) and method channels, or a Flutter plugin (e.g., `telephony`) to detect incoming financial messages and process them immediately in the background without user intervention.

## Module 2: The Data Layer & Backup System
Design the SQLite schema using `sqflite`.
* Tables: `Transactions`, `Accounts`, `Cards`, `Categories`, `CategoryMonthly` (see Data Model above)
* Write the repository classes to handle CRUD operations and aggregation queries for the dashboard tabs (by type, by account, by card, monthly totals, YTD rollups).
* On first launch, seed the `Categories` table with all built-in entries (`is_system = 1`).
* `CategoryRepo` must enforce: (a) system categories cannot be deleted; (b) deleting a user category bulk-updates `Transactions.category_slug` to `uncategorized` in the same transaction before soft-deleting the row; (c) rename only touches `Categories.name`, never `slug`.
* On every transaction write, upsert the corresponding `CategoryMonthly` row (year + month + category_slug). Always write zero-value rows for all active categories at month boundaries to keep time-series complete.
* **State Recovery (Supabase Backup):** Since iOS sideloaded apps expire after 7 days, implement a daily scheduled background task (e.g., using `workmanager`) to encrypt the SQLite `.db` file and push it to a Supabase Storage bucket. The app's Settings page must include inputs where the user defines their Supabase project credentials (URL and anon key), allowing seamless database restoration and resume after an app re-install.

## Module 3: The Triage Engine (Regex First)
Implement a fast-path parsing engine to save battery and compute.
* Write a set of robust Regex patterns to catch standard bank/UPI transaction formats.
* Populate `type`, `method`, `account_id`, `card_id` from parsed fields.
* The logic: If Regex extracts Amount, Merchant, and Type perfectly → Save to DB. If Regex fails → Route to the LLM Gateway.

## Module 4: The LLM Gateway (Local vs. Remote)
Implement the core AI parsing abstraction. The user must be able to choose their engine in the app settings.
* **The Interface:** Create an abstract class `LLMProvider` with a method `Future<Transaction> parseText(String text)`.
* **Remote Implementation (BYOK):** Implement `OpenAIProvider` and `AnthropicProvider`. Read the user's API key securely from `flutter_secure_storage`. Make the REST API call with a strict JSON schema system prompt.
* **Local Implementation:** Implement `LocalSLMProvider` using MLC-LLM. Define how the quantized model (e.g., Llama-3-8B-Instruct 4-bit) will be loaded into memory, used for inference, and unloaded to prevent OOM crashes.

## Module 5: Dashboard & Transaction UI
Implement the four-tab dashboard and transaction edit flow.
* Overview tab: monthly summary card + type breakdown + category bar chart grouped by section (Essentials / Bills / Lifestyle / Loans / Income). Query `CategoryMonthly` for O(1) renders. YTD column alongside monthly.
* Accounts tab: grouped list with per-account totals, drill-down to filtered history
* Cards tab: grouped list with outstanding / payment tallies, drill-down
* History tab: flat list with filter bar (type / account / date range / search)
* Transaction detail screen: view mode + inline edit mode with all fields
* Soft delete with 30-day recovery

## Module 6: CI/CD Pipeline
Write the GitHub Actions workflows for both platforms.
* **iOS (`ios-build.yml`):**
  * Target: `macos-latest`
  * Actions: Set up Flutter, install dependencies
  * Build Command: `flutter build ios --release --no-codesign`
  * Packaging: Script the creation of a `Payload` directory, move the `Runner.app` inside, and zip it into an `app-name.ipa` artifact for Sideloadly
* **Android (`android-build.yml`):**
  * Target: `ubuntu-latest`
  * Actions: Set up Flutter, install dependencies, configure Java
  * Build Command: `flutter build apk --release`
  * Packaging: Upload the `app-release.apk` artifact for direct installation

# Execution Protocol

## Rules
- Implement one module at a time. Do not proceed to the next module without explicit user approval.
- After completing each module, summarize what was built, list the files created or modified, and state the acceptance criteria that must pass before moving on.
- Do not scaffold future modules speculatively. Only write code for the current module.
- If a module requires a native platform decision (e.g. Kotlin vs. Flutter plugin), present the tradeoff and wait for a choice before writing code.
- If a module's scope turns out larger than expected mid-implementation, stop, describe what remains, and ask whether to continue or split it.

## Module Order & Gates

| # | Module | Gate to proceed |
|---|--------|----------------|
| 0 | **POC — Read & Display Messages** | App runs on a real Android device showing real SMS grouped by sender; iOS paste area counts and lists blocks correctly |
| 1 | **Input Layer** | Background SMS auto-captured on Android; Share Extension and clipboard prompt working on iOS |
| 2 | **Data Layer & Backup** | Transactions, Accounts, Cards, Categories, InvestmentAccounts, People tables created; CRUD tested; Supabase backup round-trips successfully |
| 3 | **Triage Engine (Regex)** | 90%+ of standard HDFC/SBI/ICICI/Axis message formats parsed correctly in unit tests |
| 4 | **LLM Gateway** | All three providers (OpenAI, Anthropic, Local) parse a test message and return a valid structured Transaction |
| 5 | **Dashboard & Transaction UI** | All 6 tabs render with real data; edit/save/delete flow works end-to-end |
| 6 | **CI/CD Pipeline** | GitHub Actions produces a downloadable `.ipa` and `.apk` artifact on every push to `main` |

## Starting point
Begin with **Module 0**. Provide the complete code for the POC screen, the platform permission setup, and the two packages (`permission_handler`, `telephony`) configured in `pubspec.yaml`. Nothing else.
