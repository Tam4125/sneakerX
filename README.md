# 📱 Sneaker E-Commerce App (Flutter)

A cross-platform marketplace mobile application built using Flutter, designed to serve multiple user roles:

* **👟 Customers:** Browse, search, and purchase sneakers.
* **🏪 Shop Owners:** Upload, manage, and track products.
* **🛒 E-commerce Flows:** Core functionality including cart management, checkout, orders, and product reviews.

This project emphasizes **clean architecture**, a **modular folder structure**, and a disciplined **Git workflow** for efficient team collaboration with team size of 4.

---

## 📂 Project Folder Structure
```css
lib/
└── src/
    ├── common/      
    ├── config/      
    ├── data/        
    ├── modules/     
    ├── services/    
    └── main.dart
```

### 1. `src/common/`

Reusable UI components and utilities shared across the entire application.

### 2. `src/config/`

Global configuration settings for the application.

### 3. `src/data/`

The business data layer, including data structures and logic for data fetching/persistence.

* **`models/`**: Defines business models.
* **`repository/`**: Repositories handle API interactions, CRUD logic, and data mapping.

### 4. `src/modules/`

The main feature modules of the application, implementing the application's core functionality.

**Internal Module Structure:**

Each module follows a consistent structure:
* `controllers/` → Business logic and state management.
* `views/` → UI screens and pages.
* `widgets/` → Module-specific reusable UI components.

### 5. `src/services/`

Shared services used by multiple modules, typically handling external interfaces.

---

# 🌳 Git Repository Structure and Workflow

## 🌿 Branch Structure

The repository uses the following hierarchy:

```bash
├──main
├── develop
├── feature/authentication
├── feature/product_listing
├── feature/cart_checkout
└── feature/shop_owner_dashboard
```

## 🌱 Branch Types & Roles

Our branching strategy is based on GitFlow, ensuring a stable release environment and isolated feature development.

### 1. `main` 🚀

* **Role:** The **Production-ready** branch.
* **Status:** Must always be **stable** and immediately deployable.
* **Rule:** Only accepts merges from the `develop` branch. **Direct commits are strictly forbidden.**

### 2. `develop` 🏗️

* **Role:** The **Central branch for integration**. This is the source for all development efforts.
* **Process:** New features are merged here first. **Extensive QA tests** are performed on this branch before it is considered stable enough to merge into `main` for a release.

### 3. `feature/` 💡

* **Role:** Used by team members to **work independently on specific tasks** without disrupting the stability of `develop`.
* **Convention:** Branches must be named descriptively, starting with `feature/`.
* **Examples:**
    * `feature/login_ui`
    * `feature/product_api`
    * `feature/shop_inventory`
---
## 👥 Team Workflow for Each Member (Step-by-Step)

Every team member must strictly adhere to this standardized Git workflow to ensure code quality, isolated development, and a smooth integration process. 

[Image of the GitFlow feature branch workflow]


### 1. Clone the Main Repository

Start by getting the repository to your local machine:

### 2. Checkout the `develop` Branch

Ensure you are up-to-date with the latest integrated code before starting a new task:

```bash
git checkout develop
git pull
```

### 3. Create Your Own Feature Branch

Create a new branch for your specific task. Naming Convention: feature/<descriptive-name>

```bash
git checkout -b feature/login-screen
```


### 4. Develop Your Feature (Code Normally)

Implement your functionality, focusing your changes within the appropriate lib/src/modules/ directory.


### 5. Commit Your Changes

Commit frequently with clear, descriptive messages using the required prefixes

```bash
git add .
git commit -m "feat: Added login UI and basic form validation"
```

### 6. Push Your Branch to Remote

Push your local branch to the remote repository for backup and collaboration:

```bash
git push --set-upstream origin feature/login-screen
```
