import Foundation
import YandexMobileMetrica

protocol AnalyticsServiceProtocol {
    func logEvent(_ event: String, parameters: [String: Any]?)
}

final class AnalyticsService: AnalyticsServiceProtocol {
    static let shared = AnalyticsService()

    private init() {
        // Инициализация Yandex Mobile Metrica
        if let configuration = YMMYandexMetricaConfiguration(apiKey: "f1b4973d-43ff-40be-94b0-0ec95c61c693") {
            YMMYandexMetrica.activate(with: configuration)
        }
    }

    // Логируем событие с параметрами
    func logEvent(_ event: String, parameters: [String: Any]? = nil) {
        YMMYandexMetrica.reportEvent(event, parameters: parameters) { error in
            print("Error reporting event: \(String(describing: error))")
        }
    }
}
