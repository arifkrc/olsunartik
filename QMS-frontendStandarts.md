QMS FRONTEND TECHNICAL DESIGN DOCUMENT (V2.0)
Project Name: Quality Management System (QMS) - Frontend

Target Platforms: Android, iOS, Windows, Web (Responsive)

Architectural Approach: Clean Architecture & Offline-First

Date: February 2026

1. EXECUTIVE SUMMARY
This document defines the frontend architecture for the QMS system developed within Frambo. The system is engineered to ensure zero data loss despite intermittent internet connectivity in industrial environments (Offline-First), manage complex quality workflows, and provide high-performance integration with the C# backend.

2. TECH STACK
The stack is curated to avoid "dependency hell" by prioritizing vanilla-friendly, high-performance, and industry-standard libraries:

Layer	Technology	Rationale
Framework	Flutter 3.x	Single codebase for mobile and native Windows desktop support.
State Management	BLoC / Cubit	Event-based state handling for predictable enterprise data flow and testability.
Local Database	Isar Database	Ultra-fast NoSQL local storage for seamless offline data persistence.
Network	Dio	Advanced HTTP client with interceptors for centralized error handling and token management.
Service Locator	GetIt	Lightweight Dependency Injection (DI) to ensure loose coupling.
Code Generation	Freezed / JsonSerializable	Ensures type safety and eliminates boilerplate errors in data models.
3. ARCHITECTURAL LAYERS (CLEAN ARCHITECTURE)
The application is decoupled into three distinct layers to ensure maintainability:

A. Data Layer (The Infrastructure)

Models: DTOs (Data Transfer Objects) mapping API JSON responses.

Data Sources: Implementation of Remote (API) and Local (Isar) data logic.

Repositories (Implementation): Logic that decides whether to fetch/push data to the local DB or the remote API.

B. Domain Layer (The Business Heart)

Entities: Pure business logic data models, independent of any framework.

Use Cases: Single-responsibility classes (e.g., SubmitAuditUseCase).

Repositories (Abstract): Interfaces defining the contracts for data operations.

C. Presentation Layer (The UI)

BLoC/Cubit: Processes UI events and emits states.

Pages & Widgets: Modular UI components built with a focus on reusability.

4. OFFLINE-FIRST & QUEUE MANAGEMENT
The "Offline-First" capability is the core pillar of this QMS, managed via the following mechanism:

4.1. Offline Write Flow

The user submits a form (e.g., an audit report).

Data is immediately persisted to Isar DB as a local record.

Simultaneously, the request metadata (method, endpoint, payload) is added to a SyncQueue table with a Pending status.

If a connection is available, the sync is triggered immediately; otherwise, it stays in the queue.

4.2. Sync Manager (The Queue Handler)

Connectivity Watcher: Real-time monitoring of network status.

Background Worker: Processes the queue even when the app is in the background.

FIFO (First-In-First-Out): Records are pushed to the backend in the exact order they were created to maintain data integrity.

5. PROJECT STRUCTURE (FEATURE-BASED)
Plaintext
lib/
├── core/                        # Global shared logic
│   ├── constants/               # App colors (Soft UI), Typography, API Endpoints
│   ├── database/                # Isar initialization and global schemas
│   ├── network/                 # Dio client and Interceptor configurations
│   ├── sync/                    # SyncQueue Manager and Background Workers
│   └── util/                    # Validations, formatters, and extensions
├── features/                    # Business modules (each with its own Clean Arch)
│   ├── audit/                   # Audit Module
│   │   ├── data/                # Models, Repositories, Datasources
│   │   ├── domain/              # Entities, Usecases
│   │   └── presentation/        # Pages, BLoC, Widgets
│   └── training/                # Training/Education Module
├── theme/                       # Material 3 & Soft Design (macOS/Papara style)
├── injection.dart               # Dependency Injection Registry (GetIt)
└── main.dart                    # Application Entry Point
6. DESIGN STANDARDS (UI/UX)

User Feedback: Clear status indicators for "Offline Mode" and "Pending Syncs" to manage user expectations.

Efficiency: Implementing Slivers and ListView.builder for high-performance rendering of large industrial data sets.

7. SECURITY & DATA INTEGRITY
Secure Storage: JWT and sensitive credentials stored via flutter_secure_storage.

Timestamp Verification: Each offline action carries a local_timestamp to ensure the backend processes the "Audit Trail" in the correct chronological order.