# Auth API Spec

## Base URL

- Relative base path: `/api/auth`

## Authentication Model

- `POST /api/auth/register` membuat user baru.
- `POST /api/auth/session` menghasilkan:
  - `accessToken` (JWT) di response body, masa berlaku 10 menit.
  - `refreshToken` (JWT) di cookie HTTP-only, masa berlaku 7 hari.
- `GET /api/auth/session` mengecek validitas access token dan mengembalikan data user login.
- `POST /api/auth/refresh` melakukan rotasi refresh token (old -> new) dan mengembalikan access token baru.
- `DELETE /api/auth/session` menghapus refresh token dari penyimpanan.

## Cookie Policy (Refresh Token)

Cookie yang dipakai: `refreshToken`

- `httpOnly: true`
- `secure: false`
- `sameSite: strict`
- `path: /api/auth/refresh`
- `maxAge: 7 hari`

> Catatan: karena `path` cookie adalah `/api/auth/refresh`, browser hanya otomatis mengirim cookie ini ke endpoint refresh.

---

## 1) Create Session (Login)

### Endpoint

- `POST /api/auth/sessions`

### Request Body (JSON)

```json
{
  "email": "user@example.com",
  "password": "your-password"
}
```

### Success Response

- Status: `200 OK`

```json
{
  "message": "create session token",
  "accessToken": "<jwt-access-token>"
}
```

### Error Responses (current behavior)

- `400 Bad Request`

```json
{
  "message": "user not registered"
}
```

Kemungkinan penyebab:

- format input tidak valid
- email tidak ditemukan
- password salah

---

## 2) Register (Create User)

### Endpoint

- `POST /api/users`

### Request Body (JSON)

```json
{
  "email": "user@example.com",
  "username": "john_doe",
  "fullname": "John Doe",
  "gender": "MALE",
  "birthDate": "2000-01-01T00:00:00.000Z",
  "password": "your-password",
  "passwordConfirmation": "your-password"
}
```

### Success Response

- Status: `201 Created`

```json
{
  "message": "create user successfully",
  "data": {
    "id": 1,
    "email": "user@example.com",
    "username": "john_doe"
  }
}
```

### Error Responses (current behavior)

- `400 Bad Request`

```json
{
  "message": "user not registered"
}
```

Kemungkinan penyebab:

- format input tidak valid
- email/username sudah terdaftar

---

## 3) Refresh Access Token

### Endpoint

- `POST /api/auth/refresh`

### Request

- Tidak membutuhkan body.
- Membutuhkan cookie `refreshToken`.

### Success Response

- Status: `200 OK`

```json
{
  "message": "create session token",
  "accessToken": "<new-jwt-access-token>"
}
```

### Error Responses (current behavior)

1. Jika cookie tidak ada:

- Status: `401 Unauthorized`

```json
{
  "message": "refresh token is required"
}
```

2. Jika token tidak valid / tidak ditemukan di storage:

- Status: `400 Bad Request`

```json
{
  "message": "refresh token not valid"
}
```

---

## 4) Delete Session (Logout)

### Endpoint

- `DELETE /api/auth/session`

### Request

- Cookie `refreshToken` dibaca dari request cookie.
- Handler juga membaca `req.user.id` dari auth context.

### Success Response

- Status: `200 OK`

```json
{
  "message": "delete session successfully"
}
```

### Error Responses (current behavior)

1. Jika `req.user.id` tidak ada:

- Status: `400 Bad Request`

```json
{
  "message": "user id not found"
}
```

2. Jika hapus refresh token gagal:

- Status: `500 Internal Server Error`

```json
{
  "message": "delete refresh token failed"
}
```

---

## 5) Check Session

### Endpoint

- `GET /api/auth/session`

### Request

- Tidak membutuhkan body.
- Membutuhkan header `Authorization: Bearer <access-token>`.

### Success Response

- Status: `200 OK`
- `message`: `session is active`
- `data`: detail user login (`id`, `username`, `email`, `profile.fullname`).

### Error Response

- Status: `401 Unauthorized` jika access token tidak ada atau tidak valid.

## Example Flow

1. Login dengan `POST /api/auth/session`.
2. Simpan `accessToken` untuk Authorization Bearer pada endpoint protected.
3. Cek status login dengan `GET /api/auth/session`.
4. Saat access token expired, panggil `POST /api/auth/refresh` agar dapat access token baru.
5. Logout dengan `DELETE /api/auth/session`.
