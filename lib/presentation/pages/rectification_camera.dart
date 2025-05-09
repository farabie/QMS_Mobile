part of 'pages.dart';

class RectificationCamera extends StatefulWidget {
  final Function(XFile, Position) onImageTaken;

  const RectificationCamera({required this.onImageTaken, super.key});

  @override
  State<RectificationCamera> createState() => _RectificationCameraState();
}

class _RectificationCameraState extends State<RectificationCamera> {
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
    try {
      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        _controller = CameraController(cameras.first, ResolutionPreset.medium);
        _initializeControllerFuture = _controller!.initialize();
        await _initializeControllerFuture;
        if (mounted) setState(() {}); // Only update UI if mounted
      } else {
        print('No cameras found on device.');
      }
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

  Future<void> _takePicture() async {
    try {
      if (_controller != null && _controller!.value.isInitialized) {
        final image = await _controller!.takePicture();
        widget.onImageTaken(image, _currentPosition!);
        Navigator.pop(context);
      } else {
        print('Camera is not initialized.');
      }
    } catch (e) {
      print('Error taking picture: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const ui.Size.fromHeight(60.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                offset: const Offset(0, 3),
                blurRadius: 10,
              ),
            ],
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.only(left: 10),
              child: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.black,
                ),
              ),
            ),
            title: Text(
              'Take Picture',
              style: TextStyle(
                color: AppColor.defaultText,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            centerTitle: true,
          ),
        ),
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              _controller != null &&
              _controller!.value.isInitialized) {
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
