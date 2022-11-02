import './shot_model.dart';

class Project {
  List<Shot>? shots;
  String? name;
  String? user;
  String? sensor;
  Project({this.name, this.shots, this.user, this.sensor});

  Project.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    user = json['user'];
    shots = json['shots'];
    sensor = json['sensor'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['name'] = name;
    data['shots'] = shots;
    data['user'] = user;
    data['sensor'] = sensor;
    return data;
  }
}
