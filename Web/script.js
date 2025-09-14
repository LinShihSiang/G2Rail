// Shared Destination Data
const DESTINATION_DATA = [
    {
        key: "neuschwanstein",
        price: "€21",
        originalPrice: "€28",
        image: "https://www.travelliker.com.hk/img/upload/img/%E6%96%B0%E5%A4%A9%E9%B5%9D%E5%A0%A102.jpg",
        discount: "25%",
        duration: "半日遊"
    },
    {
        key: "uffizi",
        price: "€35.9",
        originalPrice: "€45",
        image: "https://blog-static.kkday.com/zh-hk/blog/wp-content/uploads/shutterstock_673635160-644x444.jpg",
        discount: "20%",
        duration: "3小時"
    }
];

// Package Tour Data - Selected from Italy_Germany_tours.json
const PACKAGE_DATA = [
    {
        id: "TR__6274P15",
        key: "rome",
        price: "€232",
        originalPrice: "€280",
        image: "https://sematicweb.detie.cn/content/W__37747155.jpg",
        featureCount: 4,
        discount: "17%"
    },
    {
        id: "TR__3731P161",
        key: "milan",
        price: "€155",
        originalPrice: "€185",
        image: "https://sematicweb.detie.cn/content/W__27626748.jpg",
        featureCount: 5,
        discount: "16%"
    },
    {
        id: "TR__5326MUCNUREM",
        key: "munich",
        price: "€298",
        originalPrice: "€350",
        image: "https://sematicweb.detie.cn/content/N__296314458.jpg",
        featureCount: 5,
        discount: "15%"
    },
    {
        id: "TR__5831P13",
        key: "vatican",
        price: "€115",
        originalPrice: "€140",
        image: "https://sematicweb.detie.cn/content/W__51395665.jpg",
        featureCount: 6,
        discount: "18%"
    }
];

// App Detection and Download Logic
class AppManager {
    constructor() {
        this.isIOS = /iPad|iPhone|iPod/.test(navigator.userAgent);
        this.isAndroid = /Android/.test(navigator.userAgent);
        this.isMobile = this.isIOS || this.isAndroid;

        // App Store URL
        this.appURL = 'https://drive.google.com/file/d/1lbDW1BNVDY599gBXOD5RQwjrde2a-91t/view?usp=drive_link';

        // App URL schemes for opening installed apps
        this.appScheme = 'dodoman://';

        this.init();
    }

    init() {
        this.setupEventListeners();
        this.checkForInstalledApp();
    }

    setupEventListeners() {
        // Header app button
        const openAppBtn = document.getElementById('openAppBtn');
        if (openAppBtn) {
            openAppBtn.addEventListener('click', () => {
                this.handleAppOpen();
            });
        }

        // Hero section download button
        document.getElementById('heroDownloadBtn').addEventListener('click', () => {
            this.handleAppDownload();
        });

        // Download buttons in app promotion section
        const androidDownload = document.getElementById('androidDownload');
        if (androidDownload) {
            androidDownload.addEventListener('click', (e) => {
                e.preventDefault();
                this.downloadApp();
            });
        }

        // Gallery CTA buttons
        document.querySelectorAll('.gallery-cta').forEach(btn => {
            btn.addEventListener('click', () => {
                this.handleAppOpen();
            });
        });

        // Modal functionality
        this.setupModal();

        // Mobile menu toggle
        this.setupMobileMenu();

        // Smooth scrolling
        this.setupSmoothScrolling();

        // Language selector
        this.setupLanguageSelector();
    }

    handleAppOpen() {
        if (this.isMobile) {
            this.tryOpenApp();
        } else {
            this.showModal();
        }
    }

    handleAppDownload() {
        // 直接下載 APK
        this.downloadApp();
    }

    tryOpenApp() {
        const startTime = Date.now();

        // Try to open the app
        window.location.href = this.appScheme;

        // If app doesn't open within 2 seconds, redirect to app download
        setTimeout(() => {
            if (Date.now() - startTime < 2500) {
                window.location.href = this.appURL;
            }
        }, 2000);
    }

    downloadApp() {
        window.open(this.appURL, '_blank');
    }

    checkForInstalledApp() {
        // This is a simplified check - in real implementation you might use more sophisticated methods
        if (this.isMobile) {
            // Try to detect if app is installed (this is limited on web)
            // You could use techniques like custom protocol detection
            console.log('Checking for installed app...');
        }
    }

    setupModal() {
        const modal = document.getElementById('appModal');
        const closeBtn = document.getElementById('modalClose');
        const androidBtn = document.getElementById('modalAndroidBtn');
        const webBtn = document.getElementById('modalWebBtn');

        closeBtn.addEventListener('click', () => {
            this.hideModal();
        });

        if (androidBtn) {
            androidBtn.addEventListener('click', () => {
                this.downloadApp();
                this.hideModal();
            });
        }

        webBtn.addEventListener('click', () => {
            this.hideModal();
        });

        // Close modal when clicking outside
        window.addEventListener('click', (e) => {
            if (e.target === modal) {
                this.hideModal();
            }
        });

        // Close modal with escape key
        document.addEventListener('keydown', (e) => {
            if (e.key === 'Escape') {
                this.hideModal();
            }
        });
    }

    showModal() {
        document.getElementById('appModal').style.display = 'block';
        document.body.style.overflow = 'hidden';
    }

    hideModal() {
        document.getElementById('appModal').style.display = 'none';
        document.body.style.overflow = 'auto';
    }

    setupMobileMenu() {
        const mobileMenuToggle = document.getElementById('mobileMenuToggle');
        const navMenu = document.querySelector('.nav-menu');

        mobileMenuToggle.addEventListener('click', () => {
            navMenu.classList.toggle('active');
            mobileMenuToggle.classList.toggle('active');
        });
    }

    setupSmoothScrolling() {
        // Smooth scrolling for anchor links
        document.querySelectorAll('a[href^="#"]').forEach(anchor => {
            anchor.addEventListener('click', function (e) {
                e.preventDefault();
                const target = document.querySelector(this.getAttribute('href'));
                if (target) {
                    target.scrollIntoView({
                        behavior: 'smooth',
                        block: 'start'
                    });
                }
            });
        });
    }

    setupLanguageSelector() {
        const languageBtn = document.getElementById('languageBtn');
        const languageDropdown = document.getElementById('languageDropdown');
        const langOptions = document.querySelectorAll('.lang-option');

        if (!languageBtn || !languageDropdown) return;

        // Toggle dropdown
        languageBtn.addEventListener('click', (e) => {
            e.stopPropagation();
            languageDropdown.classList.toggle('show');
            languageBtn.classList.toggle('active');
        });

        // Handle language selection
        langOptions.forEach(option => {
            option.addEventListener('click', (e) => {
                e.stopPropagation();
                const selectedLang = option.getAttribute('data-lang');

                if (window.i18n) {
                    window.i18n.switchLanguage(selectedLang);
                }

                // Hide dropdown
                languageDropdown.classList.remove('show');
                languageBtn.classList.remove('active');
            });
        });

        // Close dropdown when clicking outside
        document.addEventListener('click', () => {
            languageDropdown.classList.remove('show');
            languageBtn.classList.remove('active');
        });

        // Close dropdown on escape key
        document.addEventListener('keydown', (e) => {
            if (e.key === 'Escape') {
                languageDropdown.classList.remove('show');
                languageBtn.classList.remove('active');
            }
        });
    }
}

// Utility Functions
function scrollToSection(sectionId) {
    const element = document.getElementById(sectionId);
    if (element) {
        element.scrollIntoView({
            behavior: 'smooth',
            block: 'start'
        });
    }
}

// Analytics and Tracking
class Analytics {
    constructor() {
        this.events = [];
    }

    track(event, data = {}) {
        const eventData = {
            event: event,
            timestamp: new Date().toISOString(),
            url: window.location.href,
            userAgent: navigator.userAgent,
            ...data
        };

        this.events.push(eventData);

        // In real implementation, send to analytics service
        console.log('Analytics Event:', eventData);

        // Example: Send to Google Analytics, Facebook Pixel, etc.
        // gtag('event', event, data);
        // fbq('track', event, data);
    }
}

// Performance Optimization
class PerformanceOptimizer {
    constructor() {
        this.init();
    }

    init() {
        this.lazyLoadImages();
        this.preloadCriticalResources();
    }

    lazyLoadImages() {
        const images = document.querySelectorAll('img[data-src]');

        const imageObserver = new IntersectionObserver((entries, observer) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    const img = entry.target;
                    img.src = img.dataset.src;
                    img.classList.remove('lazy');
                    imageObserver.unobserve(img);
                }
            });
        });

        images.forEach(img => imageObserver.observe(img));
    }

    preloadCriticalResources() {
        // Preload critical images
        const criticalImages = [
            'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=2070&q=80'
        ];

        criticalImages.forEach(src => {
            const link = document.createElement('link');
            link.rel = 'preload';
            link.as = 'image';
            link.href = src;
            document.head.appendChild(link);
        });
    }
}

// UI Enhancements
class UIEnhancements {
    constructor() {
        this.init();
    }

    init() {
        this.addScrollEffects();
        this.addHoverEffects();
        this.addLoadingStates();
    }

    addScrollEffects() {
        // Navbar background on scroll
        window.addEventListener('scroll', () => {
            const header = document.querySelector('.header');
            if (window.scrollY > 100) {
                header.style.background = 'rgba(255, 255, 255, 0.98)';
            } else {
                header.style.background = 'rgba(255, 255, 255, 0.95)';
            }
        });

        // Reveal animations on scroll
        const observerOptions = {
            threshold: 0.1,
            rootMargin: '0px 0px -50px 0px'
        };

        const observer = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    entry.target.style.opacity = '1';
                    entry.target.style.transform = 'translateY(0)';
                }
            });
        }, observerOptions);

        // Observe elements for animation
        document.querySelectorAll('.feature-card, .gallery-item, .stat-item').forEach(el => {
            el.style.opacity = '0';
            el.style.transform = 'translateY(30px)';
            el.style.transition = 'opacity 0.6s ease, transform 0.6s ease';
            observer.observe(el);
        });
    }

    addHoverEffects() {
        // Add ripple effect to buttons
        document.querySelectorAll('button, .cta-primary, .cta-secondary').forEach(button => {
            button.addEventListener('click', (e) => {
                const ripple = document.createElement('span');
                const rect = button.getBoundingClientRect();
                const size = Math.max(rect.width, rect.height);
                const x = e.clientX - rect.left - size / 2;
                const y = e.clientY - rect.top - size / 2;

                ripple.style.width = ripple.style.height = size + 'px';
                ripple.style.left = x + 'px';
                ripple.style.top = y + 'px';
                ripple.classList.add('ripple');

                button.appendChild(ripple);

                setTimeout(() => {
                    ripple.remove();
                }, 600);
            });
        });
    }

    addLoadingStates() {
        // Add loading states for buttons that trigger actions
        document.querySelectorAll('.gallery-cta').forEach(btn => {
            btn.addEventListener('click', () => {
                const originalText = btn.textContent;
                btn.textContent = '載入中...';
                btn.disabled = true;

                setTimeout(() => {
                    btn.textContent = originalText;
                    btn.disabled = false;
                }, 1000);
            });
        });
    }
}

// Gallery Manager for Popular Attractions
class GalleryManager {
    constructor() {
        this.attractions = [];
        this.init();
    }

    init() {
        this.loadAttractions();
        this.renderGallery();
        this.setupLanguageChangeListener();
    }

    loadAttractions() {
        // Use shared destination data
        this.attractions = DESTINATION_DATA;
    }

    renderGallery() {
        const galleryGrid = document.getElementById('galleryGrid');
        if (!galleryGrid) return;

        galleryGrid.innerHTML = this.attractions.map(attraction => {
            const i18n = window.i18n;

            // Helper function to safely get translation with fallback
            const safeTranslate = (key, fallback = '') => {
                if (!i18n) return fallback;
                const translation = i18n.t(key);
                // Check if translation is undefined, null, or equals the key (meaning no translation found)
                return (translation && translation !== key) ? translation : fallback;
            };

            const title = safeTranslate(`gallery.${attraction.key}.title`, attraction.key.charAt(0).toUpperCase() + attraction.key.slice(1));
            const subtitle = safeTranslate(`gallery.${attraction.key}.subtitle`, 'Experience');
            const location = safeTranslate(`gallery.${attraction.key}.location`, 'Europe');
            const description = safeTranslate(`gallery.${attraction.key}.desc`, 'Discover amazing experiences and create unforgettable memories.');
            const duration = safeTranslate(`gallery.${attraction.key}.duration`, attraction.duration || '1 Day');
            const badge = safeTranslate(`gallery.${attraction.key}.badge`, 'Featured');
            const bookNow = safeTranslate('package.bookNow', 'Book Now');

            // Generate features list (3 features for attractions)
            const features = [];
            for (let i = 1; i <= 3; i++) {
                const feature = safeTranslate(`gallery.${attraction.key}.feature${i}`, `Feature ${i}`);
                features.push(feature);
            }

            // Determine badge class based on badge text
            let badgeClass = 'featured';
            if (badge === '主打推薦' || badge === 'Featured') {
                badgeClass = 'popular';
            } else if (badge === '藝術殿堂' || badge === 'Art Gallery') {
                badgeClass = 'featured';
            } else if (badge === '經典必遊' || badge === 'Must Visit') {
                badgeClass = 'sale';
            }

            return `
                <div class="gallery-card" data-attraction-id="${attraction.key}">
                    <div class="gallery-image">
                        <img src="${attraction.image}" alt="${title}" loading="lazy" />
                        <div class="gallery-badge ${badgeClass}">${badge}</div>
                        <div class="gallery-discount">-${attraction.discount}</div>
                    </div>
                    <div class="gallery-content">
                        <div class="gallery-header">
                            <h3 class="gallery-title">${title}</h3>
                            <p class="gallery-subtitle">${subtitle}</p>
                            <div class="gallery-location">📍 ${location}</div>
                        </div>
                        <div class="gallery-description">
                            <p>${description}</p>
                        </div>
                        <div class="gallery-features">
                            <ul>
                                ${features.map(feature => `<li>${feature}</li>`).join('')}
                            </ul>
                        </div>
                        <div class="gallery-footer">
                            <div class="gallery-duration">⏱ ${duration}</div>
                            <div class="gallery-pricing">
                                <div class="gallery-pricing-left">
                                    <span class="gallery-original-price">€${attraction.originalPrice.replace('€', '')}</span>
                                    <span class="gallery-price">${attraction.price}</span>
                                </div>
                            </div>
                            <button class="gallery-book-btn" data-attraction-id="${attraction.key}">${bookNow}</button>
                        </div>
                    </div>
                </div>
            `;
        }).join('');
    }

    setupLanguageChangeListener() {
        // Listen for language change events and re-render gallery
        document.addEventListener('languageChanged', () => {
            this.renderGallery();
        });
    }
}

// Package Manager for Package Tours
class PackageManager {
    constructor() {
        this.packages = [];
        this.init();
    }

    init() {
        this.loadPackages();
        this.renderPackages();
        this.setupEventListeners();
        this.setupLanguageChangeListener();
    }

    loadPackages() {
        // Use package data
        this.packages = PACKAGE_DATA;
    }

    renderPackages() {
        const packagesGrid = document.getElementById('packagesGrid');
        if (!packagesGrid) return;

        packagesGrid.innerHTML = this.packages.map(pkg => {
            const i18n = window.i18n;

            // Helper function to safely get translation with fallback
            const safeTranslate = (key, fallback = '') => {
                if (!i18n) return fallback;
                const translation = i18n.t(key);
                return (translation && translation !== key) ? translation : fallback;
            };

            const title = safeTranslate(`package.${pkg.key}.title`, pkg.key.charAt(0).toUpperCase() + pkg.key.slice(1));
            const subtitle = safeTranslate(`package.${pkg.key}.subtitle`, 'Travel Experience');
            const location = safeTranslate(`package.${pkg.key}.location`, 'Europe');
            const description = safeTranslate(`package.${pkg.key}.description`, 'Discover amazing travel experiences with professional guides and memorable adventures.');
            const duration = safeTranslate(`package.${pkg.key}.duration`, '1 Day');
            const badge = safeTranslate(`package.${pkg.key}.badge`, 'Featured');
            const bookNow = safeTranslate('package.bookNow', 'Book Now');

            // Get fallback image based on package key
            const getFallbackImage = (key) => {
                const fallbackImages = {
                    'rome': 'https://images.unsplash.com/photo-1531572753322-ad063cecc140?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
                    'milan': 'https://images.unsplash.com/photo-1513581166391-887a96ddeafd?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
                    'munich': 'https://images.unsplash.com/photo-1595867818082-083862f3d630?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
                    'vatican': 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80'
                };
                return fallbackImages[key] || 'https://images.unsplash.com/photo-1488646953014-85cb44e25828?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80';
            };

            const imageUrl = pkg.image || getFallbackImage(pkg.key);

            // Generate features list
            const features = [];
            for (let i = 1; i <= pkg.featureCount; i++) {
                const feature = safeTranslate(`package.${pkg.key}.feature${i}`, `Feature ${i}`);
                features.push(feature);
            }

            // Determine badge class based on badge text
            let badgeClass = 'featured';
            if (badge === '特價優惠' || badge === 'Special Offer') {
                badgeClass = 'sale';
            } else if (badge === '熱門推薦' || badge === 'Popular Choice') {
                badgeClass = 'popular';
            }

            return `
                <div class="package-card" data-package-id="${pkg.id}">
                    <div class="package-image">
                        <img src="${imageUrl}" alt="${title}" loading="lazy" onerror="this.src='https://images.unsplash.com/photo-1488646953014-85cb44e25828?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80'" />
                        <div class="package-badge ${badgeClass}">${badge}</div>
                        <div class="package-discount">-${pkg.discount}</div>
                    </div>
                    <div class="package-content">
                        <div class="package-header">
                            <h3 class="package-title">${title}</h3>
                            <p class="package-subtitle">${subtitle}</p>
                            <div class="package-location">📍 ${location}</div>
                        </div>
                        <div class="package-description">
                            <p>${description}</p>
                        </div>
                        <div class="package-features">
                            <ul>
                                ${features.map(feature => `<li>${feature}</li>`).join('')}
                            </ul>
                        </div>
                        <div class="package-footer">
                            <div class="package-duration">⏱ ${duration}</div>
                            <div class="package-pricing">
                                <div class="package-pricing-left">
                                    <span class="package-original-price">€${pkg.originalPrice.replace('€', '')}</span>
                                    <span class="package-price">${pkg.price}</span>
                                </div>
                            </div>
                            <button class="package-book-btn" data-package-id="${pkg.id}">${bookNow}</button>
                        </div>
                    </div>
                </div>
            `;
        }).join('');
    }

    setupEventListeners() {
        // Add event listeners for book buttons
        document.addEventListener('click', (e) => {
            if (e.target.classList.contains('package-book-btn')) {
                const packageId = e.target.getAttribute('data-package-id');
                this.handlePackageBooking(packageId);
            }
        });
    }

    setupLanguageChangeListener() {
        // Listen for language change events and re-render packages
        document.addEventListener('languageChanged', () => {
            this.renderPackages();
        });
    }


    handlePackageBooking(packageId) {
        const selectedPackage = this.packages.find(pkg => pkg.id === packageId);
        if (selectedPackage) {
            const i18n = window.i18n;
            const title = i18n ? i18n.t(`package.${selectedPackage.key}.title`) : selectedPackage.key;

            // Track analytics
            if (window.analytics) {
                window.analytics.track('package_booking_clicked', {
                    package_id: packageId,
                    package_title: title,
                    package_price: selectedPackage.price
                });
            }

            // In a real app, this might open booking flow or redirect to booking page
            const currentLang = i18n ? i18n.getCurrentLanguage() : 'zh-TW';
            if (currentLang === 'en') {
                alert(`Booking: ${title}\nPrice: ${selectedPackage.price}\n\nRedirecting to booking page...`);
            } else {
                alert(`準備預訂：${title}\n價格：${selectedPackage.price}\n\n即將跳轉至預訂頁面...`);
            }
        }
    }
}

// Destination Carousel Manager
class DestinationCarousel {
    constructor() {
        this.currentSlide = 0;
        this.slides = [];
        this.autoPlayInterval = null;
        this.autoPlayDelay = 5000; // 5 seconds

        this.init();
    }

    init() {
        this.loadDestinations();
        this.setupEventListeners();
        this.setupLanguageChangeListener();
        this.startAutoPlay();
    }

    loadDestinations() {
        // Use shared destination data
        this.slides = DESTINATION_DATA;

        this.renderCarousel();
        this.renderDots();
    }

    renderCarousel() {
        const track = document.getElementById('carouselTrack');
        if (!track) return;

        track.innerHTML = this.slides.map(slide => {
            const i18n = window.i18n;

            // Helper function to safely get translation with fallback
            const safeTranslate = (key, fallback = '') => {
                if (!i18n) return fallback;
                const translation = i18n.t(key);
                return (translation && translation !== key) ? translation : fallback;
            };

            const title = safeTranslate(`gallery.${slide.key}.title`, slide.key.charAt(0).toUpperCase() + slide.key.slice(1));
            const location = safeTranslate(`gallery.${slide.key}.location`, 'Europe');

            return `
                <div class="carousel-slide">
                    <img src="${slide.image}" alt="${title}" />
                    <div class="carousel-slide-overlay">
                        <div class="carousel-slide-title">${title}</div>
                        <div class="carousel-slide-location">📍 ${location}</div>
                        <div class="carousel-slide-price">${slide.price}</div>
                    </div>
                </div>
            `;
        }).join('');
    }

    renderDots() {
        const dotsContainer = document.getElementById('carouselDots');
        if (!dotsContainer) return;

        dotsContainer.innerHTML = this.slides.map((_, index) => `
            <div class="carousel-dot ${index === 0 ? 'active' : ''}" data-slide="${index}"></div>
        `).join('');

        // Add click event listeners to dots
        dotsContainer.querySelectorAll('.carousel-dot').forEach(dot => {
            dot.addEventListener('click', () => {
                const slideIndex = parseInt(dot.dataset.slide);
                this.goToSlide(slideIndex);
            });
        });
    }

    setupEventListeners() {
        const prevBtn = document.getElementById('carouselPrev');
        const nextBtn = document.getElementById('carouselNext');

        if (prevBtn) {
            prevBtn.addEventListener('click', () => {
                this.prevSlide();
            });
        }

        if (nextBtn) {
            nextBtn.addEventListener('click', () => {
                this.nextSlide();
            });
        }

        // Pause autoplay on hover
        const carousel = document.querySelector('.destination-carousel');
        if (carousel) {
            carousel.addEventListener('mouseenter', () => {
                this.stopAutoPlay();
            });

            carousel.addEventListener('mouseleave', () => {
                this.startAutoPlay();
            });
        }

        // Touch/swipe support for mobile
        this.setupTouchEvents();

        // Keyboard navigation
        document.addEventListener('keydown', (e) => {
            if (e.key === 'ArrowLeft') {
                this.prevSlide();
            } else if (e.key === 'ArrowRight') {
                this.nextSlide();
            }
        });
    }

    setupTouchEvents() {
        const track = document.getElementById('carouselTrack');
        if (!track) return;

        let startX = 0;
        let startTime = 0;
        const minSwipeDistance = 50;
        const maxSwipeTime = 300;

        track.addEventListener('touchstart', (e) => {
            startX = e.touches[0].clientX;
            startTime = Date.now();
        });

        track.addEventListener('touchend', (e) => {
            if (!startX) return;

            const endX = e.changedTouches[0].clientX;
            const endTime = Date.now();
            const distance = Math.abs(endX - startX);
            const duration = endTime - startTime;

            if (distance >= minSwipeDistance && duration <= maxSwipeTime) {
                if (endX < startX) {
                    this.nextSlide(); // Swipe left - next slide
                } else {
                    this.prevSlide(); // Swipe right - previous slide
                }
            }

            startX = 0;
        });
    }

    goToSlide(index) {
        if (index < 0 || index >= this.slides.length) return;

        this.currentSlide = index;
        const track = document.getElementById('carouselTrack');
        if (track) {
            track.style.transform = `translateX(-${index * 100}%)`;
        }

        this.updateDots();
        this.resetAutoPlay();
    }

    nextSlide() {
        const nextIndex = (this.currentSlide + 1) % this.slides.length;
        this.goToSlide(nextIndex);
    }

    prevSlide() {
        const prevIndex = this.currentSlide === 0 ? this.slides.length - 1 : this.currentSlide - 1;
        this.goToSlide(prevIndex);
    }

    updateDots() {
        const dots = document.querySelectorAll('.carousel-dot');
        dots.forEach((dot, index) => {
            dot.classList.toggle('active', index === this.currentSlide);
        });
    }

    startAutoPlay() {
        this.stopAutoPlay(); // Clear any existing interval
        this.autoPlayInterval = setInterval(() => {
            this.nextSlide();
        }, this.autoPlayDelay);
    }

    stopAutoPlay() {
        if (this.autoPlayInterval) {
            clearInterval(this.autoPlayInterval);
            this.autoPlayInterval = null;
        }
    }

    resetAutoPlay() {
        this.stopAutoPlay();
        this.startAutoPlay();
    }

    setupLanguageChangeListener() {
        // Listen for language change events and re-render carousel
        document.addEventListener('languageChanged', () => {
            this.renderCarousel();
        });
    }
}

// Initialize everything when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
    const appManager = new AppManager();
    const analytics = new Analytics();
    const performanceOptimizer = new PerformanceOptimizer();
    const uiEnhancements = new UIEnhancements();
    const galleryManager = new GalleryManager();
    const packageManager = new PackageManager();
    const destinationCarousel = new DestinationCarousel();

    // Track page load
    analytics.track('page_view', {
        page: 'landing_page',
        device_type: appManager.isMobile ? 'mobile' : 'desktop',
        platform: appManager.isAndroid ? 'android' : 'web'
    });

    // Track app interactions
    document.addEventListener('click', (e) => {
        if (e.target.classList.contains('app-btn') ||
            e.target.classList.contains('download-btn') ||
            e.target.id === 'heroDownloadBtn') {
            analytics.track('app_download_attempt', {
                source: e.target.className || e.target.id,
                platform: appManager.isAndroid ? 'android' : 'web'
            });
        }
    });

    // Track carousel interactions
    document.addEventListener('click', (e) => {
        if (e.target.classList.contains('carousel-btn') ||
            e.target.classList.contains('carousel-dot')) {
            analytics.track('carousel_interaction', {
                action: e.target.classList.contains('carousel-btn') ? 'button_click' : 'dot_click',
                current_slide: destinationCarousel.currentSlide
            });
        }
    });

    // Customer Service Email Functionality
    setupCustomerServiceHandlers();

    console.log('DodoMan Landing Page with Destination Carousel initialized successfully!');
});

// Customer Service Email Handler
function setupCustomerServiceHandlers() {
    // Get all customer service buttons
    const orderInquiryBtns = document.querySelectorAll('[data-i18n="customerService.order.button"]');
    const generalInquiryBtns = document.querySelectorAll('[data-i18n="customerService.general.button"]');

    // Handle order inquiry buttons
    orderInquiryBtns.forEach(btn => {
        btn.addEventListener('click', (e) => {
            e.preventDefault();
            handleOrderInquiry();
        });
    });

    // Handle general inquiry buttons
    generalInquiryBtns.forEach(btn => {
        btn.addEventListener('click', (e) => {
            e.preventDefault();
            handleGeneralInquiry();
        });
    });
}

function handleOrderInquiry() {
    const currentLang = window.i18n?.getCurrentLanguage() || 'zh-TW';

    const subjects = {
        'zh-TW': '訂單查詢 - DodoMan 客服',
        'en': 'Order Inquiry - DodoMan Customer Service'
    };

    const bodies = {
        'zh-TW': '親愛的客服團隊，\n\n我需要查詢我的訂單，詳細資訊如下：\n\n訂單編號：[請填入您的訂單編號]\n預訂日期：[請填入預訂日期]\n問題描述：[請描述您的問題]\n\n感謝您的協助！\n\n此致\n[您的姓名]',
        'en': 'Dear Customer Service Team,\n\nI need to inquire about my order. Details are as follows:\n\nOrder Number: [Please enter your order number]\nBooking Date: [Please enter booking date]\nIssue Description: [Please describe your issue]\n\nThank you for your assistance!\n\nBest regards,\n[Your Name]'
    };

    openEmailClient(subjects[currentLang], bodies[currentLang]);
}

function handleGeneralInquiry() {
    const currentLang = window.i18n?.getCurrentLanguage() || 'zh-TW';

    const subjects = {
        'zh-TW': '一般諮詢 - DodoMan 客服',
        'en': 'General Inquiry - DodoMan Customer Service'
    };

    const bodies = {
        'zh-TW': '親愛的客服團隊，\n\n我想諮詢以下問題：\n\n問題類型：[產品諮詢/技術支援/其他]\n詳細描述：[請詳細描述您的問題或需求]\n聯絡方式：[您的電話或其他聯絡方式]\n\n期待您的回覆，謝謝！\n\n此致\n[您的姓名]',
        'en': 'Dear Customer Service Team,\n\nI would like to inquire about the following:\n\nInquiry Type: [Product Information/Technical Support/Other]\nDetailed Description: [Please describe your question or needs in detail]\nContact Information: [Your phone number or other contact method]\n\nLooking forward to your response, thank you!\n\nBest regards,\n[Your Name]'
    };

    openEmailClient(subjects[currentLang], bodies[currentLang]);
}

function openEmailClient(subject, body) {
    const customerServiceEmail = 'howard.mei@onelab.tw';
    const encodedSubject = encodeURIComponent(subject);
    const encodedBody = encodeURIComponent(body);

    const mailtoLink = `mailto:${customerServiceEmail}?subject=${encodedSubject}&body=${encodedBody}`;

    try {
        // Open email client
        window.location.href = mailtoLink;

        // Show feedback message
        showEmailFeedback();
    } catch (error) {
        console.error('Error opening email client:', error);
        // Fallback: copy email to clipboard
        fallbackEmailCopy(customerServiceEmail, subject);
    }
}

function showEmailFeedback() {
    const currentLang = window.i18n?.getCurrentLanguage() || 'zh-TW';

    const messages = {
        'zh-TW': '正在開啟您的郵件應用程式...',
        'en': 'Opening your email application...'
    };

    // Create temporary feedback message
    const feedback = document.createElement('div');
    feedback.style.cssText = `
        position: fixed;
        top: 100px;
        right: 20px;
        background: #2563eb;
        color: white;
        padding: 1rem 1.5rem;
        border-radius: 10px;
        box-shadow: 0 10px 30px rgba(0,0,0,0.2);
        z-index: 10000;
        font-size: 0.9rem;
        animation: slideIn 0.3s ease;
    `;
    feedback.textContent = messages[currentLang];

    // Add animation CSS
    if (!document.querySelector('#emailFeedbackStyle')) {
        const style = document.createElement('style');
        style.id = 'emailFeedbackStyle';
        style.textContent = `
            @keyframes slideIn {
                from { transform: translateX(100%); opacity: 0; }
                to { transform: translateX(0); opacity: 1; }
            }
        `;
        document.head.appendChild(style);
    }

    document.body.appendChild(feedback);

    // Remove feedback after 3 seconds
    setTimeout(() => {
        if (feedback && feedback.parentNode) {
            feedback.remove();
        }
    }, 3000);
}

function fallbackEmailCopy(email, subject) {
    const currentLang = window.i18n?.getCurrentLanguage() || 'zh-TW';

    const messages = {
        'zh-TW': `無法開啟郵件應用程式。客服信箱：${email}`,
        'en': `Unable to open email application. Customer service email: ${email}`
    };

    alert(messages[currentLang]);
}

// Add CSS for ripple effect
const style = document.createElement('style');
style.textContent = `
    button {
        position: relative;
        overflow: hidden;
    }

    .ripple {
        position: absolute;
        border-radius: 50%;
        background: rgba(255, 255, 255, 0.6);
        transform: scale(0);
        animation: rippleEffect 0.6s linear;
        pointer-events: none;
    }

    @keyframes rippleEffect {
        to {
            transform: scale(4);
            opacity: 0;
        }
    }

    /* Mobile menu styles */
    @media (max-width: 768px) {
        .nav-menu.active {
            display: flex;
            position: fixed;
            top: 80px;
            left: 0;
            width: 100%;
            background: white;
            flex-direction: column;
            padding: 2rem;
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.1);
            z-index: 999;
        }

        .mobile-menu-toggle.active span:nth-child(1) {
            transform: rotate(-45deg) translate(-5px, 6px);
        }

        .mobile-menu-toggle.active span:nth-child(2) {
            opacity: 0;
        }

        .mobile-menu-toggle.active span:nth-child(3) {
            transform: rotate(45deg) translate(-5px, -6px);
        }
    }
`;
document.head.appendChild(style);
