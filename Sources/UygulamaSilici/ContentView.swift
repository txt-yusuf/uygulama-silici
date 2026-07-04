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
            viewModel.loadHistory()
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

                AppDetailHeader(app: app, localizer: localizer)
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 12)

                AppInfoPanel(app: app, localizer: localizer)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 18)

                Divider()

                itemToolbar
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)

                summaryBar
                    .padding(.horizontal, 20)
                    .padding(.bottom, 12)

                if viewModel.isScanningItems {
                    Spacer()
                    VStack(spacing: 12) {
                        ProgressView()
                            .controlSize(.large)
                        Text(localizer.text("detail.scanning"))
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                } else if viewModel.removableItems.count <= 1 {
                    Spacer()
                    ContentUnavailableView(
                        localizer.text("emptyResults.title"),
                        systemImage: "checkmark.shield",
                        description: Text(localizer.text("emptyResults.description"))
                    )
                    Spacer()
                } else {
                    RemovableItemsTable(
                        items: viewModel.removableItems,
                        selectedIDs: viewModel.selectedItemIDs,
                        localizer: localizer,
                        onToggle: viewModel.toggleSelection,
                        onReveal: viewModel.revealInFinder
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

    private var summaryBar: some View {
        HStack(spacing: 10) {
            SummaryTile(
                title: localizer.text("summary.foundItems"),
                value: "\(viewModel.removableItems.count)",
                systemImage: "doc.on.doc"
            )

            SummaryTile(
                title: localizer.text("summary.optionalItems"),
                value: "\(viewModel.optionalItemCount)",
                systemImage: "sparkle.magnifyingglass"
            )

            SummaryTile(
                title: localizer.text("summary.totalSize"),
                value: viewModel.totalRemovableSize.formattedFileSize,
                systemImage: "externaldrive"
            )

            SummaryTile(
                title: localizer.text("summary.selectedSize"),
                value: viewModel.selectedSize.formattedFileSize,
                systemImage: "checkmark.circle"
            )
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
                Text(
                    localizer.format(
                        "alert.messageDetailed",
                        viewModel.selectedItems.count,
                        viewModel.selectedSize.formattedFileSize,
                        viewModel.selectedHighRiskCount,
                        viewModel.selectedMediumRiskCount
                    )
                )
            }

            if let entry = viewModel.latestHistoryEntry {
                Button {
                    viewModel.restoreLatestRemoval()
                } label: {
                    Label(localizer.format("button.restore", entry.movedItems.count), systemImage: "arrow.uturn.backward")
                }
                .help(localizer.text("help.restore"))
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
    let localizer: Localizer

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

private struct AppInfoPanel: View {
    let app: InstalledApp
    let localizer: Localizer

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: localizer.language.rawValue)
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(localizer.text("info.title"), systemImage: "info.circle")
                .font(.headline)

            LazyVGrid(columns: [
                GridItem(.adaptive(minimum: 160), spacing: 10)
            ], alignment: .leading, spacing: 10) {
                InfoField(title: localizer.text("info.size"), value: app.size.formattedFileSize, systemImage: "externaldrive")
                InfoField(title: localizer.text("info.version"), value: app.version ?? localizer.text("info.unknown"), systemImage: "number")
                InfoField(title: localizer.text("info.bundle"), value: app.bundleIdentifier ?? localizer.text("info.unknown"), systemImage: "shippingbox")
                InfoField(title: localizer.text("info.executable"), value: app.executableName ?? localizer.text("info.unknown"), systemImage: "terminal")
                InfoField(title: localizer.text("info.category"), value: formattedCategory(app.category), systemImage: "tag")
                InfoField(title: localizer.text("info.created"), value: formattedDate(app.creationDate), systemImage: "calendar.badge.plus")
                InfoField(title: localizer.text("info.modified"), value: formattedDate(app.modificationDate), systemImage: "calendar.badge.clock")
            }
        }
        .padding(14)
        .background(.quaternary.opacity(0.45), in: RoundedRectangle(cornerRadius: 8))
    }

    private func formattedDate(_ date: Date?) -> String {
        guard let date else { return localizer.text("info.unknown") }
        return dateFormatter.string(from: date)
    }

    private func formattedCategory(_ category: String?) -> String {
        guard let category, !category.isEmpty else { return localizer.text("info.unknown") }
        return category
            .replacingOccurrences(of: "public.app-category.", with: "")
            .replacingOccurrences(of: "-", with: " ")
            .capitalized
    }
}

private struct InfoField: View {
    let title: String
    let value: String
    let systemImage: String

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: systemImage)
                .foregroundStyle(.secondary)
                .frame(width: 18)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                Text(value)
                    .font(.callout)
                    .lineLimit(1)
                    .truncationMode(.middle)
                    .textSelection(.enabled)
            }
        }
        .frame(minHeight: 42, alignment: .topLeading)
    }
}

private struct SummaryTile: View {
    let title: String
    let value: String
    let systemImage: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: systemImage)
                .font(.title3)
                .foregroundStyle(.tint)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                Text(value)
                    .font(.headline)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(minWidth: 120, maxWidth: .infinity, minHeight: 58)
        .background(.quaternary.opacity(0.6), in: RoundedRectangle(cornerRadius: 8))
    }
}

private struct RemovableItemsTable: View {
    let items: [RemovableItem]
    let selectedIDs: Set<RemovableItem.ID>
    let localizer: Localizer
    let onToggle: (RemovableItem) -> Void
    let onReveal: (RemovableItem) -> Void

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

            TableColumn(localizer.text("column.risk")) { item in
                RiskBadge(risk: item.risk, localizer: localizer)
            }
            .width(92)

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

            TableColumn("") { item in
                Button {
                    onReveal(item)
                } label: {
                    Image(systemName: "folder")
                }
                .buttonStyle(.borderless)
                .help(localizer.text("button.reveal"))
            }
            .width(44)
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
        case .privilegedHelper:
            "lock.shield"
        case .other:
            "doc"
        }
    }
}

private struct RiskBadge: View {
    let risk: RemovableItem.Risk
    let localizer: Localizer

    var body: some View {
        Label(title, systemImage: icon)
            .font(.caption)
            .foregroundStyle(color)
            .labelStyle(.titleAndIcon)
    }

    private var title: String {
        switch risk {
        case .low:
            localizer.text("risk.low")
        case .medium:
            localizer.text("risk.medium")
        case .high:
            localizer.text("risk.high")
        }
    }

    private var icon: String {
        switch risk {
        case .low:
            "checkmark.circle"
        case .medium:
            "exclamationmark.triangle"
        case .high:
            "shield.lefthalf.filled"
        }
    }

    private var color: Color {
        switch risk {
        case .low:
            .green
        case .medium:
            .orange
        case .high:
            .red
        }
    }
}
