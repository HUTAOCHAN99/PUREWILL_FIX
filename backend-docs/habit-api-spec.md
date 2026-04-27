# Habit API Spec

## Base URL

- Relative base path: `/api/habits`
- **Authentication Required**: All endpoints require JWT bearer token in `Authorization` header

## Overview

- `GET /api/habits/:id` mendapatkan detail habit berdasarkan id.
- `GET /api/habits/:id/logs` mendapatkan daftar log harian untuk habit tertentu.
- `GET /api/habits/:id/reminder-settings` mendapatkan reminder settings untuk habit tertentu.
- `POST /api/habits` membuat habit baru untuk user.
- `PATCH /api/habits/:id/logs` toggle status log harian habit.
- `PATCH /api/habits` mengupdate habit yang sudah ada.
- `DELETE /api/habits` menghapus habit.

---

## 1) Get Habit Detail

### Endpoint

- `GET /api/habits/:id`

### URL Parameters

- `id` (number) - Habit ID

### Request

- Membutuhkan header `Authorization: Bearer <access_token>`.

### Success Response

- Status: `200 OK`

```json
{
  "message": "successfully get habit detail",
  "data": {
    "id": 1,
    "name": "Jogging",
    "notes": "Morning jog in the park",
    "status": "NEUTRAL",
    "isActive": true,
    "startDate": "2026-04-20T00:00:00.000Z",
    "endDate": null,
    "categoryId": 1,
    "frequencyType": "DAILY",
    "targetValue": 5,
    "reminderEnabled": true,
    "unitId": 1,
    "userId": 1,
    "createdAt": "2026-04-20T10:30:00.000Z",
    "updatedAt": "2026-04-20T10:30:00.000Z"
  }
}
```

### Error Responses

- `400 Bad Request` - habit id must be a number / habit not found
- `401 Unauthorized` - access token is required

---

## 2) Get Habit Reminder Settings

### Endpoint

- `GET /api/habits/:id/reminder-settings`

### URL Parameters

- `id` (number) - Habit ID

### Request

- Membutuhkan header `Authorization: Bearer <access_token>`.

### Success Response

- Status: `200 OK`

```json
{
  "message": "successfully get habit reminder settings",
  "data": [
    {
      "id": 1,
      "time": "2026-04-21T07:00:00.000000Z",
      "isEnabled": true,
      "snoozeDuration": 10,
      "repeatDaily": true,
      "isSoundEnabled": true,
      "isVibrationEnabled": false,
      "habitId": 1,
      "createdAt": "2026-04-20T10:30:00.000Z",
      "updatedAt": "2026-04-20T10:30:00.000Z"
    },
    {
      "id": 2,
      "time": "2026-04-21T18:00:00.000000Z",
      "isEnabled": true,
      "snoozeDuration": 5,
      "repeatDaily": true,
      "isSoundEnabled": true,
      "isVibrationEnabled": true,
      "habitId": 1,
      "createdAt": "2026-04-20T11:00:00.000Z",
      "updatedAt": "2026-04-20T11:00:00.000Z"
    }
  ]
}
```

### Error Responses

- `400 Bad Request` - habit id must be a number
- `404 Not Found` - habit not found
- `401 Unauthorized` - access token is required

### Notes

- Mengembalikan array reminder settings untuk habit tertentu.
- Reminder settings diurutkan berdasarkan `createdAt` ascending.
- Jika habit tidak memiliki reminder settings, response akan mengembalikan empty array.

---

## 3) Get Habit Logs

### Endpoint

- `GET /api/habits/:id/logs`

### URL Parameters

- `id` (number) - Habit ID

### Request

- Membutuhkan header `Authorization: Bearer <access_token>`.

### Success Response

- Status: `200 OK`

```json
{
  "message": "successfully get habit logs",
  "data": [
    {
      "id": 1,
      "status": "neutral",
      "habitId": 1,
      "actualValue": 20,
      "createdAt": "2026-04-26T06:10:00.000Z",
      "updatedAt": "2026-04-26T06:10:00.000Z"
    },
    {
      "id": 2,
      "status": "success",
      "habitId": 1,
      "actualValue": 20,
      "createdAt": "2026-04-27T06:12:00.000Z",
      "updatedAt": "2026-04-27T06:12:00.000Z"
    }
  ]
}
```

### Error Responses

- `400 Bad Request` - habit id must be a number / user id required to get habit logs
- `401 Unauthorized` - access token is required

---

## 4) Create Habit

### Endpoint

- `POST /api/habits`

### Request Body (JSON)

```json
{
  "name": "Jogging",
  "notes": "Morning jog in the park",
  "startDate": "2026-04-20T00:00:00.000Z",
  "endDate": "2026-05-20T00:00:00.000Z",
  "categoryId": 1,
  "unitId": 1,
  "frequencyType": "DAILY",
  "targetValue": 5,
  "reminderEnabled": true
}
```

### Validation Rules

- `name` - string, min 5, max 100 chars (required)
- `notes` - string, min 5, max 500 chars (optional)
- `startDate` - date, harus >= hari ini (default: hari ini)
- `endDate` - date, must be > startDate (optional)
- `categoryId` - number (required)
- `unitId` - number (optional)
- `frequencyType` - enum: `DAILY`, `WEEKLY`, `MONTHLY` (default: DAILY)
- `targetValue` - number (optional)
- `reminderEnabled` - boolean (default: false)

### Success Response

- Status: `201 Created`

```json
{
  "message": "create habit successfull",
  "data": {
    "id": 1,
    "name": "Jogging",
    "notes": "Morning jog in the park",
    "status": "NEUTRAL",
    "isActive": true,
    "startDate": "2026-04-20T00:00:00.000Z",
    "endDate": "2026-05-20T00:00:00.000Z",
    "categoryId": 1,
    "frequencyType": "DAILY",
    "targetValue": 5,
    "reminderEnabled": true,
    "unitId": 1,
    "userId": 1,
    "createdAt": "2026-04-20T10:30:00.000Z",
    "updatedAt": "2026-04-20T10:30:00.000Z"
  }
}
```

### Error Responses

- `400 Bad Request` - validation error / user id required to create habit
- `401 Unauthorized` - access token is required

---

## 5) Update Habit

### Endpoint

- `PATCH /api/habits`

### Request Body (JSON)

```json
{
  "id": 1,
  "name": "Jogging Updated",
  "frequencyType": "WEEKLY",
  "targetValue": 10
}
```

### Validation Rules

- `id` - number, positive (required)
- `name` - string, min 5, max 100 chars (optional)
- `notes` - string, min 5, max 500 chars (optional)
- `startDate` - date (optional)
- `endDate` - date, must be > startDate if provided (optional)
- `categoryId` - number, positive (optional)
- `unitId` - number, positive (optional)
- `frequencyType` - enum: `DAILY`, `WEEKLY`, `MONTHLY` (optional)
- `targetValue` - number (optional)
- `reminderEnabled` - boolean (optional)

### Success Response

- Status: `200 OK`

```json
{
  "message": "update habit successfull",
  "data": {
    "id": 1,
    "name": "Jogging Updated",
    "notes": "Morning jog in the park",
    "status": "NEUTRAL",
    "isActive": true,
    "startDate": "2026-04-20T00:00:00.000Z",
    "endDate": "2026-05-20T00:00:00.000Z",
    "categoryId": 1,
    "frequencyType": "WEEKLY",
    "targetValue": 10,
    "reminderEnabled": true,
    "unitId": 1,
    "userId": 1,
    "createdAt": "2026-04-20T10:30:00.000Z",
    "updatedAt": "2026-04-20T11:45:00.000Z"
  }
}
```

### Error Responses

- `403 Forbidden` - forbidden to update this habit
- `404 Not Found` - habit not found
- `400 Bad Request` - validation error / user id required to update habit
- `401 Unauthorized` - access token is required

---

## 6) Toggle Habit Log

### Endpoint

- `PATCH /api/habits/:id/logs`

### URL Parameters

- `id` (number) - Habit ID

### Request

- Membutuhkan header `Authorization: Bearer <access_token>`.
- Endpoint ini akan toggle status log habit berdasarkan hari berjalan.

### Success Response

- Status: `200 OK`

```json
{
  "message": "successfully to toggle log habit, current status log is DONE"
}
```

### Error Responses

- `400 Bad Request` - habit id must be a number / user id required to get habit logs
- `401 Unauthorized` - access token is required

---

## 7) Delete Habit

### Endpoint

- `DELETE /api/habits`

### Request Body (JSON)

```json
{
  "id": 1
}
```

### Request

- Membutuhkan header `Authorization: Bearer <access_token>`.
- `id` - number, habit ID (required)

### Success Response

- Status: `200 OK`

```json
{
  "message": "delete habit successfull"
}
```

### Error Responses

- `403 Forbidden` - forbidden to delete this habit
- `404 Not Found` - habit not found
- `400 Bad Request` - habit id is required / user id required to delete habit
- `401 Unauthorized` - access token is required

---

## Example Flow

1. Login dengan `POST /api/auth/sessions` untuk mendapatkan `accessToken`.
2. Gunakan token tersebut untuk semua endpoint habit dengan header `Authorization: Bearer <accessToken>`.
3. Buat habit baru dengan `POST /api/habits`.
4. Lihat detail habit dengan `GET /api/habits/:id`.
5. Lihat habit logs dengan `GET /api/habits/:id/logs`.
6. Toggle log harian dengan `PATCH /api/habits/:id/logs`.
7. Lihat reminder settings habit dengan `GET /api/habits/:id/reminder-settings`.
8. Update habit dengan `PATCH /api/habits`.
9. Hapus habit dengan `DELETE /api/habits`.
