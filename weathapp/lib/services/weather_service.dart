import 'dart:convert';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:weathapp/models/weater_model.dart';

class WeatherService {
  static const BASE_URL = 'http://api.openweathermap.org/data/2.5/weather';
  final String apiKey;
  //=

  WeatherService(this.apiKey);

  Future<Weather> getWeather(String cityName) async {
    final response = await http
        .get(Uri.parse('$BASE_URL?q=$cityName&appid=$apiKey&units=metric'));

    if (response.statusCode == 200) {
      return Weather.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load weather data');
    }
  }
  Future<String> getCurrentCity() async {
    try {
      // Verifica a permissão de localização
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return "Permissão negada";
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // Permissão permanentemente negada
        return "Permissão negada permanentemente";
      }

      // Obtenha a localização atual
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      // Converte as coordenadas em uma lista de objetos Placemark
      List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude, position.longitude);

      // Extrai o nome da cidade do primeiro Placemark
      String? city = placemarks[0].locality;

      return city ?? "Cidade não encontrada";
    } catch (e) {
      // Captura qualquer erro e retorna uma mensagem de erro
      return "Erro ao obter a localização: $e";
    }
  }
}
