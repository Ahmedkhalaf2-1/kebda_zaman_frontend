import 'dart:convert';
import 'dart:io';

void main() {
  final items = [
    {
      "id": "item_1",
      "categoryId": "cat_1",
      "name": "Alexandrian Kebda Sandwich",
      "description": "Authentic Alexandrian liver with spicy green peppers, garlic, and tahini in fresh fino bread.",
      "basePrice": 35.0,
      "imageUrl": "https://placehold.co/400x300/e65100/ffffff.png?text=Alexandrian+Kebda",
      "isAvailable": true,
      "isFeatured": true,
      "isBestSeller": true,
      "sortOrder": 1,
      "prepTimeMinutes": 10,
      "modifierGroups": [
        {
          "id": "group_tahini_1",
          "name": "Extra Tahini",
          "isRequired": false,
          "selectionType": "QUANTITY",
          "minSelections": 0,
          "maxSelections": 5,
          "options": [
            {"id": "addon_tahini_1", "name": "Extra Tahini", "priceModifier": 5.0}
          ]
        },
        {
          "id": "group_fries_1",
          "name": "Fries Pack",
          "isRequired": false,
          "selectionType": "QUANTITY",
          "minSelections": 0,
          "maxSelections": 5,
          "options": [
            {"id": "addon_fries_1", "name": "Fries Pack", "priceModifier": 15.0}
          ]
        },
        {
          "id": "group_spicy_1",
          "name": "Spicy Level",
          "isRequired": false,
          "selectionType": "SINGLE",
          "minSelections": 0,
          "maxSelections": 1,
          "options": [
            {"id": "opt_spicy_1", "name": "Extra Spicy", "priceModifier": 0.0},
            {"id": "opt_spicy_2", "name": "No Chili", "priceModifier": 0.0}
          ]
        }
      ]
    },
    {
      "id": "item_2",
      "categoryId": "cat_1",
      "name": "Grilled Kebda Meal",
      "description": "Half kilo of premium grilled liver served with rice, salad, and tahini.",
      "basePrice": 180.0,
      "discountPrice": 160.0,
      "imageUrl": "https://placehold.co/400x300/e65100/ffffff.png?text=Grilled+Kebda+Meal",
      "isAvailable": true,
      "isFeatured": false,
      "isBestSeller": false,
      "sortOrder": 2,
      "prepTimeMinutes": 20
    },
    {
      "id": "item_3",
      "categoryId": "cat_2",
      "name": "Sogo2 Sandwich",
      "description": "Juicy oriental sausage mixed with onions, tomatoes, and peppers in fino bread.",
      "basePrice": 40.0,
      "imageUrl": "https://placehold.co/400x300/bf360c/ffffff.png?text=Sogo2+Sandwich",
      "isAvailable": true,
      "isFeatured": true,
      "isBestSeller": true,
      "sortOrder": 1,
      "prepTimeMinutes": 12
    },
    {
      "id": "item_4",
      "categoryId": "cat_2",
      "name": "Pomegranate Molasses Sogo2",
      "description": "Oriental sausage cooked with sweet and sour pomegranate molasses.",
      "basePrice": 45.0,
      "imageUrl": "https://placehold.co/400x300/bf360c/ffffff.png?text=Pomegranate+Sogo2",
      "isAvailable": true,
      "isFeatured": false,
      "isBestSeller": false,
      "sortOrder": 2,
      "prepTimeMinutes": 15
    },
    {
      "id": "item_5",
      "categoryId": "cat_3",
      "name": "Classic Beef Hawawshi",
      "description": "Crispy baladi bread stuffed with spiced minced meat.",
      "basePrice": 50.0,
      "imageUrl": "https://placehold.co/400x300/ff6d00/ffffff.png?text=Beef+Hawawshi",
      "isAvailable": true,
      "isFeatured": true,
      "isBestSeller": true,
      "sortOrder": 1,
      "prepTimeMinutes": 15,
      "modifierGroups": [
        {
          "id": "group_cheese_1",
          "name": "Mozzarella Cheese",
          "isRequired": false,
          "selectionType": "QUANTITY",
          "minSelections": 0,
          "maxSelections": 1,
          "options": [
            {"id": "addon_cheese_1", "name": "Mozzarella Cheese", "priceModifier": 15.0}
          ]
        }
      ]
    },
    {
      "id": "item_6",
      "categoryId": "cat_3",
      "name": "Sogo2 Hawawshi",
      "description": "Crispy baladi bread stuffed with spiced oriental sausage.",
      "basePrice": 60.0,
      "imageUrl": "https://placehold.co/400x300/ff6d00/ffffff.png?text=Sogo2+Hawawshi",
      "isAvailable": true,
      "isFeatured": false,
      "isBestSeller": false,
      "sortOrder": 2,
      "prepTimeMinutes": 15
    },
    {
      "id": "item_7",
      "categoryId": "cat_4",
      "name": "Mix Grill Meal",
      "description": "A mix of Kebda, Sogo2, and Kofta. Served with rice, fries, and salads.",
      "basePrice": 220.0,
      "discountPrice": 199.0,
      "imageUrl": "https://placehold.co/400x300/ff9100/ffffff.png?text=Mix+Grill+Meal",
      "isAvailable": true,
      "isFeatured": true,
      "isBestSeller": false,
      "sortOrder": 1,
      "prepTimeMinutes": 25
    },
    {
      "id": "item_8",
      "categoryId": "cat_4",
      "name": "Kofta Meal",
      "description": "Half kilo of grilled Kofta. Served with rice, fries, and salads.",
      "basePrice": 190.0,
      "imageUrl": "https://placehold.co/400x300/ff9100/ffffff.png?text=Kofta+Meal",
      "isAvailable": true,
      "isFeatured": false,
      "isBestSeller": false,
      "sortOrder": 2,
      "prepTimeMinutes": 20
    },
    {
      "id": "item_9",
      "categoryId": "cat_5",
      "name": "Shish Tawook Sandwich",
      "description": "Grilled marinated chicken pieces in Syrian bread with garlic mayo.",
      "basePrice": 55.0,
      "imageUrl": "https://placehold.co/400x300/e65100/ffffff.png?text=Shish+Tawook",
      "isAvailable": true,
      "isFeatured": false,
      "isBestSeller": true,
      "sortOrder": 1,
      "prepTimeMinutes": 10
    },
    {
      "id": "item_10",
      "categoryId": "cat_5",
      "name": "Crispy Chicken Sandwich",
      "description": "Fried crispy chicken breast with cheddar cheese sauce.",
      "basePrice": 65.0,
      "imageUrl": "https://placehold.co/400x300/e65100/ffffff.png?text=Crispy+Chicken",
      "isAvailable": true,
      "isFeatured": false,
      "isBestSeller": true,
      "sortOrder": 2,
      "prepTimeMinutes": 12
    },
    {
      "id": "item_11",
      "categoryId": "cat_5",
      "name": "Kofta Sandwich",
      "description": "Grilled Kofta fingers in baladi bread with tahini.",
      "basePrice": 45.0,
      "imageUrl": "https://placehold.co/400x300/e65100/ffffff.png?text=Kofta+Sandwich",
      "isAvailable": true,
      "isFeatured": false,
      "isBestSeller": false,
      "sortOrder": 3,
      "prepTimeMinutes": 10
    },
    {
      "id": "item_12",
      "categoryId": "cat_6",
      "name": "French Fries",
      "description": "Golden crispy potato fries.",
      "basePrice": 25.0,
      "imageUrl": "https://placehold.co/400x300/ffcc80/000000.png?text=Fries",
      "isAvailable": true,
      "isFeatured": false,
      "isBestSeller": true,
      "sortOrder": 1,
      "prepTimeMinutes": 5,
      "modifierGroups": [
        {
          "id": "var_size_fries",
          "name": "Choose your size",
          "isRequired": true,
          "selectionType": "SINGLE",
          "minSelections": 1,
          "maxSelections": 1,
          "options": [
            {"id": "var_f_s", "name": "Small", "priceModifier": 0.0},
            {"id": "var_f_m", "name": "Medium", "priceModifier": 10.0},
            {"id": "var_f_l", "name": "Large", "priceModifier": 20.0}
          ]
        }
      ]
    },
    {
      "id": "item_13",
      "categoryId": "cat_6",
      "name": "Cheesy Fries",
      "description": "French fries loaded with melted cheddar cheese.",
      "basePrice": 40.0,
      "imageUrl": "https://placehold.co/400x300/ffcc80/000000.png?text=Cheesy+Fries",
      "isAvailable": true,
      "isFeatured": true,
      "isBestSeller": false,
      "sortOrder": 2,
      "prepTimeMinutes": 7
    },
    {
      "id": "item_14",
      "categoryId": "cat_6",
      "name": "Green Salad",
      "description": "Fresh oriental vegetable salad.",
      "basePrice": 15.0,
      "imageUrl": "https://placehold.co/400x300/ffcc80/000000.png?text=Green+Salad",
      "isAvailable": true,
      "isFeatured": false,
      "isBestSeller": false,
      "sortOrder": 3,
      "prepTimeMinutes": 5
    },
    {
      "id": "item_15",
      "categoryId": "cat_6",
      "name": "Tahini Dip",
      "description": "Classic sesame paste dip with garlic and lemon.",
      "basePrice": 10.0,
      "imageUrl": "https://placehold.co/400x300/ffcc80/000000.png?text=Tahini",
      "isAvailable": true,
      "isFeatured": false,
      "isBestSeller": true,
      "sortOrder": 4,
      "prepTimeMinutes": 2
    },
    {
      "id": "item_16",
      "categoryId": "cat_6",
      "name": "Tomeya (Garlic Dip)",
      "description": "Creamy garlic and yogurt dip.",
      "basePrice": 12.0,
      "imageUrl": "https://placehold.co/400x300/ffcc80/000000.png?text=Tomeya",
      "isAvailable": true,
      "isFeatured": false,
      "isBestSeller": false,
      "sortOrder": 5,
      "prepTimeMinutes": 2
    },
    {
      "id": "item_17",
      "categoryId": "cat_7",
      "name": "Rice Pudding (Roz bel Laban)",
      "description": "Creamy traditional rice pudding.",
      "basePrice": 25.0,
      "imageUrl": "https://placehold.co/400x300/ffd180/000000.png?text=Rice+Pudding",
      "isAvailable": true,
      "isFeatured": false,
      "isBestSeller": true,
      "sortOrder": 1,
      "prepTimeMinutes": 0,
      "modifierGroups": [
        {
          "id": "group_nuts_1",
          "name": "Mixed Nuts",
          "isRequired": false,
          "selectionType": "QUANTITY",
          "minSelections": 0,
          "maxSelections": 1,
          "options": [
            {"id": "addon_nuts_1", "name": "Mixed Nuts", "priceModifier": 10.0}
          ]
        }
      ]
    },
    {
      "id": "item_18",
      "categoryId": "cat_7",
      "name": "Om Ali",
      "description": "Hot traditional bread and milk pudding with nuts.",
      "basePrice": 35.0,
      "imageUrl": "https://placehold.co/400x300/ffd180/000000.png?text=Om+Ali",
      "isAvailable": true,
      "isFeatured": true,
      "isBestSeller": false,
      "sortOrder": 2,
      "prepTimeMinutes": 5
    },
    {
      "id": "item_19",
      "categoryId": "cat_8",
      "name": "Pepsi Can",
      "description": "330ml Pepsi Cola can.",
      "basePrice": 15.0,
      "imageUrl": "https://placehold.co/400x300/ffab40/000000.png?text=Pepsi",
      "isAvailable": true,
      "isFeatured": false,
      "isBestSeller": true,
      "sortOrder": 1,
      "prepTimeMinutes": 1
    },
    {
      "id": "item_20",
      "categoryId": "cat_8",
      "name": "7UP Can",
      "description": "330ml 7UP can.",
      "basePrice": 15.0,
      "imageUrl": "https://placehold.co/400x300/ffab40/000000.png?text=7UP",
      "isAvailable": true,
      "isFeatured": false,
      "isBestSeller": true,
      "sortOrder": 2,
      "prepTimeMinutes": 1
    },
    {
      "id": "item_21",
      "categoryId": "cat_8",
      "name": "Mineral Water",
      "description": "600ml bottled water.",
      "basePrice": 10.0,
      "imageUrl": "https://placehold.co/400x300/ffab40/000000.png?text=Water",
      "isAvailable": true,
      "isFeatured": false,
      "isBestSeller": false,
      "sortOrder": 3,
      "prepTimeMinutes": 1
    }
  ];

  final file = File('assets/mock/menu.json');
  file.writeAsStringSync(jsonEncode(items));
}
