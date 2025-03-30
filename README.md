# Gomine Food

<p align="center">
  <img src="assets/logo.png" alt="Gomine Food Logo" width="200"/>
</p>

<p align="center">
  <a href="https://flutter.dev"><img src="https://img.shields.io/badge/Built%20with-Flutter-02569B?style=flat-square&logo=flutter" alt="Built with Flutter"></a>
  <a href="https://www.themealdb.com/api.php"><img src="https://img.shields.io/badge/API-TheMealDB-yellow?style=flat-square" alt="TheMealDB API"></a>
  <img src="https://img.shields.io/badge/License-MIT-green?style=flat-square" alt="MIT License">
  <img src="https://img.shields.io/badge/Version-1.0.0-blue?style=flat-square" alt="Version 1.0.0">
</p>

## 📋 Overview

Gomine Food is a feature-rich recipe application built with Flutter that leverages TheMealDB API to provide users with an extensive collection of recipes from around the world. The app offers an intuitive interface for discovering, saving, and cooking delicious meals with step-by-step instructions.

## ✨ Features

### Recipe Discovery
- Browse thousands of recipes from TheMealDB's extensive collection
- Explore recipes by categories (Breakfast, Lunch, Dinner, Desserts, etc.)
- Discover meals by region/cuisine (Italian, Mexican, Indian, etc.)
- View trending and popular recipes

### Search & Filter
- Powerful search functionality to find recipes by name
- Filter recipes by ingredients you have on hand
- Advanced filtering by dietary restrictions (Vegetarian, Vegan, Gluten-Free)
- Search by meal type or preparation time

### User Experience
- Detailed recipe pages with ingredients, measurements, and instructions
- Step-by-step cooking mode with timers
- Video tutorials for complex recipes
- Ingredient substitution suggestions
- Serving size adjustment calculator

### Personalization
- Create and customize user profiles
- Save favorite recipes for quick access
- Create custom collections and meal plans
- Rate and review recipes
- Track cooking history

### Offline Capabilities
- Save recipes for offline viewing
- Automatic syncing when back online
- Reduced data usage mode

## 📱 Screenshots

<p align="center">
  <img src="screenshots/home_screen.png" width="200" alt="Home Screen"/>
  <img src="screenshots/recipe_details.png" width="200" alt="Recipe Details"/>
  <img src="screenshots/search_screen.png" width="200" alt="Search Screen"/>
  <img src="screenshots/favorites.png" width="200" alt="Favorites"/>
</p>

## 🔧 Technical Details

### TheMealDB API Integration
Gomine Food integrates with [TheMealDB API](https://www.themealdb.com/api.php), a comprehensive database of recipes and meal information. The app utilizes the following API endpoints:

- `/search.php` - Search for recipes by name or ingredient
- `/lookup.php` - Get detailed information about a specific recipe
- `/categories.php` - Get all meal categories
- `/filter.php` - Filter meals by category, area, or ingredient
- `/random.php` - Get a random meal suggestion

### Architecture
The app follows a clean architecture pattern with:
- Repository pattern for data management
- Provider for state management
- Service-oriented approach for API communication
- Local caching using SQLite for offline functionality

## 🚀 Installation

### Prerequisites
- Flutter SDK (version 3.0.0 or higher)
- Dart SDK (version 2.17.0 or higher)
- Android Studio / VS Code with Flutter extensions
- An active internet connection for API calls

### Setup Instructions

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/gomine_food.git
   cd gomine_food
# gomine-food-2.0
