# Nofap Session API Spec

## Base URL

- Relative base path: `/api/nofap-sessions`
- **Authentication Required**: Semua endpoint butuh JWT bearer token di header `Authorization`.

## Overview

- `GET /api/nofap-sessions/current` mengambil nofap session aktif (`endDate = null`) milik user login.
- `GET /api/nofap-sessions/:id` mengambil detail nofap session berdasarkan id.
- `POST /api/nofap-sessions` membuat nofap session baru untuk user login.
- `PATCH /api/nofap-sessions/current` mengupdate nofap session aktif (biasanya untuk stop session / relapse).

---

## 1) Get Current Nofap Session

### Endpoint

- `GET /api/nofap-sessions/current`

### Request

- Membutuhkan header `Authorization: Bearer <access_token>`.

### Success Response

- Status: `200 OK`

```json
{
  "message": "successfully get current nofap session",
  "data": {
    "id": 1,
    "startDate": "2026-04-20T00:00:00.000Z",
    "endDate": null,
    "relapseNotes": null,
    "userId": 1
  }
}
```

### Error Responses

- `400 Bad Request` - `user id is required`
- `401 Unauthorized` - access token is required

### Notes

- Jika user belum punya session aktif, `data` bernilai `null`.

---

## 2) Get Nofap Session Detail

### Endpoint

- `GET /api/nofap-sessions/:id`

### URL Parameters

- `id` (number) - Nofap Session ID

### Request

- Membutuhkan header `Authorization: Bearer <access_token>`.

### Success Response

- Status: `200 OK`

```json
{
  "message": "successfully get nofap session detail",
  "data": {
    "id": 1,
    "startDate": "2026-04-20T00:00:00.000Z",
    "endDate": null,
    "relapseNotes": null,
    "userId": 1
  }
}
```

### Error Responses

- `400 Bad Request` - `nofap session id must be a number`
- `404 Not Found` - `nofap session not found`
- `401 Unauthorized` - access token is required

---

## 3) Create Nofap Session

### Endpoint

- `POST /api/nofap-sessions`

### Request

- Membutuhkan header `Authorization: Bearer <access_token>`.
- Body saat ini tidak wajib.

### Request Body (JSON)

```json
{}
```

### Success Response

- Status: `201 Created`

```json
{
  "message": "create nofap session successfull",
  "data": {
    "id": 2,
    "startDate": "2026-04-23T08:30:00.000Z",
    "endDate": null,
    "relapseNotes": null,
    "userId": 1
  }
}
```

### Error Responses

- `400 Bad Request` - `user id is required`
- `401 Unauthorized` - access token is required
- `500 Internal Server Error` - kemungkinan jika user sudah punya session (karena constraint unik `userId`)

### Notes

- Implementasi repository membuat session dengan `startDate = now`, `endDate = null`, dan `relapseNotes = null`.
- Model database saat ini memberi constraint unik di `userId`, jadi satu user hanya bisa punya satu record nofap session.

---

## 4) Update Current Nofap Session

### Endpoint

- `PATCH /api/nofap-sessions/current`

### Request

- Membutuhkan header `Authorization: Bearer <access_token>`.

### Request Body (JSON)

```json
{
  "endDate": "2026-04-23T12:00:00.000Z",
  "relapseNotes": "Relapse karena trigger tertentu"
}
```

### Body Fields

- `startDate` - date string (optional)
- `endDate` - date string atau `null` (optional)
- `relapseNotes` - string atau `null` (optional)

### Success Response

- Status: `200 OK`

```json
{
  "message": "update current nofap session successfull",
  "data": {
    "id": 1,
    "startDate": "2026-04-20T00:00:00.000Z",
    "endDate": "2026-04-23T12:00:00.000Z",
    "relapseNotes": "Relapse karena trigger tertentu",
    "userId": 1
  }
}
```

### Error Responses

- `400 Bad Request` - `user id is required`
- `401 Unauthorized` - access token is required
- `404 Not Found` - current nofap session not found (expected behavior)

### Notes

- Session aktif ditentukan dari `endDate = null`.
- Endpoint ini dimaksudkan untuk update session aktif (misal stop session dengan set `endDate`).

---
