# Product Page Implementation Plan - Germany Best-Selling Tickets (Step 2)

## Overview
This document outlines the implementation plan for the Product Page in the G2Rail Flutter app, specifically for Germany Best-Selling Tickets functionality.

## Requirements

### 1. Page Header
- Display package title and description at the top of the page
- Information should be derived from the selected package in `germany_products_page`

### 2. Station Selection
- **Departure Station**: User-searchable text field with autocomplete functionality populated from `en_name` field in `data/80_Germany.xls`
- **Arrival Station**: Automatically calculated as the nearest German train station based on tour package's latitude/longitude coordinates
- **Station Selection Logic**:
  - Load all German stations from `80_Germany.xls` with their `en_name`, coordinates, and other metadata
  - Extract latitude/longitude from the selected tour package
  - Calculate distance to all German stations using haversine formula
  - Select the station with minimum distance as arrival station (also display using `en_name`)
  - **Distance Filtering**: Only search/suggest departure stations that are within a 300 km radius of the destination station to ensure reasonable travel routes
  - **Search Functionality**:
    - Implement real-time search as user types in departure station field
    - Display filtered suggestions based on partial matching of `en_name`
    - Limit search results to stations within 300 km distance constraint
    - Allow selection from search results to populate the field
- Ensure proper validation and user feedback

### 3. Date and Time Selection
- Date picker for travel date selection
- Time picker for departure time preference
- Consider timezone handling for European travel

### 4. Search Functionality
- **Search Button**: Triggers API call when clicked
- **API Integration**: Call G2Rail API to retrieve available schedules
- **Request Type**: Search Request as per API documentation

### 5. API Integration Details
- **API Documentation**: Reference `D:\BTS\G2Rail\App\Bts\doc\G2Rail API Document.pdf`
- **Authentication**:
  - Api-Key: `fa656e6b99d64f309d72d6a8e7284953`
  - Api-Secret: `9a52b1f7-7c96-4305-8569-1016a55048bc`
- **Endpoint**: Use existing `TravelRepo` service with proper authentication headers

### 6. Search Results Display
- Display results in card format below the search form
- Implement scrollable list for multiple results
- Handle loading states and error scenarios

### 7. Result Card Components
Each result card must include:
- **Departure Time**: Formatted time display
- **Arrival Time**: Formatted time display
- **Departure Station**: Station name/code
- **Arrival Station**: Station name/code
- **Transportation Type**: Train type/category
- **Price**: Formatted currency display
- **Book Button**: Action button for booking process

## Technical Implementation Notes

### File Structure
- Main implementation in `lib/pages/product_page.dart`
- API calls through `lib/repos/travel_repo.dart`
- Service layer through `lib/services/order_service.dart`
- German station coordinates data in `data/80_Germany.xls`
- Tour location data in `data/Italy_Germany_tours.json`

### State Management
- Consider using StatefulWidget for form state
- Implement proper loading/error/success states
- Handle user input validation

### API Integration
- Utilize existing G2Rail authentication pattern (MD5 hash with sorted parameters)
- Implement proper error handling for network requests
- Consider async/await patterns for user experience

### Station Data Management
- Load German station data from `80_Germany.xls` including `en_name`, latitude, longitude, and station codes
- Create station model class with fields: `en_name`, `latitude`, `longitude`, `station_code`, etc.
- Cache station data for performance optimization
- Use `en_name` field for all user-facing station displays in search results and station displays
- **Distance-based Filtering**: Filter departure stations to only show those within 300 km of the destination station for practical route planning
- **Search Implementation**: Implement efficient text search through station names with real-time filtering

### Station Distance Calculation
- Implement haversine formula for calculating distances between coordinates
- Formula: `distance = 2 * R * arcsin(sqrt(haversin(Δφ) + cos(φ1) * cos(φ2) * haversin(Δλ)))`
- Where: R = Earth's radius (6371 km), φ = latitude, λ = longitude
- Match stations by coordinates but display using `en_name` field

### UI/UX Considerations
- Follow Material Design guidelines
- Implement proper spacing and typography
- Consider responsive design for different screen sizes
- Add loading indicators and error messages
- **Search Interface**:
  - Implement autocomplete/typeahead functionality for departure station search
  - Show search suggestions in a dropdown or overlay
  - Highlight matching text in search results
  - Handle empty search states and no results scenarios
  - Provide clear visual feedback for selected station

## Dependencies
- Existing dependencies in `pubspec.yaml`
- **Required**: `excel` package for reading `80_Germany.xls` station data and `en_name` fields
- Consider adding `geolocator` package for distance calculations (or implement custom haversine function)
- **Optional**: Consider adding packages for autocomplete functionality if needed (e.g., `flutter_typeahead` or implement custom search widget)

## Next Steps
1. Add `excel` package dependency to `pubspec.yaml`
2. Create German station model class with `en_name`, `latitude`, `longitude`, and `station_code` fields
3. Create station data service to read and parse `80_Germany.xls`, extracting `en_name` and coordinate data
4. Implement haversine distance calculation utility function
5. Update `GermanyTourPackage` model to include latitude/longitude coordinates
6. Replace dropdown station selection in `product_page.dart` with searchable text field using `en_name`
7. Modify station selection logic to use nearest station calculation with `en_name` display
8. Implement 300 km radius filtering for departure stations based on destination station location
9. **Implement search functionality for departure stations**:
   - Create searchable text field with real-time filtering
   - Implement autocomplete/typeahead suggestions
   - Filter suggestions by 300 km distance constraint
   - Handle station selection from search results
10. Integrate with existing TravelRepo for API calls
11. Create result card widget components displaying station `en_name`
12. Implement navigation to booking/order page
13. Add proper error handling and user feedback
14. Test with different search scenarios and `en_name`-based station selection with 300 km filtering

## Related Files
- `lib/pages/germany_products_page.dart` - Source of package data
- `lib/repos/travel_repo.dart` - API integration
- `lib/services/order_service.dart` - Business logic
- `lib/repos/models/germany_tour_package.dart` - Tour package model (needs latitude/longitude fields)
- `data/Italy_Germany_tours.json` - Tour data with location coordinates
- `data/80_Germany.xls` - German train station coordinates database
- `doc/G2Rail API Document.pdf` - API documentation

## Data Structure Analysis

### Tour Package Coordinates (from Italy_Germany_tours.json)
Current tour packages include location coordinates:
- Venice: 45.4408°N, 12.3155°E
- Turin: 45.0703°N, 7.6869°E
- Berlin: 52.52°N, 13.405°E
- Rome: 41.9028°N, 12.4964°E
- Milan: 45.4642°N, 9.19°E
- Munich: 48.1351°N, 11.582°E

### Station Mapping Strategy
1. Load German station data from `80_Germany.xls` including `en_name`, coordinates, and metadata
2. Use `en_name` field for all user-facing station displays (departure search field, arrival station display)
3. For each tour location, calculate distance to all German stations using coordinates
4. Select closest station as default arrival station, displayed using its `en_name`
5. **Distance Filtering Strategy**: Filter departure stations to only include those within 300 km radius of the destination station
   - Calculate distance from each potential departure station to the determined arrival station
   - Only include stations where `distance <= 300 km` in the departure search results
   - This ensures reasonable train route connections and improves user experience by removing impractical long-distance options
6. **Search Strategy**:
   - Implement real-time search filtering as user types
   - Return stations matching the search query within the 300 km constraint
   - Prioritize exact matches and common stations in search results
7. Consider minimum distance thresholds to ensure logical connections

### Excel File Structure Assumptions
The `80_Germany.xls` file is expected to contain columns including:
- `en_name`: English display name for stations (e.g., "Berlin Central Station", "Munich Central Station")
- Coordinate columns: latitude/longitude data for distance calculations
- Additional metadata: station codes, local names, etc.