# GitHub Release ve Uygulama Yukleme Rehberi

Bu rehber, Uygulama Silici icin GitHub'da indirilebilir surum yayinlamak ve uygulamayi Mac'e yuklemek icin hazirlandi.

## 1. Once Projeyi Guncelle

Kodda yaptigin son degisiklikleri GitHub'a gonder:

```bash
cd "/Users/erdal/Documents/Codex/uygulama silici"
git status
git add .
git commit -m "Update app"
git push
```

Eger `nothing to commit` yazarsa yeni commit gerekmez.

## 2. Uygulama Paketini Olustur

Finder'dan cift tikla acilan `.app` dosyasini olustur:

```bash
cd "/Users/erdal/Documents/Codex/uygulama silici"
./scripts/build_app.sh
```

Bu komut su uygulamayi olusturur:

```text
dist/Uygulama Silici.app
```

## 3. Release Dosyalarini Olustur

Zip ve DMG dosyalarini tek komutla olusturmak icin:

```bash
cd "/Users/erdal/Documents/Codex/uygulama silici"
./scripts/build_release.sh
```

Olusan dosyalar:

```text
dist/Uygulama-Silici-macOS.zip
dist/Uygulama-Silici-macOS.dmg
```

DMG dosyasi kullanici icin daha kolay kurulum deneyimi sunar. Zip dosyasi ise alternatif indirme secenegi olarak kalabilir.

## 4. Sadece Zip Dosyasi Olusturmak Istersen

GitHub Release'e `.app` klasoru dogrudan yuklemek yerine zip dosyasi yuklemek daha dogrudur.

```bash
cd "/Users/erdal/Documents/Codex/uygulama silici/dist"
zip -r "Uygulama-Silici-macOS.zip" "Uygulama Silici.app"
```

Olusacak dosya:

```text
dist/Uygulama-Silici-macOS.zip
```

## 5. GitHub'da Release Olustur

1. GitHub'da proje sayfani ac:

```text
https://github.com/txt-yusuf/uygulama-silici
```

2. Sag tarafta veya ust menude `Releases` bolumune tikla.
3. `Create a new release` butonuna tikla.
4. `Choose a tag` alanina surum etiketi yaz:

```text
v0.1.0
```

5. `Create new tag: v0.1.0 on publish` sec.
6. `Release title` alanina sunu yaz:

```text
Uygulama Silici v0.1.0
```

7. Aciklama alanina ornek olarak sunu yazabilirsin:

```markdown
Ilk yayinlanan surum.

Ozellikler:
- macOS uygulamalarini listeleme
- Iliskili kalinti dosyalarini tarama
- Secili ogeleri Cop Sepeti'ne tasima
- Turkce, English ve Deutsch dil destegi
- Ozel uygulama ikonu

Kurulum:
1. Uygulama-Silici-macOS.zip dosyasini indirin.
2. Zip dosyasini acin.
3. Uygulama Silici.app dosyasini Applications klasorune tasiyin.
4. Ilk acilista sag tiklayip Open / Ac secin.
```

8. `Attach binaries by dropping them here or selecting them` bolumune su dosyalari yukle:

```text
Uygulama-Silici-macOS.zip
Uygulama-Silici-macOS.dmg
```

9. `Publish release` butonuna bas.

## 6. Kullanici Uygulamayi Nasil Yukler?

Release yayinlandiktan sonra kullanici su adimlari izler:

1. GitHub proje sayfasina gider.
2. `Releases` bolumunu acar.
3. En son surumdeki `Uygulama-Silici-macOS.dmg` dosyasini indirir.
4. DMG dosyasini acar.
5. `Uygulama Silici.app` dosyasini `Applications` kisayoluna surukler.
6. Uygulamayi acmak icin cift tiklar.

## 7. macOS Guvenlik Uyarisi

Uygulama su an Apple Developer hesabiyla imzalanmadigi ve notarize edilmedigi icin macOS ilk acilista uyari gosterebilir.

Kullanici uygulamayi acmak icin:

1. `Uygulama Silici.app` dosyasina sag tiklar.
2. `Open / Ac` secer.
3. Cikan uyarida tekrar `Open / Ac` der.

Bu islemden sonra macOS genellikle uygulamayi normal sekilde acmaya izin verir.

## 8. Yeni Surum Yayinlama

Sonraki surumlerde tag numarasini artir:

```text
v0.1.1
v0.2.0
v1.0.0
```

Genel akis:

```bash
git add .
git commit -m "Update app"
git push
./scripts/build_app.sh
./scripts/build_release.sh
```

Sonra GitHub'da yeni release olusturup yeni zip dosyasini yukle.

## 9. Daha Profesyonel Dagitim Icin

Ileride daha profesyonel dagitim yapmak istersen sunlar eklenebilir:

- Apple Developer hesabiyla kod imzalama
- Notarization
- `.dmg` kurulum paketi
- Otomatik guncelleme sistemi
- GitHub Actions ile otomatik release build
