/// Platform enum for FCM device registration.
enum DevicePlatform { ios, android }

String devicePlatformToWire(DevicePlatform p) => switch (p) {
      DevicePlatform.ios => 'ios',
      DevicePlatform.android => 'android',
    };
