import 'package:flutter_riverpod/flutter_riverpod.dart';

class SelectedCountryNotifier extends Notifier<String?> {
  @override
  String? build() {
    return null;
  }

  void selectCountry(String? countryCode) {
    state = countryCode;
  }

  void clearSelection() {
    state = null;
  }
}

final selectedCountryProvider =
    NotifierProvider<SelectedCountryNotifier, String?>(
      SelectedCountryNotifier.new,
    );
