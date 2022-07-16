
// import 'dart:convert';

const googleApi = 'AIzaSyAY0GXba4H4aNgfoDy9xU-Z58nbsY6cLTw';


class LocationHelper {
  static String genLocation({double? latitude, double? longitude}) {
    return 'https://maps.googleapis.com/maps/api/staticmap?center=$latitude,$longitude&zoom=18&size=600x300&maptype=roadmap&markers=color:red%7Clabel:A%7C$latitude,$longitude&key=$googleApi';
  }


  // this is for getting the detailed address for marked location

  // static Future<String?> getPlaceAddress(double lat, double lng) async{
  //   final url = Uri.parse('https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$googleApi');
  //   final res = await http.get(url);
  //   return json.decode(res.body)['results'][0]['formatted_address'];
  // }
}
 