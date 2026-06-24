import Flutter
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  private let restDayChannelName = "alcohol_record/rest_day_notification"
  private let restDayEnabledKey = "rest_day_notification_enabled"
  private let restDaysKey = "rest_day_notification_days"
  private let lastImmediateKey = "rest_day_notification_last_immediate"

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    configureRestDayNotificationChannel()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func configureRestDayNotificationChannel() {
    guard let controller = window?.rootViewController as? FlutterViewController else {
      return
    }

    let channel = FlutterMethodChannel(
      name: restDayChannelName,
      binaryMessenger: controller.binaryMessenger
    )
    channel.setMethodCallHandler { [weak self] call, result in
      guard let self else {
        result(nil)
        return
      }

      switch call.method {
      case "configure":
        let args = call.arguments as? [String: Any]
        let enabled = args?["enabled"] as? Bool ?? false
        let restDays = args?["restDays"] as? [Bool] ?? []
        self.configureRestDayNotifications(enabled: enabled, restDays: restDays)
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  private func configureRestDayNotifications(enabled: Bool, restDays: [Bool]) {
    let normalizedRestDays = (0..<7).map { index in
      index < restDays.count ? restDays[index] : false
    }

    let defaults = UserDefaults.standard
    defaults.set(enabled, forKey: restDayEnabledKey)
    defaults.set(normalizedRestDays, forKey: restDaysKey)

    let center = UNUserNotificationCenter.current()
    let identifiers = (0..<7).map { "rest-day-\($0)" } + ["rest-day-today"]
    center.removePendingNotificationRequests(withIdentifiers: identifiers)

    guard enabled else {
      center.removeDeliveredNotifications(withIdentifiers: identifiers)
      return
    }

    center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
      guard granted else {
        return
      }

      self.scheduleWeeklyRestDayNotifications(restDays: normalizedRestDays)
      self.scheduleTodayNotificationIfNeeded(restDays: normalizedRestDays)
    }
  }

  private func scheduleWeeklyRestDayNotifications(restDays: [Bool]) {
    let center = UNUserNotificationCenter.current()

    for (index, enabled) in restDays.enumerated() where enabled {
      let content = UNMutableNotificationContent()
      content.title = "今日は休肝日です"
      content.body = "一日中、飲酒を控える日として過ごしましょう。"
      content.sound = .default

      var date = DateComponents()
      date.weekday = index + 1
      date.hour = 0
      date.minute = 0

      let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)
      let request = UNNotificationRequest(
        identifier: "rest-day-\(index)",
        content: content,
        trigger: trigger
      )
      center.add(request)
    }
  }

  private func scheduleTodayNotificationIfNeeded(restDays: [Bool]) {
    let todayIndex = Calendar.current.component(.weekday, from: Date()) - 1
    guard todayIndex >= 0, todayIndex < restDays.count, restDays[todayIndex] else {
      return
    }

    let todayKey = Self.dateKey(Date())
    let defaults = UserDefaults.standard
    guard defaults.string(forKey: lastImmediateKey) != todayKey else {
      return
    }
    defaults.set(todayKey, forKey: lastImmediateKey)

    let content = UNMutableNotificationContent()
    content.title = "今日は休肝日です"
    content.body = "設定した休肝日です。飲酒予定がないか確認しましょう。"
    content.sound = .default

    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
    let request = UNNotificationRequest(
      identifier: "rest-day-today",
      content: content,
      trigger: trigger
    )
    UNUserNotificationCenter.current().add(request)
  }

  private static func dateKey(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.calendar = Calendar(identifier: .gregorian)
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter.string(from: date)
  }
}
