# Stock Up Fresh 🛒📦

## 1. User Stories (Required and Optional)

**Required Must-have Stories**

* Users can login/signup  
* Users can create and manage a grocery list  
* Grocery list auto-sorts items by store sections (produce, dairy, etc.)  
* Users can scan barcodes to quickly add items to the list or pantry  
* Users can track their My Kitchen  
* Items running low in pantry are suggested in the grocery list  
* Users can receive reminders when near a store  

**Optional Nice-to-have Stories**

* Users can integrate low-stock items with Apple Calendar as events  
* Users can receive smart suggestions based on usage patterns  
* Collaborative lists for multiple users to manage a shared grocery list  

## 2. Screen Archetypes

* **Login/Signup Screen**  
  * Users can login/signup  

* **Grocery List Screen** (🟢 Home)  
  * Users can create and manage a grocery list  
  * Grocery list auto-sorts by store sections  
  * Collaborative list access  
  * Suggested items from pantry (when low) show up here  

* **Add Grocery Screen**  
  * Users can manually add items to their grocery list  

* **Individual Grocery Screen**  
  * Users can view the ingredients/contents of the item including a picture  

* **Barcode Scanner Screen**  
  * Users can scan barcodes to quickly add items to the grocery list or pantry  

* **Settings/Profile Screen**  
  * Manage sync, preferences, collaborative features  
  * Enable/disable low-stock alerts and reminders  
  * Calendar integration (optional)  

* **My Kitchen Screen**  
  * Users can manage stock levels of what they have at home  
  * Items have quantities and thresholds  
  * When low, items are suggested on Grocery List  

## 3. Navigation

**Tab Navigation** (Bottom Navigation Tabs)

* Grocery List (Home)  
* My Kitchen
* Barcode Scanner  
* Settings/Profile  

**Flow Navigation** (Screen to Screen)

* Login/Signup  
  * -> Grocery List (after successful login)  

* Grocery List (Home)  
  * -> Add Grocery (manually add item)  
  * -> Individual Grocery Screen (view/edit item)  

* My Kitchen
  * -> Individual Grocery Screen (view/edit item)  
  * -> Grocery List (suggested item appears if running low)  
  * -> Calendar Integration (optional event creation)  

* Barcode Scanner  
  * -> Add item to Grocery List or Pantry based on user choice  
  * -> Return to previous screen  

* Settings/Profile  
  * -> Manage account, reminders, calendar, and inventory thresholds
