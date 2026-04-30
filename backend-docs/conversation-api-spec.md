# Conversation API Spec

## Base URL

- Relative base path: `/api/conversations`
- **Authentication Required**: All endpoints require JWT bearer token in the `Authorization` header.

## Overview

- `GET /api/conversations` mengambil daftar conversation milik user login.
- `POST /api/conversations` membuat conversation baru.
- `GET /api/conversations/:id` mengambil detail conversation berdasarkan id.
- `DELETE /api/conversations/:id` menghapus conversation milik user login.
- `GET /api/conversations/:id/messages` mengambil daftar message pada conversation tertentu.
- `POST /api/conversations/:id/messages` membuat message baru dan mendapatkan respons AI.

---

## 1) Get Conversations

### Endpoint

- `GET /api/conversations`

### Request

- Membutuhkan header `Authorization: Bearer <access_token>`.

### Query Parameters

- `userId` - optional secara dokumentasi, tetapi pada implementasi user diambil dari JWT login.

### Success Response

- Status: `200 OK`

```json
{
  "message": "Successfully retrieved conversations",
  "data": [
    {
      "id": "c3f4f7aa-5f4b-4c2c-a9aa-4a1c07a9c100",
      "userId": "1",
      "title": "Daily check-in",
      "createdAt": "2026-04-30T08:00:00.000Z",
      "updatedAt": "2026-04-30T09:10:00.000Z"
    },
    {
      "id": "0d2b2dd9-5d69-4a0b-8f83-8f9b8c3b9d31",
      "userId": "1",
      "title": "Habits and goals",
      "createdAt": "2026-04-29T08:00:00.000Z",
      "updatedAt": "2026-04-29T10:15:00.000Z"
    }
  ]
}
```

### Error Responses

- `400 Bad Request` - user id is required
- `401 Unauthorized` - access token is required

### Notes

- Data diurutkan berdasarkan `updatedAt DESC`.
- Hanya conversation milik user login yang dikembalikan.

---

## 2) Create Conversation

### Endpoint

- `POST /api/conversations`

### Request

- Membutuhkan header `Authorization: Bearer <access_token>`.

### Request Body (JSON)

```json
{
  "title": "Daily check-in"
}
```

### Body Fields

- `title` - optional, string, min 1, max 150 karakter.

### Success Response

- Status: `201 Created`

```json
{
  "message": "Conversation created successfully",
  "data": {
    "id": "c3f4f7aa-5f4b-4c2c-a9aa-4a1c07a9c100",
    "userId": "1",
    "title": "Daily check-in",
    "createdAt": "2026-04-30T08:00:00.000Z",
    "updatedAt": "2026-04-30T08:00:00.000Z"
  }
}
```

### Error Responses

- `400 Bad Request` - validation error / user id is required
- `401 Unauthorized` - access token is required

### Notes

- Jika `title` tidak dikirim, conversation tetap bisa dibuat dengan title `null`.

---

## 3) Get Conversation Detail

### Endpoint

- `GET /api/conversations/:id`

### URL Parameters

- `id` (string UUID) - Conversation ID

### Request

- Membutuhkan header `Authorization: Bearer <access_token>`.

### Success Response

- Status: `200 OK`

```json
{
  "message": "Successfully retrieved conversation",
  "data": {
    "id": "c3f4f7aa-5f4b-4c2c-a9aa-4a1c07a9c100",
    "userId": "1",
    "title": "Daily check-in",
    "createdAt": "2026-04-30T08:00:00.000Z",
    "updatedAt": "2026-04-30T09:10:00.000Z"
  }
}
```

### Error Responses

- `400 Bad Request` - user id is required
- `401 Unauthorized` - access token is required
- `403 Forbidden` - unauthorized access to conversation
- `404 Not Found` - conversation not found

### Notes

- Endpoint ini memvalidasi bahwa conversation milik user login.

---

## 4) Delete Conversation

### Endpoint

- `DELETE /api/conversations/:id`

### URL Parameters

- `id` (string UUID) - Conversation ID

### Request

- Membutuhkan header `Authorization: Bearer <access_token>`.

### Success Response

- Status: `200 OK`

```json
{
  "message": "Conversation deleted successfully",
  "data": {
    "message": "Conversation deleted successfully"
  }
}
```

### Error Responses

- `400 Bad Request` - user id is required
- `401 Unauthorized` - access token is required
- `403 Forbidden` - unauthorized access to conversation
- `404 Not Found` - conversation not found

---

## 5) Get Conversation Messages

### Endpoint

- `GET /api/conversations/:id/messages`

### URL Parameters

- `id` (string UUID) - Conversation ID

### Request

- Membutuhkan header `Authorization: Bearer <access_token>`.

### Query Parameters

- `limit` - optional, number, default `10`, max `50`
- `cursor` - optional, UUID message id untuk pagination cursor

### Success Response

- Status: `200 OK`

```json
{
  "message": "Successfully retrieved messages",
  "data": [
    {
      "id": "d2a4b1d1-7f25-4d64-8c4d-9f0f3bc5f111",
      "conversationId": "c3f4f7aa-5f4b-4c2c-a9aa-4a1c07a9c100",
      "role": "USER",
      "content": "How should I plan my day?",
      "createdAt": "2026-04-30T09:00:00.000Z"
    },
    {
      "id": "b6d19a4b-9d13-4a7e-a7df-20c0d9d3a222",
      "conversationId": "c3f4f7aa-5f4b-4c2c-a9aa-4a1c07a9c100",
      "role": "ASSISTANT",
      "content": "Try breaking your day into 3 priorities...",
      "createdAt": "2026-04-30T09:00:01.000Z"
    }
  ]
}
```

### Error Responses

- `400 Bad Request` - validation error / user id is required
- `401 Unauthorized` - access token is required
- `403 Forbidden` - unauthorized access to conversation
- `404 Not Found` - conversation not found

### Notes

- Default limit adalah `10` message.
- Messages diambil dari yang paling baru, lalu dikembalikan dalam urutan kronologis.
- Endpoint ini hanya mengembalikan message milik conversation user login.

---

## 6) Create Message And Generate AI Response

### Endpoint

- `POST /api/conversations/:id/messages`

### URL Parameters

- `id` (string UUID) - Conversation ID

### Request

- Membutuhkan header `Authorization: Bearer <access_token>`.
- Endpoint ini juga memakai rate limit per user + conversation.

### Request Body (JSON)

```json
{
  "content": "How can I improve my habits today?"
}
```

### Body Fields

- `content` - required, string, min 1, max 4000 karakter.

### Success Response

- Status: `201 Created`

```json
{
  "message": "Message created and AI response generated",
  "data": {
    "userMessage": {
      "id": "d2a4b1d1-7f25-4d64-8c4d-9f0f3bc5f111",
      "conversationId": "c3f4f7aa-5f4b-4c2c-a9aa-4a1c07a9c100",
      "role": "USER",
      "content": "How can I improve my habits today?",
      "createdAt": "2026-04-30T09:00:00.000Z"
    },
    "assistantMessage": {
      "id": "b6d19a4b-9d13-4a7e-a7df-20c0d9d3a222",
      "conversationId": "c3f4f7aa-5f4b-4c2c-a9aa-4a1c07a9c100",
      "role": "ASSISTANT",
      "content": "Start with one small action and repeat it consistently...",
      "createdAt": "2026-04-30T09:00:01.000Z"
    }
  }
}
```

### Error Responses

- `400 Bad Request` - validation error / user id is required / message content is required
- `401 Unauthorized` - access token is required
- `403 Forbidden` - unauthorized access to conversation
- `404 Not Found` - conversation not found
- `429 Too Many Requests` - too many chat requests, please try again later
- `500 Internal Server Error` - AI service / server error

### Notes

- User message disimpan dengan role `USER`.
- Assistant message disimpan dengan role `ASSISTANT`.
- Conversation `updatedAt` akan di-update saat ada message baru.
- Request ini mengambil context summary + last messages untuk prompt AI.
- Jika total message lebih dari 20, summary akan dibuat dan disimpan ke DB.

---

## Validation Rules

### Conversation

- `title` - optional string, min 1, max 150

### Message

- `content` - required string, min 1, max 4000

### Message Query

- `limit` - optional number, default 10, max 50
- `cursor` - optional UUID string

---

## Rate Limit

### Chat Endpoint Rate Limit

- Applies to `POST /api/conversations/:id/messages`
- Scoped by `userId + conversationId`
- Default: 10 requests per 60 seconds
- Configurable via `.env`:
  - `CHAT_RATE_LIMIT_MAX_REQUESTS`
  - `CHAT_RATE_LIMIT_WINDOW_MS`

---

## Summary Behavior

- Sistem mengambil summary terbaru jika ada.
- Prompt AI dibangun dari:
  1. system prompt
  2. summary terbaru
  3. last messages (default 10)
- Saat total message dalam conversation lebih dari 20, sistem membuat summary baru dan menyimpannya ke tabel `Summary`.

---

## Error Format

Sebagian besar error mengikuti format:

```json
{
  "message": "..."
}
```

atau

```json
{
  "message": "...",
  "data": null
}
```

tergantung handler yang memproses error tersebut.
