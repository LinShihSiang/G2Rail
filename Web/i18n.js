// 多語系管理系統
class I18nManager {
    constructor() {
        this.currentLanguage = localStorage.getItem('dodoman-language') || 'zh-TW';
        this.translations = {
            'zh-TW': {
                // Header 導航
                'nav.experiences': '體驗',
                'nav.destinations': '目的地',
                'nav.customerService': '客服',
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
                'gallery.title': '熱門景點',
                'gallery.neuschwanstein.badge': '主打推薦',
                'gallery.neuschwanstein.title': '新天鵝堡探索之旅',
                'gallery.neuschwanstein.subtitle': '德國浪漫童話城堡',
                'gallery.neuschwanstein.location': '德國',
                'gallery.neuschwanstein.desc': '探索德國最浪漫的童話城堡，感受路德維希二世的夢幻世界',
                'gallery.neuschwanstein.feature1': '城堡內部導覽',
                'gallery.neuschwanstein.feature2': '阿爾卑斯山景',
                'gallery.neuschwanstein.feature3': '專業中文導遊',
                'gallery.neuschwanstein.duration': '半日遊',
                'gallery.uffizi.badge': '藝術殿堂',
                'gallery.uffizi.title': '烏菲茲美術館藝術之旅',
                'gallery.uffizi.subtitle': '佛羅倫斯文藝復興寶庫',
                'gallery.uffizi.location': '佛羅倫斯',
                'gallery.uffizi.desc': '義大利佛羅倫斯文藝復興藝術寶庫，收藏世界頂級藝術品',
                'gallery.uffizi.feature1': '專業藝術導覽',
                'gallery.uffizi.feature2': '文藝復興傑作',
                'gallery.uffizi.feature3': '免排隊門票',
                'gallery.uffizi.duration': '3小時',

                'gallery.colosseum.badge': '經典必遊',
                'gallery.colosseum.title': '羅馬競技場探索',
                'gallery.colosseum.subtitle': '古羅馬帝國見證',
                'gallery.colosseum.location': '羅馬',
                'gallery.colosseum.desc': '世界八大奇蹟之一，感受古羅馬帝國的壯麗與榮耀',
                'gallery.colosseum.feature1': '歷史專業導覽',
                'gallery.colosseum.feature2': '地下層參觀',
                'gallery.colosseum.feature3': '語音導覽設備',
                'gallery.colosseum.duration': '2小時',

                // Packages Section
                'packages.title': '精選套票 Package',

                // Package 1 - Rome Independent Tour
                'package.rome.title': '羅馬獨立之旅',
                'package.rome.subtitle': '從威尼斯出發搭乘高速列車',
                'package.rome.location': '威尼斯 → 羅馬',
                'package.rome.description': '搭乘高速列車從威尼斯前往羅馬的全新觀光之旅。包含隨上隨下巴士票券，以及梵蒂岡和西斯汀教堂的專業導覽。',
                'package.rome.feature1': '高速列車來回票券',
                'package.rome.feature2': '隨上隨下巴士',
                'package.rome.feature3': '梵蒂岡專業導覽',
                'package.rome.feature4': '西斯汀教堂門票',
                'package.rome.duration': '1日遊',
                'package.rome.badge': '特價優惠',

                // Package 2 - Milan Turin Tour
                'package.milan.title': '米蘭都靈雙城記',
                'package.milan.subtitle': '北義大利精華一日遊',
                'package.milan.location': '米蘭 → 都靈',
                'package.milan.description': '一日內遊覽北義大利兩大城市。從米蘭搭乘高速列車前往都靈，參觀聖卡羅廣場17世紀教堂，享受巧克力和冰淇淋品嚐。',
                'package.milan.feature1': '高速列車',
                'package.milan.feature2': '巧克力品嚐',
                'package.milan.feature3': '冰淇淋體驗',
                'package.milan.feature4': '普羅賽克酒',
                'package.milan.feature5': '米蘭夜遊',
                'package.milan.duration': '1日遊',
                'package.milan.badge': '超值套票',

                // Package 3 - Munich Nuremberg Tour
                'package.munich.title': '慕尼黑紐倫堡探索',
                'package.munich.subtitle': '從法蘭克福出發的巴伐利亞之旅',
                'package.munich.location': '法蘭克福 → 慕尼黑 → 紐倫堡',
                'package.munich.description': '造訪德國必看的巴伐利亞城市慕尼黑和紐倫堡。參觀瑪麗安廣場、維克圖阿連市場、奧林匹克公園和聖母教堂。',
                'package.munich.feature1': '瑪麗安廣場',
                'package.munich.feature2': '維克圖阿連市場',
                'package.munich.feature3': '奧林匹克公園',
                'package.munich.feature4': '聖母教堂',
                'package.munich.feature5': '中世紀紐倫堡',
                'package.munich.duration': '1日遊',
                'package.munich.badge': '熱門推薦',

                // Package 4 - Rome Vatican Tour
                'package.vatican.title': '羅馬梵蒂岡全覽',
                'package.vatican.subtitle': '小團體深度7小時探索',
                'package.vatican.location': '羅馬 & 梵蒂岡',
                'package.vatican.description': '7小時小團體深度遊覽羅馬和梵蒂岡城。包含鬥獸場、萬神殿、羅馬廣場、西斯汀教堂、聖彼得廣場等知名景點。',
                'package.vatican.feature1': '專業導遊',
                'package.vatican.feature2': '鬥獸場門票',
                'package.vatican.feature3': '萬神殿參觀',
                'package.vatican.feature4': '西斯汀教堂',
                'package.vatican.feature5': '特雷維噴泉',
                'package.vatican.feature6': '西班牙階梯',
                'package.vatican.duration': '7小時',
                'package.vatican.badge': '精選推薦',

                // Common package terms
                'package.bookNow': '立即預訂',

                // App Promotion Section
                'app.title': '下載 DodoMan App',
                'app.subtitle': '隨時隨地探索世界，享受獨家優惠和即時預訂服務',
                'app.feature1': '✓ 獨家 App 優惠價格',
                'app.feature2': '✓ 即時行程確認',
                'app.feature3': '✓ 24/7 客服支援',
                'app.feature4': '✓ 個人化推薦',

                // Customer Service Section
                'customerService.title': '需要客服協助嗎？',
                'customerService.order.title': '諮詢訂單問題',
                'customerService.order.desc': '將帶您至訂單列表選擇要詢問的訂單',
                'customerService.order.button': '查詢訂單',
                'customerService.general.title': '諮詢商品或其他問題',
                'customerService.general.desc': '由於諮詢量大，將盡快在一天內回覆',
                'customerService.general.button': '聯絡客服',

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
                'nav.customerService': 'Support',
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
                'gallery.title': 'Popular Attractions',
                'gallery.neuschwanstein.badge': 'Featured',
                'gallery.neuschwanstein.title': 'Neuschwanstein Castle Tour',
                'gallery.neuschwanstein.subtitle': 'Germany\'s Romantic Fairy-tale Castle',
                'gallery.neuschwanstein.location': 'Germany',
                'gallery.neuschwanstein.desc': 'Explore Germany\'s most romantic fairy-tale castle and experience King Ludwig II\'s dream world',
                'gallery.neuschwanstein.feature1': 'Castle Interior Tour',
                'gallery.neuschwanstein.feature2': 'Alpine Mountain Views',
                'gallery.neuschwanstein.feature3': 'Professional Guide',
                'gallery.neuschwanstein.duration': 'Half Day',

                'gallery.uffizi.badge': 'Art Gallery',
                'gallery.uffizi.title': 'Uffizi Gallery Art Tour',
                'gallery.uffizi.subtitle': 'Florence Renaissance Treasure',
                'gallery.uffizi.location': 'Florence',
                'gallery.uffizi.desc': 'Renaissance art treasure in Florence, Italy, housing world-class masterpieces',
                'gallery.uffizi.feature1': 'Professional Art Guide',
                'gallery.uffizi.feature2': 'Renaissance Masterpieces',
                'gallery.uffizi.feature3': 'Skip-the-Line Tickets',
                'gallery.uffizi.duration': '3 Hours',

                'gallery.colosseum.badge': 'Must Visit',
                'gallery.colosseum.title': 'Colosseum Exploration',
                'gallery.colosseum.subtitle': 'Ancient Roman Empire Witness',
                'gallery.colosseum.location': 'Rome',
                'gallery.colosseum.desc': 'One of the World\'s Eight Wonders, experience the grandeur and glory of the Ancient Roman Empire',
                'gallery.colosseum.feature1': 'Historical Expert Guide',
                'gallery.colosseum.feature2': 'Underground Level Visit',
                'gallery.colosseum.feature3': 'Audio Guide Equipment',
                'gallery.colosseum.duration': '2 Hours',

                // Packages Section
                'packages.title': 'Featured Packages',

                // Package 1 - Rome Independent Tour
                'package.rome.title': 'Rome Independent Tour',
                'package.rome.subtitle': 'From Venice by High-Speed Train',
                'package.rome.location': 'Venice → Rome',
                'package.rome.description': 'A new sightseeing tour with daily departure from Venice by round trip high speed train. Includes ticket to hop-on hop-off bus and a tour of the Vatican and Sistine Chapel with an expert guide.',
                'package.rome.feature1': 'Round-trip High-speed Train',
                'package.rome.feature2': 'Hop-on Hop-off Bus',
                'package.rome.feature3': 'Vatican Expert Guide',
                'package.rome.feature4': 'Sistine Chapel Ticket',
                'package.rome.duration': 'Day Trip',
                'package.rome.badge': 'Special Offer',

                // Package 2 - Milan Turin Tour
                'package.milan.title': 'Milan & Turin Twin Cities',
                'package.milan.subtitle': 'Northern Italy Highlights Day Tour',
                'package.milan.location': 'Milan → Turin',
                'package.milan.description': 'Visit two of northern Italy\'s top cities in a single day. From Milan, travel to Turin by high-speed train, and see sights such as Piazza San Carlo with its 17th-century churches. You\'ll also enjoy a chocolate and gelato tasting.',
                'package.milan.feature1': 'High-speed Train',
                'package.milan.feature2': 'Chocolate Tasting',
                'package.milan.feature3': 'Gelato Experience',
                'package.milan.feature4': 'Prosecco Glass',
                'package.milan.feature5': 'Milan Evening Tour',
                'package.milan.duration': 'Day Trip',
                'package.milan.badge': 'Great Value',

                // Package 3 - Munich Nuremberg Tour
                'package.munich.title': 'Munich & Nuremberg Explorer',
                'package.munich.subtitle': 'Bavarian Cities from Frankfurt',
                'package.munich.location': 'Frankfurt → Munich → Nuremberg',
                'package.munich.description': 'Spend a day in the must-see Bavarian cities of Munich and Nuremberg. Visit top Munich attractions including Marienplatz, Viktualienmarkt, Olympic Park, and the Cathedral Church of Our Lady.',
                'package.munich.feature1': 'Marienplatz',
                'package.munich.feature2': 'Viktualienmarkt',
                'package.munich.feature3': 'Olympic Park',
                'package.munich.feature4': 'Frauenkirche',
                'package.munich.feature5': 'Medieval Nuremberg',
                'package.munich.duration': 'Day Trip',
                'package.munich.badge': 'Popular Choice',

                // Package 4 - Rome Vatican Tour
                'package.vatican.title': 'Rome & Vatican Complete',
                'package.vatican.subtitle': 'Small Group 7-Hour Deep Exploration',
                'package.vatican.location': 'Rome & Vatican',
                'package.vatican.description': 'Immerse yourself in the magic and history of Rome and Vatican City during this 7-hour small-group tour. See the area\'s most historic sights including the famous Colosseum, the Pantheon, and the Sistine Chapel.',
                'package.vatican.feature1': 'Expert Guide',
                'package.vatican.feature2': 'Colosseum Ticket',
                'package.vatican.feature3': 'Pantheon Visit',
                'package.vatican.feature4': 'Sistine Chapel',
                'package.vatican.feature5': 'Trevi Fountain',
                'package.vatican.feature6': 'Spanish Steps',
                'package.vatican.duration': '7 Hours',
                'package.vatican.badge': 'Editor\'s Choice',

                // Common package terms
                'package.bookNow': 'Book Now',

                // App Promotion Section
                'app.title': 'Download DodoMan App',
                'app.subtitle': 'Explore the world anytime, anywhere with exclusive offers and instant booking services',
                'app.feature1': '✓ Exclusive app pricing',
                'app.feature2': '✓ Instant trip confirmation',
                'app.feature3': '✓ 24/7 customer support',
                'app.feature4': '✓ Personalized recommendations',

                // Customer Service Section
                'customerService.title': 'Need Customer Support?',
                'customerService.order.title': 'Order Inquiry',
                'customerService.order.desc': 'We will direct you to your order list to select the order you want to inquire about',
                'customerService.order.button': 'View Orders',
                'customerService.general.title': 'Product or Other Inquiries',
                'customerService.general.desc': 'Due to high inquiry volume, we will respond as soon as possible within one day',
                'customerService.general.button': 'Contact Support',

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