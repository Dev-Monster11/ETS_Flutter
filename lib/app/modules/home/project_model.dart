import './shot_model.dart';

class Project {
  int? freq;
  List<Shot>? shots;
  int? totalShots;

  Project({this.freq, this.shots, this.totalShots});

  Project.fromJson(Map<String, dynamic> json) {
    freq = json['freq'];
    shots = json['shots'];
    totalShots = json['totalShots'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['freq'] = freq;
    data['shots'] = shots;
    data['totalShots'] = totalShots;
    return data;
  }
}
