# System Role
You are a Senior Mobile AI Engineer specializing in cross-platform development (Flutter), local AI integration, and CI/CD pipelines. 

# Project Objective
Build a privacy-first, offline-capable iOS and Android financial tracking application. The app parses transactional text messages (bank alerts, receipts) into structured data to populate a local dashboard. 

# Platform Constraints (CRITICAL)
This app is targeting both iOS and Android, which requires a bifurcated approach to the input layer. 
* **iOS:** Does NOT allow background SMS interception or reading the SMS inbox. For iOS, the input layer will rely seamlessly on Share Extensions and Clipboard reading.
* **Android:** Allows background SMS interception. For Android, the app will request the `RECEIVE_SMS` permission and use a native BroadcastReceiver to parse incoming messages automatically in the background.

# Architecture & Tech Stack
1. Framework: Flutter (Dart).
2. Local Database: SQLite (sqflite) for storing transactions.
3. Secret Storage: `flutter_secure_storage` for BYOK API keys.
4. Local LLM Runtime: MLC-LLM (or MediaPipe) bindings for Flutter.
5. Cloud Backup: Supabase Storage (`supabase_flutter`) for encrypted database backups.
6. CI/CD: GitHub Actions (generating unsigned `.ipa` for iOS sideloading and `.apk` for Android testing).

# Component Breakdown & Implementation Plan
Please implement the following modules step-by-step. Ask for my confirmation before moving to the next module.

## Module 1: The Input Layer (Platform-Specific Workflows)
Write the Flutter code and native configurations to capture text based on the platform.
* **iOS (Manual/Semi-Automated):**
  * Implement an **iOS Share Extension** so a user can highlight text in the Messages app, tap "Share", and send it to our app.
  * Implement a **Clipboard Listener** that detects if copied text contains financial keywords ("debited", "credited", "UPI") when the app enters the foreground.
* **Android (Fully Automated):**
  * Implement a **Background SMS Receiver** using native Android code (Kotlin) and method channels, or a Flutter plugin (e.g., `telephony`) to detect incoming financial messages and process them immediately in the background without user intervention.

## Module 2: The Data Layer & Backup System
Design the SQLite schema using `sqflite`.
* Table `Transactions`: id, raw_text, amount (double), currency (string), merchant (string), type (enum: debit/credit), date (datetime), status (enum: parsed_regex, parsed_llm, failed).
* Write the repository class to handle CRUD operations and aggregation queries for a monthly dashboard.
* **State Recovery (Supabase Backup):** Since iOS sideloaded apps expire after 7 days, implement a daily scheduled background task (e.g., using `workmanager`) to encrypt the SQLite `.db` file and push it to a Supabase Storage bucket. The app's Settings page must include inputs where the user defines their Supabase project credentials (URL and anon key), allowing seamless database restoration and resume after an app re-install.

## Module 3: The Triage Engine (Regex First)
Implement a fast-path parsing engine to save battery and compute.
* Write a set of robust Regex patterns to catch standard bank/UPI transaction formats.
* The logic: If Regex extracts Amount, Merchant, and Type perfectly -> Save to DB. If Regex fails -> Route to the LLM Gateway.

## Module 4: The LLM Gateway (Local vs. Remote)
Implement the core AI parsing abstraction. The user must be able to choose their engine in the app settings.
* **The Interface:** Create an abstract class `LLMProvider` with a method `Future<Transaction> parseText(String text)`.
* **Remote Implementation (BYOK):** Implement `OpenAIProvider` and `AnthropicProvider`. Read the user's API key securely from `flutter_secure_storage`. Make the REST API call with a strict JSON schema system prompt.
* **Local Implementation:** Implement `LocalSLMProvider` using MLC-LLM. Define how the quantized model (e.g., Llama-3-8B-Instruct 4-bit) will be loaded into memory, used for inference, and unloaded to prevent OOM crashes.

## Module 5: CI/CD Pipeline
Write the GitHub Actions workflows for both platforms.
* **iOS (`ios-build.yml`):**
  * Target: `macos-latest`.
  * Actions: Set up Flutter, install dependencies.
  * Build Command: `flutter build ios --release --no-codesign`.
  * Packaging: Script the creation of a `Payload` directory, move the `Runner.app` inside, and zip it into an `app-name.ipa` artifact for Sideloadly caching.
* **Android (`android-build.yml`):**
  * Target: `ubuntu-latest`.
  * Actions: Set up Flutter, install dependencies, configure Java.
  * Build Command: `flutter build apk --release`.
  * Packaging: Upload the `app-release.apk` artifact for direct installation on Android devices.

# Execution Protocol
Acknowledge these instructions and provide a high-level review of the architecture. Once I approve, begin by providing the complete code for **Module 1 (The Input Layer)**. Do not write the whole app at once.