# ⛽ Fuel Pass Management System (Distributed System with Python RMI, Supabase & Flutter)

A robust, enterprise-grade distributed fuel pass distribution and management system. This application utilizes a multi-tier architecture where **Python** acts as the central RMI (Remote Method Invocation) server, **Supabase (PostgreSQL)** serves as the cloud database backend, and cross-platform **Flutter** applications power both the User and Station clients.

---

## 🏗️ System Architecture & Tech Stack

* **Backend Server:** Python (RMI Method implementation, dynamic network port binding, and server-side business logic).
* **Database & BaaS:** Supabase (PostgreSQL relational database, real-time data sync, and secure backend storage).
* **Frontend Clients:** Flutter (Cross-platform mobile/web apps tailored for Users and Fuel Stations).
* **Communication Protocol:** Distributed RMI over custom socket/network ports connecting clients to the Python backend and Supabase cloud.

---

## 🏛️ Database Schema (Supabase / PostgreSQL)

The system relies on a well-structured relational database managed via Supabase:
* **`users` table:** Stores citizen profiles, vehicle details, and authentication credentials.
* **`stations` table:** Manages authorized fuel station branches, locations, and operator info.
* **`fuel_passes` table:** Tracks QR-based fuel quotas, allowance limits, and transaction history.
* **`transactions` table:** Logs real-time fuel distribution records, dispensed amounts, and timestamps.

---

## 🧩 Core Components & Features

### 1. Python RMI Server & Supabase Integration
* Acts as the core orchestrator of the distributed system.
* Exposes remote procedure calls via **RMI** to handle client requests securely.
* Interfaces directly with **Supabase** for persistent data storage, authentication, and quota validations.
* Dynamic port configuration ensuring smooth communication between clients and the server.

### 2. Flutter User Application
* **Digital Fuel Pass:** Secure QR/Barcode-based fuel quota pass for citizens.
* **Quota Tracking:** Real-time monitoring of remaining fuel allocations.
* **Transaction History:** Detailed logs of past fuel refilling events.

### 3. Flutter Station Application
* **Pass Verification:** Instant scanner tool for station operators to validate user fuel passes.
* **Distribution Control:** Records dispensed fuel amounts and communicates with the Python RMI server to update quotas instantly.
* **Port Binding & Sync:** Connects to the active server port for real-time validation and database updates via Supabase.

---

## 🔄 Distributed Workflow
1. The **Python RMI Server** initializes, binds to a configured network port, and connects securely to **Supabase**.
2. **Flutter Clients (User & Station)** configure their network settings to locate the server port.
3. When a user requests a pass or a station operator scans a QR code, the client invokes a remote method on the Python server.
4. The Python server processes the business logic, updates the **Supabase** database, and returns the response in real-time.

---

## 🚀 Getting Started & Installation

### Prerequisites
* Python 3.x installed.
* Flutter SDK installed.
* Supabase account and database credentials configured.

### 1. Run the Python RMI Backend Server
```bash
cd Backend_2
pip install -r requirements.txt
python server.py
