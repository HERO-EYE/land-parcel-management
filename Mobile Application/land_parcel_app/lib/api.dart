import 'dart:convert';

import 'package:http/http.dart' as http;
import 'parcel.dart';
import 'env.dart';

class API {

  String GET_PARCELS = "/api/app/parcels/";
  String POST_LOGIN = "/api/app/login/";

  Future<List<Parcel>?> getLandParcels(int ownerId) async {

    if (ownerId==null) return null;

    List<Parcel>? parcels = [];
    try {
      var url = Uri.parse("${ENV.HOST}$GET_PARCELS?owner=$ownerId");
      var header = {
        'Authorization': ENV.APIKEY
      };
      var response = await http.get(url, headers: header);

      List<dynamic> json = jsonDecode(response.body);
      json.forEach((element) {
        parcels!.add(Parcel.fromJson(element));
      });
    } catch(e) {}

   return parcels;

  }

  Future<Map<String, dynamic>?> login(String username, String password) async {

    try {
      var url = Uri.parse('${ENV.HOST}$POST_LOGIN');

      var body = {'username': username, 'password': password};
      var header = {
        'Authorization': ENV.APIKEY
      };
      var response = await http.post(url, body: body, headers: header);

      if (response.body.toString().isNotEmpty) {
        if (response.body.startsWith("{")) {
          Map<String, dynamic> json = jsonDecode(response.body);
          if (json.containsKey("success")) {
            return json["success"];
          }
        } else if (response.body.startsWith("[")) {
          List<dynamic> json = jsonDecode(response.body);
          if (json[0] == "error") {
            return null;
          }
        }
      }
    } catch(e) {}

    return null;
  }

  // Map<String, dynamic> listToMap(List<dynamic> list) {
  //   Map<String, dynamic> resultMap = {};
  //
  //   for (int i = 0; i < list.length; i++) {
  //     resultMap['item$i'] = list[i];
  //   }
  //
  //   return resultMap;
  // }
}