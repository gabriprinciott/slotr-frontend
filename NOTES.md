# 📑 NOTES.md — Slotr Frontend Architecture & Retrospective

This document outlines the architectural decisions, the use of Artificial Intelligence tools throughout development, and potential future improvements for the **Slotr** frontend project.

---

### 1. Technical Decisions

* **Framework & State Management**: **Flutter** was chosen for UI development, adopting the **BLoC (Business Logic Component)** pattern for state management. This ensures a strict separation between business logic and UI components, making the codebase highly testable, predictable, and maintainable.
* **Networking & Dependency Injection**:
    * **Dio & Retrofit**: Backend communication is handled via **Dio**, integrated with **Retrofit** for automatic generation of a strongly-typed REST client. This eliminates HTTP request/response boilerplate and guarantees compile-time type safety.
    * **get_it**: Used as a Service Locator for Dependency Injection, decoupling the creation of services, repositories, Dio clients, and BLoCs, thereby facilitating unit testing through mocking.
* **Routing with GoRouter**: The application utilizes **GoRouter** for navigation. For a web application, GoRouter is essential as it natively supports URL-based navigation, deep linking, reactive listening to BLoC state changes, and clean handling of dynamic routes (e.g., `/bookings/:date`).
* **Real-Time Synchronization**: WebSocket integration allows BLoCs to reactively emit state updates as soon as another client selects or locks a slot, updating the grid in real time without polling.
* **Design System & Accessibility**: The visual theme was generated from the app icon's color palette via *Flutter Theme Generator*. Subsequently, color contrasts (backgrounds, surfaces, primary/secondary typography) were refined to meet high accessibility standards (WCAG) and ensure optimal legibility.

---

### 2. Use of AI

During frontend development, AI tools (such as Claude / Antigravity) were leveraged in the following areas:
* **Brand Asset Generation**: Concept creation and generation of the application icon.
* **Theme Refinement & Accessibility**: Optimization of the color palette extracted from the theme generator to ensure WCAG-compliant contrasts between text and backgrounds.
* **Boilerplate & Code Generation**: Initial configuration scaffolding for Retrofit, `build_runner`, base `Event` and `State` structures for BLoCs, and service registration in `get_it`.
* **Manual Implementation & Verification**: The core project architecture, dependency injection wiring, WebSocket lifecycle management, Dio error interceptor mappings (`409 Conflict`), and custom reactive BLoC integrations were written, tested, and verified manually.

---

### 3. What to do with More Time

Given additional time, the priorities for evolving the frontend would be:
1. **Automated Testing**: Implement automated tests for the frontend.
2. **Full Cross-Platform Support**: Extending testing and official support to desktop operating systems (Linux, macOS, Windows) and mobile platforms (iOS, Android), taking full advantage of Flutter's multi-platform capabilities.
3. **PWA (Progressive Web App) & Offline Caching**: Configuring PWA features for browser installability and implementing local caching/storage strategies to gracefully handle transient network disconnections.
4. Setup **CI/CD** Pipelines
5. **WebSocket Synchronization**: Align cancelled reservations with sockets.