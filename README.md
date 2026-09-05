# Ustam — Flutter sürümü

Bu klasör, v0 ile oluşturduğun Next.js/React projesinin (`usta-cagri-platformu.zip`)
Flutter'a taşınmış halidir. Ekranlar, akışlar ve renk paleti orijinal koddan
birebir uyarlanmıştır.

## Neyin neye karşılık geldiği

| Next.js (v0) | Flutter |
|---|---|
| `app/page.tsx` | `lib/screens/home/home_screen.dart` |
| `app/ustalar/page.tsx` | `lib/screens/providers/providers_screen.dart` |
| `app/taleplerim/page.tsx` | `lib/screens/requests/my_requests_screen.dart` |
| `app/talep/yeni/page.tsx` + `new-request-form.tsx` | `lib/screens/requests/new_request_screen.dart` |
| `components/auth-form.tsx` + `sign-in`/`sign-up` sayfaları | `lib/screens/auth/auth_screen.dart` |
| `components/app-shell.tsx` | `lib/screens/root_shell.dart` |
| `lib/categories.ts` | `lib/models/category.dart` |
| `lib/db/schema.ts` (Drizzle + Postgres) | `supabase/schema.sql` (Supabase/Postgres) |
| `app/actions/*.ts` (server actions) | `lib/services/*_repository.dart` |
| Better Auth (`lib/auth.ts`) | Supabase Auth (`lib/state/auth_state.dart`) |

**Not:** Orijinal v0 projesinde "Usta Paneli" (`/usta`) sayfası için arayüz
henüz yazılmamıştı — sadece navigasyon linki ve gerekli server action'lar
(`createProviderProfile`, `getProviderJobs`, `acceptRequest`, `completeJob`)
vardı. Flutter sürümünde bu eksik ekran da tamamlandı
(`lib/screens/usta/usta_panel_screen.dart`).

## Neden Drizzle/Postgres yerine Supabase?

Flutter'da kendi Node.js sunucunu (Next.js server actions, Better Auth)
çalıştıramazsın; mobil uygulamanın bir backend'e ihtiyacı var. En hızlı yol,
zaten Postgres tabanlı olan şemanı **Supabase**'e taşımak: aynı tablolar,
üstelik hazır Auth ve otomatik REST API ile. `supabase/schema.sql` dosyası
`lib/db/schema.ts`'deki tabloların (providers, service_requests, reviews)
birebir karşılığıdır; kullanıcı tablosu için Supabase'in kendi
`auth.users` tablosu kullanılır.

İstersen ilerde kendi Node/Express backend'ini de yazabilirsin — bu durumda
sadece `lib/services/*_repository.dart` dosyalarındaki Supabase çağrılarını
kendi API isteklerinle (`http` paketiyle) değiştirmen yeterli, ekranlar
aynı kalır.

## Kurulum

1. **Flutter SDK**'yı kur (VS Code'da zaten Flutter/Dart eklentilerini
   kurman yeterli): https://docs.flutter.dev/get-started/install

2. **Supabase projesi oluştur**: https://supabase.com → New Project

3. SQL Editor'e gidip `supabase/schema.sql` dosyasının içeriğini yapıştırıp
   çalıştır. Bu, `providers`, `service_requests`, `reviews` tablolarını ve
   RLS (satır bazlı izin) politikalarını oluşturur.

4. Supabase Dashboard > Project Settings > API sayfasından `Project URL` ve
   `anon public key` değerlerini al.

5. Bağımlılıkları yükle:
   ```bash
   cd usta_cagirma_flutter
   flutter pub get
   ```

6. Uygulamayı bu iki değeri vererek çalıştır:
   ```bash
   flutter run \
     --dart-define=SUPABASE_URL=https://xxxx.supabase.co \
     --dart-define=SUPABASE_ANON_KEY=xxxxxxxx
   ```

   VS Code'da her seferinde yazmak istemezsen, proje köküne bir
   `.vscode/launch.json` ekleyip `args` içine bu iki `--dart-define`'ı
   koyabilirsin; ya da geçici olarak `lib/services/supabase_config.dart`
   dosyasındaki `defaultValue` alanlarını doğrudan kendi bilgilerinle
   değiştirebilirsin (sadece geliştirme için, gerçek anahtarları repoya
   commit'lememeye dikkat et).

7. `flutter run` ile bir emülatörde veya gerçek cihazda çalıştır.

## Tasarım

Renkler orijinal `app/globals.css` içindeki oklch tasarım tokenlarından
`lib/theme/app_theme.dart` dosyasına aktarıldı: turuncu vurgu (#F2712B),
lacivert-gri metin, beyaz kart/arkaplan. Yazı tipi olarak orijinaldeki gibi
Google Fonts üzerinden **Manrope** kullanılıyor.

## Eksik / sonraki adımlar

- Şu an ustayı arama ekranında harita/konum özelliği yok (orijinal projede
  de yoktu, sadece telefonla arama vardı).
- Push bildirim, resim/avatar yükleme gibi özellikler eklenmedi.
- İstersen state management için `provider` yerine `riverpod` gibi daha
  büyük projelerde tercih edilen bir çözüme geçilebilir; şu anki yapı
  basit tutuldu.
