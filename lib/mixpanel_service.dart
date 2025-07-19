import 'package:mixpanel_flutter/mixpanel_flutter.dart';

class MixpanelService {
  static Mixpanel? _mixpanel;

  static Future<void> init() async {
    _mixpanel = await Mixpanel.init(
      "55e2e0b4403ef25fbf29fad03109fbd8",
      trackAutomaticEvents: true,
    );
  }

  static Mixpanel get instance {
    if (_mixpanel == null) {
      throw Exception(
        "Mixpanel not initialized. Call MixpanelService.init() first.",
      );
    }
    return _mixpanel!;
  }
}
