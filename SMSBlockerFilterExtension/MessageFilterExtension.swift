//
//  MessageFilterExtension.swift
//  SMSBlockerFilterExtension
//
//  Created by Cristopher Martinez Reyes on 6/05/25.
//

import IdentityLookup
import Foundation // Necesario para JSONDecoder y UUID

// Asegúrate de que esta estructura sea accesible para este target (Ver Paso 1 de la solución)
// Si no creaste un archivo separado, puedes definirla aquí también.
struct FilterItem: Codable, Identifiable { // Identifiable no es estrictamente necesario aquí, pero Codable sí.
    var id: UUID
    var text: String
}

final class MessageFilterExtension: ILMessageFilterExtension {}

extension MessageFilterExtension: ILMessageFilterQueryHandling {

    func handle(
        _ queryRequest: ILMessageFilterQueryRequest,
        context: ILMessageFilterExtensionContext,
        completion: @escaping (ILMessageFilterQueryResponse) -> Void
    ) {
        let response = ILMessageFilterQueryResponse()

        guard let messageBody = queryRequest.messageBody else {
            response.action = .allow
            completion(response)
            return
        }

        let lowercasedMessage = messageBody.lowercased()

        // Leer filtros guardados desde App Group
        let userDefaults = UserDefaults(suiteName: "group.jcm.SMS-Blocker")
        let filtersKey = "savedFilters" // La misma clave que usas en la app
        var filterKeywords: [String] = []

        if let savedData = userDefaults?.data(forKey: filtersKey) {
            let decoder = JSONDecoder()
            if let decodedFilterItems = try? decoder.decode([FilterItem].self, from: savedData) {
                filterKeywords = decodedFilterItems.map { $0.text.lowercased() } // Extraer el texto y convertir a minúsculas
            } else {
                print("MessageFilterExtension: Error al decodificar los filtros.")
                // Considera qué acción tomar si la decodificación falla, por ahora resultará en no filtros.
            }
        } else {
            print("MessageFilterExtension: No se encontraron datos para la clave de filtros '\(filtersKey)'.")
        }

        // Usar los filterKeywords extraídos
        var matched = false
        for keyword in filterKeywords {
            if lowercasedMessage.contains(keyword) {
                matched = true
                break
            }
        }

        if matched {
            response.action = .junk // También puedes usar .promotion si prefieres categorizar diferente
        } else {
            response.action = .allow
        }

        completion(response)
    }
}
