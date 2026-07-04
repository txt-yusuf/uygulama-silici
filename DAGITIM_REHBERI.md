# Profesyonel Dagitim Rehberi

Bu rehber, Uygulama Silici'yi daha profesyonel sekilde dagitmak icin hazirlandi.

## Hazir Olanlar

Projede su dagitim ciktilari uretilebilir:

- `.app` paketi
- `.zip` paketi
- `.dmg` kurulum paketi

`.dmg` paketi kullaniciya daha profesyonel bir kurulum deneyimi verir. Kullanici uygulamayi acilan pencereden `Applications` kisayoluna surukleyebilir.

## Tek Komutla Release Ciktilari

Release icin zip ve dmg dosyalarini birlikte olusturmak icin:

```bash
cd "/Users/erdal/Documents/Codex/uygulama silici"
./scripts/build_release.sh
```

Olusan dosyalar:

```text
dist/Uygulama-Silici-macOS.zip
dist/Uygulama-Silici-macOS.dmg
```

GitHub Release'e ikisini de yukleyebilirsin. Genellikle kullanicilar icin `.dmg`, teknik kullanicilar icin `.zip` iyi olur.

## Sadece DMG Olusturma

Sadece `.dmg` olusturmak icin:

```bash
./scripts/build_dmg.sh
```

Olusan dosya:

```text
dist/Uygulama-Silici-macOS.dmg
```

## Kullanici Nasil Yukler?

DMG ile kurulum:

1. `Uygulama-Silici-macOS.dmg` dosyasini indir.
2. DMG dosyasina cift tikla.
3. `Uygulama Silici.app` dosyasini `Applications` kisayoluna surukle.
4. Applications klasorunden uygulamayi ac.

Zip ile kurulum:

1. `Uygulama-Silici-macOS.zip` dosyasini indir.
2. Zip dosyasini ac.
3. `Uygulama Silici.app` dosyasini `Applications` klasorune surukle.
4. Applications klasorunden uygulamayi ac.

## macOS Guvenlik Uyarisi

Uygulama su an Apple Developer hesabi ile imzalanmadigi ve notarize edilmedigi icin ilk acilista macOS guvenlik uyarisi gosterebilir.

Kullanici acmak icin:

1. Uygulamaya sag tiklar.
2. `Open / Ac` secer.
3. Cikan uyarida tekrar `Open / Ac` der.

## Kod Imzalama ve Notarization

Daha profesyonel dagitim icin Apple Developer hesabi gerekir.

Gerekenler:

- Apple Developer Program uyeligi
- Developer ID Application sertifikasi
- App-specific password veya notarytool profile

Genel surec:

```bash
codesign --deep --force --options runtime --sign "Developer ID Application: AD SOYAD (TEAMID)" "dist/Uygulama Silici.app"
xcrun notarytool submit "dist/Uygulama-Silici-macOS.dmg" --keychain-profile "notary-profile" --wait
xcrun stapler staple "dist/Uygulama-Silici-macOS.dmg"
```

Bu bilgiler olmadan imzalama/notarization otomatik yapilamaz. Yine de proje yapisi buna hazir hale getirildi.
