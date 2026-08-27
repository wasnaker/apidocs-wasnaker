# apidocs.wasnaker.lan

Repository khusus menampung **hasil generate dokumentasi API** untuk
`wasnaker.lan` (Laravel API-only).

Dokumentasi di-generate oleh [Scribe](https://github.com/knuckleswtf/scribe)
dari repo `wasnaker/lrvl-wasnaker_core`, lalu output static-nya di-commit ke
repo ini dan di-serve oleh aaPanel di domain `apidocs.wasnaker.lan`.

## Isi repo

```
public/
  index.html        # Dokumentasi HTML statis (dokumentasi utama)
  openapi.yaml      # Spesifikasi OpenAPI 3
  collection.json   # Koleksi Postman
  css/ js/ images/  # Asset statis Scribe
.gitignore
README.md
deploy-docs.sh      # Skrip bantu regenerate + sync ke folder live
```

> Repo ini **hanya** berisi hasil generate. Jangan edit file di `public/`
> secara manual — selalu regenerate dari `lrvl-wasnaker_core`.

## Cara regenerate dari repo core

```bash
cd /path/to/wasnaker-core
php artisan scribe:generate --force
```

Scribe dikonfigurasi menulis langsung ke
`/www/wwwroot/apidocs.wasnaker.lan/public` (lihat `config/scribe.php`
key `static.output_path`).

Atau pakai skrip bantu ini (jalankan dari folder repo apidocs):

```bash
./deploy-docs.sh /path/to/wasnaker-core
```

Skrip akan:
1. Menjalankan `scribe:generate --force` di folder core.
2. Menyalin hasil ke `public/`.
3. (Opsional) Melakukan git add + commit + push.

## Endpoint yang didokumentasikan

- `GET /api/health` — health check
- `GET /api/user` — user terautentikasi (Sanctum)
- Settings (key-value API):
  - `GET /api/settings/{key}`
  - `PUT /api/settings/{key}` (upsert)
  - `DELETE /api/settings/{key}`
  - `POST /api/settings/bulk`
- Modul Sales (nwidart): `api/v1/sales/*`

Semua endpoint `/api/*` (kecuali `/api/health`) membutuhkan auth
Sanctum bearer token.

## Deploy (aaPanel)

Folder `public/` di-render oleh nginx vhost
`/www/server/panel/vhost/nginx/apidocs.wasnaker.lan.conf`
dengan `root /www/wwwroot/apidocs.wasnaker.lan/public`.

Setelah push ke GitHub, tarik di server:

```bash
cd /www/wwwroot/apidocs.wasnaker.lan
git pull origin main
```
