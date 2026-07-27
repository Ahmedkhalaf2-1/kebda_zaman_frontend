import 'dart:convert';
import 'dart:io';

// Very lightweight classes for generation
class ModifierOption {
  final String id;
  final String name;
  final double priceModifier;
  final bool isDefault;
  final List<ModifierGroup> nestedModifierGroups;

  ModifierOption({
    required this.id,
    required this.name,
    this.priceModifier = 0.0,
    this.isDefault = false,
    this.nestedModifierGroups = const [],
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'priceModifier': priceModifier,
        'isDefault': isDefault,
        'isAvailable': true,
        'nestedModifierGroups': nestedModifierGroups.map((e) => e.toJson()).toList(),
      };
}

class ModifierGroup {
  final String id;
  final String name;
  final bool isRequired;
  final String selectionType;
  final int minSelections;
  final int maxSelections;
  final List<ModifierOption> options;

  ModifierGroup({
    required this.id,
    required this.name,
    this.isRequired = false,
    this.selectionType = 'SINGLE',
    this.minSelections = 0,
    this.maxSelections = 1,
    required this.options,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'isRequired': isRequired,
        'selectionType': selectionType,
        'minSelections': minSelections,
        'maxSelections': maxSelections,
        'options': options.map((e) => e.toJson()).toList(),
      };
}

void main() {
  final drinkSizeGroup = ModifierGroup(
    id: 'grp_drink_size',
    name: 'Drink Size',
    isRequired: true,
    selectionType: 'SINGLE',
    minSelections: 1,
    maxSelections: 1,
    options: [
      ModifierOption(id: 'opt_drink_size_reg', name: 'Regular', priceModifier: 0.0, isDefault: true),
      ModifierOption(id: 'opt_drink_size_lrg', name: 'Large Drink', priceModifier: 10.0),
    ],
  );
  final doubleBurger = {
    'id': 'item_burger_1',
    'categoryId': 'cat_1',
    'name': 'Double Burger',
    'description': 'Two juicy beef patties with our signature sauce.',
    'basePrice': 120.0,
    'imageUrl': 'https://placehold.co/400x300/e65100/ffffff.png?text=Double+Burger',
    'isAvailable': true,
    'isFeatured': true,
    'isBestSeller': true,
    'sortOrder': 1,
    'prepTimeMinutes': 15,
    'modifierGroups': [
      ModifierGroup(
        id: 'grp_burger_size',
        name: 'Choose Size',
        isRequired: true,
        selectionType: 'SINGLE',
        minSelections: 1,
        maxSelections: 1,
        options: [
          ModifierOption(id: 'opt_size_reg', name: 'Regular', priceModifier: 0.0, isDefault: true),
          ModifierOption(id: 'opt_size_lrg', name: 'Large', priceModifier: 30.0),
        ],
      ).toJson(),
      ModifierGroup(
        id: 'grp_burger_meal',
        name: 'Make it a Meal',
        isRequired: false,
        selectionType: 'SINGLE',
        minSelections: 0,
        maxSelections: 1,
        options: [
          ModifierOption(
            id: 'opt_meal_yes',
            name: 'Yes',
            priceModifier: 50.0,
            nestedModifierGroups: [
              ModifierGroup(
                id: 'grp_meal_fries',
                name: 'Choose Fries',
                isRequired: true,
                selectionType: 'SINGLE',
                minSelections: 1,
                maxSelections: 1,
                options: [
                  ModifierOption(id: 'opt_fries_reg', name: 'Regular Fries', isDefault: true),
                  ModifierOption(id: 'opt_fries_lrg', name: 'Large Fries', priceModifier: 15.0),
                ],
              ),
              ModifierGroup(
                id: 'grp_meal_drink',
                name: 'Choose Drink',
                isRequired: true,
                selectionType: 'SINGLE',
                minSelections: 1,
                maxSelections: 1,
                options: [
                  ModifierOption(id: 'opt_drink_coke', name: 'Coca-Cola', isDefault: true, nestedModifierGroups: [drinkSizeGroup]),
                  ModifierOption(id: 'opt_drink_sprite', name: 'Sprite', nestedModifierGroups: [drinkSizeGroup]),
                ],
              ),
            ],
          ),
        ],
      ).toJson(),
      ModifierGroup(
        id: 'grp_burger_extras',
        name: 'Add Extras',
        isRequired: false,
        selectionType: 'QUANTITY',
        minSelections: 0,
        maxSelections: 5,
        options: [
          ModifierOption(id: 'opt_extra_cheese', name: 'Extra Cheese', priceModifier: 15.0),
          ModifierOption(id: 'opt_extra_beef', name: 'Extra Beef', priceModifier: 50.0),
        ],
      ).toJson(),
      ModifierGroup(
        id: 'grp_burger_remove',
        name: 'Remove Ingredients',
        isRequired: false,
        selectionType: 'MULTIPLE',
        minSelections: 0,
        maxSelections: 5,
        options: [
          ModifierOption(id: 'opt_remove_onion', name: 'Onion', priceModifier: 0.0),
          ModifierOption(id: 'opt_remove_pickles', name: 'Pickles', priceModifier: 0.0),
          ModifierOption(id: 'opt_remove_tomato', name: 'Tomato', priceModifier: 0.0),
        ],
      ).toJson(),
    ]
  };

  final items = [
    doubleBurger,
    // Add a few more generic items so we have a full menu
    {
      'id': 'item_pasta_1',
      'categoryId': 'cat_2',
      'name': 'Chicken Alfredo Pasta',
      'description': 'Creamy pasta with grilled chicken and mushrooms.',
      'basePrice': 95.0,
      'imageUrl': 'https://placehold.co/400x300/ff6d00/ffffff.png?text=Chicken+Pasta',
      'isAvailable': true,
      'isFeatured': false,
      'isBestSeller': true,
      'sortOrder': 2,
      'prepTimeMinutes': 20,
      'modifierGroups': [
        ModifierGroup(
          id: 'grp_pasta_size',
          name: 'Portion Size',
          isRequired: true,
          selectionType: 'SINGLE',
          minSelections: 1,
          maxSelections: 1,
          options: [
            ModifierOption(id: 'opt_pasta_reg', name: 'Regular', isDefault: true),
            ModifierOption(id: 'opt_pasta_fam', name: 'Family Size', priceModifier: 70.0),
          ]
        ).toJson(),
        ModifierGroup(
          id: 'grp_pasta_extras',
          name: 'Extra Toppings',
          selectionType: 'MULTIPLE',
          maxSelections: 3,
          options: [
            ModifierOption(id: 'opt_xtra_mush', name: 'Extra Mushrooms', priceModifier: 10.0),
            ModifierOption(id: 'opt_xtra_chick', name: 'Extra Chicken', priceModifier: 30.0),
            ModifierOption(id: 'opt_xtra_parm', name: 'Extra Parmesan', priceModifier: 15.0),
          ]
        ).toJson()
      ]
    },
    {
      'id': 'item_dessert_1',
      'categoryId': 'cat_7',
      'name': 'Chocolate Molten Cake',
      'description': 'Warm chocolate cake with a gooey center.',
      'basePrice': 60.0,
      'imageUrl': 'https://placehold.co/400x300/4e342e/ffffff.png?text=Molten+Cake',
      'isAvailable': true,
      'isFeatured': true,
      'isBestSeller': false,
      'sortOrder': 3,
      'prepTimeMinutes': 10,
      'modifierGroups': [
        ModifierGroup(
          id: 'grp_dessert_icecream',
          name: 'Add Ice Cream Scoop',
          selectionType: 'QUANTITY',
          maxSelections: 3,
          options: [
            ModifierOption(id: 'opt_ic_vanilla', name: 'Vanilla Scoop', priceModifier: 15.0),
            ModifierOption(id: 'opt_ic_choc', name: 'Chocolate Scoop', priceModifier: 15.0),
          ]
        ).toJson()
      ]
    }
  ];

  File('assets/mock/menu.json').writeAsStringSync(jsonEncode(items));
}
