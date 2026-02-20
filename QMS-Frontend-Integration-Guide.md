# QMS API - Frontend Integration Guide

**Version:** 1.0  
**Base URL:** `http://localhost:5000` (dev) | `https://api.qms.com` (production)  
**Authentication:** JWT Bearer Token  
**Date:** 2026-01-27

---

## Table of Contents

1. [Authentication Flow](#1-authentication-flow)
2. [API Endpoints](#2-api-endpoints)
3. [Data Models (DTOs)](#3-data-models-dtos)
4. [Error Handling](#4-error-handling)
5. [File Upload](#5-file-upload)
6. [Idempotency & Retries](#6-idempotency--retries)

---

## 1. Authentication Flow

### 1.1 Login

**Endpoint:** `POST /api/auth/login`  
**Auth Required:** No

**Request:**
```json
{
  "kullaniciAdi": "admin",
  "parola": "Admin123"
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Giriş başarılı.",
  "data": {
    "userId": 1,
    "username": "admin",
    "hesapSeviyesi": "Admin",
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "expiration": "2026-01-27T23:00:00Z"
  }
}
```

**Response (401 Unauthorized):**
```json
{
  "success": false,
  "message": "Kullanıcı adı veya parola hatalı.",
  "data": null
}
```

**Flutter Example:**
```dart
final response = await http.post(
  Uri.parse('$baseUrl/api/auth/login'),
  headers: {'Content-Type': 'application/json'},
  body: jsonEncode({
    'kullaniciAdi': username,
    'parola': password,
  }),
);

if (response.statusCode == 200) {
  final result = jsonDecode(response.body);
  if (result['success']) {
    final token = result['data']['token'];
    // Store token securely (SharedPreferences, SecureStorage)
    await storage.write('auth_token', token);
  }
}
```

---

### 1.2 Register

**Endpoint:** `POST /api/auth/register`  
**Auth Required:** No

**Request:**
```json
{
  "kullaniciAdi": "operator1",
  "parola": "Operator123",
  "hesapSeviyesi": "Operator",
  "personelId": 5
}
```

**HesapSeviyesi Values:**
- `"Admin"` (0)
- `"Inspector"` (1)
- `"Operator"` (2)
- `"QualityEngineer"` (3)

**Response (201 Created):**
```json
{
  "success": true,
  "message": "Kullanıcı başarıyla oluşturuldu.",
  "data": {
    "id": 10,
    "kullaniciAdi": "operator1",
    "hesapSeviyesi": "Operator",
    "personelId": 5,
    "personelAdi": "Ahmet Yılmaz",
    "kayitTarihi": "2026-01-27T20:00:00+00:00"
  }
}
```

**Validation Errors (400 Bad Request):**
```json
{
  "success": false,
  "message": "Validation failed",
  "errors": {
    "Parola": ["Parola en az 8 karakter olmalıdır."]
  }
}
```

---

### 1.3 Get Current User

**Endpoint:** `GET /api/auth/me`  
**Auth Required:** ✅ Yes

**Headers:**
```
Authorization: Bearer {token}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Kullanıcı bilgileri alındı.",
  "data": {
    "id": 1,
    "kullaniciAdi": "admin",
    "hesapSeviyesi": "Admin",
    "personelId": null,
    "personelAdi": null,
    "kayitTarihi": "2026-01-01T00:00:00+00:00"
  }
}
```

---

## 2. API Endpoints

### 2.1 Fire Kayıt Formu (Scrap Forms)

#### 2.1.1 Get Paginated Forms

**Endpoint:** `GET /api/firekayitformu?pageNumber=1&pageSize=10`  
**Auth Required:** ✅ Yes

**Query Parameters:**
- `pageNumber` (int, default: 1)
- `pageSize` (int, default: 10, max: 100)

**Role-Based Filtering:**
- **Admin/Inspector:** See all records
- **Operator:** See only own records (OlusturanKullaniciId = CurrentUserId)

**Response (200 OK):**
```json
{
  "items": [
    {
      "id": 125,
      "vardiyaId": 1,
      "vardiyaAdi": "Sabah",
      "islemTarihi": "2026-01-27T08:30:00+03:00",
      "urunKodu": "BRK-001",
      "sarjNo": "SRJ-2024-01",
      "tezgahId": 3,
      "tezgahNo": "T-03",
      "operasyonId": 5,
      "operasyonAdi": "Tornalama",
      "bolgeId": 2,
      "bolgeAdi": "A Blok",
      "retKoduId": 7,
      "retKodu": "R-05",
      "operatorAdi": "Mehmet Demir",
      "aciklama": "Ölçü dışı",
      "fotografYolu": "2026/01/27/photos/abc123def456.jpg",
      "kullaniciId": 8,
      "kullaniciAdi": "operator1",
      "olusturmaZamani": "2026-01-27T08:35:00+00:00",
      "guncellemeZamani": null
    }
  ],
  "currentPage": 1,
  "pageSize": 10,
  "totalCount": 125,
  "totalPages": 13
}
```

---

#### 2.1.2 Get Form by ID

**Endpoint:** `GET /api/firekayitformu/{id}`  
**Auth Required:** ✅ Yes

**Response (200 OK):** Same as single item above

**Response (404 Not Found):**
```json
{
  "success": false,
  "message": "Fire kayıt formu bulunamadı.",
  "data": null
}
```

---

#### 2.1.3 Create Form

**Endpoint:** `POST /api/firekayitformu`  
**Auth Required:** ✅ Yes

**Request:**
```json
{
  "vardiyaId": 1,
  "urunKodu": "BRK-001",
  "sarjNo": "SRJ-2024-01",
  "tezgahId": 3,
  "operasyonId": 5,
  "bolgeId": 2,
  "retKoduId": 7,
  "operatorAdi": "Mehmet Demir",
  "aciklama": "Ölçü dışı"
}
```

**Response (201 Created):**
```json
{
  "success": true,
  "message": "Fire kayıt formu başarıyla oluşturuldu.",
  "data": {
    "id": 126,
    // ... full object
  }
}
```

**Note:** `kullaniciId` is automatically set from JWT token (CurrentUserId)

---

#### 2.1.4 Update Form

**Endpoint:** `PUT /api/firekayitformu/{id}`  
**Auth Required:** ✅ Yes

**Request:**
```json
{
  "id": 126,
  "vardiyaId": 1,
  "urunKodu": "BRK-002",
  "sarjNo": "SRJ-2024-02",
  "tezgahId": 4,
  "operasyonId": 6,
  "bolgeId": 2,
  "retKoduId": 8,
  "operatorAdi": "Ahmet Yılmaz",
  "aciklama": "Güncellenmiş açıklama"
}
```

**Response (200 OK):** Full updated object

**Response (400 Bad Request - ID Mismatch):**
```json
{
  "success": false,
  "message": "ID uyuşmazlığı.",
  "data": null
}
```

---

#### 2.1.5 Delete Form (Soft Delete)

**Endpoint:** `DELETE /api/firekayitformu/{id}`  
**Auth Required:** ✅ Yes (Admin/Inspector only)

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Fire kayıt formu başarıyla silindi."
}
```

---

#### 2.1.6 Upload Photo

**Endpoint:** `POST /api/firekayitformu/{id}/photo`  
**Auth Required:** ✅ Yes  
**Content-Type:** `multipart/form-data`

**Request (FormData):**
```dart
var request = http.MultipartRequest(
  'POST',
  Uri.parse('$baseUrl/api/firekayitformu/$id/photo'),
);
request.headers['Authorization'] = 'Bearer $token';
request.files.add(
  await http.MultipartFile.fromPath('photo', imageFile.path),
);
var response = await request.send();
```

**Validation:**
- Max size: 5MB
- Allowed types: JPG, PNG only
- MIME type validation: `image/jpeg`, `image/png`

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Fotoğraf başarıyla yüklendi.",
  "data": "2026/01/27/photos/abc123def456.jpg"
}
```

**Photo URL:**
```
http://localhost:5000/uploads/photos/2026/01/27/abc123def456.jpg
```

---

### 2.2 Lookup Data (Master Tables)

All lookup endpoints require authentication.

#### 2.2.1 Vardiyalar (Shifts)

**GET /api/vardiyalar**

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "vardiyaAdi": "Sabah",
      "baslangicSaati": "08:00:00",
      "bitisSaati": "16:00:00"
    },
    {
      "id": 2,
      "vardiyaAdi": "Akşam",
      "baslangicSaati": "16:00:00",
      "bitisSaati": "00:00:00"
    }
  ]
}
```

**POST /api/vardiyalar**

**Request:**
```json
{
  "id": 3,
  "vardiyaAdi": "Gece",
  "baslangicSaati": "00:00:00",
  "bitisSaati": "08:00:00"
}
```

---

#### 2.2.2 Operasyonlar

**GET /api/lookup/operasyonlar**

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "operasyonKodu": "OP-001",
      "operasyonAdi": "Tornalama"
    }
  ]
}
```

**POST /api/lookup/operasyonlar**

---

#### 2.2.3 Tezgahlar (Workstations)

**GET /api/lookup/tezgahlar**

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "tezgahNo": "T-01",
      "tezgahTuru": "CNC Torna"
    }
  ]
}
```

**POST /api/lookup/tezgahlar**

---

#### 2.2.4 Bolgeler (Zones)

**GET /api/lookup/bolgeler**  
**POST /api/lookup/bolgeler**

---

#### 2.2.5 Ret Kodları (Reject Codes)

**GET /api/lookup/ret-kodlari**  
**POST /api/lookup/ret-kodlari**

---

## 3. Data Models (DTOs)

### 3.1 Result Wrapper

All responses use the `Result<T>` pattern:

```typescript
{
  success: boolean;        // true if operation succeeded
  message: string;         // Human-readable message (Turkish)
  data: T | null;          // Response data (null if failed)
  errors?: {               // Validation errors (if any)
    [key: string]: string[];
  };
}
```

---

### 3.2 FireKayitFormuDto

```typescript
{
  id: number;
  vardiyaId?: number;
  vardiyaAdi?: string;
  islemTarihi: string;     // ISO 8601
  urunKodu: string;
  sarjNo?: string;
  tezgahId?: number;
  tezgahNo?: string;
  operasyonId?: number;
  operasyonAdi?: string;
  bolgeId?: number;
  bolgeAdi?: string;
  retKoduId?: number;
  retKodu?: string;
  operatorAdi?: string;
  aciklama?: string;
  fotografYolu?: string;
  kullaniciId: number;
  kullaniciAdi?: string;
  olusturmaZamani: string; // ISO 8601
  guncellemeZamani?: string;
}
```

---

### 3.3 CreateFireKayitFormuDto

```typescript
{
  vardiyaId?: number;
  urunKodu: string;        // Required
  sarjNo?: string;
  tezgahId?: number;
  operasyonId?: number;
  bolgeId?: number;
  retKoduId?: number;
  operatorAdi?: string;
  aciklama?: string;
}
```

---

### 3.4 PaginatedResult<T>

```typescript
{
  items: T[];
  currentPage: number;
  pageSize: number;
  totalCount: number;
  totalPages: number;
}
```

---

## 4. Error Handling

### 4.1 HTTP Status Codes

| Code | Meaning | When |
|------|---------|------|
| 200 | OK | Success (GET, PUT) |
| 201 | Created | Success (POST) |
| 400 | Bad Request | Validation error, business rule violation |
| 401 | Unauthorized | Missing/invalid token, wrong credentials |
| 403 | Forbidden | Insufficient permissions (role check) |
| 404 | Not Found | Resource not found |
| 500 | Internal Server Error | Unexpected server error |

---

### 4.2 Validation Errors

**Response (400 Bad Request):**
```json
{
  "success": false,
  "message": "Validation failed",
  "errors": {
    "UrunKodu": ["Ürün kodu boş bırakılamaz."],
    "VardiyaId": ["Vardiya seçilmelidir."]
  }
}
```

**Flutter Handling:**
```dart
if (!result['success'] && result['errors'] != null) {
  final errors = result['errors'] as Map<String, dynamic>;
  errors.forEach((field, messages) {
    print('Field $field: ${messages.join(", ")}');
  });
}
```

---

### 4.3 Distributed Lock Errors

When two users edit the same record concurrently:

```json
{
  "success": false,
  "message": "Kaynak şu an başka bir kullanıcı tarafından düzenleniyor. Lütfen birkaç saniye sonra tekrar deneyin."
}
```

**Flutter:**
```dart
if (!result['success'] && result['message'].contains('kilitli')) {
  // Show retry dialog
  await Future.delayed(Duration(seconds: 2));
  // Retry request
}
```

---

## 5. File Upload

### 5.1 Photo Upload Process

1. **Select image** from gallery/camera
2. **Compress** if needed (max 5MB)
3. **Upload** via multipart/form-data
4. **Get relative path** in response
5. **Construct full URL** for display

**Flutter Example:**
```dart
// 1. Compress image
final compressedBytes = await FlutterImageCompress.compressWithList(
  imageBytes,
  minHeight: 1920,
  minWidth: 1080,
  quality: 85,
);

// 2. Upload
var request = http.MultipartRequest(
  'POST',
  Uri.parse('$baseUrl/api/firekayitformu/$id/photo'),
);
request.headers['Authorization'] = 'Bearer $token';
request.files.add(
  http.MultipartFile.fromBytes(
    'photo',
    compressedBytes,
    filename: 'photo.jpg',
    contentType: MediaType('image', 'jpeg'),
  ),
);

var response = await request.send();
var responseBody = await response.stream.bytesToString();
var result = jsonDecode(responseBody);

// 3. Construct URL
if (result['success']) {
  final relativePath = result['data'];
  final fullUrl = '$baseUrl/uploads/photos/$relativePath';
  // Display with CachedNetworkImage
}
```

---

### 5.2 Photo Display

**Using CachedNetworkImage:**
```dart
CachedNetworkImage(
  imageUrl: '$baseUrl/uploads/photos/${form.fotografYolu}',
  headers: {'Authorization': 'Bearer $token'},  // If needed
  placeholder: (context, url) => CircularProgressIndicator(),
  errorWidget: (context, url, error) => Icon(Icons.error),
)
```

**Cache Headers (Automatic):**
- `Cache-Control: max-age=86400` (1 day)
- Efficient CDN-like serving

---

## 6. Idempotency & Retries

### 6.1 Idempotency Keys

For commands (Create, Update), use idempotency keys to prevent duplicates:

**Flutter:**
```dart
final idempotencyKey = Uuid().v4();  // Generate once

// First request
final response1 = await createFireKayit({
  'idempotencyKey': idempotencyKey,
  'urunKodu': 'BRK-001',
  // ... other fields
});

// If timeout/network error, retry with SAME key
if (response1.timeout) {
  final response2 = await createFireKayit({
    'idempotencyKey': idempotencyKey,  // SAME KEY
    'urunKodu': 'BRK-001',
    // ... same data
  });
  // Backend returns original result (no duplicate)
}
```

**Backend Behavior:**
- First request: Creates record, caches response
- Retry with same key: Returns cached response (no duplicate creation)

---

### 6.2 Network Retry Strategy

**Exponential Backoff:**
```dart
Future<T> retryWithBackoff<T>(
  Future<T> Function() operation, {
  int maxRetries = 3,
}) async {
  for (int attempt = 0; attempt < maxRetries; attempt++) {
    try {
      return await operation();
    } catch (e) {
      if (attempt == maxRetries - 1) rethrow;
      await Future.delayed(
        Duration(milliseconds: 100 * (1 << attempt)),  // 100, 200, 400ms
      );
    }
  }
  throw Exception('Max retries exceeded');
}
```

---

## 7. Best Practices

### 7.1 Token Management

```dart
class AuthService {
  static const _tokenKey = 'auth_token';
  
  Future<void> saveToken(String token) async {
    final storage = FlutterSecureStorage();
    await storage.write(key: _tokenKey, value: token);
  }
  
  Future<String?> getToken() async {
    final storage = FlutterSecureStorage();
    return await storage.read(key: _tokenKey);
  }
  
  Future<bool> isTokenValid() async {
    final token = await getToken();
    if (token == null) return false;
    
    // Decode JWT and check expiration
    final parts = token.split('.');
    if (parts.length != 3) return false;
    
    final payload = json.decode(
      utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
    );
    
    final exp = payload['exp'] as int;
    return DateTime.now().millisecondsSinceEpoch < exp * 1000;
  }
}
```

---

### 7.2 Automatic Token Refresh

```dart
class ApiClient {
  Future<http.Response> _makeRequest(
    Future<http.Response> Function() request,
  ) async {
    var response = await request();
    
    if (response.statusCode == 401) {
      // Token expired, try to refresh
      await refreshToken();
      response = await request();  // Retry
    }
    
    return response;
  }
}
```

---

### 7.3 Offline Support

```dart
// Queue operations when offline
class OfflineQueue {
  Future<void> addOperation(Map<String, dynamic> operation) async {
    final box = await Hive.openBox('offline_queue');
    await box.add(operation);
  }
  
  Future<void> syncWhenOnline() async {
    final box = await Hive.openBox('offline_queue');
    for (var operation in box.values) {
      try {
        await executeOperation(operation);
        await box.delete(operation.key);
      } catch (e) {
        // Keep in queue, retry later
      }
    }
  }
}
```

---

**Version:** 1.0  
**Last Updated:** 2026-01-27  
**Maintained By:** Backend Team
