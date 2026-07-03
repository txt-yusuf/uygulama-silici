import SwiftUI

struct ContentView: View {
    @State private var viewModel = AppCleanerViewModel()
    @State private var showingDeleteConfirmation = false
    @AppStorage("appLanguage") private var languageCode = AppLanguage.turkish.rawValue

    private var selectedLanguage: AppLanguage {
        AppLanguage(rawValue: languageCode) ?? .turkish
    }

    private var localizer: Localizer {
        Localizer(language: selectedLanguage)
    }

    var body: some View {
        NavigationSplitView {
            sidebar
        } detail: {
            detail
        }
        .searchable(text: $viewModel.searchText, prompt: Text(localizer.text("search.placeholder")))
        .toolbar {
            ToolbarItemGroup {
                Button {
                    viewModel.refreshApplications()
                } label: {
                    Label(localizer.text("toolbar.refresh"), systemImage: "arrow.clockwise")
                }
                .disabled(viewModel.isScanningApplications)

                Button {
                    viewModel.scanSelectedApplication()
                } label: {
                    Label(localizer.text("toolbar.scan"), systemImage: "magnifyingglass")
                }
                .disabled(viewModel.selectedApplication == nil || viewModel.isScanningItems)

                Menu {
                    Picker(localizer.text("toolbar.language"), selection: $languageCode) {
                        ForEach(AppLanguage.allCases) { language in
                            Text(language.displayName).tag(language.rawValue)
                        }
                    }
                } label: {
                    Label(selectedLanguage.displayName, systemImage: "globe")
                }
                .help(localizer.text("toolbar.language"))
            }
        }
        .onAppear {
            viewModel.language = selectedLanguage
            if viewModel.applications.isEmpty {
                viewModel.refreshApplications()
            }
        }
        .onChange(of: languageCode) { _, _ in
            viewModel.language = selectedLanguage
        }
    }

    private var sidebar: some View {
        VStack(spacing: 0) {
            if viewModel.isScanningApplications {
                ProgressView()
                    .controlSize(.small)
                    .padding(.top, 12)
            }

            List(viewModel.filteredApplications, selection: Binding(
                get: { viewModel.selectedApplication?.id },
                set: { selectedID in
                    guard let selectedID,
                          let app = viewModel.applications.first(where: { $0.id == selectedID }) else { return }
                    viewModel.select(app)
                }
            )) { app in
                AppRow(app: app, localizer: localizer)
                    .tag(app.id)
            }
        }
        .navigationTitle(localizer.text("sidebar.title"))
    }

    private var detail: some View {
        VStack(spacing: 0) {
            if let app = viewModel.selectedApplication {
                languageBar
                    .padding(.horizontal, 20)
                    .padding(.top, 14)

                AppDetailHeader(app: app)
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 20)

                Divider()

                itemToolbar
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)

                if viewModel.isScanningItems {
                    Spacer()
                    ProgressView(localizer.text("detail.scanning"))
                    Spacer()
                } else {
                    RemovableItemsTable(
                        items: viewModel.removableItems,
                        selectedIDs: viewModel.selectedItemIDs,
                        localizer: localizer,
                        onToggle: viewModel.toggleSelection
                    )
                }

                Divider()

                bottomBar
                    .padding(20)
            } else {
                ContentUnavailableView(
                    localizer.text("empty.title"),
                    systemImage: "app.dashed",
                    description: Text(localizer.text("empty.description"))
                )
            }
        }
    }

    private var languageBar: some View {
        HStack {
            Spacer()

            Picker(selection: $languageCode) {
                ForEach(AppLanguage.allCases) { language in
                    Text(language.displayName).tag(language.rawValue)
                }
            } label: {
                Label(localizer.text("toolbar.language"), systemImage: "globe")
            }
            .pickerStyle(.segmented)
            .frame(width: 260)
        }
    }

    private var itemToolbar: some View {
        HStack {
            Label(localizer.format("items.count", viewModel.removableItems.count), systemImage: "doc.on.doc")
                .font(.headline)

            Spacer()

            Button {
                viewModel.selectAllOptionalItems()
            } label: {
                Label(localizer.text("button.selectAll"), systemImage: "checklist.checked")
            }

            Button {
                viewModel.clearOptionalSelection()
            } label: {
                Label(localizer.text("button.onlyApp"), systemImage: "app")
            }
        }
    }

    private var bottomBar: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.statusMessage)
                    .font(.callout)

                if let result = viewModel.lastResult, !result.failedItems.isEmpty {
                    Text(localizer.text("error.someFailed"))
                        .font(.caption)
                        .foregroundStyle(.red)
                } else if viewModel.selectedApplication?.isSystemApp == true {
                    Text(localizer.text("warning.systemApp"))
                        .font(.caption)
                        .foregroundStyle(.orange)
                } else {
                    Text(localizer.format("status.selectedSize", viewModel.selectedSize.formattedFileSize))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Button(role: .destructive) {
                showingDeleteConfirmation = true
            } label: {
                Label(localizer.text("button.trash"), systemImage: "trash")
            }
            .buttonStyle(.borderedProminent)
            .disabled(!viewModel.canMoveSelectedItemsToTrash || viewModel.isScanningItems)
            .alert(localizer.text("alert.title"), isPresented: $showingDeleteConfirmation) {
                Button(localizer.text("alert.cancel"), role: .cancel) {}
                Button(localizer.text("alert.move"), role: .destructive) {
                    viewModel.moveSelectedItemsToTrash()
                }
            } message: {
                Text(localizer.format("alert.message", viewModel.selectedItems.count))
            }
        }
    }
}

private struct AppRow: View {
    let app: InstalledApp
    let localizer: Localizer

    var body: some View {
        HStack(spacing: 10) {
            Image(nsImage: app.icon)
                .resizable()
                .frame(width: 28, height: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(app.name)
                    .lineLimit(1)

                Text(app.bundleIdentifier ?? app.url.path)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            if app.isSystemApp {
                Image(systemName: "lock.fill")
                    .foregroundStyle(.secondary)
                    .help(localizer.text("help.systemApp"))
            }
        }
        .padding(.vertical, 4)
    }
}

private struct AppDetailHeader: View {
    let app: InstalledApp

    var body: some View {
        HStack(spacing: 16) {
            Image(nsImage: app.icon)
                .resizable()
                .frame(width: 64, height: 64)

            VStack(alignment: .leading, spacing: 6) {
                Text(app.name)
                    .font(.largeTitle.weight(.semibold))
                    .lineLimit(1)

                HStack {
                    if let version = app.version {
                        Label(version, systemImage: "number")
                    }

                    if let bundleIdentifier = app.bundleIdentifier {
                        Label(bundleIdentifier, systemImage: "shippingbox")
                    }
                }
                .font(.callout)
                .foregroundStyle(.secondary)

                Text(app.url.path)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()
        }
    }
}

private struct RemovableItemsTable: View {
    let items: [RemovableItem]
    let selectedIDs: Set<RemovableItem.ID>
    let localizer: Localizer
    let onToggle: (RemovableItem) -> Void

    var body: some View {
        Table(items) {
            TableColumn("") { item in
                Toggle("", isOn: Binding(
                    get: { selectedIDs.contains(item.id) },
                    set: { _ in onToggle(item) }
                ))
                .labelsHidden()
                .disabled(item.isRequired)
                .help(item.isRequired ? localizer.text("help.required") : localizer.text("help.toggle"))
            }
            .width(36)

            TableColumn(localizer.text("column.name")) { item in
                HStack {
                    Image(systemName: iconName(for: item.kind))
                        .foregroundStyle(.secondary)
                        .frame(width: 18)
                    Text(item.displayName)
                        .lineLimit(1)
                }
            }

            TableColumn(localizer.text("column.type")) { item in
                Text(localizer.itemKind(item.kind))
                    .foregroundStyle(.secondary)
            }
            .width(120)

            TableColumn(localizer.text("column.size")) { item in
                Text(item.size.formattedFileSize)
                    .foregroundStyle(.secondary)
            }
            .width(90)

            TableColumn(localizer.text("column.location")) { item in
                Text(item.path)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
    }

    private func iconName(for kind: RemovableItem.Kind) -> String {
        switch kind {
        case .application:
            "app"
        case .support:
            "folder"
        case .cache:
            "externaldrive"
        case .preferences:
            "slider.horizontal.3"
        case .logs:
            "doc.text"
        case .container:
            "shippingbox"
        case .launchAgent:
            "bolt"
        case .other:
            "doc"
        }
    }
}
