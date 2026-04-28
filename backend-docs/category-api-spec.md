# Category API Spec

## Base URL

- Relative base path: `/api/categories`
- **Authentication Required**: All endpoints require JWT bearer token in `Authorization` header

## Overview

- `POST /api/categories` membuat category baru.
- `PATCH /api/categories` mengupdate category.
- `DELETE /api/categories` menghapus category.

---

## 1) Create Category

### Endpoint

- `POST /api/categories`

### Request Body (JSON)

```json
{
  "name": "Fitness",
  "description": "Category for fitness-related habits"
}
```

### Validation Rules

- `name` - string, min 3, max 100 chars (required)
- `description` - string, min 3, max 255 chars (optional)

### Success Response

- Status: `201 Created`

```json
{
  "message": "create category successfull",
  "data": {
    "id": 1,
    "name": "Fitness",
    "description": "Category for fitness-related habits",
    "createdAt": "2026-04-20T10:00:00.000Z",
    "updatedAt": "2026-04-20T10:00:00.000Z"
  }
}
```

### Error Responses

- `400 Bad Request` - validation error
- `401 Unauthorized` - access token is required

Kemungkinan penyebab:

- name kosong atau terlalu pendek
- description terlalu pendek / terlalu panjang
- nama category sudah ada

---

## 2) Update Category

### Endpoint

- `PATCH /api/categories`

### Request Body (JSON)

```json
{
  "id": 1,
  "name": "Fitness Updated",
  "description": "Updated description"
}
```

### Validation Rules

- `id` - number, positive (required)
- `name` - string, min 3, max 100 chars (optional)
- `description` - string, min 3, max 255 chars (optional)

### Success Response

- Status: `200 OK`

```json
{
  "message": "update category successfull",
  "data": {
    "id": 1,
    "name": "Fitness Updated",
    "description": "Updated description",
    "createdAt": "2026-04-20T10:00:00.000Z",
    "updatedAt": "2026-04-20T11:00:00.000Z"
  }
}
```

### Error Responses

- `400 Bad Request` - validation error
- `404 Not Found` - category not found
- `401 Unauthorized` - access token is required

---

## 3) Delete Category

### Endpoint

- `DELETE /api/categories`

### Request Body (JSON)

```json
{
  "id": 1
}
```

### Request

- `id` - number, category ID (required)
- Membutuhkan header `Authorization: Bearer <access_token>`.

### Success Response

- Status: `200 OK`

```json
{
  "message": "delete category successfull"
}
```

### Error Responses

- `400 Bad Request` - category id is required / category is used by habit
- `404 Not Found` - category not found
- `401 Unauthorized` - access token is required

Kemungkinan penyebab delete gagal:

- category masih dipakai oleh habit
- category id tidak valid

---

## Example Flow

1. Login dengan `POST /api/auth/sessions` untuk mendapatkan `accessToken`.
2. Gunakan token tersebut untuk akses `/api/categories`.
3. Buat category baru dengan `POST /api/categories`.
4. Update category dengan `PATCH /api/categories`.
5. Hapus category dengan `DELETE /api/categories` jika tidak dipakai habit.
