# Me API Spec

## Base URL

- Relative base path: `/api/me`

## Overview

- `GET /api/me` mendapatkan data user yang sedang login.
- `GET /api/me/habits` mendapatkan semua habits milik user yang sedang login.
- `GET /api/me/categories` mendapatkan semua categories milik user yang sedang login.
- `GET /api/me/units` mendapatkan semua units default yang tersedia.
- `GET /api/me/nofap-sessions` mendapatkan nofap session milik user yang sedang login.
- `PATCH /api/me` mengupdate data user yang sedang login.
- `DELETE /api/me` melakukan soft delete user yang sedang login.

---

## 1) Get Me / Current User

### Endpoint

- `GET /api/me`

### Description

Mengambil data user yang sedang login berdasarkan token JWT pada header Authorization.

### Request

- Membutuhkan header `Authorization: Bearer <access_token>`.

### Success Response

- Status: `200 OK`

```json
{
  "message": "get user data successfull",
  "data": {
    "id": 1,
    "username": "john_doe",
    "email": "user@example.com"
  }
}
```

### Error Responses

- `401 Unauthorized` - access token is required
- `400 Bad Request` - user not found

### Notes

- Endpoint ini setara dengan fitur "me" pada auth flow.
- Response hanya berisi data profil dasar user yang sedang login.

---

## 2) Get Me Habits

### Endpoint

- `GET /api/me/habits`

### Description

Mengambil seluruh habit milik user yang sedang login. Data bisa difilter berdasarkan tanggal melalui query URL `date`.

### Query Parameters

- `date` (string, optional) - format tanggal yang direkomendasikan: `YYYY-MM-DD`.

### Request

- Membutuhkan header `Authorization: Bearer <access_token>`.

### Example Request

- Tanpa filter tanggal:
  - `GET /api/me/habits`
- Dengan filter tanggal:
  - `GET /api/me/habits?date=2026-04-25`

### Success Response

- Status: `200 OK`

```json
{
  "message": "get me habits successfull",
  "data": [
    {
      "id": 1,
      "name": "Jogging",
      "notes": "Morning jog",
      "status": "NEUTRAL",
      "isActive": true,
      "startDate": "2026-04-20T00:00:00.000Z",
      "endDate": "2026-05-01T00:00:00.000Z",
      "categoryId": 1,
      "frequencyType": "DAILY",
      "targetValue": 1,
      "reminderEnabled": false,
      "unitId": 1,
      "userId": 1,
      "createdAt": "2026-04-20T10:00:00.000Z",
      "updatedAt": "2026-04-20T10:00:00.000Z"
    }
  ]
}
```

### Error Responses

- `400 Bad Request` - user id is required
- `401 Unauthorized` - access token is required

### Notes

- Jika query `date` tidak dikirim, endpoint akan mengembalikan semua habit user.
- Jika query `date` dikirim, endpoint akan mengembalikan habit aktif pada tanggal tersebut.

---

## 3) Get Me Categories

### Endpoint

- `GET /api/me/categories`

### Description

Mengambil seluruh category yang bisa dipakai user yang sedang login.
Endpoint ini mengembalikan category milik user **dan** category default sistem.

### Request

- Membutuhkan header `Authorization: Bearer <access_token>`.

### Success Response

- Status: `200 OK`

```json
{
  "message": "successfully get me categories",
  "data": [
    {
      "id": 1,
      "name": "Health",
      "description": "Default health category",
      "isDefault": true,
      "color": "#ffffff",
      "createdAt": "2026-04-20T10:00:00.000Z",
      "updatedAt": "2026-04-20T10:00:00.000Z",
      "userId": null
    },
    {
      "id": 2,
      "name": "Personal",
      "description": "My personal category",
      "isDefault": false,
      "color": "#22c55e",
      "createdAt": "2026-04-21T10:00:00.000Z",
      "updatedAt": "2026-04-21T10:00:00.000Z",
      "userId": 1
    }
  ]
}
```

### Error Responses

- `400 Bad Request` - user id is required
- `401 Unauthorized` - access token is required

### Notes

- Data category diurutkan berdasarkan `createdAt` ascending.
- Hasil berisi gabungan category default (`isDefault: true`) dan category milik user (`userId` sesuai user login).

---

## 4) Get Units

### Endpoint

- `GET /api/me/units`

### Description

Mengambil semua unit yang tersedia untuk dipakai pada habit.

### Request

- Membutuhkan header `Authorization: Bearer <access_token>`.

### Success Response

- Status: `200 OK`

```json
{
  "message": "successfully get units",
  "data": [
    {
      "id": 1,
      "name": "Minute",
      "abbreviation": "min",
      "createdAt": "2026-04-20T10:00:00.000Z",
      "updatedAt": "2026-04-20T10:00:00.000Z"
    },
    {
      "id": 2,
      "name": "Hour",
      "abbreviation": "hr",
      "createdAt": "2026-04-20T10:00:00.000Z",
      "updatedAt": "2026-04-20T10:00:00.000Z"
    }
  ]
}
```

### Error Responses

- `401 Unauthorized` - access token is required

### Notes

- Endpoint ini mengembalikan seluruh unit global.
- Data diurutkan berdasarkan `createdAt` ascending.

---

## 5) Get Nofap Session

### Endpoint

- `GET /api/me/nofap-sessions`

### Description

Mengambil data nofap session milik user yang sedang login.

### Request

- Membutuhkan header `Authorization: Bearer <access_token>`.

### Success Response

- Status: `200 OK`

```json
{
  "message": "successfully get me nofap sessions",
  "data": [
    {
      "id": 5,
      "startDate": "2026-04-20T00:00:00.000Z",
      "endDate": null,
      "relapseNotes": null,
      "userId": 1
    },
    {
      "id": 4,
      "startDate": "2026-04-10T08:00:00.000Z",
      "endDate": "2026-04-19T22:00:00.000Z",
      "relapseNotes": "Stres karena pekerjaan menumpuk.",
      "userId": 1
    },
    {
      "id": 3,
      "startDate": "2026-03-25T10:00:00.000Z",
      "endDate": "2026-04-09T23:30:00.000Z",
      "relapseNotes": "Terlalu lama scrolling media sosial di malam hari.",
      "userId": 1
    },
    {
      "id": 2,
      "startDate": "2026-03-15T09:00:00.000Z",
      "endDate": "2026-03-24T15:00:00.000Z",
      "relapseNotes": "Lupa mematikan filter konten dewasa.",
      "userId": 1
    },
    {
      "id": 1,
      "startDate": "2026-03-01T12:00:00.000Z",
      "endDate": "2026-03-14T20:00:00.000Z",
      "relapseNotes": "Sesi pertama, masih penyesuaian.",
      "userId": 1
    }
  ]
}
```

### Error Responses

- `400 Bad Request` - user id is required
- `401 Unauthorized` - access token is required

### Notes

- Jika user belum memiliki nofap session, `currentSession` bernilai `null`, `sessions` bernilai empty array, dan summary bernilai `0` / `false`.

---

## 6) Update Me

### Endpoint

- `PATCH /api/me`

### Description

Mengupdate data user yang sedang login. Field yang dikirim bersifat opsional.

### Request

- Membutuhkan header `Authorization: Bearer <access_token>`.

### Request Body (JSON)

```json
{
  "email": "new-email@example.com",
  "username": "new_username",
  "fullname": "New Name",
  "gender": "MALE",
  "birthDate": "2000-01-01T00:00:00.000Z",
  "password": "new-password"
}
```

### Success Response

- Status: `200 OK`

```json
{
  "message": "successfully update me",
  "data": {
    "id": 1,
    "email": "new-email@example.com",
    "username": "new_username",
    "createdAt": "2026-04-21T10:00:00.000Z",
    "updatedAt": "2026-04-21T11:00:00.000Z",
    "profile": {
      "id": 1,
      "fullname": "New Name",
      "gender": "male",
      "birthDate": "2000-01-01T00:00:00.000Z"
    }
  }
}
```

### Error Responses

- `400 Bad Request` - validation error / user id is required / error update me
- `401 Unauthorized` - access token is required

---

## 7) Delete Me

### Endpoint

- `DELETE /api/me`

### Description

Melakukan soft delete terhadap user yang sedang login dengan mengisi `deletedAt`.

### Request

- Membutuhkan header `Authorization: Bearer <access_token>`.

### Success Response

- Status: `200 OK`

```json
{
  "message": "successfully delete me"
}
```

### Error Responses

- `400 Bad Request` - user id is required / error delete me
- `401 Unauthorized` - access token is required
