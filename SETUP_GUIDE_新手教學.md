# 🧊 鮮守衛 FreshGuard — 新手設定教學

## 📋 你需要的東西
1. 一台 Mac 電腦
2. 從 App Store 下載安裝 **Xcode**（免費）
3. 本專案的所有程式碼（你已經有了）

---

## 🚀 建立步驟（照著做就對了）

### Step 1：用 Xcode 建立新專案
1. 打開 **Xcode**
2. 點選 **「Create New Project」**（建立新專案）
3. 選擇 **「App」** → 點 **Next**
4. 填寫以下資訊：
   - **Product Name**：`FreshGuard`
   - **Team**：選你的 Apple Developer 帳號（沒有的話先跳過）
   - **Organization Identifier**：`com.freshguard`
   - **Interface**：選 **SwiftUI**
   - **Language**：選 **Swift**
   - ❌ 不要勾 Core Data
   - ❌ 不要勾 Include Tests
5. 點 **Next** → 選一個地方儲存 → 點 **Create**

### Step 2：建立資料夾結構
在 Xcode 左側的檔案面板中，**右鍵點擊「FreshGuard」資料夾**：
1. 選 **New Group**，建立以下資料夾（每個都右鍵 → New Group）：
   ```
   App
   Models
   ViewModels
   Views
     ├── Main
     ├── Space
     ├── Settings
     ├── Subscription
     └── Components
   Services
   Extensions
   Localization
     ├── en.lproj
     ├── zh-Hant.lproj
     └── zh-Hans.lproj
   ```

### Step 3：把程式碼檔案加入專案
對每個資料夾，**右鍵 → New File → Swift File**，命名後把對應的程式碼貼進去：

| 資料夾 | 檔案名稱 | 說明 |
|-------|---------|------|
| App | `FreshGuardApp.swift` | App 入口（替換掉 Xcode 自動生成的那個） |
| App | `AppState.swift` | 全域狀態管理 |
| Models | `Models.swift` | 資料模型 |
| ViewModels | `SpaceViewModel.swift` | 商業邏輯 |
| Views/Main | `ContentView.swift` | 根視圖（替換掉自動生成的） |
| Views/Main | `HomeView.swift` | 主畫面 |
| Views/Main | `OnboardingView.swift` | 新手導覽 |
| Views/Space | `SpaceDetailView.swift` | 空間內頁 |
| Views/Space | `ItemSheets.swift` | 新增/編輯品項 |
| Views/Settings | `SettingsView.swift` | 設定頁面 |
| Views/Subscription | `SubscriptionView.swift` | 訂閱頁面 |
| Views/Components | `ColorPickerSheet.swift` | 顏色選擇器 |
| Services | `NotificationService.swift` | 推播服務 |
| Services | `StoreManager.swift` | 內購管理 |
| Extensions | `Extensions.swift` | 工具擴展 |

### Step 4：加入本地化字串檔
1. 在 Xcode 上方選單 → **File → New → File**
2. 搜尋 **「Strings File」**
3. 命名為 **`Localizable`** → Create
4. 點選新建的 `Localizable.strings`
5. 右側面板（Inspector）找到 **Localization**
6. 點 **「Localize...」** 按鈕
7. 勾選 **English、Chinese (Traditional)、Chinese (Simplified)**
8. 對每個語言版本，貼上對應的翻譯內容

💡 **如果找不到語言選項**：
- 點專案最上層的 **FreshGuard** (藍色圖示)
- 找到 **Info** → **Localizations**
- 點 **「+」** 加入 Chinese (Traditional) 和 Chinese (Simplified)

### Step 5：加入 StoreKit 測試檔
1. 把 `FreshGuardProducts.storekit` 檔案拖入 Xcode 專案
2. 在 Xcode 上方選單 → **Product → Scheme → Edit Scheme**
3. 左側選 **Run** → **Options** 分頁
4. **StoreKit Configuration** 選擇 `FreshGuardProducts.storekit`

### Step 6：設定 Info.plist
1. 點專案最上層 → **Info** 分頁
2. 加入以下 key：
   - `Privacy - User Notifications Usage Description`：值填 `FreshGuard needs to send you notifications to remind you when items are about to expire.`
   - `Application uses non-exempt encryption`：設為 `NO`

### Step 7：執行！
1. 左上角選 **iPhone 15** 模擬器
2. 按 **▶️** 或 `Cmd + R`
3. 等待編譯 → App 就會在模擬器跑起來了！🎉

---

## ⚠️ 常見問題

### Q: 出現紅色錯誤怎麼辦？
- 確認你有刪除 Xcode 自動產生的 `ContentView.swift` 和 `FreshGuardApp.swift`（或用我的版本完全替換）
- 確認所有檔案都在正確的資料夾裡

### Q: 模擬器上看不到中文？
- 在模擬器的 Settings → General → Language → 選繁體中文

### Q: 通知沒有跳出來？
- 模擬器第一次會問你要不要允許通知 → 選 **Allow**

### Q: 怎麼上架到 App Store？
1. 你需要一個 **Apple Developer 帳號**（年費 $99 美金）
2. 在 https://developer.apple.com 註冊
3. 在 **App Store Connect** 建立你的 App
4. 在 Xcode 用 **Product → Archive** 打包
5. 上傳到 App Store Connect 審核

---

## 📁 更簡單的方法：直接拖入檔案

如果你覺得一個個建太麻煩：
1. 在 Finder 中打開解壓縮後的 `FreshGuard/FreshGuard/` 資料夾
2. 在 Xcode 新專案中，把我的整個資料夾結構 **直接拖入** Xcode 左側面板
3. 勾選 **「Copy items if needed」** 和 **「Create groups」**
4. 刪除 Xcode 原本自動生成的 `ContentView.swift` 和 `FreshGuardApp.swift`

這樣最快！
