# Backend - Frontend İletişim Dokümanı (endpoint.md)

Bu doküman, QualityApp projesi için backend ve frontend arasındaki her türlü veri alışverişini, endpoint yapılarını, request/response modellerini ve kullanım amaçlarını detaylandırmak için hazırlanmıştır.

## Genel Kurallar
- **Base URL**: `/api/v1`
- **Format**: JSON (`Content-Type: application/json`)
- **Dosya Yükleme**: `multipart/form-data`
- **Authentication**: Tüm isteklerde (Login hariç) Header'da `Authorization: Bearer <token>` taşınmalıdır.
- **Tarih Formatı**: ISO 8601 (`YYYY-MM-DDTHH:mm:ss.sssZ`)

---

## 1. Kimlik Doğrulama (Authentication)

### 1.1. Kullanıcı Girişi
**Endpoint:** `POST /auth/login`

**Amaç:** Kullanıcının sisteme giriş yapmasını sağlamak ve erişim token'ı (JWT) oluşturmak.

**Request Body:**
```json
{
  "username": "furkan",
  "password": "secretparams_password"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "accessToken": "eyJhGci...",
    "refreshToken": "dGg5y...",
    "user": {
      "id": "u123",
      "username": "furkan",
      "fullName": "Furkan Yılmaz",
      "role": "operator" // veya "admin"
    }
  }
}
```

### 1.2. Token Yenileme
**Endpoint:** `POST /auth/refresh`

**Amaç:** Süresi dolan access token yerine refresh token kullanarak yeni bir token almak. Kullanıcıyı oturumdan atmadan sürekliliği sağlar.

**Request Body:**
```json
{
  "refreshToken": "dGg5y..."
}
```

---

## 2. Form İşlemleri (Quality Forms)

Bu endpointler sahadaki operatörlerin veri girişi yaptığı formlar içindir.

### 2.1. Kalite Onay Formu Kaydı
**Endpoint:** `POST /forms/quality-approval`

**Amaç:** Üretimden çıkan parçaların anlık kalite onay durumunu (Uygun/Ret) kaydetmek.

**Request Body:**
```json
{
  "productCode": "6312011",      // Ürün Kodu
  "productName": "SAF B9",       // Ürün Adı
  "productType": "Dövme",        // Ürün Türü
  "amount": 100,                 // Kontrol edilen adet
  "complianceStatus": "RET",     // 'Uygun' veya 'RET'
  "rejectCode": "Hata 001",      // Eğer RET ise hata kodu, yoksa null
  "description": "Yüzeyde çizikler mevcut", // Opsiyonel açıklama
  "operatorId": "u123"           // İşlemi yapan operatör ID'si
}
```

### 2.2. Numune / Deneme Formu Kaydı
**Endpoint:** `POST /forms/sample`
**Content-Type:** `multipart/form-data` (Görsel içerdiği için)

**Amaç:** Yeni ürün denemeleri veya numune kontrollerinin sonuçlarını ve fotoğraflarını kaydetmek.

**Form Data Parameters:**
- `productCode`: "6312011"
- `quantity`: 5
- `batchNo`: "26F025A" (Yıl-Dökümhane-Gün-Hat formatında şarj no)
- `title`: "Yeni Kalıp Denemesi"
- `generalResult`: "Ölçüler uygun"
- `operatorId`: "u123"
- `images`: [binary_file_1, binary_file_2] (Çoklu dosya gönderimi)

**Gerekçe:** Görsel kanıtlar numune süreçlerinde kritiktir, bu yüzden multipart yapı kullanılmıştır.

### 2.3. Fire Kayıt Formu
**Endpoint:** `POST /forms/wastage`
**Content-Type:** `multipart/form-data`

**Amaç:** Üretim sırasında oluşan hurda/fire ürünlerin kaydını tutmak ve nedenlerini analiz etmek.

**Form Data Parameters:**
- `productCode`: "6312011"
- `productName`: "SAF B9"
- `productType`: "Dövme"
- `quantity`: 2
- `machine`: "CNC-A"           // Hatanın oluştuğu tezgah
- `zone`: "Z2 (İşleme)"        // Hatanın oluştuğu bölge
- `productState`: "İşlenmiş"   // 'Ham' veya 'İşlenmiş'
- `batchNo`: "26F025A"
- `errorReason`: "Yüzey Kalitesi" // Seçilen hata nedeni
- `description`: "Derin çizikler var"
- `operatorId`: "u123"
- `image`: binary_file (Opsiyonel tek fotoğraf)

### 2.4. Giriş Kalite Kontrol Kaydı
**Endpoint:** `POST /forms/incoming-quality`

**Amaç:** Tedarikçiden gelen hammaddelerin kabul/ret durumlarını ve irsaliye bilgilerini kaydetmek.

**Request Body:**
```json
{
  "supplier": "Metal A.Ş.",
  "invoiceNo": "IRS-2026-001",
  "productCode": "HM-101",
  "productName": "Çelik Bar",
  "productType": "Hammadde",
  "quantity": 5000,
  "batchNo": "26F025A",
  "status": "Şartlı Kabul", // 'Kabul', 'Red', 'Şartlı Kabul'
  "operatorId": "u123",
  "description": "Yüzeyde hafif paslanma var ama üretime uygun"
}
```

### 2.5. Rework (Tamir) Kaydı
**Endpoint:** `POST /forms/rework`

**Amaç:** Hatalı ürünlerin tamir edilip edilmediğinin takibini yapmak.

**Request Body:**
```json
{
  "productCode": "6312011",
  "quantity": 10,
  "batchNo": "26F025A",
  "errorReason": "Çapak",
  "result": "Tamir Edildi", // 'Tamir Edildi', 'Hurda', 'İade', 'Beklemede'
  "description": "Zımpara ile giderildi",
  "operatorId": "u123"
}
```

---

## 3. Üretim Takibi (Production Tracking)

### 3.1. Üretim Loglarını Senkronize Et (Batch Sync)
**Endpoint:** `POST /production/sync-logs`

**Amaç:** SAF B9 gibi sayaçlı ekranlarda operatörün yaptığı "Düzce Ekle", "Hurda Ekle" gibi işlemlerin loglarını sunucuya göndermek.

**Request Body:**
```json
{
  "machineId": "Tezgah 1",
  "logs": [
    {
      "timestamp": "2026-02-01T14:30:00Z",
      "actionType": "duzce",      // 'duzce', 'almanya', 'hurda', 'rework'
      "quantity": 5,
      "scrapReason": null,        // Sadece hurda ise dolu
      "operatorId": "u123",
      "productCode": "6312011"
    },
    {
      "timestamp": "2026-02-01T14:35:00Z",
      "actionType": "hurda",
      "quantity": 1,
      "scrapReason": "Boyut Hatası",
      "operatorId": "u123",
      "productCode": "6312011"
    }
  ]
}
```

**Gerekçe:** Operatör internet bağlantısı olmadan da çalışabilir veya her tıkta istek atmak yerine işlem sonunda toplu gönderim (batch) sunucu yükünü azaltır.

---

## 4. Ortak Veriler (Master Data)

Frontend'deki dropdown'ları doldurmak için gereken veriler.

### 4.1. Hata Kodlarını Getir
**Endpoint:** `GET /master-data/reject-codes`
**Response:** `["Hata 001 - Boyut Hatası", "Hata 002 - Yüzey Hatası", ...]`

### 4.2. Tezgah Listesini Getir
**Endpoint:** `GET /master-data/machines`
**Response:** `["CNC-A", "CNC-B", "M21", ...]`

---

## Özet
Bu doküman, mobil uygulamanın sorunsuz çalışması için gereken temel iletişim noktalarını belirler. Backend geliştiricisi bu kontrata (contract) sadık kalarak API'yi geliştirmeli, frontend geliştiricisi de bu endpointlere uygun istekleri atmalıdır.
