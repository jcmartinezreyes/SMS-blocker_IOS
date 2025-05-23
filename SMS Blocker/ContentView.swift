import SwiftUI
import Foundation

struct FilterItem: Identifiable, Codable, Equatable { // Added Equatable for easier comparison if needed
    var id = UUID()
    var text: String
}

struct HomeView: View {
    @State private var filters: [FilterItem] = []
    @State private var showingAddFilter = false
    @State private var newFilterText = ""
    @State private var showingDuplicateAlert = false

    @State private var showingEditAlert = false
    @State private var editedFilterText = ""
    @State private var selectedFilterId: UUID?

    let filtersKey = "savedFilters"
    let userDefaults = UserDefaults(suiteName: "group.jcm.SMS-Blocker")

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 0) { // >>> CAMBIO: spacing 0 para controlar manualmente
                VStack(alignment: .leading, spacing: 5) { // >>> CAMBIO: spacing ajustado
                    Text("SMS Blocker")
                        .font(.largeTitle.weight(.bold)) // >>> CAMBIO: .weight(.bold)
                        .padding(.top)
                    Text("Create and personalize your filters")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.horizontal)
                .padding(.bottom, 10) // >>> CAMBIO: Añadido padding inferior

                // >>> CAMBIO: Divider para separación visual
                Divider()
                    .padding(.bottom, 5)


                if filters.isEmpty {
                    Spacer()
                    VStack(spacing: 15) {
                        Image(systemName: "tray.fill") // Un icono más representativo
                            .font(.system(size: 50))
                            .foregroundColor(.gray.opacity(0.7))
                        Text("No filters yet!")
                            .font(.title2)
                            .foregroundColor(.gray)
                        Text("Tap the '+' button to add your first filter.")
                            .font(.callout)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal)
                    Spacer()
                } else {
                    List {
                        ForEach(filters) { filterItem in
                            HStack {
                                Text(filterItem.text)
                                    .padding(.vertical, 6) // >>> CAMBIO: Padding vertical en el texto para más aire
                                Spacer()
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button("Edit") {
                                    selectedFilterId = filterItem.id
                                    editedFilterText = filterItem.text
                                    showingEditAlert = true
                                }
                                .tint(.blue)

                                Button("Delete", role: .destructive) {
                                    if let index = filters.firstIndex(where: { $0.id == filterItem.id }) {
                                        deleteFilter(at: IndexSet(integer: index))
                                    }
                                }
                                .tint(.red)
                            }
                        }
                    }
                    // >>> CAMBIO: Estilo de lista para un look más moderno
                    .listStyle(.plain) // o .insetGrouped() si prefieres ese estilo
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        newFilterText = ""
                        showingAddFilter = true
                    }) {
                        Image(systemName: "plus.circle.fill") // >>> CAMBIO: .fill para un icono más prominente
                            .font(.title2) // >>> CAMBIO: Un poco más grande
                    }
                }
            }
            .alert("New Filter", isPresented: $showingAddFilter) {
                TextField("Enter filter keyword", text: $newFilterText)
                Button("Add", action: addNewFilter)
                Button("Cancel", role: .cancel) {
                    newFilterText = ""
                }
            } message: {
                Text("Enter the word or phrase to block SMS messages containing it.")
            }
            .alert("Duplicate Filter", isPresented: $showingDuplicateAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("That filter already exists.")
            }
            .alert("Edit Filter", isPresented: $showingEditAlert) {
                TextField("Edit filter", text: $editedFilterText)
                Button("Save") {
                    saveEditedFilter() // >>> CAMBIO: Lógica de guardado movida a función
                }
                Button("Cancel", role: .cancel) {
                    selectedFilterId = nil
                    showingEditAlert = false
                }
            } message: {
                 Text("Modify the keyword for this filter.")
            }
            .onAppear(perform: loadFilters)
        }
        // >>> CAMBIO: Para que la barra de navegación no se superponga en iOS 16+ con algunos estilos
        .navigationViewStyle(.stack)
    }

    func addNewFilter() {
        let trimmed = newFilterText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty {
            // >>> CAMBIO: Comprobar duplicados ignorando mayúsculas/minúsculas
            if filters.contains(where: { $0.text.localizedCaseInsensitiveCompare(trimmed) == .orderedSame }) {
                showingDuplicateAlert = true
            } else {
                filters.append(FilterItem(text: trimmed))
                sortAndSaveFilters() // >>> CAMBIO: Usar nueva función
            }
        }
        newFilterText = ""
    }

    func saveEditedFilter() {
        guard let id = selectedFilterId,
              let index = filters.firstIndex(where: { $0.id == id }) else {
            selectedFilterId = nil
            showingEditAlert = false
            return
        }

        let trimmed = editedFilterText.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmed.isEmpty {
            // Opcional: podrías eliminar el filtro si el texto se deja vacío
            // deleteFilter(at: IndexSet(integer: index))
            selectedFilterId = nil
            showingEditAlert = false
            return
        }

        // Si el texto no cambió (ignorando mayúsculas/minúsculas)
        if trimmed.localizedCaseInsensitiveCompare(filters[index].text) == .orderedSame {
            selectedFilterId = nil
            showingEditAlert = false
            return
        }

        // Comprobar si el nuevo texto (ignorar mayúsculas/minúsculas) ya existe en otro filtro
        if filters.contains(where: { $0.text.localizedCaseInsensitiveCompare(trimmed) == .orderedSame && $0.id != id }) {
            selectedFilterId = nil // Resetear para no reabrir con el mismo filtro
            showingEditAlert = false // Cerrar la alerta actual
            // Esperar un poco para que la alerta de edición se cierre antes de mostrar la de duplicado
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                showingDuplicateAlert = true
            }
            return
        }

        filters[index].text = trimmed
        sortAndSaveFilters() // >>> CAMBIO: Usar nueva función
        selectedFilterId = nil
        showingEditAlert = false
    }

    func deleteFilter(at offsets: IndexSet) {
        filters.remove(atOffsets: offsets)
        // No es necesario ordenar aquí, ya que la eliminación no cambia el orden relativo de los demás
        saveFilters()
    }

    // >>> CAMBIO: Nueva función para centralizar el ordenamiento y guardado
    func sortAndSaveFilters() {
        filters.sort { $0.text.localizedCaseInsensitiveCompare($1.text) == .orderedAscending }
        saveFilters()
    }

    func saveFilters() {
        if let encoded = try? JSONEncoder().encode(filters) {
            userDefaults?.set(encoded, forKey: filtersKey)
        } else {
            print("Failed to encode filters")
        }
    }

    func loadFilters() {
        if let savedData = userDefaults?.data(forKey: filtersKey) {
            if let decodedFilters = try? JSONDecoder().decode([FilterItem].self, from: savedData) {
                filters = decodedFilters
                // >>> CAMBIO: Ordenar al cargar
                filters.sort { $0.text.localizedCaseInsensitiveCompare($1.text) == .orderedAscending }
            } else {
                print("Failed to decode filters")
            }
        }
    }
}

#Preview {
    HomeView()
}
