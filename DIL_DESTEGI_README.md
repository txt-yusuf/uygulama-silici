# Dil Destegi Rehberi

Bu proje su anda 3 dili destekler:

- Turkce
- English
- Deutsch

Dil secimi uygulama icinde yapilir. Kullanici ust kisimdaki dil seciciden dili degistirdiginde arayuz metinleri aninda guncellenir.

## Dil Sistemi Nerede?

Dil destegi su dosyada tutulur:

```text
Sources/UygulamaSilici/Localization.swift
```

Bu dosyada iki ana parca vardir:

```swift
enum AppLanguage
```

Desteklenen dilleri tanimlar.

```swift
struct Localizer
```

Arayuzde kullanilan metinleri secili dile gore getirir.

## Yeni Dil Ekleme

Ornek olarak Fransizca eklemek istedigimizi dusunelim.

### 1. Yeni dili AppLanguage icine ekle

`Localization.swift` dosyasinda:

```swift
enum AppLanguage: String, CaseIterable, Identifiable {
    case turkish = "tr"
    case english = "en"
    case german = "de"
    case french = "fr"
}
```

### 2. Dil adini displayName icine ekle

Ayni dosyada `displayName` bolumune yeni dilin gorunen adini ekle:

```swift
case .french:
    "Francais"
```

### 3. Ceviri sozlugune yeni dili ekle

Her metin anahtarinda yeni dilin cevirisini eklemen gerekir.

Ornek:

```swift
"toolbar.refresh": [
    .turkish: "Yenile",
    .english: "Refresh",
    .german: "Aktualisieren",
    .french: "Actualiser"
]
```

Bu islemi `Localizer.values` icindeki tum satirlar icin yapmalisin.

## Yeni Arayuz Metni Ekleme

Yeni bir buton, uyari veya baslik eklediginde sabit metni dogrudan SwiftUI icine yazma. Onun yerine `Localization.swift` icine yeni bir anahtar ekle.

Ornek:

```swift
"button.example": [
    .turkish: "Ornek",
    .english: "Example",
    .german: "Beispiel"
]
```

Sonra SwiftUI tarafinda soyle kullan:

```swift
Text(localizer.text("button.example"))
```

## Degiskenli Metinler

Sayi veya uygulama adi gibi degisken iceren metinlerde `format` kullanilir.

Ornek ceviri:

```swift
"status.appsFound": [
    .turkish: "%d uygulama bulundu.",
    .english: "%d applications found.",
    .german: "%d Programme gefunden."
]
```

Kullanim:

```swift
localizer.format("status.appsFound", apps.count)
```

String icin:

```swift
"status.scanningItems": [
    .turkish: "%@ icin iliskili dosyalar araniyor...",
    .english: "Searching related files for %@...",
    .german: "Zugehorige Dateien fur %@ werden gesucht..."
]
```

Kullanim:

```swift
localizer.format("status.scanningItems", app.name)
```

## Ceviri Eklerken Dikkat Edilecekler

- Her yeni dil icin tum anahtarlara ceviri ekle.
- Metinleri cok uzun tutma; macOS arayuzunde butonlar dar olabilir.
- Buton metinlerinde kisa ve net ifadeler kullan.
- Teknik terimleri hedef dilde kullanici dostu sekilde cevir.
- Degiskenli metinlerde `%d` ve `%@` siralarini bozma.
- Bir ceviri eksik kalirsa uygulama once English metnine, o da yoksa anahtar adina geri duser.

## GitHub'da Farkli Dillerde Destek Sunma

Uygulama icinde dil destegi vermek ile GitHub'da farkli dillerde dokumantasyon sunmak farkli seylerdir.

### Uygulama ici dil destegi

Uygulama metinleri `Localization.swift` dosyasindan yonetilir.

### GitHub dokumantasyon dil destegi

GitHub icin farkli README dosyalari ekleyebilirsin:

```text
README.md
README.en.md
README.de.md
```

Ana `README.md` icine dil secim linkleri koyabilirsin:

```markdown
Languages: [Turkce](README.md) | [English](README.en.md) | [Deutsch](README.de.md)
```

Bu sayede GitHub ziyaretcileri kendi dillerindeki dokumantasyonu acabilir.

## Onerilen Dil Destegi Plani

Ilk asama:

- Turkce
- English
- Deutsch

Sonraki asama:

- Spanish
- French
- Italian

Daha sonra uygulama indirme sayfasinda veya GitHub release notlarinda desteklenen dilleri acikca yazabilirsin.

## Degisiklikten Sonra Test

Yeni dil veya ceviri ekledikten sonra:

```bash
swift build
./scripts/build_app.sh
```

Uygulamayi acip dil seciciden her dili tek tek kontrol et:

- Butonlar tasiyor mu?
- Tablo basliklari okunuyor mu?
- Uyari metinleri dogru mu?
- Degiskenli metinlerde sayilar ve uygulama adi dogru gorunuyor mu?
