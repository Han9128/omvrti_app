
# OmVrti.ai Mobile Application  
### Architecture & Development Planning  

---

## 1. Objective

The goal of this document is to define a scalable, maintainable, and production-ready architecture for the OmVrti.ai mobile application.

To ensure long-term scalability, we focus on three core pillars:

- **Architecture Plan**  
  Defines how different layers (UI, business logic, and data) are structured and interact.

- **Folder Structure**  
  Defines how the project is organized based on features and architectural decisions.

- **State Management**  
  Defines how data flows through the application and how UI updates are handled.

---

## 2. Architecture Plan

In modern application development, one of the most widely used approaches is **Clean Architecture combined with a Feature-First folder structure**.

### 2.1 Clean Architecture Overview

Clean Architecture organizes the application into three main layers, like an onion:

| Layer          | Description              |
|---------------|--------------------------|
| Presentation  | UI, Screens, Widgets     |
| Domain        | Business Logic, Rules          |
| Data          | APIs, Database , Local Storage         |

The rule is: inner layers never know about outer layers. Your business logic should not care if data comes from an API or a local database. This makes testing and swapping things out easy. But, for now we will follow a MVVM (Model-View-ViewModel) architecture as clean architecture is too advanced and would become too complex at this moment so for simplicity and easiness MVVM will be followed and then later as the application grows in complexity, we can progressively transition to Clean Architecture by:

- Introducing a **Domain layer** (Use Cases, Entities)  
- Adding a **Repository layer** for better data abstraction  
- Decoupling data sources (API, local storage) from business logic  

### 2.2 MVVM Architecture Overview (Application Perspective)

To better understand how the application will be structured, the following illustrates how the **MVVM (Model-View-ViewModel)** architecture will be applied in the OmVrti.ai mobile app.

#### MVVM Layers

The application will be divided into three primary components:

View (UI Layer)  

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↓  

ViewModel (Logic Layer)  

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↓  

Model (Data Layer)

#### View (Presentation Layer)

This layer is responsible for:
- Rendering UI (Screens & Widgets)
- Handling user interactions (clicks, inputs)

**Examples in OmVrti.ai:**
- Dashboard Screen  
- Trip Details Screen  
- Flight Listing Screen  
- Booking Summary Screen  

**Responsibility:**
- Display data provided by ViewModel  
- Send user actions to ViewModel  

> Note: No business logic should be written in this layer.


#### ViewModel (Business Logic Layer)

This layer acts as a bridge between the UI and data.

**Responsibilities:**
- Fetch and manage data  
- Handle business logic  
- Prepare data for UI  
- Manage state  

**Examples in OmVrti.ai:**
- Fetch available flights for a trip  
- Calculate savings and budget usage  
- Handle booking selection logic  

#### Model (Data Layer)

This layer represents the data structures used in the application.

**Examples in OmVrti.ai:**
- Trip Model  
- Flight Model  
- Hotel Model  
- User Model  
- Rewards Model  

**Responsibility:**
- Define data format  
- Map API responses to usable objects  

---

## 3. Folder Structure (AutoPilot – MVVM)

```
lib/
├── core/
│   ├── constants/
│   ├── theme/
│   ├── utils/
│
├── features/
│
│   ├── autopilot/
│   │
│   │   ├── view/                    ← UI Layer
│   │   │   ├── screens/
│   │   │   │   ├── autopilot_alert_screen.dart
│   │   │   │   ├── autopilot_booking_screen.dart
│   │   │   │   ├── autopilot_summary_screen.dart
│   │   │   │
│   │   │   ├── widgets/
│   │   │       ├── flight_card.dart
│   │   │       ├── hotel_card.dart
│   │   │       ├── car_card.dart
│   │   │       ├── savings_card.dart
│   │
│   │   ├── viewmodel/               ← Logic Layer
│   │   │   ├── autopilot_viewmodel.dart
│   │
│   │   ├── model/                   ← Data Layer
│   │   │   ├── trip_model.dart
│   │   │   ├── flight_model.dart
│   │   │   ├── hotel_model.dart
│   │   │   ├── car_model.dart
│   │
│   │   ├── service/                 ← API / Data fetching 
│   │       ├── autopilot_service.dart
│
│
│   ├── dashboard/
│   ├── trip/
│   ├── booking/
│   ├── profile/

```

## 4. State Management
 
**Chosen Solution:** Riverpod 2.x
 
Riverpod is a reactive state management library for Flutter. It provides a centralized way to manage and share data across screens without passing values manually through widget layers.
 
**Why Riverpod over alternatives:**
 
| Option | Reason Rejected |
|---|---|
| setState | Cannot share state across screens |
| Provider | Outdated — Riverpod was built to replace it |
| GetX | Poor testability, not production-grade |
| Bloc | Too much boilerplate for current team size |
 
**Provider Types Used:**
 
| Type | Used For |
|---|---|
| `Provider` | Service instances, dependencies |
| `FutureProvider` | Fetching and displaying data (read-only screens) |
| `StateNotifierProvider` | Screens with user interactions and state changes |
 
**Widget Types:**
 
- `ConsumerWidget` — default choice, used when screen only displays data
- `ConsumerStatefulWidget` — used only when lifecycle methods are needed
 
**Upgrade Path:** If the team scales or compliance requires full event logging, Bloc can be adopted per feature without touching the service or model layers.
