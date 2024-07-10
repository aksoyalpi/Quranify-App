class Recitator {
  final int id;
  final String name;
  String? style;

  Recitator({required this.id, required this.name, this.style});

  factory Recitator.fromJson(Map<String, dynamic> json) {
    return switch(json){
      {
        "id": int id,
        "reciter_name": String name,
        "style": String? style
      } => Recitator(id: id, name: name, style: style),
      _ => throw FormatException("Failed to load Recitator")
    };
  }
}