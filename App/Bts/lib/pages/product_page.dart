import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_typeahead/flutter_typeahead.dart';
import '../repos/travel_repo.dart';
import '../repos/models/germany_tour_package.dart';
import '../repos/models/german_station.dart';
import '../services/station_service.dart';

class ProductPage extends StatefulWidget {
  final GermanyTourPackage package;

  const ProductPage({
    super.key,
    required this.package,
  });

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  final _formKey = GlobalKey<FormState>();
  late TravelRepo _travelRepo;

  // Form controllers
  GermanStation? _selectedDepartureStation;
  final TextEditingController _departureStationController = TextEditingController();
  String? _selectedDate;
  String? _selectedTime;

  // Search state
  bool _isSearching = false;
  List<dynamic> _searchResults = [];
  String? _errorMessage;

  // Station management
  final StationService _stationService = StationService.instance;
  GermanStation? _arrivalStation;
  bool _isLoadingStations = true;

  @override
  void initState() {
    super.initState();
    // Initialize TravelRepo with API credentials from documentation
    _travelRepo = TravelRepo(
      httpClient: http.Client(),
      baseUrl: 'http://alpha-api.g2rail.com',
      apiKey: 'fa656e6b99d64f309d72d6a8e7284953',
      secret: '9a52b1f7-7c96-4305-8569-1016a55048bc',
    );
    _loadStations();
  }

  Future<void> _loadStations() async {
    try {
      // Find nearest station to tour package location
      final nearestStation = await _stationService.findNearestStation(
        widget.package.latitude,
        widget.package.longitude,
      );

      setState(() {
        _arrivalStation = nearestStation;
        _isLoadingStations = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingStations = false;
        _errorMessage = 'Failed to load station data: $e';
      });
    }
  }


  Future<void> _searchTrains() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDepartureStation == null ||
        _selectedDate == null ||
        _selectedTime == null ||
        _arrivalStation == null) {
      setState(() {
        _errorMessage = 'Please fill in all required fields';
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _errorMessage = null;
      _searchResults.clear();
    });

    try {
      final result = await _travelRepo.getSolutions(
        _selectedDepartureStation!.stationCode,
        _arrivalStation!.stationCode,
        _selectedDate!,
        _selectedTime!,
        1, // adult
        0, // child
        0, // junior
        0, // senior
        0, // infant
      );

      setState(() {
        _isSearching = false;
        if (result['solutions'] != null) {
          _searchResults = result['solutions'];
        } else {
          _errorMessage = 'No train schedules found for the selected criteria';
        }
      });
    } catch (e) {
      setState(() {
        _isSearching = false;
        _errorMessage = 'Failed to search trains: ${e.toString()}';
      });
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );

    if (picked != null) {
      setState(() {
        _selectedTime = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.package.name),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Package Header
                _buildPackageHeader(),
                const SizedBox(height: 24),

                // Search Form
                _buildSearchForm(),
                const SizedBox(height: 24),

                // Search Button
                _buildSearchButton(),
                const SizedBox(height: 24),

                // Error Message
                if (_errorMessage != null) _buildErrorMessage(),

                // Loading Indicator
                if (_isSearching) _buildLoadingIndicator(),

                // Search Results
                if (_searchResults.isNotEmpty) _buildSearchResults(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPackageHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.package.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.package.intro,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.red, size: 18),
                const SizedBox(width: 4),
                Text(
                  widget.package.location,
                  style: const TextStyle(fontSize: 16),
                ),
                const Spacer(),
                Text(
                  '€${widget.package.sellPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Search Train Schedules',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Departure Station Search Field
            _isLoadingStations
                ? const LinearProgressIndicator()
                : Column(
                    children: [
                      TypeAheadField<GermanStation>(
                        controller: _departureStationController,
                        builder: (context, controller, focusNode) {
                          return TextFormField(
                            controller: controller,
                            focusNode: focusNode,
                            decoration: const InputDecoration(
                              labelText: 'Search Departure Station (within 300km)',
                              hintText: 'Type to search stations...',
                              prefixIcon: Icon(Icons.search),
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (_selectedDepartureStation == null || value?.isEmpty == true) {
                                return 'Please select a departure station';
                              }
                              return null;
                            },
                            onChanged: (value) {
                              // Clear selection if user modifies the text
                              if (_selectedDepartureStation != null &&
                                  value != _selectedDepartureStation!.enName) {
                                setState(() {
                                  _selectedDepartureStation = null;
                                });
                              }
                            },
                          );
                        },
                        suggestionsCallback: (pattern) async {
                          return await _stationService.searchFilteredDepartureStations(
                            pattern,
                            _arrivalStation,
                          );
                        },
                        itemBuilder: (context, station) {
                          return ListTile(
                            leading: const Icon(Icons.train),
                            title: Text(station.enName),
                          );
                        },
                        onSelected: (station) {
                          setState(() {
                            _selectedDepartureStation = station;
                            _departureStationController.text = station.enName;
                          });
                        },
                        emptyBuilder: (context) => const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            'No stations found within 300km. Try a different search term.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
                    ],
                  ),
            if (!_isLoadingStations && _arrivalStation != null)
              Padding(
                padding: const EdgeInsets.only(left: 12.0, top: 4.0),
                child: Text(
                  'Search shows stations within 300km of destination',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            const SizedBox(height: 16),

            // Arrival Station (Read-only)
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Arrival Station (Nearest to Tour Location)',
                prefixIcon: Icon(Icons.location_on),
                border: OutlineInputBorder(),
              ),
              controller: TextEditingController(
                text: _arrivalStation?.enName ?? 'Calculating nearest station...',
              ),
              readOnly: true,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),

            // Date Selector
            InkWell(
              onTap: _selectDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Travel Date',
                  prefixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(),
                ),
                child: Text(
                  _selectedDate ?? 'Select Date',
                  style: TextStyle(
                    color: _selectedDate == null ? Colors.grey : Colors.black,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Time Selector
            InkWell(
              onTap: _selectTime,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Departure Time',
                  prefixIcon: Icon(Icons.access_time),
                  border: OutlineInputBorder(),
                ),
                child: Text(
                  _selectedTime ?? 'Select Time',
                  style: TextStyle(
                    color: _selectedTime == null ? Colors.grey : Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchButton() {
    return ElevatedButton(
      onPressed: _isSearching ? null : _searchTrains,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        _isSearching ? 'Searching...' : 'Search Trains',
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Card(
      color: Colors.red[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(32.0),
        child: Center(
          child: Column(
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Searching for available trains...'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available Trains (${_searchResults.length})',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _searchResults.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final result = _searchResults[index];
            return _buildResultCard(result);
          },
        ),
      ],
    );
  }

  Widget _buildResultCard(dynamic result) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                // Departure Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        result['departure_time']?.toString() ?? 'N/A',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        result['departure_station']?.toString() ?? _selectedDepartureStation?.enName ?? 'N/A',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),

                // Arrow
                const Icon(Icons.arrow_forward, color: Colors.blue),

                // Arrival Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        result['arrival_time']?.toString() ?? 'N/A',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        result['arrival_station']?.toString() ?? _arrivalStation?.enName ?? 'N/A',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),

            Row(
              children: [
                // Transportation Type
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.train, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        result['transportation_type']?.toString() ?? 'Train',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),

                // Price
                Text(
                  '€${result['price']?.toString() ?? widget.package.sellPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),

                const SizedBox(width: 16),

                // Book Button
                ElevatedButton(
                  onPressed: () => _bookTrain(result),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Book'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _bookTrain(dynamic result) {
    // Navigate to booking/order page
    // For now, show a dialog as booking functionality needs to be integrated
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Book Train'),
        content: const Text('Booking functionality will be integrated with the order page.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _travelRepo.httpClient.close();
    _departureStationController.dispose();
    super.dispose();
  }
}