// Shared Destination Data
const DESTINATION_DATA = [
    {
        title: "新天鵝堡探索之旅",
        location: "德國",
        price: "€21 起",
        image: "https://www.travelliker.com.hk/img/upload/img/%E6%96%B0%E5%A4%A9%E9%B5%9D%E5%A0%A102.jpg",
        intro: "探索德國最浪漫的童話城堡",
        badge: "主打推薦"
    },
    {
        title: "烏菲茲美術館藝術之旅",
        location: "佛羅倫斯",
        price: "€35.9 起",
        image: "https://blog-static.kkday.com/zh-hk/blog/wp-content/uploads/shutterstock_673635160-644x444.jpg",
        intro: "義大利文藝復興藝術寶庫",
        badge: "藝術殿堂"
    }
];

// App Detection and Download Logic
class AppManager {
    constructor() {
        this.isIOS = /iPad|iPhone|iPod/.test(navigator.userAgent);
        this.isAndroid = /Android/.test(navigator.userAgent);
        this.isMobile = this.isIOS || this.isAndroid;

        // App Store URL
        this.appURL = 'https://drive.google.com/file/d/1lbDW1BNVDY599gBXOD5RQwjrde2a-91t/view?usp=sharing';

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

// Gallery Manager for Popular Destinations
class GalleryManager {
    constructor() {
        this.slides = [];
        this.init();
    }

    init() {
        this.loadDestinations();
        this.renderGallery();
    }

    loadDestinations() {
        // Use shared destination data
        this.slides = DESTINATION_DATA;
    }

    renderGallery() {
        const galleryGrid = document.getElementById('galleryGrid');
        if (!galleryGrid) return;

        galleryGrid.innerHTML = this.slides.map(slide => `
            <div class="gallery-item large featured fullwidth">
                <img src="${slide.image}" alt="${slide.title}" />
                <div class="gallery-overlay">
                    <div class="featured-badge">${slide.badge}</div>
                    <h3>${slide.title}</h3>
                    <p>${slide.intro}</p>
                    <div class="price-tag">${slide.price}</div>
                    <div class="location-tag">📍 ${slide.location}</div>
                    <!-- <a href="https://drive.google.com/drive/folders/1iToAnV1foN8SU-Kt2eVE-0Hg4NxhDDAo?usp=drive_link" class="gallery-cta primary">立即預訂</a> -->
                </div>
            </div>
        `).join('');
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

        track.innerHTML = this.slides.map(slide => `
            <div class="carousel-slide">
                <img src="${slide.image}" alt="${slide.title}" />
                <div class="carousel-slide-overlay">
                    <div class="carousel-slide-title">${slide.title}</div>
                    <div class="carousel-slide-location">📍 ${slide.location}</div>
                    <div class="carousel-slide-price">${slide.price}</div>
                </div>
            </div>
        `).join('');
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
}

// Initialize everything when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
    const appManager = new AppManager();
    const analytics = new Analytics();
    const performanceOptimizer = new PerformanceOptimizer();
    const uiEnhancements = new UIEnhancements();
    const galleryManager = new GalleryManager();
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

    console.log('DodoMan Landing Page with Destination Carousel initialized successfully!');
});

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