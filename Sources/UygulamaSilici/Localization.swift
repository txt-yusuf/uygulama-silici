import Foundation

enum AppLanguage: String, CaseIterable, Identifiable {
    case turkish = "tr"
    case english = "en"
    case german = "de"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .turkish:
            "Turkce"
        case .english:
            "English"
        case .german:
            "Deutsch"
        }
    }
}

struct Localizer {
    let language: AppLanguage

    func text(_ key: String) -> String {
        Self.values[key]?[language] ?? Self.values[key]?[.english] ?? key
    }

    func format(_ key: String, _ arguments: CVarArg...) -> String {
        String(format: text(key), locale: Locale(identifier: language.rawValue), arguments: arguments)
    }

    func itemKind(_ kind: RemovableItem.Kind) -> String {
        switch kind {
        case .application:
            text("kind.application")
        case .support:
            text("kind.support")
        case .cache:
            text("kind.cache")
        case .preferences:
            text("kind.preferences")
        case .logs:
            text("kind.logs")
        case .container:
            text("kind.container")
        case .launchAgent:
            text("kind.launchAgent")
        case .privilegedHelper:
            text("kind.privilegedHelper")
        case .other:
            text("kind.other")
        }
    }

    private static let values: [String: [AppLanguage: String]] = [
        "search.placeholder": [.turkish: "Uygulama ara", .english: "Search apps", .german: "Apps suchen"],
        "toolbar.refresh": [.turkish: "Yenile", .english: "Refresh", .german: "Aktualisieren"],
        "toolbar.scan": [.turkish: "Tara", .english: "Scan", .german: "Scannen"],
        "toolbar.language": [.turkish: "Dil", .english: "Language", .german: "Sprache"],
        "sidebar.title": [.turkish: "Uygulamalar", .english: "Applications", .german: "Programme"],
        "detail.scanning": [.turkish: "Iliskili dosyalar araniyor...", .english: "Searching related files...", .german: "Zugehorige Dateien werden gesucht..."],
        "summary.foundItems": [.turkish: "Bulunan", .english: "Found", .german: "Gefunden"],
        "summary.selectedItems": [.turkish: "Secili", .english: "Selected", .german: "Ausgewahlt"],
        "summary.totalSize": [.turkish: "Toplam boyut", .english: "Total size", .german: "Gesamtgrosse"],
        "summary.selectedSize": [.turkish: "Secili boyut", .english: "Selected size", .german: "Ausgewahlte Grosse"],
        "summary.optionalItems": [.turkish: "Kalinti dosyasi", .english: "Leftovers", .german: "Reste"],
        "info.title": [.turkish: "Uygulama bilgileri", .english: "App information", .german: "App-Informationen"],
        "info.size": [.turkish: "Uygulama boyutu", .english: "App size", .german: "App-Grosse"],
        "info.version": [.turkish: "Surum", .english: "Version", .german: "Version"],
        "info.bundle": [.turkish: "Bundle ID", .english: "Bundle ID", .german: "Bundle-ID"],
        "info.executable": [.turkish: "Calistirilabilir", .english: "Executable", .german: "Ausfuhrbare Datei"],
        "info.category": [.turkish: "Kategori", .english: "Category", .german: "Kategorie"],
        "info.created": [.turkish: "Olusturulma", .english: "Created", .german: "Erstellt"],
        "info.modified": [.turkish: "Guncellenme", .english: "Modified", .german: "Geandert"],
        "info.unknown": [.turkish: "Bilinmiyor", .english: "Unknown", .german: "Unbekannt"],
        "emptyResults.title": [.turkish: "Kalinti bulunmadi", .english: "No leftovers found", .german: "Keine Reste gefunden"],
        "emptyResults.description": [.turkish: "Bu uygulama icin sadece ana uygulama paketi kaldirilabilir gorunuyor.", .english: "Only the main app package appears removable for this app.", .german: "Fur diese App scheint nur das Hauptpaket entfernbar zu sein."],
        "empty.title": [.turkish: "Uygulama secin", .english: "Select an app", .german: "App auswahlen"],
        "empty.description": [.turkish: "Kaldirilacak uygulamayi soldaki listeden secin.", .english: "Choose the app to remove from the list on the left.", .german: "Wahlen Sie links die App aus, die entfernt werden soll."],
        "items.count": [.turkish: "%d oge", .english: "%d items", .german: "%d Objekte"],
        "button.selectAll": [.turkish: "Tumunu sec", .english: "Select all", .german: "Alle auswahlen"],
        "button.onlyApp": [.turkish: "Sadece uygulama", .english: "App only", .german: "Nur App"],
        "button.reveal": [.turkish: "Finder'da Goster", .english: "Show in Finder", .german: "Im Finder zeigen"],
        "button.restore": [.turkish: "%d ogeyi geri al", .english: "Restore %d items", .german: "%d Objekte wiederherstellen"],
        "help.restore": [.turkish: "Son Cop Sepeti'ne tasima islemini geri al", .english: "Restore the latest move-to-trash action", .german: "Letzte Papierkorb-Aktion wiederherstellen"],
        "error.someFailed": [.turkish: "Bazi ogeler tasinamadi. Izin gerekebilir veya dosya kullanimda olabilir.", .english: "Some items could not be moved. Permission may be required or a file may be in use.", .german: "Einige Objekte konnten nicht verschoben werden. Moglicherweise fehlt eine Berechtigung oder eine Datei ist in Verwendung."],
        "warning.systemApp": [.turkish: "Sistem ve yardimci uygulamalar guvenlik icin tasinmaz.", .english: "System and utility apps are blocked for safety.", .german: "System- und Dienstprogramme werden aus Sicherheitsgrunden blockiert."],
        "status.selectedSize": [.turkish: "Secili boyut: %@", .english: "Selected size: %@", .german: "Ausgewahlte Grosse: %@"],
        "button.trash": [.turkish: "Cop Sepeti'ne Tasi", .english: "Move to Trash", .german: "In den Papierkorb"],
        "alert.title": [.turkish: "Secili ogeler Cop Sepeti'ne tasinsin mi?", .english: "Move selected items to Trash?", .german: "Ausgewahlte Objekte in den Papierkorb bewegen?"],
        "alert.cancel": [.turkish: "Vazgec", .english: "Cancel", .german: "Abbrechen"],
        "alert.move": [.turkish: "Tasi", .english: "Move", .german: "Bewegen"],
        "alert.message": [.turkish: "%d oge tasinacak. Bu islem dosyalari kalici olarak silmez.", .english: "%d items will be moved. This does not permanently delete the files.", .german: "%d Objekte werden bewegt. Dadurch werden die Dateien nicht endgultig geloscht."],
        "alert.messageDetailed": [.turkish: "%d oge (%@) Cop Sepeti'ne tasinacak. Yuksek risk: %d, dikkat: %d. Bu islem kalici silme yapmaz ve son islem geri alinabilir.", .english: "%d items (%@) will be moved to Trash. High risk: %d, caution: %d. This does not permanently delete files and the latest action can be restored.", .german: "%d Objekte (%@) werden in den Papierkorb bewegt. Hohe Gefahr: %d, Achtung: %d. Dateien werden nicht endgultig geloscht und die letzte Aktion kann wiederhergestellt werden."],
        "help.systemApp": [.turkish: "Sistem veya yardimci uygulama", .english: "System or utility app", .german: "System- oder Dienstprogramm"],
        "help.required": [.turkish: "Uygulama paketi ana ogedir", .english: "The app package is the main item", .german: "Das App-Paket ist das Hauptelement"],
        "help.toggle": [.turkish: "Bu ogeyi sec veya birak", .english: "Select or deselect this item", .german: "Dieses Objekt aus- oder abwahlen"],
        "column.name": [.turkish: "Ad", .english: "Name", .german: "Name"],
        "column.type": [.turkish: "Tur", .english: "Type", .german: "Typ"],
        "column.risk": [.turkish: "Risk", .english: "Risk", .german: "Risiko"],
        "column.size": [.turkish: "Boyut", .english: "Size", .german: "Grosse"],
        "column.location": [.turkish: "Konum", .english: "Location", .german: "Ort"],
        "risk.low": [.turkish: "Guvenli", .english: "Safe", .german: "Sicher"],
        "risk.medium": [.turkish: "Dikkat", .english: "Caution", .german: "Achtung"],
        "risk.high": [.turkish: "Yuksek", .english: "High", .german: "Hoch"],
        "status.initial": [.turkish: "Uygulamalari gormek icin yenileyin.", .english: "Refresh to see applications.", .german: "Aktualisieren, um Programme zu sehen."],
        "status.scanningApps": [.turkish: "Uygulamalar taraniyor...", .english: "Scanning applications...", .german: "Programme werden gescannt..."],
        "status.appsFound": [.turkish: "%d uygulama bulundu.", .english: "%d applications found.", .german: "%d Programme gefunden."],
        "status.scanningItems": [.turkish: "%@ icin iliskili dosyalar araniyor...", .english: "Searching related files for %@...", .german: "Zugehorige Dateien fur %@ werden gesucht..."],
        "status.itemsFound": [.turkish: "%d kaldirilabilir oge bulundu.", .english: "%d removable items found.", .german: "%d entfernbare Objekte gefunden."],
        "status.moved": [.turkish: "%d oge Cop Sepeti'ne tasindi.", .english: "%d items moved to Trash.", .german: "%d Objekte in den Papierkorb bewegt."],
        "status.movedWithFailures": [.turkish: "%d oge tasindi, %d oge tasinamadi.", .english: "%d items moved, %d items failed.", .german: "%d Objekte bewegt, %d fehlgeschlagen."],
        "status.restored": [.turkish: "%d oge geri alindi.", .english: "%d items restored.", .german: "%d Objekte wiederhergestellt."],
        "status.restoredWithFailures": [.turkish: "%d oge geri alindi, %d oge alinamadi.", .english: "%d items restored, %d failed.", .german: "%d Objekte wiederhergestellt, %d fehlgeschlagen."],
        "kind.application": [.turkish: "Uygulama", .english: "Application", .german: "App"],
        "kind.support": [.turkish: "Destek dosyasi", .english: "Support file", .german: "Supportdatei"],
        "kind.cache": [.turkish: "Onbellek", .english: "Cache", .german: "Cache"],
        "kind.preferences": [.turkish: "Tercihler", .english: "Preferences", .german: "Einstellungen"],
        "kind.logs": [.turkish: "Gunluk", .english: "Log", .german: "Protokoll"],
        "kind.container": [.turkish: "Kapsayici", .english: "Container", .german: "Container"],
        "kind.launchAgent": [.turkish: "Baslatma ogesi", .english: "Launch agent", .german: "Startobjekt"],
        "kind.privilegedHelper": [.turkish: "Yardimci servis", .english: "Privileged helper", .german: "Hilfsdienst"],
        "kind.other": [.turkish: "Diger", .english: "Other", .german: "Andere"]
    ]
}
