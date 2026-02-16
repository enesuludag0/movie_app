class Movie {
  final int id;
  final String name;
  final String? summary;
  final String? image;
  final String? imageOriginal;
  final Rating? rating;
  final List<String> genres;
  final String? status;
  final String? premiered;
  final String? ended;
  final String? network;
  final String? type;
  final String? language;
  final int? runtime;
  final int? averageRuntime;
  final String? officialSite;
  final Schedule? schedule;
  final int? weight;
  final String? url;

  Movie({
    required this.id,
    required this.name,
    this.summary,
    this.image,
    this.imageOriginal,
    this.rating,
    required this.genres,
    this.status,
    this.premiered,
    this.ended,
    this.network,
    this.type,
    this.language,
    this.runtime,
    this.averageRuntime,
    this.officialSite,
    this.schedule,
    this.weight,
    this.url,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown',
      summary: json['summary'],
      image: json['image']?['medium'],
      imageOriginal: json['image']?['original'],
      rating: json['rating'] != null ? Rating.fromJson(json['rating']) : null,
      genres: List<String>.from(json['genres'] ?? []),
      status: json['status'],
      premiered: json['premiered'],
      ended: json['ended'],
      network: json['network']?['name'],
      type: json['type'],
      language: json['language'],
      runtime: json['runtime'],
      averageRuntime: json['averageRuntime'],
      officialSite: json['officialSite'],
      schedule: json['schedule'] != null
          ? Schedule.fromJson(json['schedule'])
          : null,
      weight: json['weight'],
      url: json['url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'summary': summary,
      'image': image,
      'imageOriginal': imageOriginal,
      'rating': rating?.toJson(),
      'genres': genres,
      'status': status,
      'premiered': premiered,
      'ended': ended,
      'network': network,
      'type': type,
      'language': language,
      'runtime': runtime,
      'averageRuntime': averageRuntime,
      'officialSite': officialSite,
      'schedule': schedule?.toJson(),
      'weight': weight,
      'url': url,
    };
  }
}

class Rating {
  final double? average;

  Rating({this.average});

  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(average: (json['average'] as num?)?.toDouble());
  }

  Map<String, dynamic> toJson() {
    return {'average': average};
  }
}

class Schedule {
  final String? time;
  final List<String> days;

  Schedule({this.time, required this.days});

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      time: json['time'],
      days: List<String>.from(json['days'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {'time': time, 'days': days};
  }
}
