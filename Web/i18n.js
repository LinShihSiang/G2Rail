// 多語系管理系統
class I18nManager {
    constructor() {
        this.currentLanguage = localStorage.getItem('dodoman-language') || 'zh-TW';
        this.translations = {
            'zh-TW': {
                // Header 導航
                'nav.experiences': '體驗',
                'nav.destinations': '目的地',
                'nav.about': '關於我們',
                'nav.openApp': '打開 App',

                // Hero Section
                'hero.title': '探索世界的奇蹟',
                'hero.subtitle': '與我們一起踏上難忘的旅程，發現隱藏的寶石和經典景點',
                'hero.downloadBtn': '立即下載 App',
                'hero.browseBtn': '瀏覽體驗',

                // Features Section
                'features.title': '為什麼選擇 DodoMan？',
                'features.unique.title': '獨特體驗',
                'features.unique.desc': '精心策劃的旅遊體驗，讓您深度體驗當地文化和自然美景，創造難忘的回憶。',
                'features.guide.title': '專業導遊',
                'features.guide.desc': '經驗豐富的在地導遊，為您提供專業的解說和貼心的服務，確保旅程順利愉快。',
                'features.booking.title': '即時預訂',
                'features.booking.desc': '隨時隨地透過手機 App 預訂行程，即時確認，讓您的旅行計劃更加彈性便利。',

                // Gallery Section
                'gallery.title': '熱門目的地',
                'gallery.neuschwanstein.badge': '主打推薦',
                'gallery.neuschwanstein.title': '新天鵝堡',
                'gallery.neuschwanstein.desc': '德國最浪漫的童話城堡',
                'gallery.uffizi.badge': '藝術殿堂',
                'gallery.uffizi.title': '烏菲茲美術館',
                'gallery.uffizi.desc': '義大利佛羅倫斯文藝復興藝術寶庫',

                // App Promotion Section
                'app.title': '下載 DodoMan App',
                'app.subtitle': '隨時隨地探索世界，享受獨家優惠和即時預訂服務',
                'app.feature1': '✓ 獨家 App 優惠價格',
                'app.feature2': '✓ 即時行程確認',
                'app.feature3': '✓ 24/7 客服支援',
                'app.feature4': '✓ 個人化推薦',

                // About Section
                'about.title': '關於 DodoMan',
                'about.desc': 'DodoMan 致力於為旅行者提供最優質的旅遊體驗。我們相信每一次旅行都應該是獨特而難忘的，因此我們精心策劃每一個行程，確保您能夠深度體驗當地文化、品嚐地道美食、欣賞壯麗景色。',
                'about.countries': '個國家',
                'about.customers': '滿意客戶',
                'about.experiences': '精選體驗',
                'about.rating': '客戶評價',

                // Footer
                'footer.tagline': '探索世界，創造回憶',
                'footer.services': '服務',
                'footer.service1': '旅遊體驗',
                'footer.service2': '團體預訂',
                'footer.service3': '企業服務',
                'footer.service4': '客製化行程',
                'footer.support': '支援',
                'footer.support1': '客服中心',
                'footer.support2': '預訂查詢',
                'footer.support3': '退改政策',
                'footer.support4': '常見問題',
                'footer.company': '公司',
                'footer.company1': '關於我們',
                'footer.company2': '加入我們',
                'footer.company3': '隱私政策',
                'footer.company4': '服務條款',
                'footer.copyright': '© 2024 DodoMan. 保留所有權利。',

                // Modal
                'modal.title': '選擇您的平台',
                'modal.desc': '為了獲得最佳體驗，請下載我們的官方 App',
                'modal.android': '下載 Android App',
                'modal.web': '繼續使用網頁版',

                // Language Selector
                'lang.selector': '語言',
                'lang.zh-TW': '繁體中文',
                'lang.en': 'English'
            },
            'en': {
                // Header Navigation
                'nav.experiences': 'Experiences',
                'nav.destinations': 'Destinations',
                'nav.about': 'About Us',
                'nav.openApp': 'Open App',

                // Hero Section
                'hero.title': 'Discover World Wonders',
                'hero.subtitle': 'Join us on unforgettable journeys to discover hidden gems and iconic destinations',
                'hero.downloadBtn': 'Download App Now',
                'hero.browseBtn': 'Browse Experiences',

                // Features Section
                'features.title': 'Why Choose DodoMan?',
                'features.unique.title': 'Unique Experiences',
                'features.unique.desc': 'Carefully curated travel experiences that let you deeply immerse in local culture and natural beauty, creating unforgettable memories.',
                'features.guide.title': 'Professional Guides',
                'features.guide.desc': 'Experienced local guides provide professional commentary and thoughtful service to ensure your journey is smooth and enjoyable.',
                'features.booking.title': 'Instant Booking',
                'features.booking.desc': 'Book trips anytime, anywhere through our mobile app with instant confirmation, making your travel planning more flexible and convenient.',

                // Gallery Section
                'gallery.title': 'Popular Destinations',
                'gallery.neuschwanstein.badge': 'Featured',
                'gallery.neuschwanstein.title': 'Neuschwanstein Castle',
                'gallery.neuschwanstein.desc': 'Germany\'s most romantic fairy-tale castle',
                'gallery.uffizi.badge': 'Art Gallery',
                'gallery.uffizi.title': 'Uffizi Gallery',
                'gallery.uffizi.desc': 'Renaissance art treasure in Florence, Italy',

                // App Promotion Section
                'app.title': 'Download DodoMan App',
                'app.subtitle': 'Explore the world anytime, anywhere with exclusive offers and instant booking services',
                'app.feature1': '✓ Exclusive app pricing',
                'app.feature2': '✓ Instant trip confirmation',
                'app.feature3': '✓ 24/7 customer support',
                'app.feature4': '✓ Personalized recommendations',

                // About Section
                'about.title': 'About DodoMan',
                'about.desc': 'DodoMan is committed to providing travelers with the highest quality travel experiences. We believe every journey should be unique and memorable, so we carefully curate every itinerary to ensure you can deeply experience local culture, taste authentic cuisine, and enjoy magnificent scenery.',
                'about.countries': 'Countries',
                'about.customers': 'Satisfied Customers',
                'about.experiences': 'Curated Experiences',
                'about.rating': 'Customer Rating',

                // Footer
                'footer.tagline': 'Explore the World, Create Memories',
                'footer.services': 'Services',
                'footer.service1': 'Travel Experiences',
                'footer.service2': 'Group Bookings',
                'footer.service3': 'Corporate Services',
                'footer.service4': 'Custom Itineraries',
                'footer.support': 'Support',
                'footer.support1': 'Customer Service',
                'footer.support2': 'Booking Inquiry',
                'footer.support3': 'Cancellation Policy',
                'footer.support4': 'FAQ',
                'footer.company': 'Company',
                'footer.company1': 'About Us',
                'footer.company2': 'Join Us',
                'footer.company3': 'Privacy Policy',
                'footer.company4': 'Terms of Service',
                'footer.copyright': '© 2024 DodoMan. All rights reserved.',

                // Modal
                'modal.title': 'Choose Your Platform',
                'modal.desc': 'For the best experience, please download our official App',
                'modal.android': 'Download Android App',
                'modal.web': 'Continue with Web',

                // Language Selector
                'lang.selector': 'Language',
                'lang.zh-TW': '繁體中文',
                'lang.en': 'English'
            }
        };

        this.init();
    }

    init() {
        this.updateContent();
        this.updateLanguageSelector();
    }

    // 獲取翻譯文字
    t(key) {
        return this.translations[this.currentLanguage][key] || key;
    }

    // 切換語言
    switchLanguage(language) {
        if (this.translations[language]) {
            this.currentLanguage = language;
            localStorage.setItem('dodoman-language', language);
            this.updateContent();
            this.updateLanguageSelector();

            // 觸發語言切換事件
            document.dispatchEvent(new CustomEvent('languageChanged', {
                detail: { language: language }
            }));
        }
    }

    // 更新頁面內容
    updateContent() {
        // 更新所有具有 data-i18n 屬性的元素
        document.querySelectorAll('[data-i18n]').forEach(element => {
            const key = element.getAttribute('data-i18n');
            const translation = this.t(key);

            if (element.tagName === 'INPUT' && element.type === 'submit') {
                element.value = translation;
            } else if (element.hasAttribute('placeholder')) {
                element.placeholder = translation;
            } else {
                element.textContent = translation;
            }
        });

        // 更新 HTML lang 屬性
        document.documentElement.lang = this.currentLanguage;
    }

    // 更新語言選擇器
    updateLanguageSelector() {
        const currentLangBtn = document.querySelector('#currentLanguage');
        const langOptions = document.querySelectorAll('.lang-option');

        if (currentLangBtn) {
            currentLangBtn.textContent = this.t(`lang.${this.currentLanguage}`);
        }

        langOptions.forEach(option => {
            const lang = option.getAttribute('data-lang');
            if (lang === this.currentLanguage) {
                option.classList.add('active');
            } else {
                option.classList.remove('active');
            }
        });
    }

    // 獲取當前語言
    getCurrentLanguage() {
        return this.currentLanguage;
    }

    // 獲取支援的語言列表
    getSupportedLanguages() {
        return Object.keys(this.translations);
    }
}

// 創建全域 i18n 實例
window.i18n = new I18nManager();