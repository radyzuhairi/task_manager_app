
class Category {
  final String id;
  final String name;
  final String color;

  const Category({
    required this.id,
    required this.name,
    required this.color,
  });
}

const List<Category> defaultCategories = [
  Category(id: '1', name: 'عمل', color: '#4CAF50'),
  Category(id: '2', name: 'شخصي', color: '#2196F3'),
  Category(id: '3', name: 'تسوق', color: '#F44336'),
  Category(id: '4', name: 'دراسة', color: '#9C27B0'),
  Category(id: '5', name: 'أخرى', color: '#607D8B'),
];