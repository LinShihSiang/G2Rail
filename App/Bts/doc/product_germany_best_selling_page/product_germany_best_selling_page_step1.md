# Product Page - Germany Best-Selling Tickets - Step 1

## Overview
The Germany Best-Selling Tickets page displays filtered tour packages specifically for German destinations (Berlin and Munich) from the `data/Italy_Germany_tours.json` file. This page serves as Step 1 in the user booking journey, allowing users to browse and select German tour packages before proceeding to train timetable queries.

## Data Source & Structure

### Source File
- **File**: `data/Italy_Germany_tours.json`
- **Size**: ~483KB with comprehensive tour data
- **Format**: JSON array of tour package objects

### Tour Package Data Structure
```json
{
  "_id": "TR__6005P2",
  "name": "Skip the line: DDR Museum Berlin",
  "intro": "Experience life in socialist East Germany with a trip to Berlin's award-winning DDR Museum to understand life under the dictatorship of the former DDR government between 1949 and 1989. Avoid the long queues with your skip the line entrance ticket which admits you to all areas of the museum. This interactive museum allows you to sit in an authentic Trabi car, undergo a Stasi interrogation or visit a replicated East German apartment complete with original television programming and more.",
  "highlights": "",
  "price_eur": "12.0",  // Original price - Sell price = (price_eur * 0.9 + 2) rounded to 2 decimal places
  "images": [
    "https://sematicweb.detie.cn/content/N__353640561.jpg"
  ],
  "location": "Berlin"
}
```

### German Destinations
- **Berlin**: Multiple attractions including museums, walking tours, city passes, river cruises
- **Munich**: Various tour packages and experiences
- **Filter Criteria**: `location === "Berlin"` OR `location === "Munich"`

## Architecture Design

### File Structure
```
lib/
├── pages/
│   └── germany_products_page.dart        # Main listing page
├── repos/
│   └── germany_tours_repo.dart           # Data repository
├── models/
│   └── germany_tour_package.dart         # Tour package model
└── widgets/
    └── germany_tour_card.dart            # Tour card component
```

### Data Model
```dart
class GermanyTourPackage {
  final String id;           // from _id
  final String name;         // package name
  final String intro;        // description
  final String priceEur;     // original price in EUR
  final double sellPrice;    // calculated sell price = (priceEur * 0.9 + 2) rounded to 2 decimal places
  final List<String> images; // image URLs
  final String location;     // Berlin or Munich

  const GermanyTourPackage({
    required this.id,
    required this.name,
    required this.intro,
    required this.priceEur,
    required this.sellPrice,
    required this.images,
    required this.location,
  });
}
```

### Repository Layer
```dart
class GermanyToursRepo {
  Future<List<GermanyTourPackage>> getGermanyTours() async {
    // Load and parse Italy_Germany_tours.json
    // Filter for location: "Berlin" or "Munich"
    // Convert to GermanyTourPackage objects
    // Calculate sellPrice = (priceEur * 0.9 + 2) rounded to 2 decimal places for each tour
  }

  List<GermanyTourPackage> filterByLocation(List<GermanyTourPackage> tours, String location) {
    // Additional filtering if needed
  }
}
```

## Page Implementation

### Page Class Structure
```dart
class GermanyProductsPage extends StatefulWidget {
  final GermanyToursRepo repo;

  const GermanyProductsPage({super.key, required this.repo});

  @override
  State<GermanyProductsPage> createState() => _GermanyProductsPageState();
}

class _GermanyProductsPageState extends State<GermanyProductsPage> {
  late Future<List<GermanyTourPackage>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.repo.getGermanyTours();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Germany Best-Selling Tickets'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: FutureBuilder<List<GermanyTourPackage>>(
        future: _future,
        builder: (context, snapshot) {
          // Handle loading, error, and success states
          // Return ListView with GermanyTourCard items
        },
      ),
    );
  }
}
```

## UI Components

### Tour Card Design
Each tour package displays as a card containing:

1. **Image Section**
   - Height: 200px
   - Width: Full width
   - Image source: First URL from `images` array
   - Fallback: Grey placeholder if image fails

2. **Content Section**
   - **Package Name**: Large, bold text
   - **Description**: Up to 3 lines with ellipsis overflow
   - **Price**: Always show the calculated sell price, formatted to two decimal places, with EUR symbol (e.g. `€12.34`).
   - **Navigation Arrow**: Indicates tap interaction

### Card Layout Structure
```dart
Card(
  elevation: 4,
  margin: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
  child: InkWell(
    onTap: () => _navigateToTimetable(tour),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image Container
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(tour.images.first),
              fit: BoxFit.cover,
            ),
            color: Colors.grey[300], // Fallback background
          ),
        ),

        // Content Padding
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Package Name
              Text(
                tour.name,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 8),

              // Description
              Text(
                tour.intro,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 12),

              // Price Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    // Always use sellPrice, formatted to two decimals
                    '€${tour.sellPrice.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.green[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  ),
)
```

## Navigation Flow

### Current Page Flow
```
Home Page → Germany Products Page → Train Timetable Query Page
```

### Navigation Implementation
```dart
void _navigateToTimetable(GermanyTourPackage tour) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => TrainTimetableQueryPage(
        selectedPackage: tour,
      ),
    ),
  );
}
```

### Data Passed to Next Page
The complete `GermanyTourPackage` object is passed, containing:
- **Package ID**: Unique identifier for tracking
- **Package Name**: For display and reference
- **Location**: Destination city (Berlin/Munich)
- **Original Price**: Raw price_eur from JSON
- **Sell Price**: Calculated price ((price_eur * 0.9 + 2) rounded to 2 decimal places) for cost calculation
- **Description**: For context and details
- **Images**: For visual consistency

## Error Handling

### Loading States
1. **Loading**: CircularProgressIndicator while fetching data
2. **Error**: User-friendly error message with retry option
3. **Empty**: "No packages available" message
4. **Success**: Display filtered tour list

### Image Loading
- **Network Images**: Graceful fallback to placeholder
- **Loading Indicator**: Show while image loads
- **Error Handling**: Grey background if image fails

### Data Validation
- Validate JSON structure before parsing
- Handle missing or malformed tour data
- Ensure required fields are present
- Filter out invalid packages

## Performance Considerations

### Data Loading
- Load JSON asynchronously to avoid blocking UI
- Cache parsed data to prevent repeated file reads
- Use FutureBuilder for reactive state management

### Image Optimization
- Implement image caching for network images
- Use placeholder images during loading
- Consider image resizing for better performance

### List Performance
- Use ListView.builder for efficient scrolling
- Implement separator builders for consistent spacing
- Consider pagination if dataset grows large

## Integration Requirements

### Dependencies
```yaml
dependencies:
  flutter: ^3.9.0
  http: ^1.5.0  # For potential API calls
  cached_network_image: ^3.3.0  # For image caching (recommended)
```

### Repository Integration
- Follows existing `ProductRepo` pattern
- Consistent with current architecture
- Easy integration with existing navigation flow

### Model Consistency
- Compatible with existing `Product` model pattern
- Maintains type safety throughout the app
- Supports future API integration

This page serves as the entry point for German tour package selection, providing users with comprehensive information to make informed decisions before proceeding to the train booking process.