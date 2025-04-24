# Stock Up Fresh 🛒📦

## Table of Contents
- [Overview](#overview)
- [Product Spec](#product-spec)
- [Wireframes](#wireframes)
- [Schema](#schema)

## Overview

**Description**  
Stock Up Fresh is an intelligent grocery management with integrated pantry tracking and smart, location-based reminders. It helps users efficiently track pantry inventory, and receive actionable reminders when they’re near relevant stores. Designed with Apple ecosystem integration in mind, Stock Up Fresh reduces food waste, saves time, and ensures you never forget an item again — all while offering a seamless iOS-native experience.

**App Evaluation**  
- **Category**: Productivity, Lifestyle  
- **Mobile**: Mobile application only  
- **Story**: Users can easily manage their grocery shopping experience, pantry stock and get location-based reminder when low on stock, and close to a grocery store.  
- **Market**: Everyday shoppers, especially those who like to stay organized and manage their grocery shopping efficiently.  
- **Habit**: Daily use (shopping, pantry management)  
- **Scope**: Broad in features, from grocery list management to pantry tracking and location based reminders.

---

## Product Spec

### 1. User Stories (Required and Optional)

**Required Must-have Stories**  
- [x] 🔑 Users can login/signup  
- [x] 📝 Users can create and manage a grocery list  
- [x] 🏷️ Grocery list auto-sorts items by store sections (produce, dairy, etc.)  
- [x] 📱 Users can scan barcodes to quickly add items to the list or pantry  
- [x] 🍽️ Users can track their My Kitchen  
- [x] 🔴 Items running low in pantry are suggested in the grocery list  
- [x] ⏰ Users can receive reminders when near a store  

**Optional Nice-to-have Stories**  
- [x] 📅 Users can integrate low-stock items with Apple Calendar as events  
- [ ] 🤖 Users can receive smart suggestions based on usage patterns  
- [x] 👥 Collaborative lists for multiple users to manage a shared grocery list  

### 2. Screen Archetypes

- **Login/Signup Screen**  
  * 🔑 Users can login/signup  

- **Grocery List Screen** (🟢 Home)  
  * 📝 Users can create and manage a grocery list  
  * 🏷️ Grocery list auto-sorts by store sections  
  * 👥 Collaborative list access  
  * 🍽️ Suggested items from pantry (when low) show up here  

- **Add Grocery Screen**  
  * ➕ Users can manually add items to their grocery list  

- **Individual Grocery Screen**  
  * 🍔 Users can view the ingredients/contents of the item including a picture  

- **Barcode Scanner Screen**  
  * 📱 Users can scan barcodes to quickly add items to the grocery list or pantry  

- **Settings/Profile Screen**  
  * ⚙️ Manage sync, preferences, collaborative features  
  * 🔔 Enable/disable low-stock alerts and reminders  
  * 📅 Calendar integration (optional)  

- **My Kitchen Screen**  
  * 🏠 Users can manage stock levels of what they have at home  
  * 📊 Items have quantities and thresholds  
  * 🛒 When low, items are suggested on Grocery List  

### 3. Navigation

**Tab Navigation** (Bottom Navigation Tabs)  
- 🛒 Grocery List (Home)  
- 🍽️ My Kitchen  
- 📱 Barcode Scanner  
- ⚙️ Settings/Profile  

**Flow Navigation** (Screen to Screen)  
- **Login/Signup**  
  * -> 🛒 Grocery List (after successful login)  

- **Grocery List (Home)**  
  * -> ➕ Add Grocery (manually add item)  
  * -> 🍔 Individual Grocery Screen (view/edit item)  

- **My Kitchen**  
  * -> 🍔 Individual Grocery Screen (view/edit item)  
  * -> 🛒 Grocery List (suggested item appears if running low)  
  * -> 📅 Calendar Integration (optional event creation)  

- **Barcode Scanner**  
  * -> ➕ Add item to Grocery List or Pantry based on user choice  
  * -> 🔙 Return to previous screen  

- **Settings/Profile**  
  * -> ⚙️ Manage account, reminders, calendar, and inventory thresholds  

---

## Wireframes

**Low Fidelity Wireframe**
<img width="1125" alt="Screenshot 2025-04-03 at 3 52 39 PM" src="https://github.com/user-attachments/assets/1010f1c1-da9c-45ae-8e10-ce000d45e7e3" />

**Digital Wireframes & Mockups**  
![PHOTO-2025-04-03-15-53-21](https://github.com/user-attachments/assets/6ec7b9b6-f101-4a8d-add9-6ae41e04f5c5)

**Demos**  
* Milestone 1 \
![Simulator Screen Recording - iPhone 16 Pro - 2025-04-24 at 11 20 43](https://github.com/user-attachments/assets/300904ad-eada-4f84-bc03-8711cf29293f)


---

## Schema

### Models

**User**  
| Property   | Type    | Description                               |
|------------|---------|-------------------------------------------|
| username   | String  | Unique ID for the user                    |
| password   | String  | User's password for login authentication  |
| latitude   | Float   | User’s current latitude (for location-based reminders) |
| longitude  | Float   | User’s current longitude (for location-based reminders) |

**Item**  
| Property    | Type    | Description                               |
|-------------|---------|-------------------------------------------|
| name        | String  | Name of the grocery item                 |
| category    | String  | Category (produce, dairy, etc.)           |
| barcode     | String  | Barcode of the item (for scanning)       |
| quantity    | Integer | Stock quantity available in pantry       |
| threshold   | Integer | Threshold for when a low-stock alert triggers |
| store_location | String | Location of the store associated with the item |

**Location** (New)  
| Property     | Type    | Description                              |
|--------------|---------|------------------------------------------|
| store_name   | String  | Name of the store                       |
| store_address| String  | Address of the store                    |
| latitude     | Float   | Latitude of the store                   |
| longitude    | Float   | Longitude of the store                  |

---

## Networking

**List of network requests by screen**

- **Login/Signup Screen**  
  [POST] /users - To create a new user  
  [POST] /login - To authenticate and login the user  

- **Grocery List Screen**  
  [GET] /grocery_list - To retrieve user's grocery list  
  [POST] /grocery_list - To add an item to the grocery list  
  [PUT] /grocery_list/{id} - To update an item in the list  
  [DELETE] /grocery_list/{id} - To remove an item from the list  

- **My Kitchen Screen**  
  [GET] /pantry - To retrieve items in the pantry  
  [POST] /pantry - To add an item to the pantry  
  [PUT] /pantry/{id} - To update the stock of an item  
  [DELETE] /pantry/{id} - To remove an item from the pantry  

- **Barcode Scanner Screen**  
  [GET] /items/{barcode} - To retrieve item details by barcode  

- **Settings/Profile Screen**  
  [PUT] /settings - To update user preferences, reminders, and notifications  

- **Location-based Reminders**  
  [POST] /reminders/locations - To send a location-based reminder when the user is near a relevant store  
  [GET] /location/{user_id} - To get the current location of the user and check if reminders need to be triggered
