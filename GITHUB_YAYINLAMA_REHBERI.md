# GitHub Yayinlama Rehberi

Bu rehber, Uygulama Silici projesini GitHub'da yayinlamak ve isterseniz indirilebilir `.app` surumu paylasmak icin hazirlandi.

## 1. GitHub'da Yeni Repository Olustur

1. GitHub hesabina gir.
2. Sag ustten `+` menusune tikla.
3. `New repository` sec.
4. Repository adi olarak ornegin sunu yaz:

```text
uygulama-silici
```

5. Aciklama olarak sunu kullanabilirsin:

```text
macOS icin sade, guvenli ve cok dilli uygulama kaldirma araci.
```

6. `Public` veya `Private` sec.
7. `Add a README file` kutusunu isaretleme. Bu projede README zaten var.
8. `Create repository` butonuna bas.

## 2. Projeyi Git'e Hazirla

Terminalde proje klasorune git:

```bash
cd "/Users/erdal/Documents/Codex/uygulama silici"
```

Git deposu baslat:

```bash
git init
```

Dosyalari kontrol et:

```bash
git status
```

Dosyalari ekle:

```bash
git add .
```

Ilk commit'i olustur:

```bash
git commit -m "Initial macOS app cleaner"
```

## 3. GitHub Repository ile Bagla

GitHub sana repository sayfasinda buna benzer bir URL verecek:

```text
https://github.com/KULLANICI_ADIN/uygulama-silici.git
```

Bu URL'yi kendi GitHub kullanici adinla degistirerek terminalde calistir:

```bash
git remote add origin https://github.com/KULLANICI_ADIN/uygulama-silici.git
```

Ana branch adini `main` yap:

```bash
git branch -M main
```

Projeyi GitHub'a yukle:

```bash
git push -u origin main
```

## 4. Uygulama Paketini Olustur

GitHub'a kaynak kodu yukledikten sonra kullanicilarin indirebilecegi `.app` paketini olusturmak icin:

```bash
./scripts/build_app.sh
```

Olusan uygulama:

```text
dist/Uygulama Silici.app
```

GitHub Release'e yuklemek icin bunu zip dosyasi yapmak daha uygundur:

```bash
cd dist
zip -r "Uygulama-Silici-macOS.zip" "Uygulama Silici.app"
```

Zip dosyasi su sekilde olusur:

```text
dist/Uygulama-Silici-macOS.zip
```

## 5. GitHub Release Olustur

1. GitHub'da repository sayfasina git.
2. Sag tarafta veya ust menude `Releases` bolumunu ac.
3. `Create a new release` tikla.
4. Tag olarak sunu yaz:

```text
v0.1.0
```

5. Release basligi:

```text
Uygulama Silici v0.1.0
```

6. Aciklama olarak sunu kullanabilirsin:

```text
Ilk surum.

- macOS uygulamalarini listeleme
- Iliskili kalinti dosyalarini tarama
- Secili ogeleri Cop Sepeti'ne tasima
- Turkce, English ve Deutsch dil destegi
- Ozel uygulama ikonu
```

7. `Uygulama-Silici-macOS.zip` dosyasini release ekine yukle.
8. `Publish release` butonuna bas.

## 6. Sonraki Guncellemeler

Kodda degisiklik yaptiktan sonra:

```bash
swift build
./scripts/build_app.sh
git status
git add .
git commit -m "Update app"
git push
```

Yeni indirilebilir surum yayinlamak icin:

1. Yeni zip dosyasi olustur.
2. GitHub'da yeni release ac.
3. Tag'i artir:

```text
v0.1.1
v0.2.0
v1.0.0
```

## 7. Onerilen Ek Dosyalar

Herkese acik bir proje icin ileride sunlari eklemek iyi olur:

- `LICENSE`
- Ekran goruntuleri
- Daha detayli gizlilik/guvenlik aciklamasi
- Imzali ve notarize edilmis macOS release paketi

## 8. macOS Guvenlik Uyarisi Hakkinda

Bu uygulama su an yerel olarak paketlenmis ve imzasizdir. Bu nedenle macOS ilk acilista guvenlik uyarisi gosterebilir.

Kullanici uygulamayi acmak icin:

1. Uygulamaya sag tiklar.
2. `Open / Ac` secer.
3. Cikan uyarida tekrar `Open / Ac` der.

Daha profesyonel dagitim icin Apple Developer hesabi ile kod imzalama ve notarization sureci eklenmelidir.
