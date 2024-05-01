import 'dart:convert';

class Parcel {
  int? id;
  String? parcel_number;
  double? area;
  String? city;
  String? address;
  double? geometry_latitude;
  double? geometry_longitude;
  Map<String, dynamic>? owner;
  Map<String, dynamic>? zoning;
  Map<String, dynamic>? delivery;

  Parcel({
    required this.id,
    required this.parcel_number,
    required this.area,
    this.city,
    this.address,
    required this.geometry_latitude,
    required this.geometry_longitude,
    required this.owner,
    required this.zoning,
    this.delivery,
  });

  factory Parcel.fromJson(Map<String, dynamic> json) {

    Map<String, dynamic>? owner;
    Map<String, dynamic>? zoning;
    Map<String, dynamic>? delivery;

    
    if(json.containsKey("owner")) owner = json["owner"] as Map<String, dynamic>;
    if(json.containsKey("zoning")) zoning = json["zoning"] as Map<String, dynamic>;
    if(json.containsKey("delivery")) delivery = json["delivery"] as Map<String, dynamic>;


    return Parcel(
      id: int.parse(json["id"].toString()),
      parcel_number: json["parcel_number"].toString(),
      area: double.parse(json["area"].toString()),
      city: json["city"],
      address: json["address"],
      geometry_latitude: json["geometry_latitude"] as double,
      geometry_longitude: json["geometry_longitude"] as double,
      owner: owner,
      zoning: zoning,
      delivery: delivery,
    );
  }

  // Map<String, dynamic> toJson() => {
  //   "id": id,
  //   "name": name,
  //   "position": position,
  // };

}