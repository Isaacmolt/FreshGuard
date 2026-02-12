# 🧊 鮮守衛 FreshGuard

> 守護每一份新鮮 — Keep everything fresh

一款簡潔、直覺的 iOS App，幫你記錄冰箱（及更多空間）裡物品的有效期限，透過紅黃綠燈號與推播通知，讓你再也不會忘記食物過期！

---

## ✨ 功能特色

### 免費版
- 🧊 **冰箱管理** — 冷凍/冷藏分區，一目了然
- 🚦 **紅黃綠燈號** — 自動依剩餘天數變色，帶發光效果
- 🔔 **智慧推播** — 到期前自動通知，每個燈號可獨立開關
- 📅 **小日曆選擇器** — 直覺設定有效期限，支援快速日期按鈕
- 🌓 **深色模式** — 護眼舒適
- 🌏 **三語言** — 繁體中文、簡體中文、English（日曆也會切換語言）
- 🕐 **時區設定** — 帶時差顯示

### Pro 會員 (NT$35/月 或 NT$190/永久)
- 🍿 **零食櫃** — 管理零食有效期限
- 💄 **化妝台** — 化妝品/保養品分區
- 🍷 **酒櫃** — 顯示存放天數（酒不會過期）
- 📦 **自訂空間** — 無限新增
- 🎨 **自訂燈號** — 自選顏色與天數
- ✏️ **專屬命名** — 幫每個空間取名

---

## 📱 操作方式

1. **主畫面** — 左右滑動瀏覽不同空間，磁吸式靠齊
2. **點擊冰箱** — 進入查看所有品項，上冷凍/下冷藏
3. **右下角 +** — 新增品項，選分區、設日期
4. **左滑品項** — 刪除
5. **點擊品項** — 編輯
6. **右上調色盤** — 自訂空間顏色
7. **長按標題** — 重新命名空間
8. **齒輪設定** — 燈號天數、語言、時區、深色模式、訂閱

---

## 🏗️ 技術架構

- **SwiftUI** — 100% SwiftUI 介面
- **MVVM** — Model-View-ViewModel 架構
- **StoreKit 2** — In-App Purchase
- **UserNotifications** — 本地推播通知
- **@AppStorage** — 持久化設定
- **iOS 16+** — 最低支援版本

---

## 📂 專案結構

```
FreshGuard/
├── App/                    # App entry point, AppState
├── Models/                 # Data models
├── ViewModels/             # Business logic
├── Views/
│   ├── Main/              # HomeView, ContentView, Onboarding
│   ├── Space/             # SpaceDetailView, ItemSheets
│   ├── Settings/          # SettingsView, TrafficLight, Timezone
│   ├── Subscription/      # SubscriptionView
│   └── Components/        # ColorPicker, shared UI
├── Services/              # Notifications, StoreManager
├── Extensions/            # Color, View helpers
├── Localization/          # en, zh-Hant, zh-Hans
└── Resources/             # Assets, StoreKit config
```

---

## 🚀 上架清單

- [x] Info.plist 完整配置
- [x] 隱私政策 (PRIVACY_POLICY.md)
- [x] 服務條款 (TERMS_OF_SERVICE.md)
- [x] ITSAppUsesNonExemptEncryption = NO
- [x] StoreKit 配置檔
- [x] 訂閱自動續訂說明
- [x] 恢復購買功能
- [x] 通知權限說明 (NSUserNotificationsUsageDescription)
- [x] 三語言完整本地化
- [x] 廣告橫幅預留空間（底部 50pt）
- [x] Onboarding 引導頁

---

## 📝 定價

| 方案 | 台灣 | 其他國家 |
|------|------|---------|
| 月訂閱 | NT$ 35 | $1.19 USD |
| 永久買斷 | NT$ 190 | $5.99 USD |

---

## 🛠️ 開發環境

- Xcode 15+
- iOS 16.0+
- Swift 5.9+

## 📧 聯絡

support@freshguard.app
