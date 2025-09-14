# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a DodoMan landing page website that promotes a travel app. The project is a static website built with vanilla HTML, CSS, and JavaScript focused on showcasing travel experiences and encouraging app downloads.

## Key Features

The landing page includes:
- Hero section with call-to-action for app downloads
- "Why Choose DodoMan?" section
- Popular destinations showcase
- Download DodoMan APP section
- About DodoMan section
- Footer with contact information

## Architecture

This is a simple static website with the following structure:

### Core Files
- `index.html` - Main HTML page with all sections (header, hero, features, destinations, about, footer)
- `styles.css` - Complete CSS styling with responsive design and modern UI components
- `script.js` - JavaScript functionality for:
  - App detection and download logic (`AppManager` class)
  - Mobile app installation detection (iOS/Android)
  - Smooth scrolling navigation
  - Mobile menu toggle functionality
  - Tour data loading and display

### Reference Data
- `Reference/tours.json` - Large JSON file (991KB) containing tour data with destinations across Europe including Rome, Paris, London, Berlin, Madrid, Munich, etc. Each tour includes:
  - Tour name, introduction, highlights
  - Pricing in EUR
  - Location and images
  - Unique tour IDs

### App Integration
The website includes smart app detection:
- Detects iOS/Android platforms
- Attempts to open installed DodoMan app via `dodoman://` scheme
- Falls back to app store URLs if app not installed
- Currently uses placeholder URLs for App Store and Play Store

## Development Commands

This is a static website that can be served directly:

```bash
# Serve locally using Python
python -m http.server 8000

# Or using Node.js
npx serve .

# Or any other static file server
```

## Testing and Deployment

Since this is a static website:
- No build process required
- Can be deployed to any static hosting service (Netlify, Vercel, GitHub Pages, etc.)
- Test by opening `index.html` directly in browser or serving via local server

## Important Notes

- The app store URLs in `script.js:9-10` are currently placeholders and need to be updated with actual store URLs
- Tour data is loaded from a large JSON file - consider pagination or lazy loading for performance
- Mobile responsiveness is implemented throughout the CSS
- All text content is in Traditional Chinese (zh-TW)