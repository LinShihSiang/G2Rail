# DodoMan Landing Page 產品需求文件 (PRD)

## 1. 專案概述

### 1.1 產品願景
DodoMan Landing Page 是推廣旅遊 App 的核心入口，透過精美的視覺設計和流暢的用戶體驗，引導潛在用戶下載並使用 DodoMan 旅遊應用程式。

### 1.2 核心價值主張
- **獨特體驗**: 精心策劃的旅遊體驗，深度體驗當地文化
- **專業導遊**: 經驗豐富的在地導遊服務
- **即時預訂**: 透過 App 隨時隨地預訂行程

### 1.3 目標用戶群體
- 主要：25-45歲熱愛旅遊的用戶
- 次要：企業差旅用戶
- 地理範圍：主要服務歐洲旅遊市場

### 1.4 商業目標
- 增加 App 下載量
- 提升品牌知名度
- 促進預訂轉換率

## 2. Sprint 需求映射

### Sprint 1: 新天鵝堡德國門票預訂
**目標**: 啟用透過 App 進行信用卡付款預訂功能

#### 2.1 Landing Page 需求
- **預訂按鈕啟用**: 取消當前註解的預訂按鈕 (`index.html:98, 109`)
- **深度連結整合**: 實現從 Landing Page 到 App 特定產品頁面的深度連結
- **價格顯示**: 新天鵝堡門票價格展示 (目前顯示 €21 起)
- **庫存狀態**: 即時顯示門票可用性

#### 2.2 技術實作需求
```javascript
// 新增預訂功能
handleTicketBooking(ticketType, price) {
    // 檢查 App 是否已安裝
    // 如已安裝：打開 App 特定頁面
    // 如未安裝：引導下載並保存預訂意圖
}
```

### Sprint 2: 德國點對點火車票
**目標**: 在 Landing Page 新增車站搜尋功能

#### 2.1 新增功能區塊
- **車站搜尋區塊**: 在熱門目的地後新增搜尋功能
- **熱門路線展示**: 展示熱門火車路線 (如 Munich-Berlin)
- **即時價格**: 顯示點對點票價

#### 2.2 UI/UX 設計
```html
<!-- 新增車站搜尋區塊 -->
<section class="train-search" id="train-tickets">
    <div class="container">
        <h2 class="section-title">德國火車票搜尋</h2>
        <div class="search-form">
            <div class="station-input">
                <label>出發站</label>
                <input type="text" id="departure" placeholder="輸入出發站">
            </div>
            <div class="station-input">
                <label>到達站</label>
                <input type="text" id="arrival" placeholder="輸入到達站">
            </div>
            <button class="search-btn" id="searchTrains">搜尋班次</button>
        </div>
    </div>
</section>
```

### Sprint 3: 旅程套票組合
**目標**: 推廣新天鵝堡套票和組合產品

#### 2.3 套票展示區塊
- **套票卡片**: 新天鵝堡城堡套票展示
- **組合優惠**: 城堡門票 + 火車票組合
- **價格比較**: 單獨購買 vs 套票價格對比

## 3. 功能需求 (Functional Requirements)

### 3.1 預訂系統整合

#### 3.1.1 當前問題修復
- **修復註解的預訂按鈕**
  - 檔案位置: `index.html:98, 109`
  - 需要啟用並連結到實際預訂流程

#### 3.1.2 預訂流程
1. 用戶點擊「立即預訂」
2. 檢測是否安裝 DodoMan App
3. 已安裝：打開 App 對應產品頁面
4. 未安裝：顯示 App 下載彈窗，保存預訂意圖

### 3.2 信用卡支付流程

#### 3.2.1 支付整合
```javascript
// 支付流程整合
class PaymentHandler {
    constructor() {
        this.supportedCards = ['visa', 'mastercard', 'amex'];
        this.securePaymentGateway = 'stripe'; // 建議使用
    }

    processPayment(bookingData) {
        // 處理支付邏輯
        // 整合信用卡驗證
        // 確保 PCI DSS 合規
    }
}
```

#### 3.2.2 安全要求
- SSL/TLS 加密傳輸
- PCI DSS 合規性
- 敏感資料不在前端儲存

### 3.3 App 下載與安裝流程

#### 3.3.1 當前問題修復
- **啟用 iOS 下載按鈕**: `index.html:130-133` (目前被註解)
- **更新 App Store 連結**: 更新 `script.js:9-10` 中的假 URL

#### 3.3.2 智能下載策略
```javascript
// 改進 AppManager 類別
class AppManager {
    // 新增功能
    detectPlatformAndRedirect() {
        // 優化平台檢測
        // 支援 PWA 安裝
        // 處理 App 已安裝情況
    }

    handleDeepLink(productId, bookingData) {
        // 實現深度連結
        // 保存預訂上下文
    }
}
```

### 3.4 搜尋功能

#### 3.4.1 車站搜尋 (Sprint 2)
- 自動完成功能
- 熱門車站建議
- 即時驗證車站名稱

#### 3.4.2 搜尋 API 整合
```javascript
// 車站搜尋 API
class StationSearch {
    async searchStations(query) {
        // 整合德國鐵路車站 API
        // 返回車站列表和代碼
        // 支援模糊搜尋
    }

    async getPricing(departure, arrival, date) {
        // 獲取票價資訊
        // 即時庫存檢查
    }
}
```

## 4. 技術需求 (Technical Requirements)

### 4.1 當前程式碼結構分析

#### 4.1.1 現有檔案結構
```
Web/
├── index.html          # 主頁面 (完整，需修復預訂按鈕)
├── styles.css          # CSS 樣式 (響應式設計完備)
├── script.js           # JavaScript 邏輯 (App 檢測完整)
├── Reference/
│   └── tours.json      # 旅遊數據 (991KB，豐富資源)
└── Specs/
    └── Sprint Items.txt # 開發規劃
```

#### 4.1.2 程式碼品質評估
- **HTML**: 語意化標籤使用良好，結構清晰
- **CSS**: 現代化設計，響應式布局完整
- **JavaScript**: ES6+ 語法，模組化設計良好

### 4.2 響應式設計規格

#### 4.2.1 斷點定義
```css
/* 當前支援的斷點 */
@media (max-width: 768px) {
    /* Mobile 優化 */
}

@media (min-width: 769px) and (max-width: 1024px) {
    /* Tablet 優化 */
}

@media (min-width: 1025px) {
    /* Desktop 優化 */
}
```

#### 4.2.2 需要新增的響應式功能
- 搜尋表單在移動端的最佳化
- 套票卡片的彈性布局
- 觸控友善的互動元素

### 4.3 性能要求

#### 4.3.1 載入性能目標
- **First Contentful Paint**: < 2 秒
- **Largest Contentful Paint**: < 3 秒
- **Cumulative Layout Shift**: < 0.1

#### 4.3.2 最佳化策略
```javascript
// 圖片懶載入
class ImageOptimizer {
    static lazyLoad() {
        // 實現圖片懶載入
        // 支援 WebP 格式
        // 響應式圖片尺寸
    }
}

// API 快取策略
class CacheManager {
    static cacheStrategy = {
        stations: 'localStorage', // 車站資料快取 24小時
        pricing: 'sessionStorage', // 價格快取 1小時
        images: 'browser-cache'    // 圖片快取 7天
    };
}
```

### 4.4 瀏覽器支援

#### 4.4.1 支援範圍
- **桌面**: Chrome 90+, Firefox 88+, Safari 14+, Edge 90+
- **移動**: iOS Safari 14+, Chrome Mobile 90+, Samsung Internet 14+

#### 4.4.2 Polyfill 需求
```javascript
// 必要的 Polyfill
if (!window.IntersectionObserver) {
    // 載入 Intersection Observer polyfill
}

if (!CSS.supports('backdrop-filter', 'blur(10px)')) {
    // 提供 backdrop-filter 降級方案
}
```

### 4.5 API 整合規格

#### 4.5.1 所需 API 端點
```
# 票務 API
POST /api/v1/bookings          # 建立預訂
GET  /api/v1/tickets/{id}      # 取得票券詳情
GET  /api/v1/availability      # 檢查庫存

# 車站搜尋 API
GET  /api/v1/stations/search   # 車站搜尋
GET  /api/v1/routes/pricing    # 路線定價

# 套票 API
GET  /api/v1/bundles           # 取得套票選項
POST /api/v1/bundles/booking   # 套票預訂
```

#### 4.5.2 API 回應格式
```json
{
    "success": true,
    "data": {
        "id": "ticket_123",
        "type": "neuschwanstein_castle",
        "price": {
            "amount": 21.00,
            "currency": "EUR"
        },
        "availability": {
            "status": "available",
            "remaining": 150
        }
    },
    "meta": {
        "timestamp": "2024-09-14T12:30:00Z",
        "request_id": "req_abc123"
    }
}
```

### 4.6 安全性要求

#### 4.6.1 資料保護
- 所有 API 請求透過 HTTPS
- 敏感資料不儲存在 localStorage
- CSP (Content Security Policy) 設定

#### 4.6.2 程式碼安全
```javascript
// XSS 防護
function sanitizeInput(input) {
    return DOMPurify.sanitize(input);
}

// CSRF 保護
const csrfToken = document.querySelector('meta[name="csrf-token"]').content;
```

## 5. 用戶體驗需求 (UX Requirements)

### 5.1 用戶旅程設計

#### 5.1.1 主要用戶流程
1. **發現階段**
   - 用戶透過搜尋引擎或廣告到達
   - Hero 區塊吸引注意力
   - 清楚的價值主張展示

2. **探索階段**
   - 瀏覽熱門目的地
   - 了解服務特色
   - 查看價格資訊

3. **決策階段**
   - 比較不同選項
   - 閱讀詳細資訊
   - 查看用戶評價 (統計數據)

4. **行動階段**
   - 點擊預訂或下載 App
   - 完成預訂流程
   - 確認預訂成功

#### 5.1.2 用戶痛點解決方案
- **複雜的預訂流程**: 簡化為一鍵預訂
- **價格不透明**: 清楚顯示所有費用
- **語言障礙**: 提供繁體中文介面

### 5.2 互動設計規範

#### 5.2.1 按鈕設計標準
```css
/* 主要行動按鈕 (CTA) */
.btn-primary {
    background: #2563eb;
    color: white;
    padding: 12px 24px;
    border-radius: 8px;
    font-weight: 600;
    transition: all 0.3s ease;
    min-height: 44px; /* 觸控友善尺寸 */
}

.btn-primary:hover {
    background: #1d4ed8;
    transform: translateY(-2px);
    box-shadow: 0 4px 12px rgba(37, 99, 235, 0.3);
}

/* 次要按鈕 */
.btn-secondary {
    background: transparent;
    color: #2563eb;
    border: 2px solid #2563eb;
    /* 其他樣式... */
}
```

#### 5.2.2 載入狀態設計
```javascript
// 載入狀態管理
class LoadingStateManager {
    static showLoading(element) {
        element.innerHTML = '<span class="loading-spinner"></span>載入中...';
        element.disabled = true;
    }

    static hideLoading(element, originalText) {
        element.innerHTML = originalText;
        element.disabled = false;
    }
}
```

### 5.3 無障礙設計

#### 5.3.1 WCAG 2.1 AA 合規
- **色彩對比**: 至少 4.5:1 比例
- **鍵盤導航**: 所有互動元素可用 Tab 鍵存取
- **螢幕閱讀器**: 適當的 ARIA 標籤

#### 5.3.2 無障礙改進
```html
<!-- 改進的按鈕標籤 -->
<button class="cta-primary"
        id="heroDownloadBtn"
        aria-label="下載 DodoMan 應用程式，開始您的旅遊體驗">
    立即下載 App
</button>

<!-- 圖片替代文字 -->
<img src="neuschwanstein.jpg"
     alt="德國新天鵝堡，一座位於巴伐利亞阿爾卑斯山的童話城堡" />
```

### 5.4 多語言支援 (未來版本)

#### 5.4.1 語言切換機制
```javascript
// 語言管理系統
class LanguageManager {
    static supportedLanguages = ['zh-TW', 'en', 'de', 'ja'];

    static switchLanguage(lang) {
        // 更新所有文字內容
        // 保存用戶語言偏好
        // 更新 URL 路由
    }
}
```

## 6. 實作細節

### 6.1 當前程式碼狀態分析

#### 6.1.1 需要修復的問題清單

| 問題 | 檔案位置 | 優先級 | 描述 |
|------|----------|--------|------|
| 預訂按鈕被註解 | `index.html:98, 109` | 高 | 無法實際預訂 |
| iOS 下載按鈕被註解 | `index.html:130-133` | 高 | 只有 Android 下載 |
| App Store URL 假的 | `script.js:9-10` | 高 | 需要真實商店連結 |
| 社群連結為 # | `index.html:185-189` | 中 | 無法連結社群媒體 |
| tours.json 未使用 | `Reference/tours.json` | 中 | 豐富資料未展示 |

#### 6.1.2 修復計劃

**階段 1: 核心功能修復**
```html
<!-- 取消註解並修復預訂按鈕 -->
<a href="#" class="gallery-cta primary" onclick="handleBooking('neuschwanstein')">
    立即預訂
</a>

<!-- 啟用 iOS 下載 -->
<a href="https://apps.apple.com/app/dodoman/id[REAL_ID]"
   class="download-btn ios" id="iosDownload">
    <img src="https://developer.apple.com/assets/elements/badges/download-on-the-app-store.svg"
         alt="Download on App Store" />
</a>
```

**階段 2: JavaScript 功能增強**
```javascript
// 新增預訂處理功能
function handleBooking(productType) {
    const appManager = new AppManager();

    // 嘗試打開 App
    const appOpened = appManager.tryOpenApp(`dodoman://booking/${productType}`);

    if (!appOpened) {
        // 顯示下載提示
        showAppDownloadModal(productType);
    }
}

// 保存預訂意圖
function saveBookingIntent(productType, productData) {
    localStorage.setItem('pendingBooking', JSON.stringify({
        type: productType,
        data: productData,
        timestamp: Date.now()
    }));
}
```

### 6.2 新功能開發規格

#### 6.2.1 車站搜尋功能 (Sprint 2)

**HTML 結構**
```html
<section class="train-search" id="train-booking">
    <div class="container">
        <h2 class="section-title">德國火車票預訂</h2>
        <div class="search-widget">
            <div class="route-selector">
                <div class="station-input-group">
                    <label for="departure-station">出發站</label>
                    <input type="text"
                           id="departure-station"
                           placeholder="例：München Hbf"
                           autocomplete="off"
                           role="combobox"
                           aria-expanded="false">
                    <ul class="station-suggestions" role="listbox"></ul>
                </div>

                <button class="swap-stations" aria-label="交換出發站與到達站">
                    ⇄
                </button>

                <div class="station-input-group">
                    <label for="arrival-station">到達站</label>
                    <input type="text"
                           id="arrival-station"
                           placeholder="例：Berlin Hbf"
                           autocomplete="off"
                           role="combobox"
                           aria-expanded="false">
                    <ul class="station-suggestions" role="listbox"></ul>
                </div>
            </div>

            <div class="travel-date">
                <label for="travel-date">出發日期</label>
                <input type="date"
                       id="travel-date"
                       min="2024-09-14"
                       value="2024-09-15">
            </div>

            <button class="search-trains-btn" id="searchTrainsBtn">
                <span class="btn-text">搜尋班次</span>
                <span class="btn-loading hidden">
                    <span class="spinner"></span>搜尋中...
                </span>
            </button>
        </div>

        <div class="popular-routes">
            <h3>熱門路線</h3>
            <div class="route-cards">
                <div class="route-card" data-route="munich-berlin">
                    <div class="route-info">
                        <span class="route-name">慕尼黑 ⇄ 柏林</span>
                        <span class="route-duration">4小時 30分鐘</span>
                    </div>
                    <div class="route-price">€39 起</div>
                </div>
                <div class="route-card" data-route="frankfurt-munich">
                    <div class="route-info">
                        <span class="route-name">法蘭克福 ⇄ 慕尼黑</span>
                        <span class="route-duration">3小時 45分鐘</span>
                    </div>
                    <div class="route-price">€29 起</div>
                </div>
                <div class="route-card" data-route="berlin-hamburg">
                    <div class="route-info">
                        <span class="route-name">柏林 ⇄ 漢堡</span>
                        <span class="route-duration">2小時 15分鐘</span>
                    </div>
                    <div class="route-price">€19 起</div>
                </div>
            </div>
        </div>
    </div>
</section>
```

**CSS 樣式**
```css
/* 火車搜尋區塊樣式 */
.train-search {
    padding: 80px 0;
    background: linear-gradient(135deg, #f8fafc 0%, #e2e8f0 100%);
}

.search-widget {
    background: white;
    padding: 40px;
    border-radius: 20px;
    box-shadow: 0 10px 40px rgba(0, 0, 0, 0.1);
    margin-bottom: 40px;
}

.route-selector {
    display: grid;
    grid-template-columns: 1fr auto 1fr;
    gap: 20px;
    align-items: end;
    margin-bottom: 30px;
}

.station-input-group {
    position: relative;
}

.station-input-group label {
    display: block;
    margin-bottom: 8px;
    font-weight: 600;
    color: #374151;
}

.station-input-group input {
    width: 100%;
    padding: 16px;
    border: 2px solid #e5e7eb;
    border-radius: 12px;
    font-size: 16px;
    transition: all 0.3s ease;
}

.station-input-group input:focus {
    border-color: #2563eb;
    outline: none;
    box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.1);
}

.station-suggestions {
    position: absolute;
    top: 100%;
    left: 0;
    right: 0;
    background: white;
    border: 1px solid #e5e7eb;
    border-radius: 8px;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
    max-height: 200px;
    overflow-y: auto;
    z-index: 100;
    display: none;
}

.station-suggestions.show {
    display: block;
}

.station-suggestion {
    padding: 12px 16px;
    cursor: pointer;
    border-bottom: 1px solid #f3f4f6;
}

.station-suggestion:hover,
.station-suggestion.highlighted {
    background: #f8fafc;
}

.swap-stations {
    background: #f3f4f6;
    border: none;
    width: 40px;
    height: 40px;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    cursor: pointer;
    font-size: 18px;
    transition: all 0.3s ease;
}

.swap-stations:hover {
    background: #e5e7eb;
    transform: rotate(180deg);
}

.travel-date {
    grid-column: 1 / -1;
    max-width: 200px;
}

.search-trains-btn {
    background: #2563eb;
    color: white;
    border: none;
    padding: 16px 32px;
    border-radius: 12px;
    font-size: 18px;
    font-weight: 600;
    cursor: pointer;
    transition: all 0.3s ease;
    position: relative;
    overflow: hidden;
}

.search-trains-btn:hover {
    background: #1d4ed8;
    transform: translateY(-2px);
}

.btn-loading {
    display: flex;
    align-items: center;
    gap: 8px;
}

.spinner {
    width: 16px;
    height: 16px;
    border: 2px solid transparent;
    border-top: 2px solid white;
    border-radius: 50%;
    animation: spin 1s linear infinite;
}

/* 熱門路線卡片 */
.popular-routes h3 {
    margin-bottom: 20px;
    color: #374151;
}

.route-cards {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
    gap: 20px;
}

.route-card {
    background: white;
    padding: 24px;
    border-radius: 16px;
    border: 2px solid #f3f4f6;
    cursor: pointer;
    transition: all 0.3s ease;
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.route-card:hover {
    border-color: #2563eb;
    transform: translateY(-4px);
    box-shadow: 0 8px 32px rgba(37, 99, 235, 0.15);
}

.route-name {
    font-weight: 600;
    font-size: 16px;
    color: #111827;
}

.route-duration {
    font-size: 14px;
    color: #6b7280;
}

.route-price {
    font-size: 18px;
    font-weight: 700;
    color: #2563eb;
}

/* 響應式設計 */
@media (max-width: 768px) {
    .route-selector {
        grid-template-columns: 1fr;
        gap: 20px;
    }

    .swap-stations {
        justify-self: center;
        transform: rotate(90deg);
    }

    .search-widget {
        padding: 24px;
    }

    .route-cards {
        grid-template-columns: 1fr;
    }
}
```

**JavaScript 功能**
```javascript
// 火車搜尋功能類別
class TrainSearchManager {
    constructor() {
        this.germanStations = [
            { name: 'Berlin Hauptbahnhof', code: 'BEHE', city: 'Berlin' },
            { name: 'München Hauptbahnhof', code: 'MUHE', city: 'Munich' },
            { name: 'Frankfurt (Main) Hbf', code: 'FHBF', city: 'Frankfurt' },
            { name: 'Hamburg Hauptbahnhof', code: 'HAHE', city: 'Hamburg' },
            { name: 'Köln Hauptbahnhof', code: 'KOHE', city: 'Cologne' },
            { name: 'Stuttgart Hauptbahnhof', code: 'STHE', city: 'Stuttgart' },
            { name: 'Düsseldorf Hauptbahnhof', code: 'DUHE', city: 'Düsseldorf' },
            { name: 'Leipzig Hauptbahnhof', code: 'LEHE', city: 'Leipzig' },
            { name: 'Dresden Hauptbahnhof', code: 'DRHE', city: 'Dresden' },
            { name: 'Hannover Hauptbahnhof', code: 'HAHE', city: 'Hannover' }
        ];

        this.popularRoutes = {
            'munich-berlin': { from: 'MUHE', to: 'BEHE', price: 39 },
            'frankfurt-munich': { from: 'FHBF', to: 'MUHE', price: 29 },
            'berlin-hamburg': { from: 'BEHE', to: 'HAHE', price: 19 }
        };

        this.init();
    }

    init() {
        this.setupEventListeners();
        this.initializeAutocomplete();
        this.setupRouteCards();
    }

    setupEventListeners() {
        // 搜尋按鈕
        document.getElementById('searchTrainsBtn').addEventListener('click',
            (e) => this.handleSearch(e));

        // 交換車站按鈕
        document.querySelector('.swap-stations').addEventListener('click',
            () => this.swapStations());

        // 熱門路線卡片
        document.querySelectorAll('.route-card').forEach(card => {
            card.addEventListener('click', (e) => this.selectRoute(e));
        });
    }

    initializeAutocomplete() {
        const departureInput = document.getElementById('departure-station');
        const arrivalInput = document.getElementById('arrival-station');

        [departureInput, arrivalInput].forEach(input => {
            input.addEventListener('input', (e) => this.handleStationInput(e));
            input.addEventListener('keydown', (e) => this.handleKeyboardNavigation(e));
            input.addEventListener('blur', (e) => this.hideSuggestions(e));
        });
    }

    handleStationInput(event) {
        const input = event.target;
        const query = input.value.toLowerCase();

        if (query.length < 2) {
            this.hideSuggestions(event);
            return;
        }

        const suggestions = this.germanStations.filter(station =>
            station.name.toLowerCase().includes(query) ||
            station.city.toLowerCase().includes(query)
        );

        this.showSuggestions(input, suggestions);
    }

    showSuggestions(input, suggestions) {
        const suggestionsContainer = input.nextElementSibling;
        suggestionsContainer.innerHTML = '';

        suggestions.forEach((station, index) => {
            const li = document.createElement('li');
            li.className = 'station-suggestion';
            li.textContent = `${station.name} (${station.city})`;
            li.addEventListener('mousedown', () => {
                input.value = station.name;
                this.hideSuggestions({ target: input });
            });

            suggestionsContainer.appendChild(li);
        });

        suggestionsContainer.classList.add('show');
        input.setAttribute('aria-expanded', 'true');
    }

    hideSuggestions(event) {
        setTimeout(() => {
            const suggestionsContainer = event.target.nextElementSibling;
            suggestionsContainer.classList.remove('show');
            event.target.setAttribute('aria-expanded', 'false');
        }, 150);
    }

    handleKeyboardNavigation(event) {
        const suggestions = event.target.nextElementSibling;
        const highlighted = suggestions.querySelector('.highlighted');

        switch (event.key) {
            case 'ArrowDown':
                event.preventDefault();
                if (highlighted) {
                    highlighted.classList.remove('highlighted');
                    const next = highlighted.nextElementSibling;
                    if (next) next.classList.add('highlighted');
                } else {
                    const first = suggestions.querySelector('.station-suggestion');
                    if (first) first.classList.add('highlighted');
                }
                break;

            case 'ArrowUp':
                event.preventDefault();
                if (highlighted) {
                    highlighted.classList.remove('highlighted');
                    const prev = highlighted.previousElementSibling;
                    if (prev) prev.classList.add('highlighted');
                }
                break;

            case 'Enter':
                if (highlighted) {
                    event.preventDefault();
                    event.target.value = highlighted.textContent.split(' (')[0];
                    this.hideSuggestions(event);
                }
                break;

            case 'Escape':
                this.hideSuggestions(event);
                break;
        }
    }

    swapStations() {
        const departureInput = document.getElementById('departure-station');
        const arrivalInput = document.getElementById('arrival-station');

        const temp = departureInput.value;
        departureInput.value = arrivalInput.value;
        arrivalInput.value = temp;

        // 視覺回饋
        const swapBtn = document.querySelector('.swap-stations');
        swapBtn.style.transform = 'rotate(180deg) scale(1.1)';
        setTimeout(() => {
            swapBtn.style.transform = '';
        }, 300);
    }

    selectRoute(event) {
        const routeCard = event.currentTarget;
        const routeId = routeCard.dataset.route;
        const route = this.popularRoutes[routeId];

        if (route) {
            // 填入車站資訊
            const departureStation = this.germanStations.find(s => s.code === route.from);
            const arrivalStation = this.germanStations.find(s => s.code === route.to);

            document.getElementById('departure-station').value = departureStation.name;
            document.getElementById('arrival-station').value = arrivalStation.name;

            // 視覺回饋
            routeCard.style.transform = 'scale(1.02)';
            setTimeout(() => {
                routeCard.style.transform = '';
            }, 200);

            // 滾動到搜尋表單
            document.querySelector('.search-widget').scrollIntoView({
                behavior: 'smooth'
            });
        }
    }

    async handleSearch(event) {
        const button = event.target;
        const departure = document.getElementById('departure-station').value;
        const arrival = document.getElementById('arrival-station').value;
        const travelDate = document.getElementById('travel-date').value;

        // 驗證輸入
        if (!departure || !arrival) {
            this.showError('請選擇出發站和到達站');
            return;
        }

        if (!travelDate) {
            this.showError('請選擇出發日期');
            return;
        }

        // 顯示載入狀態
        this.setLoadingState(button, true);

        try {
            // 模擬 API 呼叫
            await this.searchTrains(departure, arrival, travelDate);

            // 引導用戶到 App
            this.redirectToApp('train-booking', {
                from: departure,
                to: arrival,
                date: travelDate
            });

        } catch (error) {
            this.showError('搜尋失敗，請稍後再試');
            console.error('Train search error:', error);
        } finally {
            this.setLoadingState(button, false);
        }
    }

    async searchTrains(departure, arrival, date) {
        // 模擬 API 延遲
        return new Promise((resolve) => {
            setTimeout(() => {
                resolve({
                    routes: [
                        {
                            departure: departure,
                            arrival: arrival,
                            date: date,
                            duration: '4h 30m',
                            price: 39
                        }
                    ]
                });
            }, 2000);
        });
    }

    redirectToApp(feature, params) {
        const appManager = new AppManager();
        const deepLink = `dodoman://trains?${new URLSearchParams(params)}`;

        const appOpened = appManager.tryOpenApp(deepLink);

        if (!appOpened) {
            // 保存搜尋參數
            localStorage.setItem('pendingTrainSearch', JSON.stringify(params));

            // 顯示 App 下載提示
            this.showAppDownloadModal();
        }
    }

    setLoadingState(button, isLoading) {
        const btnText = button.querySelector('.btn-text');
        const btnLoading = button.querySelector('.btn-loading');

        if (isLoading) {
            btnText.classList.add('hidden');
            btnLoading.classList.remove('hidden');
            button.disabled = true;
        } else {
            btnText.classList.remove('hidden');
            btnLoading.classList.add('hidden');
            button.disabled = false;
        }
    }

    showError(message) {
        // 創建錯誤提示
        const errorDiv = document.createElement('div');
        errorDiv.className = 'error-message';
        errorDiv.textContent = message;
        errorDiv.style.cssText = `
            position: fixed;
            top: 20px;
            right: 20px;
            background: #dc2626;
            color: white;
            padding: 12px 20px;
            border-radius: 8px;
            z-index: 1000;
            animation: slideInRight 0.3s ease;
        `;

        document.body.appendChild(errorDiv);

        // 3秒後自動移除
        setTimeout(() => {
            errorDiv.remove();
        }, 3000);
    }

    showAppDownloadModal() {
        // 顯示專門的 App 下載彈窗
        const modal = document.getElementById('appModal');
        modal.style.display = 'flex';

        // 更新彈窗內容
        const modalContent = modal.querySelector('.modal-content');
        modalContent.innerHTML = `
            <span class="modal-close" onclick="this.closest('.modal').style.display='none'">&times;</span>
            <h3>下載 DodoMan App 完成預訂</h3>
            <p>我們已為您保存搜尋條件，下載 App 後即可完成火車票預訂</p>
            <div class="modal-buttons">
                <button class="modal-btn ios" onclick="window.open('${this.getAppStoreURL()}')">
                    iOS App Store
                </button>
                <button class="modal-btn android" onclick="window.open('${this.getPlayStoreURL()}')">
                    Google Play
                </button>
            </div>
        `;
    }

    getAppStoreURL() {
        return 'https://apps.apple.com/app/dodoman/id123456789'; // 實際 URL
    }

    getPlayStoreURL() {
        return 'https://play.google.com/store/apps/details?id=com.dodoman.app'; // 實際 URL
    }
}

// 初始化火車搜尋功能
document.addEventListener('DOMContentLoaded', () => {
    const trainSearch = new TrainSearchManager();
});
```

#### 6.2.2 套票功能 (Sprint 3)

**HTML 結構**
```html
<section class="bundle-packages" id="packages">
    <div class="container">
        <h2 class="section-title">旅程套票組合</h2>
        <p class="section-subtitle">組合購買享受更多優惠</p>

        <div class="packages-grid">
            <!-- 新天鵝堡套票 -->
            <div class="package-card featured">
                <div class="package-badge">限時優惠</div>
                <div class="package-image">
                    <img src="https://www.travelliker.com.hk/img/upload/img/新天鵝堡02.jpg"
                         alt="新天鵝堡套票組合" />
                </div>
                <div class="package-content">
                    <h3 class="package-title">新天鵝堡城堡套票</h3>
                    <p class="package-description">
                        包含新天鵝堡門票、慕尼黑往返交通、專業導覽服務
                    </p>

                    <div class="package-includes">
                        <h4>套票包含：</h4>
                        <ul>
                            <li>✓ 新天鵝堡門票</li>
                            <li>✓ 慕尼黑 ⇄ 新天鵝堡巴士</li>
                            <li>✓ 中文導覽服務</li>
                            <li>✓ 霍恩施萬高城堡門票</li>
                        </ul>
                    </div>

                    <div class="package-pricing">
                        <div class="price-comparison">
                            <div class="original-price">
                                <span class="label">單獨購買</span>
                                <span class="price">€65</span>
                            </div>
                            <div class="package-price">
                                <span class="label">套票價格</span>
                                <span class="price">€49</span>
                                <span class="savings">節省 €16</span>
                            </div>
                        </div>
                    </div>

                    <button class="package-cta" onclick="bookPackage('neuschwanstein-castle-pass')">
                        立即預訂套票
                    </button>
                </div>
            </div>

            <!-- 德國探索套票 -->
            <div class="package-card">
                <div class="package-image">
                    <img src="https://images.unsplash.com/photo-1467269204594-9661b134dd2b"
                         alt="德國探索套票" />
                </div>
                <div class="package-content">
                    <h3 class="package-title">德國探索套票</h3>
                    <p class="package-description">
                        7天德國任意城市火車通行證 + 熱門景點門票組合
                    </p>

                    <div class="package-includes">
                        <h4>套票包含：</h4>
                        <ul>
                            <li>✓ 7天德國火車通票</li>
                            <li>✓ 新天鵝堡門票</li>
                            <li>✓ 柏林博物館島通票</li>
                            <li>✓ 科隆大教堂導覽</li>
                        </ul>
                    </div>

                    <div class="package-pricing">
                        <div class="price-comparison">
                            <div class="original-price">
                                <span class="label">單獨購買</span>
                                <span class="price">€280</span>
                            </div>
                            <div class="package-price">
                                <span class="label">套票價格</span>
                                <span class="price">€199</span>
                                <span class="savings">節省 €81</span>
                            </div>
                        </div>
                    </div>

                    <button class="package-cta" onclick="bookPackage('germany-explorer-pass')">
                        立即預訂套票
                    </button>
                </div>
            </div>

            <!-- 週末精選套票 -->
            <div class="package-card">
                <div class="package-image">
                    <img src="https://images.unsplash.com/photo-1591535314284-b581df490bd5"
                         alt="週末精選套票" />
                </div>
                <div class="package-content">
                    <h3 class="package-title">週末精選套票</h3>
                    <p class="package-description">
                        完美的 2 天 1 夜巴伐利亞之旅
                    </p>

                    <div class="package-includes">
                        <h4>套票包含：</h4>
                        <ul>
                            <li>✓ 慕尼黑住宿 1 晚</li>
                            <li>✓ 新天鵝堡一日遊</li>
                            <li>✓ 啤酒花園晚餐</li>
                            <li>✓ 機場接送服務</li>
                        </ul>
                    </div>

                    <div class="package-pricing">
                        <div class="price-comparison">
                            <div class="original-price">
                                <span class="label">單獨購買</span>
                                <span class="price">€180</span>
                            </div>
                            <div class="package-price">
                                <span class="label">套票價格</span>
                                <span class="price">€149</span>
                                <span class="savings">節省 €31</span>
                            </div>
                        </div>
                    </div>

                    <button class="package-cta" onclick="bookPackage('weekend-bavaria-package')">
                        立即預訂套票
                    </button>
                </div>
            </div>
        </div>

        <!-- 客製化套票 -->
        <div class="custom-package">
            <h3>需要客製化套票？</h3>
            <p>我們的旅遊專家可以為您量身打造專屬行程</p>
            <button class="custom-package-btn" onclick="requestCustomPackage()">
                聯繫專家
            </button>
        </div>
    </div>
</section>
```

### 6.3 整合測試計劃

#### 6.3.1 單元測試
```javascript
// 測試 AppManager 類別
describe('AppManager', () => {
    let appManager;

    beforeEach(() => {
        appManager = new AppManager();
    });

    test('should detect iOS platform', () => {
        // 模擬 iOS UserAgent
        Object.defineProperty(navigator, 'userAgent', {
            value: 'Mozilla/5.0 (iPhone; CPU iPhone OS 14_0 like Mac OS X)',
            configurable: true
        });

        const manager = new AppManager();
        expect(manager.isIOS).toBe(true);
        expect(manager.isMobile).toBe(true);
    });

    test('should handle app download correctly', () => {
        const spy = jest.spyOn(window, 'open');
        appManager.downloadApp('ios');
        expect(spy).toHaveBeenCalledWith(appManager.appStoreURL);
    });
});

// 測試火車搜尋功能
describe('TrainSearchManager', () => {
    let trainSearch;

    beforeEach(() => {
        document.body.innerHTML = `
            <input id="departure-station" />
            <input id="arrival-station" />
            <button id="searchTrainsBtn"></button>
        `;
        trainSearch = new TrainSearchManager();
    });

    test('should filter stations correctly', () => {
        const suggestions = trainSearch.germanStations.filter(station =>
            station.name.toLowerCase().includes('berlin')
        );
        expect(suggestions.length).toBeGreaterThan(0);
        expect(suggestions[0].name).toContain('Berlin');
    });
});
```

#### 6.3.2 整合測試
```javascript
// E2E 測試使用 Playwright 或 Cypress
describe('Landing Page E2E Tests', () => {
    test('should complete booking flow', async () => {
        await page.goto('http://localhost:3000');

        // 測試預訂流程
        await page.click('[data-testid="neuschwanstein-booking"]');
        await page.waitForSelector('.modal');

        // 檢查是否顯示 App 下載彈窗
        const modal = await page.textContent('.modal-content h3');
        expect(modal).toContain('下載');
    });

    test('should search trains successfully', async () => {
        await page.fill('#departure-station', 'Berlin');
        await page.fill('#arrival-station', 'Munich');
        await page.fill('#travel-date', '2024-09-20');

        await page.click('#searchTrainsBtn');

        // 應該觸發 App 下載流程
        await page.waitForSelector('.modal');
    });
});
```

#### 6.3.3 性能測試
```javascript
// 使用 Lighthouse 進行性能測試
const lighthouse = require('lighthouse');
const chromeLauncher = require('chrome-launcher');

async function runLighthouse() {
    const chrome = await chromeLauncher.launch({chromeFlags: ['--headless']});
    const options = {logLevel: 'info', output: 'html', port: chrome.port};
    const runnerResult = await lighthouse('http://localhost:3000', options);

    // 檢查性能指標
    const lhr = runnerResult.lhr;
    const performanceScore = lhr.categories.performance.score * 100;

    expect(performanceScore).toBeGreaterThanOrEqual(90);

    await chrome.kill();
}
```

## 7. 驗收標準

### 7.1 功能驗收條件

#### 7.1.1 Sprint 1 - 新天鵝堡門票預訂
- [ ] 預訂按鈕已啟用且可點擊
- [ ] 點擊預訂按鈕觸發 App 檢測流程
- [ ] 未安裝 App 時顯示下載提示彈窗
- [ ] 已安裝 App 時成功打開對應產品頁面
- [ ] 信用卡支付流程整合完成
- [ ] 價格顯示正確（€21 起）

#### 7.1.2 Sprint 2 - 德國點對點火車票
- [ ] 車站搜尋功能正常運作
- [ ] 自動完成建議準確顯示
- [ ] 熱門路線卡片可點擊填入
- [ ] 搜尋結果引導至 App 下載/開啟
- [ ] 搜尋參數正確保存至 localStorage
- [ ] 響應式設計在各裝置正常顯示

#### 7.1.3 Sprint 3 - 旅程套票組合
- [ ] 套票卡片正確顯示價格對比
- [ ] 套票內容清單完整展示
- [ ] 預訂按鈕連結至正確的 App 頁面
- [ ] 節省金額計算正確
- [ ] 客製化套票聯繫功能運作

### 7.2 技術驗收標準

#### 7.2.1 程式碼品質
- [ ] ESLint 無錯誤警告
- [ ] CSS 通過 W3C 驗證
- [ ] HTML 通過語意化檢查
- [ ] 所有功能通過單元測試
- [ ] E2E 測試覆蓋率 > 80%

#### 7.2.2 無障礙性
- [ ] WCAG 2.1 AA 標準合規
- [ ] 鍵盤導航完全可用
- [ ] 螢幕閱讀器相容
- [ ] 色彩對比比例符合標準
- [ ] Focus 狀態清楚可見

#### 7.2.3 瀏覽器相容性
- [ ] Chrome 90+ 完全支援
- [ ] Firefox 88+ 完全支援
- [ ] Safari 14+ 完全支援
- [ ] Edge 90+ 完全支援
- [ ] 移動端瀏覽器正常運作

### 7.3 性能指標

#### 7.3.1 Core Web Vitals
- [ ] First Contentful Paint < 2 秒
- [ ] Largest Contentful Paint < 3 秒
- [ ] Cumulative Layout Shift < 0.1
- [ ] First Input Delay < 100ms

#### 7.3.2 資源最佳化
- [ ] 圖片使用 WebP 格式
- [ ] CSS/JS 檔案已最小化
- [ ] 啟用 Gzip 壓縮
- [ ] 設置適當的快取標頭

### 7.4 用戶體驗標準

#### 7.4.1 載入體驗
- [ ] 載入動畫流暢自然
- [ ] 骨架螢幕減少載入感知時間
- [ ] 錯誤狀態提供清楚指引
- [ ] 成功狀態給予適當回饋

#### 7.4.2 互動體驗
- [ ] 按鈕點擊有視覺回饋
- [ ] 表單驗證即時且友善
- [ ] 彈窗關閉方式多樣化
- [ ] 導航流暢無中斷感

## 8. 結論與後續規劃

### 8.1 實作優先序
1. **Phase 1**: 修復現有功能問題（預訂按鈕、App Store 連結）
2. **Phase 2**: 實作 Sprint 1 新天鵝堡預訂功能
3. **Phase 3**: 開發 Sprint 2 火車票搜尋功能
4. **Phase 4**: 建置 Sprint 3 套票組合功能

### 8.2 技術債務管理
- 定期重構 JavaScript 程式碼
- 優化 CSS 效能和可維護性
- 建立完整的測試涵蓋範圍
- 實施 CI/CD 自動化流程

### 8.3 未來擴展計劃
- 多語言支援（英文、德文、日文）
- PWA 功能實作
- 離線瀏覽支援
- 進階個人化推薦

---

**文件版本**: 1.0
**最後更新**: 2024-09-14
**負責人**: DodoMan 開發團隊
**審核人**: 產品經理