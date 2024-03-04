import 'package:flutter_secure_storage/flutter_secure_storage.dart';


class FlutterSecureStorageClass{

  late FlutterSecureStorage storage = FlutterSecureStorage();
  
  FlutterSecureStorageClass(){
    AndroidOptions getAndroidOptions() => const AndroidOptions(
      encryptedSharedPreferences: true,
    );
    storage = FlutterSecureStorage(
        aOptions: getAndroidOptions(),
    );
  }

  Future<void> writeSecureData(String key, String value) async {
    await storage.write(key: key, value: value);
  }

  Future<String?> readSecureData(String key) async {
    return await storage.read(key: key);
  }

  Future<void> deleteSecureData(String key) async {
    await storage.delete(key: key);
  }

  Future<void> deleteAllSecureData() async {
    await storage.deleteAll();
  }

  Future<Map<String, String>> readAllSecureData() async {
    return await storage.readAll();
  }

}
