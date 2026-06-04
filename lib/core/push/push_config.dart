/// Feature flag: set to true once Firebase project is provisioned by the
/// backend team and native config files are placed in the project.
///
/// When false the entire push-notification code path is a no-op.
/// The app compiles and runs without any Firebase dependency.
const bool kEnablePush = false;

/// FCM sender ID / App ID placeholder (fill once Firebase project exists).
const String kFcmAppId = '';
