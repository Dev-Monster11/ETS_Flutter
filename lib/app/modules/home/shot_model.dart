import 'dart:ffi';

class Shot {
  DateTime? timestamp;
  String? user;
  String? sensorID;
  int? gain;
  int? sr;
  int? line;
  int? shot;
  double? lat;
  double? lon;
  int? gpsAcc;
  String? notes;
  List<int>? shotData;

  Shot(
      {this.timestamp,
      this.user,
      this.sensorID,
      this.gain,
      this.sr,
      this.line,
      this.shot,
      this.lat,
      this.lon,
      this.gpsAcc,
      this.notes,
      this.shotData});
  void initialize() {
    timestamp = DateTime.now();
    user = "";
    sensorID = "";
    gain = 1;
    sr = 900;
    line = 1;
    shot = 0;
    lat = 0;
    lon = 0;
    gpsAcc = 0;
    notes = "";
    shotData = [];
  }

  Shot.fromJson(Map<String, dynamic> json) {
    timestamp = json['timestamp'];
    user = json['user'];
    sensorID = json['sensorID'];
    gain = json['gain'];
    sr = json['sr'];
    line = json['line'];
    shot = json['shot'];
    lat = json['lat'];
    lon = json['lon'];
    gpsAcc = json['gpsAcc'];
    notes = json['notes'];
    line = json['line'];
    shotData = json['shotData'].cast<int>();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['timestamp'] = timestamp;
    data['user'] = user;
    data['sensorID'] = sensorID;
    data['gain'] = gain;
    data['sr'] = sr;
    data['line'] = line;
    data['shot'] = shot;
    data['lat'] = lat;
    data['lon'] = lon;
    data['gpsAcc'] = gpsAcc;
    data['notes'] = notes;
    data['line'] = line;
    data['shotData'] = shotData;
    return data;
  }
}
