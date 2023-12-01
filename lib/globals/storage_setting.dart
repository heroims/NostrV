
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

enum StorageKeys {

  relayUrls(1, 'relay_urls');

  const StorageKeys(this.number, this.value);

  final int number;
  final String value;
}

const iosSecureStorageOptions = IOSOptions(accessibility: KeychainAccessibility.unlocked);
const androidSecureStorageOptions = AndroidOptions(encryptedSharedPreferences: true);

const defaultRelayUrls = ['wss://relay.plebstr.com'];
