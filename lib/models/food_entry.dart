//this one is used when the user scans a barcode, and it will be used to get the food information from the openfoodfacts api
class FoodEntry {
  final String name;
  final double kcalPer100g;//
  final double? proteinPer100g;
  final double? carbsPer100g;
  final double? fatPer100g;
  final String? barcode;// null for manual entries

  const FoodEntry({
    required this.name,
    required this.kcalPer100g,
    this.proteinPer100g,
    this.carbsPer100g,
    this.fatPer100g,
    this.barcode,
  });
}