
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

