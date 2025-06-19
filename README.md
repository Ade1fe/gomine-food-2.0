# 🍽️ Gomine Food

<p align="center">
  <img src="assets/logo.png" alt="Gomine Food Logo" width="200"/>
</p>

<p align="center">
  <a href="https://flutter.dev"><img src="https://img.shields.io/badge/Built%20with-Flutter-02569B?style=flat-square&logo=flutter" alt="Built with Flutter"></a>
  <a href="https://www.themealdb.com/api.php"><img src="https://img.shields.io/badge/API-TheMealDB-yellow?style=flat-square" alt="TheMealDB API"></a>
  <img src="https://img.shields.io/badge/License-MIT-green?style=flat-square" alt="MIT License">
  <img src="https://img.shields.io/badge/Version-2.0.0-blue?style=flat-square" alt="Version 2.0.0">
</p>

---

## 📋 Overview

**Gomine Food** is a feature-rich Flutter application for discovering and cooking delicious meals. It leverages the [TheMealDB API](https://www.themealdb.com/api.php) to provide access to a wide range of recipes from global cuisines. The app offers a seamless user experience, from browsing to saving favorites — even offline!

---

## ✨ Features

### 🍳 Recipe Discovery
- Explore recipes by **categories** (e.g. Breakfast, Lunch, Desserts)
- Discover meals by **region** (e.g. Italian, Mexican, Nigerian)
- View **trending**, **random**, and **new** meals

### 🔍 Smart Search & Filters
- Search by meal name or ingredients
- Filter by **dietary needs** (Vegetarian, Vegan, etc.)
- Filter by **cuisine**, **meal type**, or **prep time**

### 👩‍🍳 Cooking Experience
- Step-by-step cooking instructions
- Ingredient substitution suggestions
- Auto-calculated serving adjustments
- Timer mode for guided cooking
- Video tutorials (if available)

### 📁 Personalization
- Save favorite recipes
- Create custom collections & meal plans
- Track cooking history
- User profiles (for multiple users or devices)

### 📶 Offline Mode
- Save recipes for offline viewing
- Auto-sync when reconnected
- Data-saving mode

---

## 📱 Screenshots

<p align="center">
  <img src="screenshots/home_screen.png" width="200" alt="Home Screen"/>
  <img src="screenshots/recipe_details.png" width="200" alt="Recipe Details"/>
  <img src="screenshots/search_screen.png" width="200" alt="Search Screen"/>
  <img src="screenshots/favorites.png" width="200" alt="Favorites"/>
</p>

---

## 🔧 Technical Details

### 🧠 Architecture
- **MVVM pattern** with `Provider` for state management
- **Repository layer** to abstract API and local storage
- API integration via `http` package
- Offline caching with `sqflite`
- Responsive UI using `LayoutBuilder` and `MediaQuery`

### 🌐 API Endpoints Used
- `search.php?s=...` — Search by name
- `lookup.php?i=...` — Meal details by ID
- `categories.php` — Get meal categories
- `filter.php?c=...` — Meals by category
- `random.php` — Get random meals

---

## 🚀 Getting Started

### 📦 Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (>= 3.0.0)
- Dart SDK (>= 2.17.0)
- VS Code / Android Studio
- A connected device or emulator

### 🧪 Installation

```bash
git clone https://github.com/yourusername/gomine_food.git
cd gomine_food
flutter pub get
flutter run
