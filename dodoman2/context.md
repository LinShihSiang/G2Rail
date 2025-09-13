# DoDoMan 天鵝堡門票 App - 完整開發文檔

## 專案概述

這是一個 Flutter 開發的天鵝堡門票預訂應用程式，名稱為 "DoDoMan天鵝堡門票"。應用程式提供用戶預訂天鵝堡門票的完整流程，包含表單填寫、即時票價計算、和自動郵件發送功能。

## 應用程式架構

### 主要文件結構
```
lib/
  main.dart           # 主要應用程式代碼
pubspec.yaml          # 依賴項配置
image/
  castle.jpg          # 天鵝堡門票圖片
android/
  app/src/main/AndroidManifest.xml  # Android 權限配置
```

## 依賴項配置 (pubspec.yaml)

### 必要依賴項
```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  url_launcher: ^6.3.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
```

### 資源配置
```yaml
flutter:
  uses-material-design: true
  assets:
    - image/
```

## 主要功能設計

### 1. 頁面布局設計
- **上半部 (flex: 1)**: 天鵝堡門票圖片
  - 圖片來源: `image/castle.jpg`
  - 圓角設計: 底部左右角 20px 圓角
  - 陰影效果: 灰色透明陰影
- **下半部 (flex: 2)**: 訂單資訊表單
  - 可滾動設計 (SingleChildScrollView)
  - 內邊距: 20px

### 2. 表單欄位設計

#### 護照姓名欄位
```dart
TextFormField(
  decoration: InputDecoration(
    labelText: '護照姓名',
    border: OutlineInputBorder(),
    prefixIcon: Icon(Icons.person),
    hintText: '請輸入與護照相同的姓名',
  ),
  validator: 必填驗證
)
```

#### 大人小孩數量欄位 (並排顯示)
```dart
Row(
  children: [
    Expanded(child: 大人數量欄位),
    SizedBox(width: 16),
    Expanded(child: 小孩數量欄位),
  ]
)
```

**大人數量特性:**
- 預設值: 1
- 最小值: 1 (至少需要1位大人)
- 即時更新: onChanged 觸發 setState()

**小孩數量特性:**
- 預設值: 0
- 最小值: 0
- 即時更新: onChanged 觸發 setState()

#### 參觀日期選擇
```dart
InkWell + InputDecorator + DatePicker
- 可選日期範圍: 今天到一年後
- 顯示格式: YYYY/M/D
```

#### 參觀時段選擇
```dart
DropdownButtonFormField
選項:
- 上午 (09:00-12:00)
- 下午 (13:00-17:00)
```

### 3. 票價計算系統

#### 票價常量
```dart
static const int adultPrice = 690;  // 大人票價 NT$690
static const int childPrice = 0;    // 小孩票價 免費
```

#### 即時計算邏輯
```dart
int get totalPrice => adults * adultPrice + children * childPrice;
```

#### 票價顯示區域設計
```dart
Container(
  padding: EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Colors.blue.withValues(alpha: 0.1),
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
  ),
  child: 票價明細內容
)
```

**票價明細內容:**
- 標題: "票價明細" (藍色粗體)
- 大人票: "大人票 (X 位)" - "NT$ XXX"
- 小孩票: "小孩票 (X 位)" - "免費"
- 分隔線
- 總計: "總計" - "NT$ XXX" (紅色粗體)

### 4. 郵件發送功能

#### 郵件配置
```dart
收件者: baluce@gmail.com
主旨: DoDoMan天鵝堡門票訂單 - [護照姓名]
```

#### 郵件內容格式
```
天鵝堡門票訂單資訊
====================

護照姓名: [用戶輸入]
大人數量: [數量] 位
小孩數量: [數量] 位
總票數: [總數] 張
參觀日期: [選擇日期]
參觀時段: [選擇時段]

票價明細:
大人票 ([數量] 位): NT$ [金額]
小孩票 ([數量] 位): 免費
總計: NT$ [總金額]

訂單時間: [當前時間]
```

#### 郵件發送邏輯
```dart
Future<void> _sendOrderEmail() async {
  // 組合郵件主旨和內容
  // 使用 url_launcher 開啟郵件應用程式
  final emailUri = Uri(
    scheme: 'mailto',
    path: 'baluce@gmail.com',
    query: 'subject=$subject&body=$body',
  );
  await launchUrl(emailUri);
}
```

### 5. 訂單流程設計

#### 送出訂單按鈕邏輯
1. 表單驗證 (`_formKey.currentState?.validate()`)
2. 檢查參觀日期是否已選擇
3. 顯示處理中提示 ("正在發送訂單郵件...")
4. 執行 `_sendOrderEmail()`
5. 顯示確認對話框或錯誤提示

#### 確認對話框內容
```dart
AlertDialog(
  title: Text('訂單已送出'),
  content: 完整訂單資訊 + 票價明細 + "訂單郵件已自動發送至 baluce@gmail.com"
)
```

## Android 權限配置

### AndroidManifest.xml 必要配置
```xml
<queries>
    <intent>
        <action android:name="android.intent.action.PROCESS_TEXT"/>
        <data android:mimeType="text/plain"/>
    </intent>
    <intent>
        <action android:name="android.intent.action.SENDTO" />
        <data android:scheme="mailto" />
    </intent>
</queries>
```

## 狀態管理設計

### 主要狀態變數
```dart
String passportName = '';     // 護照姓名
int adults = 1;              // 大人數量
int children = 0;            // 小孩數量
DateTime? selectedDate;       // 參觀日期
String timeSlot = '上午';      // 參觀時段
```

### 即時更新機制
- 大人/小孩數量變更時觸發 `setState()`
- 票價顯示區域自動重新渲染
- 使用 getter `totalPrice` 計算總價

## UI/UX 設計要點

### 顏色主題
- 主色調: Colors.blue
- 成功色: Colors.green  
- 錯誤色: Colors.red
- 票價強調色: Colors.red (總計金額)

### 間距設計
- 表單欄位間距: 16px
- 區塊間距: 20px
- 容器內邊距: 16-20px

### 字體設計
- 標題: 24px, FontWeight.bold
- 子標題: 18px, FontWeight.bold
- 內容: 16px, 正常粗細
- 總價: 18px, FontWeight.bold

## 開發重建指令

### 1. 創建 Flutter 專案
```bash
flutter create dodoman2
cd dodoman2
```

### 2. 更新 pubspec.yaml
添加依賴項:
- url_launcher: ^6.3.0
- 資源配置: assets: - image/

### 3. 替換 lib/main.dart
實現完整的 TicketPage 功能

### 4. 添加圖片資源
在 image/ 資料夾放入 castle.jpg

### 5. 更新 Android 權限
修改 android/app/src/main/AndroidManifest.xml

### 6. 執行專案
```bash
flutter pub get
flutter run
```

## 測試要點

1. 表單驗證功能
2. 即時票價計算
3. 日期選擇器功能
4. 郵件發送功能
5. 響應式布局
6. 錯誤處理機制

## 注意事項

1. 圖片 castle.jpg 必須放在 image/ 資料夾
2. Android 郵件權限必須正確配置
3. 大人數量不能少於 1
4. 小孩數量不能小於 0
5. 必須選擇參觀日期才能送出訂單
6. 郵件收件者固定為 baluce@gmail.com

---

此文檔包含了完整重建 DoDoMan 天鵝堡門票 App 所需的所有資訊。