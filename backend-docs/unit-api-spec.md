# Unit API Spec

## Base URL

- Relative base path: `/api/units`
- **Authentication**: Optional (public endpoints)

## Overview

- `GET /api/units` mendapatkan semua units yang tersedia.
- `GET /api/units/:id` mendapatkan detail unit berdasarkan id.
- `POST /api/units` membuat unit baru.
- `PATCH /api/units` mengupdate unit yang sudah ada.
- `DELETE /api/units` menghapus unit.

---

## 1) Get All Units

### Endpoint

- `GET /api/units`

### Request

- Tidak membutuhkan authentication.

### Success Response

- Status: `200 OK`

```json
{
  "message": "successfully get all units",
  "data": [
    {
      "id": 1,
      "name": "Kilometer",
      "abbreviation": "km",
      "createdAt": "2026-04-20T10:00:00.000Z",
      "updatedAt": "2026-04-20T10:00:00.000Z"
    },
    {
      "id": 2,
      "name": "Kilogram",
      "abbreviation": "kg",
      "createdAt": "2026-04-20T10:05:00.000Z",
      "updatedAt": "2026-04-20T10:05:00.000Z"
    }
  ]
}
```

---

## 2) Get Unit Detail

### Endpoint

- `GET /api/units/:id`

### URL Parameters

- `id` (number) - Unit ID

### Request

- Tidak membutuhkan authentication.

### Success Response

- Status: `200 OK`

```json
{
  "message": "successfully get unit detail",
  "data": {
    "id": 1,
    "name": "Kilometer",
    "abbreviation": "km",
    "createdAt": "2026-04-20T10:00:00.000Z",
    "updatedAt": "2026-04-20T10:00:00.000Z"
  }
}
```

### Error Responses

- `400 Bad Request` - unit id must be a number
- `404 Not Found` - unit not found

---

## 3) Create Unit

### Endpoint

- `POST /api/units`

### Request Body (JSON)

```json
{
  "name": "Kilometer",
  "abbreviation": "km"
}
```

### Validation Rules

- `name` - string, min 3, max 100 chars (required)
- `abbreviation` - string, min 1, max 50 chars (optional)

### Success Response

- Status: `201 Created`

```json
{
  "message": "create unit successfull",
  "data": {
    "id": 1,
    "name": "Kilometer",
    "abbreviation": "km",
    "createdAt": "2026-04-20T10:00:00.000Z",
    "updatedAt": "2026-04-20T10:00:00.000Z"
  }
}
```

### Error Responses

- `400 Bad Request` - validation error

---

## 4) Update Unit

### Endpoint

- `PATCH /api/units`

### Request Body (JSON)

```json
{
  "id": 1,
  "name": "Kilometer Updated",
  "abbreviation": "km"
}
```

### Validation Rules

- `id` - number, positive (required)
- `name` - string, min 3, max 100 chars (optional)
- `abbreviation` - string, min 1, max 50 chars (optional)

### Success Response

- Status: `200 OK`

```json
{
  "message": "update unit successfull",
  "data": {
    "id": 1,
    "name": "Kilometer Updated",
    "abbreviation": "km",
    "createdAt": "2026-04-20T10:00:00.000Z",
    "updatedAt": "2026-04-20T10:30:00.000Z"
  }
}
```

### Error Responses

- `404 Not Found` - unit not found
- `400 Bad Request` - validation error

---

## 5) Delete Unit

### Endpoint

- `DELETE /api/units`

### Request Body (JSON)

```json
{
  "id": 1
}
```

### Request

- `id` - number, unit ID (required)

### Success Response

- Status: `200 OK`

```json
{
  "message": "delete unit successfull"
}
```

### Error Responses

- `404 Not Found` - unit not found
- `400 Bad Request` - unit id is required

---

## Example Flow

1. Ambil semua units yang tersedia dengan `GET /api/units`.
2. Gunakan unit ID untuk mengisi `unitId` saat membuat habit.
3. Admin dapat membuat unit baru dengan `POST /api/units`.
4. Update unit dengan `PATCH /api/units`.
5. Hapus unit dengan `DELETE /api/units`.
