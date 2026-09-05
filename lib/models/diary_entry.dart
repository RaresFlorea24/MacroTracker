//this one is used when the user scans a barcode, and it will be used to get the food information from the openfoodfacts api
class DiaryEntry {
  final String name;
  final double kcal;//
  final double? protein;
  final double? carbs;
  final double? fat;
  final double grams;

  const DiaryEntry({
    required this.name,
    required this.kcal,
    this.protein,
    this.carbs,
    this.fat,
    required this.grams,
  });
}