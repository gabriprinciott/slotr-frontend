# Slotr — Frontend

**Slotr** is a real-time time-slot booking web application built with **Flutter**.

---

### Project Overview & Technical Challenge Context

This application was developed as part of the **Fullstack Technical Challenge** — an end-to-end time-slot booking system built according to the following specifications:

* **End-to-End Booking System**: Complete CRUD handling for the `bookings` resource (`name`, `date`, `time_slot`, `note`) with persistent storage.
* **Strict Uniqueness Constraint**: Guarantees that no two bookings can be created for the same `date` + `time_slot` combination. The backend rejects conflicts (`409 Conflict`), and the frontend gracefully handles and displays the error.
* **Interactive Frontend**: Allows users to select dates, view occupied and available slots, create bookings, delete existing bookings, and receive clear visual feedback on conflicts (e.g., slot already taken).
* **Real API Communication**: Direct, real-world communication with the backend REST API (via Dio and Retrofit, without mocks).
* **Real-Time Concurrency & Lock Sync (Optional Bonus Implemented)**: Implements active slot locking and real-time state synchronization via WebSockets. When a user is viewing or selecting a slot, other clients immediately see it as unavailable or locked in real time (verifiable across parallel browser tabs) to prevent race conditions prior to submission.

---

### Platform Note

> **Note:** The application was intentionally developed and tested **exclusively for the Web platform**. As the primary objective of this challenge is to evaluate end-to-end integration and real-time synchronization with the backend API, mobile (iOS/Android) and desktop builds were not targeted for this scope. However, the architecture is fully modular and prepared for future cross-platform adaptation.

---

### Key Features

* **Slot Selection & Date Exploration**: Reactive calendar/grid interface to browse dates, view availability, and check booked or temporarily locked slots.
* **Real-time Lock Sync (Bonus)**: WebSocket integration that instantly updates the UI when a slot is inspected or locked by another concurrent client.
* **End-to-End Error & Conflict Handling**: Clear visual feedback (banners and toasts) when attempting to book a slot that has already been taken (`409 Conflict`).
* **Predictable State Management**: Structured with the **BLoC** (Business Logic Component) pattern for clean separation of concerns and robust testability.

---

### Environment Configuration (`.env`)

The application uses a `.env` file at the root of the project to configure the backend API and WebSocket URLs:

```bash
cp .env.example .env
```

Default variables (`.env.example`):
```env
BASE_URL=http://localhost:3000
WS_URL=ws://localhost:3000
```

---

### Quick Start

#### Option A: Local Execution (Requires Flutter SDK)

1. **Clone the repository and install dependencies:**
   ```bash
   git clone https://github.com/gabriprinciott/slotr_app.git
   cd slotr_app
   flutter pub get
   ```

2. **Configure environment variables:**
   ```bash
   cp .env.example .env
   ```

3. **Start the application in development mode:**
   ```bash
   flutter run -d chrome
   ```

---

#### Option B: Docker Compose

If serving the pre-built web client via Nginx with Docker Compose:

1. **Create the Docker Compose override file for local testing:**
   ```bash
   cp docker-compose.override.yml.example docker-compose.override.yml
   ```
   *(This step configures the local ports, keeping the base `docker-compose.yml` clean for production deployments.)*

2. **Start the container:**
   ```bash
   docker compose up -d
   ```

The application will be accessible in your browser at: `http://localhost:8080` (or whichever port you configured in `.env`).

---

### Architectural Documentation

For technical decisions, AI tooling disclosure, and future roadmap, please refer to **[`NOTES.md`](./NOTES.md)**.