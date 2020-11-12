class BusinessCategory {
  final String name;
  final bool enabled;

  BusinessCategory({this.name, this.enabled});

  static BusinessCategory fromJson(Map<String, dynamic> j) {
    return BusinessCategory(name: j["name"], enabled: j["enabled"]);
  }

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "enabled": enabled,
    };
  }
}
