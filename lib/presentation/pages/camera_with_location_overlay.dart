part of 'pages.dart';

class CameraWithLocationOverlay extends StatefulWidget {
  final Function(XFile, Position) onImageTaken;

  const CameraWithLocationOverlay({required this.onImageTaken, super.key});

  @override
  State<CameraWithLocationOverlay> createState() =>
      _CameraWithLocationOverlayState();
}

class _CameraWithLocationOverlayState extends State<CameraWithLocationOverlay> {
  CameraController? _controller;
  // late Future<void> _initializeControllerFuture;
  Future<void>? _initializeControllerFuture;
  Position? _currentPosition;
  String? _currentAddress;
  final documentations = <XFile>[].obs;
  final panoramicImages = <XFile>[].obs;
  final nearViewImages = <XFile>[].obs;
  final farViewImages = <XFile>[].obs;
  final edtLatitudeInstall = TextEditingController();
  final edtLongitudeInstall = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _getCurrentLocation();
  }

  void _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    _controller = CameraController(
      firstCamera,
      ResolutionPreset.high,
    );

    // try {
    //   _initializeControllerFuture = _controller!.initialize();
    //   await _initializeControllerFuture; // Ensure the controller is fully initialized
    //   if (!mounted) return;
    //   setState(() {});
    // } catch (e) {
    //   print('Error initializing camera: $e');
    // }
    try {
      _initializeControllerFuture = _controller!.initialize().then((_) {
        if (!mounted) return;
        setState(() {}); // Update UI once camera is initialized
      });
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  void _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          distanceFilter: 10,
          accuracy: LocationAccuracy.best,
        ),
      );
      setState(() {
        _currentPosition = position;
        edtLatitudeInstall.text = position.latitude.toString();
        edtLongitudeInstall.text = position.longitude.toString();
      });

      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        setState(() {
          _currentAddress =
              "${placemarks.first.locality}, ${placemarks.first.country}";
        });
      }
    } catch (e) {
      print('Error fetching location: $e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  // Future<void> _takePicture() async {
  //   try {
  //     await _initializeControllerFuture;

  //     // Cek jika _currentPosition null
  //     if (_currentPosition != null) {
  //       final image = await _controller!.takePicture();
  //       widget.onImageTaken(image, _currentPosition!);
  //       Navigator.pop(context);
  //     } else {
  //       // Tampilkan pesan kesalahan jika _currentPosition belum tersedia
  //       print('Position data is not available.');
  //     }
  //   } catch (e) {
  //     print(e);
  //   }
  // }

  Future<void> _takePicture() async {
    try {
      if (_initializeControllerFuture != null) {
        await _initializeControllerFuture; // Ensure the controller is initialized

        // Cek jika _currentPosition null
        if (_currentPosition != null) {
          final image = await _controller!.takePicture();
          widget.onImageTaken(image, _currentPosition!);
          Navigator.pop(context);
        } else {
          print('Position data is not available.');
        }
      } else {
        print('Camera is not initialized.');
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Camera with Location Overlay'),
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: [
                CameraPreview(_controller!),
                Positioned(
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: EdgeInsets.all(10),
                    color: AppColor.defaultText.withOpacity(0.5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Latitude: ${_currentPosition?.latitude ?? 'Loading...'}',
                          style: TextStyle(color: Colors.white),
                        ),
                        Text(
                          'Longitude: ${_currentPosition?.longitude ?? 'Loading...'}',
                          style: TextStyle(color: Colors.white),
                        ),
                        Text(
                          'Location: $_currentAddress',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _takePicture,
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}
