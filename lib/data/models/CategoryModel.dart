class CategoryModel {
  String description;

  CategoryModel({required this.description});

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['description'] = description;
    return data;
  }
}
