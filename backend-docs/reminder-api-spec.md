# Reminder Setting API Spec

## Base URL

- Relative base path: `/api/reminder-settings`
- **Authentication Required**: All endpoints require JWT bearer token in `Authorization` header

## Overview

- `POST /api/reminder-settings` membuat reminder setting baru untuk habit (max 5 per habit).
- `GET /api/reminder-settings/:id` mendapatkan detail reminder setting berdasarkan id.
- `PATCH /api/reminder-settings/:id` mengupdate reminder setting yang sudah ada.
- `DELETE /api/reminder-settings/:id` menghapus reminder setting.

---

## 1) Create Reminder Setting

### Endpoint

- `POST /api/reminder-settings`

### Request Body (JSON)

```json
{
  "habitId": 1,
  "time": "2026-04-21T07:00:00.000Z",
  "isEnabled": true,
  "snoozeDuration": 10,
  "repeatDaily": true,
  "isSoundEnabled": true,
  "isVibrationEnabled": false
}
```

### Validation Rules

- `habitId` - number, positive (required)
- `time` - date/datetime (required)
- `isEnabled` - boolean (optional, default: false)
- `snoozeDuration` - number, positive (optional)
- `repeatDaily` - boolean (optional, default: true)
- `isSoundEnabled` - boolean (optional, default: true)
- `isVibrationEnabled` - boolean (optional, default: false)

### Success Response

- Status: `201 Created`

```json
{
  "message": "create reminder successfull",
  "data": {
    "id": 1,
    "habitId": 1,
    "time": "2026-04-21T07:00:00.000000Z",
    "isEnabled": true,
    "snoozeDuration": 10,
    "repeatDaily": true,
    "isSoundEnabled": true,
    "isVibrationEnabled": false,
    "createdAt": "2026-04-20T10:30:00.000Z",
    "updatedAt": "2026-04-20T10:30:00.000Z"
  }
}
```

### Error Responses

- `400 Bad Request` - validation error / maximum 5 reminders per habit / user id required to add reminder
- `403 Forbidden` - forbidden to add reminder to this habit
- `404 Not Found` - habit not found
- `401 Unauthorized` - access token is required

### Notes

- Setiap habit dapat memiliki maksimal 5 reminder settings.
- Backend melakukan validasi kepemilikan habit sebelum membuat reminder.

---

## 2) Get Reminder Setting

### Endpoint

- `GET /api/reminder-settings/:id`

### URL Parameters

- `id` (number) - Reminder Setting ID

### Request

- Membutuhkan header `Authorization: Bearer <access_token>`.

### Success Response

- Status: `200 OK`

```json
{
  "message": "successfully get reminder",
  "data": {
    "id": 1,
    "habitId": 1,
    "time": "2026-04-21T07:00:00.000000Z",
    "isEnabled": true,
    "snoozeDuration": 10,
    "repeatDaily": true,
    "isSoundEnabled": true,
    "isVibrationEnabled": false,
    "createdAt": "2026-04-20T10:30:00.000Z",
    "updatedAt": "2026-04-20T10:30:00.000Z"
  }
}
```

### Error Responses

- `400 Bad Request` - reminder id must be a number / user id required to get reminder
- `403 Forbidden` - forbidden to access this reminder
- `404 Not Found` - reminder not found
- `401 Unauthorized` - access token is required

---

## 3) Update Reminder Setting

### Endpoint

- `PATCH /api/reminder-settings/:id`

### URL Parameters

- `id` (number) - Reminder Setting ID

### Request Body (JSON)

```json
{
  "time": "2026-04-21T08:00:00.000Z",
  "isEnabled": false,
  "snoozeDuration": 15
}
```

### Validation Rules

- `time` - date/datetime (optional)
- `isEnabled` - boolean (optional)
- `snoozeDuration` - number, positive (optional)
- `repeatDaily` - boolean (optional)
- `isSoundEnabled` - boolean (optional)
- `isVibrationEnabled` - boolean (optional)

### Success Response

- Status: `200 OK`

```json
{
  "message": "update reminder successfull",
  "data": {
    "id": 1,
    "habitId": 1,
    "time": "2026-04-21T08:00:00.000000Z",
    "isEnabled": false,
    "snoozeDuration": 15,
    "repeatDaily": true,
    "isSoundEnabled": true,
    "isVibrationEnabled": false,
    "createdAt": "2026-04-20T10:30:00.000Z",
    "updatedAt": "2026-04-20T11:00:00.000Z"
  }
}
```

### Error Responses

- `400 Bad Request` - validation error / reminder id must be a number / user id required to update reminder
- `403 Forbidden` - forbidden to update this reminder
- `404 Not Found` - reminder not found
- `401 Unauthorized` - access token is required

---

## 4) Delete Reminder Setting

### Endpoint

- `DELETE /api/reminder-settings/:id`

### URL Parameters

- `id` (number) - Reminder Setting ID

### Request

- Membutuhkan header `Authorization: Bearer <access_token>`.

### Success Response

- Status: `200 OK`

```json
{
  "message": "delete reminder successfull"
}
```

### Error Responses

- `400 Bad Request` - reminder id must be a number / user id required to delete reminder
- `403 Forbidden` - forbidden to delete this reminder
- `404 Not Found` - reminder not found
- `401 Unauthorized` - access token is required

---

## Example Flow

1. Login dengan `POST /api/auth/sessions` untuk mendapatkan `accessToken`.
2. Gunakan token tersebut untuk akses endpoint reminder settings.
3. Buat reminder baru dengan `POST /api/reminder-settings`.
4. Dapatkan detail reminder dengan `GET /api/reminder-settings/:id`.
5. Update reminder dengan `PATCH /api/reminder-settings/:id`.
6. Hapus reminder dengan `DELETE /api/reminder-settings/:id`.
7. Lihat semua reminder untuk habit tertentu dengan `GET /api/habits/:habitId/reminder-settings`.

---

## Important Notes

- Setiap reminder milik satu habit, dan customer dapat membuat maksimal 5 reminder per habit.
- Reminder-setting dapat diakses hanya oleh user yang memiliki habit tersebut.
- Waktu reminder menyimpan datetime lengkap dari backend, namun client biasanya hanya menggunakan komponen waktu saja.
- Perubahan pada reminder setting akan otomatis mengupdate timestamp `updatedAt`.
