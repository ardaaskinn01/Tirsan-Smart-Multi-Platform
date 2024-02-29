import 'dart:async';
import 'dart:convert';
import 'dart:io' as mobile;
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:win_ble/win_ble.dart' as windowsBluetooth;
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart'
    as flutterBluetooth;
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:typed_data';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_bluetooth_basic/flutter_bluetooth_basic.dart'
    as iosBluetooth;
// import 'dart:html' as web;

void showToast(String message) {
  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    timeInSecForIosWeb: 1,
    backgroundColor: Colors.grey,
    textColor: Colors.white,
    fontSize: 13.0,
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: LayoutBuilder(
          builder: (context, constraints) {
            return Center(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: 850.0, // Maksimum genişlik
                  maxHeight: 850.0, // Maksimum yükseklik
                ),
                child: LoginApp(),
              ),
            );
          },
        ),
        backgroundColor: myCustomColor,
      ),
    );
  }
}

const Color bg = Color(0xFF03123E); // Özel renk kodu
const Color myCustomColor = Color(0xFF2A3688); // Özel renk kodu
const Color myCustomColor2 = Color(0xFF30B7B0); // Özel renk kodu
const Color kirmiziRenk = Color(0xFFFF0000);
const Color yesilRenk = Color(0xFF00FF00);
String deviceName = '';
String deviceName2 = '';
String? torqueData = '';
String? tempData = '';
String? torqueData2 = '';
String? tempData2 = '';
Stream<Uint8List>? inputStream;
Stream<Uint8List>? inputStream2;
late bool isConnectedDevice1;
late bool isConnectedDevice2;
bool changing = false;
int connectionAttempts = 0;
int maxConnectionAttempts = 6;
int connectionAttempts2 = 0;
int maxConnectionAttempts2 = 2147483647;
bool isBluetoothConnected = false;
flutterBluetooth.BluetoothConnection? bluetoothConnection;
flutterBluetooth.BluetoothConnection? bluetoothConnection2;
bool isConnected = false;
bool isConnected2 = false;
iosBluetooth.BluetoothManager bluetoothManager =
    iosBluetooth.BluetoothManager.instance;
int maxDataPoints = 90; // Maksimum gösterilecek veri noktası sayısı
int updateIntervalMillis = 1000; // Saniye güncelleme aralığı
List<dynamic> torqueDataList1 = [];
List<dynamic> torqueDataList2 = [];
List<dynamic> tempDataList1 = [];
List<dynamic> tempDataList2 = [];
bool isVisible = false; // Görünürlük durumunu kontrol eden bir değişken
bool isVisible2 = false; // Görünürlük durumunu kontrol eden bir değişken
bool isVisible3 = false; // Görünürlük durumunu kontrol eden bir değişken
bool isVisible4 = false; // Görünürlük durumunu kontrol eden bir değişken
bool isVisible5 = false; // Görünürlük durumunu kontrol eden bir değişken
// private lateinit var editOffset: EditText;
bool offset = false;
bool offset2 = false;
int div = 1;
int div2 = 1;
int? pressed = null;
bool lowhigh = false;
bool lowhigh2 = false;
bool back = false;
bool back2 = false;
bool isChecked = false;
bool isChecked2 = false;
//Job? myCoroutine = null;
//Job? myCoroutine2 = null;
//Job? myCoroutine3 = null;
ByteData byteData =
    ByteData(1024); // 1024 byte kapasitesinde bir ByteData oluşturun
int lastUpdateTime = 0;
bool retryConnection = false;
int temperatureUpdateInterval = 125; // 0.125 saniye (ms)
String highestTorque = "";
String lowestTorque = "";
String highestTemperature = "";
String lowestTemperature = "";
String highestTorque2 = "";
String lowestTorque2 = "";
String highestTemperature2 = "";
String lowestTemperature2 = "";
bool isOpen = false;
bool isOpen2 = false;
String? outputFile = null;
int hours = 0;
int minutes = 0;
int seconds = 0;
int milliseconds = 0;
int hours2 = 0;
int minutes2 = 0;
int seconds2 = 0;
int milliseconds2 = 0;
int dataCountTorque = 0;
int dataCountTorque2 = 0;
int dataCountTemp = 0;
int dataCountTemp2 = 0;
String sabitTorque = "0";
String sabitTorque2 = "0";
String createdAt = "00-00-0000 00:00:00";
//var workbook = HSSFWorkbook();
//var sheetTorque = workbook.createSheet("Cihaz 1 Tork Verileri");
//var sheetTemp = workbook.createSheet("Cihaz 1 Temp Verileri");
//var sheetTorque2 = workbook.createSheet("Cihaz 2 Tork Verileri");
//var sheetTemp2 = workbook.createSheet("Cihaz 2 Temp Verileri")
//var startTime = SystemClock.elapsedRealtime();
//var handler = Handler();

class LoginApp extends StatefulWidget {
  @override
  _LoginAppState createState() => _LoginAppState();
}

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper.internal();
  factory DatabaseHelper() => _instance;
  static Database? _db;

  DatabaseHelper.internal();

  Future<Database> get db async {
    if (_db != null) {
      return _db!;
    }
    _db = await initDb();
    return _db!;
  }

  Future<Database> initDb() async {
    String path = join(await getDatabasesPath(), 'database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE test_results (
            id INTEGER PRIMARY KEY,
            testName TEXT,
            testDescription TEXT,
            user TEXT,
            status TEXT,
            createdAt TEXT,
            elapsedTime TEXT
          )
        ''');
      },
    );
  }

  Future<void> saveData(String id) async {
    // Burada id'yi kullanarak veritabanına kayıt ekleyin.
  }

  Future<void> deleteData(String id) async {
    // Burada id'yi kullanarak veritabanındaki kaydı silin.
  }
}

class _LoginAppState extends State<LoginApp> {
  TextEditingController kullaniciAdiController = TextEditingController();
  TextEditingController parolaController = TextEditingController();

  void _login(BuildContext context) {
    String girilenKullaniciAdi = kullaniciAdiController.text;
    String girilenParola = parolaController.text;
    String dogruKullaniciAdi = "tirsan";
    String dogruParola = "Trs1957!";

    if (girilenKullaniciAdi == dogruKullaniciAdi &&
        girilenParola == dogruParola) {
      // AnaSayfa'ya yönlendir
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => AnaSayfa(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              "Giriş Başarısız. Lütfen kullanıcı adı ve şifreyi kontrol edin."),
        ),
      );
    }
  }

  @override
  void dispose() {
    kullaniciAdiController.dispose();
    parolaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ColorFiltered(
        colorFilter: ColorFilter.mode(
          bg.withAlpha(20),
          BlendMode.srcATop,
        ),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: 850.0,
            maxWidth: 850.0,
          ), // Constraints için ekstra noktalı virgülü kaldırın
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  image: const DecorationImage(
                    image: AssetImage('assets/images/background.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Align(
                alignment: Alignment(0, -0.85),
                child: FractionallySizedBox(
                  widthFactor: 0.2,
                  heightFactor: 0.16,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: AssetImage('assets/images/logo.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment(0, -0.5),
                child: Text(
                  'TİRSAN KARDAN',
                  style: TextStyle(
                    fontFamily: 'amaranth',
                    fontSize: 33.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Align(
                alignment: Alignment(0, 0),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Container(
                      constraints: BoxConstraints(
                        maxHeight: constraints.maxHeight * 0.28,
                        maxWidth: constraints.maxWidth * 0.75,
                      ),
                      padding: EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Column(
                        children: <Widget>[
                          TextFormField(
                            controller: kullaniciAdiController,
                            decoration: InputDecoration(
                              hintText: 'Username',
                              hintStyle: TextStyle(color: Colors.black),
                            ),
                            style: TextStyle(color: Colors.black),
                          ),
                          TextFormField(
                            controller: parolaController,
                            obscureText: true,
                            decoration: InputDecoration(
                              hintText: 'Password',
                              hintStyle: TextStyle(color: Colors.black),
                            ),
                            style: TextStyle(color: Colors.black),
                          ),
                          SizedBox(height: 25),
                          ElevatedButton(
                            onPressed: () {
                              _login(context);
                            },
                            child: Text(
                              'LOGIN',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16.0,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              primary: Color(0xFF2A3688),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Align(
                alignment: Alignment(0, 1),
                child: FractionallySizedBox(
                  widthFactor: 1.2, // Tam ekran genişliği
                  heightFactor: 0.35,
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        colorFilter: ColorFilter.mode(
                          Colors.white.withAlpha(1),
                          BlendMode.srcATop,
                        ),
                        image: AssetImage('assets/images/logoo.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AnaSayfa extends StatelessWidget {
  Future<List<Map<String, dynamic>>>? _loadMainTests;
  Database? _database;

  AnaSayfa() {
    _loadMainTests = _loadMainTestsData();
  }

  Future<List<Map<String, dynamic>>> _loadMainTestsData() async {
    if (_database == null) {
      // _database henüz initialize edilmediyse, initialize et
      _database = await openDatabase(
        join(await getDatabasesPath(), 'database.db'),
        version: 1,
        onCreate: (db, version) {
          return db.execute('''
            CREATE TABLE test_results (
              id INTEGER PRIMARY KEY,
              testName TEXT,
              testDescription TEXT,
              user TEXT,
              status TEXT,
              createdAt TEXT,
              elapsedTime TEXT
            )
          ''');
        },
      );
    }

    List<Map<String, dynamic>> tests =
    await _database!.query('table', orderBy: 'ROWID DESC', limit: 6);
    return tests;
  }

  Widget loadMainTestsTable(List<Map<String, dynamic>> tests) {
    return Table(
      children: <TableRow>[
        for (Map<String, dynamic> test in tests) ...[
          TableRow(
            children: <Widget>[
              buildTableCell('Save', 15.0, () {
                saveData(test['id'].toString());
              }),
              buildTableCell('Delete', 15.0, () {
                deleteData(test['id'].toString());
              }),
            ],
          ),
        ],
      ],
    );
  }

  Widget buildTableCell(String text, double fontSize, VoidCallback onPressed) {
    return TableCell(
      child: Center(
        child: ElevatedButton(
          onPressed: onPressed,
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: fontSize,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> saveData(String id) async {
    // Save işlemleri burada gerçekleştirilecek
  }

  Future<void> deleteData(String id) async {
    // Delete işlemleri burada gerçekleştirilecek
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'MAIN MENU',
          style: TextStyle(
            color: myCustomColor,
            fontWeight: FontWeight.bold,
            fontSize: 22.0,
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: Center(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: 850.0,
            maxHeight: 850.0,
          ),
          child: ColorFiltered(
            colorFilter: ColorFilter.mode(
              bg.withAlpha(20),
              BlendMode.srcATop,
            ),
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/background.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment(0, 0.301),
                  child: FutureBuilder<List<Map<String, dynamic>>>(
                    future: _loadMainTests,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Database Error');
                      } else {
                        List<Map<String, dynamic>> tests = snapshot.data!;
                        return loadMainTestsTable(tests);
                      }
                    },
                  ),
                ),
                Align(
                  alignment: Alignment(0, -0.75),
                  child: FractionallySizedBox(
                    heightFactor: 0.1,
                    widthFactor: 0.5,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => TestOlustur(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.white,
                        onPrimary: myCustomColor,
                        padding: EdgeInsets.all(16),
                      ),
                      child: Text(
                        'CREATE TEST',
                        style: TextStyle(
                          fontSize: 16.0,
                        ),
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment(0, -0.3),
                  child: FractionallySizedBox(
                    heightFactor: 0.1,
                    widthFactor: 0.5,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => TestList(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.white,
                        onPrimary: myCustomColor,
                        padding: EdgeInsets.all(16),
                      ),
                      child: Text(
                        'TEST LIST',
                        style: TextStyle(
                          fontSize: 16.0,
                        ),
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment(0, 0.175),
                  child: FractionallySizedBox(
                    widthFactor: 1,
                    heightFactor: 0.075,
                    child: Container(
                      color: Colors.white,
                      child: Center(
                        child: Text(
                          'LAST TESTS',
                          style: TextStyle(
                            color: myCustomColor,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      backgroundColor: myCustomColor,
    );
  }
}

class TestOlustur extends StatefulWidget {
  @override
  _TestOlusturState createState() => _TestOlusturState();
}

class Test {
  String testNameText;
  String testDescriptionText;
  String? selectedValue1;
  String selectedValue2;
  String selectedValue3;
  String? selectedValue4;
  String selectedValue5;
  String selectedValue6;
  bool isChecked;
  bool isChecked2;
  String? selectedDeviceAddress1;
  String? selectedDeviceAddress2;

  Test({
    required this.testNameText,
    required this.testDescriptionText,
    this.selectedValue1,
    required this.selectedValue2,
    required this.selectedValue3,
    this.selectedValue4,
    required this.selectedValue5,
    required this.selectedValue6,
    required this.isChecked,
    required this.isChecked2,
    this.selectedDeviceAddress1,
    this.selectedDeviceAddress2,
  }) {
    // Buraya constructor gövdesi ekleyebilirsiniz, ancak şu an için boş bırakıldı.
  }
}

// getDeviceAddress fonksiyonu burada tanımlanıyor
class Device {
  final String deviceName;

  Device({required this.deviceName});

  @override
  String toString() {
    return 'Device: $deviceName';
  }
}

class _TestOlusturState extends State<TestOlustur> {
  Device? webDevice;
  iosBluetooth.BluetoothDevice? iosDevice;
  Device? winDevice;
  Device? winDevice2;
  flutterBluetooth.BluetoothDevice? mobileDevice;
  Device? webDevice2;
  iosBluetooth.BluetoothDevice? iosDevice2;
  flutterBluetooth.BluetoothDevice? mobileDevice2;
  List<dynamic> devices = []; // dynamic olarak tanımlanıyor
  List<dynamic> devices2 = []; // dynamic olarak tanımlanıyor
  TextEditingController testName = TextEditingController();
  TextEditingController testDescription = TextEditingController();
  String selectedValue1 = '';
  String selectedValue2 = 'Not Applicable';
  String selectedValue3 = 'Not Applicable';
  String selectedValue4 = '';
  String selectedValue5 = 'Not Applicable';
  String selectedValue6 = 'Not Applicable';
  String selectedDeviceAddress1 = 'address 1';
  String selectedDeviceAddress2 = 'address 2';
  String desiredUUID = "00001101-0000-1000-8000-00805f9b34fb";

//  final apiService = BluetoothApiService(baseUrl: 'http://localhost:5000/api/bluetooth');

  /*void main() async{
    var handler = const shelf.Pipeline().addMiddleware(shelf.logRequests()).addHandler(_echoRequest);
    var server = await io.serve(handler, 'localhost', 5000);
    print('Server listening on http://${server.address.host}:${server.port}');
    String deviceName = "HedefCihazAdı"; // Hedef cihazın adı
    getDeviceAddress(deviceName).then((address) {
      if (address != null) {
        print("Hedef Cihazın MAC Adresi: $address");
      } else {
        print("Cihaz adresi alınamadı.");
      }
    });
  }

  shelf.Response _echoRequest(shelf.Request request) {
    return shelf.Response.ok('Hello, World!');
  }*/

  void initState() {
    selectedValue1 = '';
    selectedValue2 = 'Not Applicable';
    selectedValue3 = 'Not Applicable';
    selectedValue4 = '';
    selectedValue5 = 'Not Applicable';
    selectedValue6 = 'Not Applicable';
  }

  /* Future<void> sendToUWP() async {
    final socket = web.WebSocket('ws://localhost:5002/deviceshub');

    try {
      await socket.onOpen.first;
      print('WebSocket connected.');

      socket.onMessage.listen((web.MessageEvent event) {
        print("${event.data}");

        try {
          // Gelen string veriyi JSON olarak çöz
          final List<dynamic> responseData = jsonDecode(event.data);

          if (responseData != null && responseData.isNotEmpty) {
            for (var responseItem in responseData) {
              if (responseItem is Map<String, dynamic> &&
                  responseItem.containsKey('command') &&
                  responseItem['command'] == 'getDevices') {
                // İlk öğe bir Map ve command "getDevices" ise, devices listesini al
                final List<dynamic> devices = responseItem['devices'];

                if (devices != null) {
                  for (var cihaz in devices) {
                    print("$cihaz");
                    devices.add(cihaz);
                    devices2.add(cihaz);
                  }
                } else {
                  print('Cihazlar null olarak alındı.');
                }
              } else {
                print('Beklenen "getDevices" komutu bulunamadı.');
              }
            }
          } else {
            print('Gelen veri boş veya bir liste değil.');
          }
        } catch (e) {
          print('JSON çözme hatası: $e');
        }
      });

      // 'getDevices' komutunu gönder
      final message = {'command': 'getDevices'};
      socket.sendString(jsonEncode(message));
    } catch (e) {
      print('WebSocket Hata: $e');
    } finally {
      // WebSocket bağlantısını kapat
      socket.onClose.listen((web.CloseEvent closeEvent) {
        print('WebSocket disconnected.');
      });
    }
  }*/

  getDeviceAddress(String deviceName, int deviceIndex) async {
    try {
      if (kIsWeb || mobile.Platform.isWindows) {
        return null;
      } else if (mobile.Platform.isAndroid) {
        if ((deviceIndex == 1 && isChecked) ||
            (deviceIndex == 2 && isChecked2)) {
          await flutterBluetooth.FlutterBluetoothSerial.instance
              .requestEnable();

          if (deviceIndex == 1) {
            flutterBluetooth.BluetoothDevice? targetDevice =
                devices.firstWhere((device) => device.name == deviceName);
            if (targetDevice != null) {
              // Hedef cihazı bulduysanız MAC adresini döndür
              return targetDevice.address;
            } else {
              showToast("Hedef cihaz bulunamadı: $deviceName");
              return null;
            }
          } else {
            flutterBluetooth.BluetoothDevice? targetDevice =
                devices2.firstWhere((device) => device.name == deviceName);
            if (targetDevice != null) {
              // Hedef cihazı bulduysanız MAC adresini döndür
              return targetDevice.address;
            } else {
              showToast("Hedef cihaz bulunamadı: $deviceName");
              return null;
            }
          }
        }
      } else {
        if ((deviceIndex == 1 && isChecked) ||
            (deviceIndex == 2 && isChecked2)) {
          if (deviceIndex == 1) {
            iosBluetooth.BluetoothDevice targetDevice =
                devices.firstWhere((device) => device.name == deviceName);
            if (targetDevice != null) {
              // Hedef cihazı bulduysanız MAC adresini döndür
              return targetDevice.address;
            } else {
              showToast("Hedef cihaz bulunamadı: $deviceName");
              return null;
            }
          } else {
            iosBluetooth.BluetoothDevice targetDevice =
                devices2.firstWhere((device) => device.name == deviceName);
            if (targetDevice != null) {
              // Hedef cihazı bulduysanız MAC adresini döndür
              return targetDevice.address;
            } else {
              showToast("Hedef cihaz bulunamadı: $deviceName");
              return null;
            }
          }
        } else {
          return null;
        }
      }
    } catch (e) {
      print("Hataaa: $e");
      return null;
    }
  }

  void getPairedDevices() async {
    if (kIsWeb) {
      try {
        // await sendToUWP();
      } catch (e) {
        showToast("Web Error: $e");
      }
    } else if (mobile.Platform.isWindows) {
      //  await sendToUWP();
    } else if (mobile.Platform.isAndroid) {
      // Mobil platformunda çalışırken
      requestPermissions();
      try {
        // Sadece cihaz isimlerini alarak yeni bir liste oluştur
        devices = await flutterBluetooth.FlutterBluetoothSerial.instance
            .getBondedDevices();
        devices2 = await flutterBluetooth.FlutterBluetoothSerial.instance
            .getBondedDevices();
      } catch (error) {
        showToast('Mobile Error: $error');
      }
    } else {
      bluetoothManager.startScan(timeout: Duration(seconds: 1));
      try {
        bluetoothManager.scanResults.listen((results) {
          setState(() {
            devices = results;
            devices2 = results;
          });
        });
      } catch (error) {
        showToast("$error");
      }
    }
  }

  Future<void> requestPermissions() async {
    const bluetoothPermission = Permission.bluetoothConnect;
    final permissionStatus = await bluetoothPermission.request();

    if (permissionStatus.isGranted) {
      // Bluetooth izni verildiğinde yapılacak işlemler
    } else {
      // Bluetooth izni verilmediğinde yapılacak işlemler
    }
  }

  bool getSpinnerEnabled() {
    return isChecked;
  }

  bool getSpinnerEnabled2() {
    return isChecked2;
  }

  @override
  Widget build(BuildContext context) {
    String testNameText = testName.text;
    String testDescriptionText = testDescription.text;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'CREATE TEST',
          style: TextStyle(
            color: myCustomColor,
            fontWeight: FontWeight.bold,
            fontSize: 22.0,
          ),
        ),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: myCustomColor,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Center(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: 850.0,
            maxHeight: 850.0,
          ),
          child: ColorFiltered(
            colorFilter: ColorFilter.mode(
              myCustomColor.withAlpha(50),
              BlendMode.srcATop,
            ),
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/background.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment(0, 0.945), // Özel konum belirleme
                  child: FractionallySizedBox(
                    heightFactor: 0.095,
                    widthFactor: 0.4,
                    child: ElevatedButton(
                      onPressed: () async {
                        Test test = Test(
                          // Test sınıfını oluşturun
                          testNameText: testNameText as String,
                          testDescriptionText: testDescriptionText as String,
                          selectedValue1: selectedValue1,
                          selectedValue2: selectedValue2,
                          selectedValue3: selectedValue3,
                          selectedValue4: selectedValue4,
                          selectedValue5: selectedValue5,
                          selectedValue6: selectedValue6,
                          isChecked: isChecked,
                          isChecked2: isChecked2,
                          selectedDeviceAddress1:
                              await getDeviceAddress(selectedValue1, 1),
                          selectedDeviceAddress2:
                              await getDeviceAddress(selectedValue4, 2),
                        );

                        setState(() {
                          if (isChecked == true && isChecked2 == true) {
                            if (test.testNameText.isEmpty &&
                                test.testDescriptionText.isEmpty) {
                              showToast(
                                  "Lütfen test için isim ve açıklama giriniz");
                            } else if (test.testNameText.isEmpty &&
                                test.testDescriptionText.isNotEmpty) {
                              showToast("Lütfen test için isim giriniz");
                            } else if (test.testNameText.isNotEmpty &&
                                test.testDescriptionText.isEmpty) {
                              showToast("Lütfen test için açıklama giriniz");
                            } else if ((test.selectedValue2 ==
                                        "Not Applicable" &&
                                    test.selectedValue3 == "Not Applicable") ||
                                (test.selectedValue5 == "Not Applicable" &&
                                    test.selectedValue6 == "Not Applicable")) {
                              showToast("Lütfen veri tipi seçiniz");
                            } else {
                              if (test.selectedDeviceAddress1 ==
                                  test.selectedDeviceAddress2) {
                                showToast("Lütfen farklı cihazlar seçiniz");
                              } else {
                                try {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CanliTest(
                                          test:
                                              test), // Test nesnesini burada geçirin
                                    ),
                                  );
                                } catch (e) {
                                  if (e
                                      .toString()
                                      .contains("getDeviceAddress")) {
                                    final deviceAddress =
                                        test.selectedDeviceAddress1;
                                    final deviceAddress2 =
                                        test.selectedDeviceAddress2;
                                    final errorMessage =
                                        "getDeviceAddress hatası. deviceAddress: $deviceAddress, $deviceAddress2, hata: $e";
                                    showToast(
                                        errorMessage); // showToast fonksiyonunu tanımlamış olmanız gerekir
                                  } else {
                                    final errorMessage = "Bir hata oluştu: $e";
                                    showToast(errorMessage);
                                  }
                                }
                              }
                            }
                          } else if (isChecked == true && isChecked2 == false) {
                            if (test.testNameText.isEmpty &&
                                test.testDescriptionText.isEmpty) {
                              showToast(
                                  "Lütfen test için isim ve açıklama giriniz");
                            } else if (test.testNameText.isEmpty &&
                                test.testDescriptionText.isNotEmpty) {
                              showToast("Lütfen test için isim giriniz");
                            } else if (test.testNameText.isNotEmpty &&
                                test.testDescriptionText.isEmpty) {
                              showToast("Lütfen test için açıklama giriniz");
                            } else if ((test.selectedValue2 ==
                                    "Not Applicable" &&
                                test.selectedValue3 == "Not Applicable")) {
                              showToast("Lütfen veri tipi seçiniz.");
                            } else {
                              try {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CanliTest(
                                        test:
                                            test), // Test nesnesini burada geçirin
                                  ),
                                );
                              } catch (e) {
                                if (e.toString().contains("getDeviceAddress")) {
                                  final deviceAddress =
                                      test.selectedDeviceAddress1;
                                  final errorMessage =
                                      "getDeviceAddress hatası. deviceAddress: $deviceAddress, hata: $e";
                                  showToast(
                                      errorMessage); // showToast fonksiyonunu tanımlamış olmanız gerekir
                                } else {
                                  final errorMessage = "Bir hata oluştu: $e";
                                  showToast(errorMessage);
                                }
                              }
                            }
                          } else if (isChecked == false && isChecked2 == true) {
                            if (test.testNameText.isEmpty &&
                                test.testDescriptionText.isEmpty) {
                              showToast(
                                  "Lütfen test için isim ve açıklama giriniz");
                            } else if (test.testNameText.isEmpty &&
                                test.testDescriptionText.isNotEmpty) {
                              showToast("Lütfen test için isim giriniz");
                            } else if (test.testNameText.isNotEmpty &&
                                test.testDescriptionText.isEmpty) {
                              showToast("Lütfen test için açıklama giriniz");
                            } else if ((test.selectedValue5 ==
                                    "Not Applicable" &&
                                test.selectedValue6 == "Not Applicable")) {
                              showToast("Lütfen veri tipi seçiniz.");
                            } else {
                              try {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CanliTest(
                                        test:
                                            test), // Test nesnesini burada geçirin
                                    settings: RouteSettings(
                                        arguments: test), // Veriyi iletmek için
                                  ),
                                );
                              } catch (e) {
                                if (e.toString().contains("getDeviceAddress")) {
                                  final deviceAddress2 =
                                      test.selectedDeviceAddress2;
                                  final errorMessage =
                                      "getDeviceAddress hatası. deviceAddress: $deviceAddress2, hata: $e";
                                  showToast(
                                      errorMessage); // showToast fonksiyonunu tanımlamış olmanız gerekir
                                } else {
                                  final errorMessage = "Bir hata oluştu: $e";
                                  showToast(errorMessage);
                                }
                              }
                            }
                          } else {
                            showToast("Lütfen cihazları aktive edin.");
                          }
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        primary: myCustomColor,
                        onPrimary: Colors.white,
                        padding: EdgeInsets.all(12),
                      ),
                      child: Text(
                        'CREATE',
                        style: TextStyle(
                          fontSize: 19.0,
                        ),
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment(0, -0.945), // Özel konum belirleme
                  child: FractionallySizedBox(
                    heightFactor: 0.09,
                    widthFactor: 0.33,
                    child: ElevatedButton(
                      onPressed: () {
                        getPairedDevices();
                      },
                      style: ElevatedButton.styleFrom(
                        primary: myCustomColor2,
                        onPrimary: Colors.white,
                        padding: EdgeInsets.all(12),
                      ),
                      child: Text(
                        'SCAN',
                        style: TextStyle(
                          fontSize: 16.0,
                        ),
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment(-0.88, -0.67), // Özel konum belirleme
                  child: FractionallySizedBox(
                    widthFactor: 0.45,
                    heightFactor: 0.06,
                    child: Container(
                      color: myCustomColor2, // Arka plan rengi
                      padding: EdgeInsets.all(12),
                      child: Align(
                        alignment:
                            Alignment.center, // Metni yatay olarak ortala
                        child: Text(
                          'TEST NAME',
                          style: TextStyle(
                            color: Colors.white, // Metin rengi
                            fontSize: 14.0, // Metin boyutu
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment(0.88, -0.67), // Özel konum belirleme
                  child: FractionallySizedBox(
                    widthFactor: 0.45,
                    heightFactor: 0.06,
                    child: Container(
                      color: myCustomColor2, // Arka plan rengi
                      padding: EdgeInsets.all(12),
                      child: Align(
                        alignment:
                            Alignment.center, // Metni yatay olarak ortala
                        child: Text(
                          'TEST DESCRIPTION',
                          style: TextStyle(
                            color: Colors.white, // Metin rengi
                            fontSize: 14.0, // Metin boyutu
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment(0.88, 0.365),
                  child: FractionallySizedBox(
                    widthFactor: 0.45, // Genişlik faktörü
                    heightFactor: 0.54, // Yükseklik faktörü
                    child: Container(
                      color: Colors.white, // Beyaz arka plan rengi
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment(-0.88, 0.365),
                  child: FractionallySizedBox(
                    widthFactor: 0.45, // Genişlik faktörü
                    heightFactor: 0.54, // Yükseklik faktörü
                    child: Container(
                      color: Colors.white, // Beyaz arka plan rengi
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment(0.88, -0.536),
                  child: FractionallySizedBox(
                    widthFactor: 0.45, // Genişlik faktörü
                    heightFactor: 0.07, // Yükseklik faktörü
                    child: Container(
                      color: Colors.white, // Beyaz arka plan rengi
                      child: TextFormField(
                        controller: testDescription,
                        style: TextStyle(
                          color: Colors.black, // Metin rengi
                          fontSize: 16.0, // Metin boyutu
                        ),
                        decoration: InputDecoration(
                          labelText: 'Description...',
                        ),
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment(-0.88, -0.536),
                  child: FractionallySizedBox(
                    widthFactor: 0.45, // Genişlik faktörü
                    heightFactor: 0.07, // Yükseklik faktörü
                    child: Container(
                      color: Colors.white, // Beyaz arka plan rengi
                      child: TextFormField(
                        controller: testName,
                        style: TextStyle(
                          color: Colors.black, // Metin rengi
                          fontSize: 16.0, // Metin boyutu
                        ),
                        decoration: InputDecoration(
                          labelText: 'Name...',
                        ),
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment(-0.88, -0.1),
                  child: FractionallySizedBox(
                    widthFactor: 0.35,
                    heightFactor: 0.08,
                    child: kIsWeb
                        ? DropdownButton<Device>(
                            value: webDevice,
                            onChanged: getSpinnerEnabled()
                                ? (newValue) {
                                    setState(() {
                                      webDevice = newValue;
                                      selectedValue1 = newValue?.deviceName ??
                                          'Bilinmeyen Cihaz'; // Aynı zamanda selectedValue1'i de güncelliyoruz.
                                    });
                                  }
                                : null,
                            items: devices.map((device) {
                              return DropdownMenuItem<Device>(
                                value: device,
                                child: Text(
                                    device.deviceName ?? 'Bilinmeyen Cihaz'),
                              );
                            }).toList(),
                          )
                        : mobile.Platform.isWindows
                            ? DropdownButton<Device>(
                                value: winDevice,
                                onChanged: getSpinnerEnabled()
                                    ? (newValue) {
                                        setState(() {
                                          winDevice = newValue;
                                          selectedValue1 = newValue
                                                  ?.deviceName ??
                                              'Bilinmeyen Cihaz'; // Aynı zamanda selectedValue1'i de güncelliyoruz.
                                        });
                                      }
                                    : null,
                                items: devices.map((device) {
                                  return DropdownMenuItem<Device>(
                                    value: device,
                                    child: Text(device.deviceName ??
                                        'Bilinmeyen Cihaz'),
                                  );
                                }).toList(),
                              )
                            : mobile.Platform.isAndroid
                                // Mobil platformdaysanız flutterBluetooth'un DropdownButton'ını kullanın
                                ? DropdownButton<
                                    flutterBluetooth.BluetoothDevice>(
                                    value:
                                        mobileDevice, // Burada, başlangıçta seçili değeri selectedValue1 olarak belirtiyoruz.
                                    onChanged: getSpinnerEnabled()
                                        ? (flutterBluetooth.BluetoothDevice?
                                            newValue) {
                                            setState(() {
                                              mobileDevice =
                                                  newValue; // Kullanıcı bir cihaz seçtiğinde mobileDevice değerini güncelliyoruz.
                                              selectedValue1 = newValue?.name ??
                                                  'Bilinmeyen Cihaz'; // Aynı zamanda selectedValue1'i de güncelliyoruz.
                                            });
                                          }
                                        : null,
                                    items: devices.map((device) {
                                      return DropdownMenuItem<
                                          flutterBluetooth.BluetoothDevice>(
                                        value: device,
                                        child: Text(
                                            device.name ?? 'Bilinmeyen Cihaz'),
                                      );
                                    }).toList(),
                                  )
                                :
                                // Ios platformdaysanız flutterBluetooth'un DropdownButton'ını kullanın
                                DropdownButton<iosBluetooth.BluetoothDevice>(
                                    value:
                                        iosDevice, // Burada, başlangıçta seçili değeri selectedValue1 olarak belirtiyoruz.
                                    onChanged: getSpinnerEnabled()
                                        ? (iosBluetooth.BluetoothDevice?
                                            newValue) {
                                            setState(() {
                                              iosDevice =
                                                  newValue; // Kullanıcı bir cihaz seçtiğinde mobileDevice değerini güncelliyoruz.
                                              selectedValue1 = newValue?.name ??
                                                  'Bilinmeyen Cihaz'; // Aynı zamanda selectedValue1'i de güncelliyoruz.
                                            });
                                          }
                                        : null,
                                    items: devices.map((device) {
                                      return DropdownMenuItem<
                                          iosBluetooth.BluetoothDevice>(
                                        value: device,
                                        child: Text(
                                            device.name ?? 'Bilinmeyen Cihaz'),
                                      );
                                    }).toList(),
                                  ),
                  ),
                ),
                Align(
                  alignment: Alignment(0.6, -0.1),
                  child: FractionallySizedBox(
                    widthFactor: 0.35,
                    heightFactor: 0.08,
                    child: kIsWeb
                        ? DropdownButton<Device>(
                            value: webDevice2,
                            onChanged: getSpinnerEnabled()
                                ? (newValue) {
                                    setState(() {
                                      webDevice2 = newValue;
                                      selectedValue1 = newValue?.deviceName ??
                                          'Bilinmeyen Cihaz'; // Aynı zamanda selectedValue1'i de güncelliyoruz.
                                    });
                                  }
                                : null,
                            items: devices.map((device) {
                              return DropdownMenuItem<Device>(
                                value: device,
                                child: Text(
                                    device.deviceName ?? 'Bilinmeyen Cihaz'),
                              );
                            }).toList(),
                          )
                        : mobile.Platform.isWindows
                            ? DropdownButton<Device>(
                                value: winDevice2,
                                onChanged: getSpinnerEnabled()
                                    ? (newValue) {
                                        setState(() {
                                          winDevice2 = newValue;
                                          selectedValue4 = newValue
                                                  ?.deviceName ??
                                              'Bilinmeyen Cihaz'; // Aynı zamanda selectedValue1'i de güncelliyoruz.
                                        });
                                      }
                                    : null,
                                items: devices2.map((device) {
                                  return DropdownMenuItem<Device>(
                                    value: device,
                                    child: Text(device.deviceName ??
                                        'Bilinmeyen Cihaz'),
                                  );
                                }).toList(),
                              )
                            : mobile.Platform.isAndroid
                                // Mobil platformdaysanız flutterBluetooth'un DropdownButton'ını kullanın
                                ? DropdownButton<
                                    flutterBluetooth.BluetoothDevice>(
                                    value:
                                        mobileDevice2, // Burada, başlangıçta seçili değeri selectedValue1 olarak belirtiyoruz.
                                    onChanged: getSpinnerEnabled2()
                                        ? (flutterBluetooth.BluetoothDevice?
                                            newValue2) {
                                            setState(() {
                                              mobileDevice2 =
                                                  newValue2; // Kullanıcı bir cihaz seçtiğinde mobileDevice değerini güncelliyoruz.
                                              selectedValue4 = newValue2
                                                      ?.name ??
                                                  'Bilinmeyen Cihaz'; // Aynı zamanda selectedValue1'i de güncelliyoruz.
                                            });
                                          }
                                        : null,
                                    items: devices2.map((device) {
                                      return DropdownMenuItem<
                                          flutterBluetooth.BluetoothDevice>(
                                        value: device,
                                        child: Text(
                                            device.name ?? 'Bilinmeyen Cihaz'),
                                      );
                                    }).toList(),
                                  )
                                :
                                // Mobil platformdaysanız flutterBluetooth'un DropdownButton'ını kullanın
                                DropdownButton<iosBluetooth.BluetoothDevice>(
                                    value:
                                        iosDevice2, // Burada, başlangıçta seçili değeri selectedValue1 olarak belirtiyoruz.
                                    onChanged: getSpinnerEnabled2()
                                        ? (iosBluetooth.BluetoothDevice?
                                            newValue2) {
                                            setState(() {
                                              iosDevice2 =
                                                  newValue2; // Kullanıcı bir cihaz seçtiğinde mobileDevice değerini güncelliyoruz.
                                              selectedValue4 = newValue2
                                                      ?.name ??
                                                  'Bilinmeyen Cihaz'; // Aynı zamanda selectedValue1'i de güncelliyoruz.
                                            });
                                          }
                                        : null,
                                    items: devices2.map((device) {
                                      return DropdownMenuItem<
                                          iosBluetooth.BluetoothDevice>(
                                        value: device,
                                        child: Text(
                                            device.name ?? 'Bilinmeyen Cihaz'),
                                      );
                                    }).toList(),
                                  ),
                  ),
                ),
                Align(
                  alignment: Alignment(-0.88, 0.2), // Özel konum belirleme
                  child: FractionallySizedBox(
                    widthFactor: 0.35, // Genişlik faktörü
                    heightFactor: 0.08,
                    child: DropdownButton<String>(
                      value: selectedValue2, // Seçili değeri saklayan değişken
                      onChanged: getSpinnerEnabled()
                          ? (String? newValue) {
                              setState(() {
                                selectedValue2 = newValue!;
                              });
                            }
                          : null,
                      items: <String>['Not Applicable', 'Temperature', 'Torque']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value), // Seçenek metni
                        );
                      }).toList(),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment(-0.88, 0.5), // Özel konum belirleme
                  child: FractionallySizedBox(
                    widthFactor: 0.35, // Genişlik faktörü
                    heightFactor: 0.08,
                    child: DropdownButton<String>(
                      value: selectedValue3, // Seçili değeri saklayan değişken
                      onChanged: getSpinnerEnabled()
                          ? (String? newValue) {
                              setState(() {
                                selectedValue3 = newValue!;
                              });
                            }
                          : null,
                      items: <String>['Not Applicable', 'Temperature', 'Torque']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value), // Seçenek metni
                        );
                      }).toList(),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment(0.6, 0.2), // Özel konum belirleme
                  child: FractionallySizedBox(
                    widthFactor: 0.35, // Genişlik faktörü
                    heightFactor: 0.08,
                    child: DropdownButton<String>(
                      value: selectedValue5, // Seçili değeri saklayan değişken
                      onChanged: getSpinnerEnabled2()
                          ? (String? newValue) {
                              setState(() {
                                selectedValue5 = newValue!;
                              });
                            }
                          : null,
                      items: <String>['Not Applicable', 'Temperature', 'Torque']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value), // Seçenek metni
                        );
                      }).toList(),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment(0.6, 0.5), // Özel konum belirleme
                  child: FractionallySizedBox(
                    widthFactor: 0.35, // Genişlik faktörü
                    heightFactor: 0.08,
                    child: DropdownButton<String>(
                      value: selectedValue6, // Seçili değeri saklayan değişken
                      onChanged: getSpinnerEnabled2()
                          ? (String? newValue) {
                              setState(() {
                                selectedValue6 = newValue!;
                              });
                            }
                          : null,
                      items: <String>['Not Applicable', 'Temperature', 'Torque']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value), // Seçenek metni
                        );
                      }).toList(),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment(
                      -0.91, -0.3075), // Metni yatay ve dikey olarak ortala
                  child: FractionallySizedBox(
                    heightFactor: 0.07,
                    widthFactor: 0.19,
                    child: Text(
                      'DEVICE 1',
                      style: TextStyle(
                        color: myCustomColor, // Metin rengi
                        fontSize: 17.0, // Metin boyutu
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment(
                      0.275, -0.3075), // Metni yatay ve dikey olarak ortala
                  child: FractionallySizedBox(
                    heightFactor: 0.07,
                    widthFactor: 0.19,
                    child: Text(
                      'DEVICE 2',
                      style: TextStyle(
                        color: myCustomColor, // Metin rengi
                        fontSize: 17.0, // Metin boyutu
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment(-0.15, -0.34),
                  child: FractionallySizedBox(
                    heightFactor: 0.07,
                    widthFactor: 0.2,
                    // Checkbox'u yatay ve dikey olarak ortala
                    child: Checkbox(
                      value: isChecked,
                      onChanged: (bool? newValue) {
                        setState(() {
                          isChecked = newValue ?? false;
                        });
                      },
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment(1.05, -0.34),
                  child: FractionallySizedBox(
                    heightFactor: 0.07,
                    widthFactor: 0.2,
                    // Checkbox'u yatay ve dikey olarak ortala
                    child: Checkbox(
                      value: isChecked2,
                      onChanged: (bool? newValue) {
                        setState(() {
                          isChecked2 = newValue ?? false;
                        });
                      },
                    ),
                  ),
                ),
                Align(
                  alignment:
                      Alignment(-0.92, -0.185), // Align widget'ı merkeze hizala
                  child: FractionallySizedBox(
                    widthFactor: 0.2, // Genişlik faktörü
                    heightFactor: 0.03,
                    child: Container(
                      color: myCustomColor, // Beyaz arka plan rengi
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          'CONNECT:',
                          style: TextStyle(
                            color: Colors.white, // Metin rengi (siyah)
                            fontSize: 12.0, // Metin boyutu
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment:
                      Alignment(-0.92, 0.1), // Align widget'ı merkeze hizala
                  child: FractionallySizedBox(
                    widthFactor: 0.2, // Genişlik faktörü
                    heightFactor: 0.03,
                    child: Container(
                      color: myCustomColor, // Beyaz arka plan rengi
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          'SENSOR 1:',
                          style: TextStyle(
                            color: Colors.white, // Metin rengi (siyah)
                            fontSize: 12.0, // Metin boyutu
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment:
                      Alignment(-0.92, 0.385), // Align widget'ı merkeze hizala
                  child: FractionallySizedBox(
                    widthFactor: 0.2, // Genişlik faktörü
                    heightFactor: 0.03,
                    child: Container(
                      color: myCustomColor, // Beyaz arka plan rengi
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          'SENSOR 2:',
                          style: TextStyle(
                            color: Colors.white, // Metin rengi (siyah)
                            fontSize: 12.0, // Metin boyutu
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment:
                      Alignment(0.28, -0.185), // Align widget'ı merkeze hizala
                  child: FractionallySizedBox(
                    widthFactor: 0.2, // Genişlik faktörü
                    heightFactor: 0.03,
                    child: Container(
                      color: myCustomColor, // Beyaz arka plan rengi
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          'CONNECT:',
                          style: TextStyle(
                            color: Colors.white, // Metin rengi (siyah)
                            fontSize: 12.0, // Metin boyutu
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment:
                      Alignment(0.28, 0.1), // Align widget'ı merkeze hizala
                  child: FractionallySizedBox(
                    widthFactor: 0.2, // Genişlik faktörü
                    heightFactor: 0.03,
                    child: Container(
                      color: myCustomColor, // Beyaz arka plan rengi
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          'SENSOR 1:',
                          style: TextStyle(
                            color: Colors.white, // Metin rengi (siyah)
                            fontSize: 12.0, // Metin boyutu
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment:
                      Alignment(0.28, 0.385), // Align widget'ı merkeze hizala
                  child: FractionallySizedBox(
                    widthFactor: 0.2, // Genişlik faktörü
                    heightFactor: 0.03,
                    child: Container(
                      color: myCustomColor, // Beyaz arka plan rengi
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          'SENSOR 2:',
                          style: TextStyle(
                            color: Colors.white, // Metin rengi (siyah)
                            fontSize: 12.0, // Metin boyutu
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      backgroundColor: myCustomColor,
    );
  }
}

class TestList extends StatefulWidget {
  @override
  _TestListState createState() => _TestListState();
}

class _TestListState extends State<TestList> {
  DatabaseHelper? _databaseHelper;
  Database? _database;

  @override
  void initState() {
    super.initState();
    _databaseHelper = DatabaseHelper();
    _initDatabase();
  }

  Future<void> _initDatabase() async {
    _database = await _databaseHelper?.initDb();
  }

  Future<List<Map<String, dynamic>>> _loadTests() async {
    if (_database != null) {
      List<Map<String, dynamic>> tests = await _database!.query('test_results');
      return tests;
    } else {
      return []; // Boş bir liste döndür
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'TEST LIST',
          style: TextStyle(
            color: myCustomColor,
            fontWeight: FontWeight.bold,
            fontSize: 22.0,
          ),
        ),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: myCustomColor,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _loadTests(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            List<Map<String, dynamic>> tests = snapshot.data!;
            return Center(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: 950.0,
                  maxHeight: 950.0,
                ),
                child: ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    myCustomColor.withAlpha(50),
                    BlendMode.srcATop,
                  ),
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(
                              'assets/images/background.jpg',
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment(0, -0.98),
                        child: ListView.builder(
                          itemCount: tests.length + 1,
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              return loadTestsTableHeader();
                            } else {
                              return loadTestsTableRow(tests[index - 1]);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        },
      ),
      backgroundColor: myCustomColor,
    );
  }

  Widget loadTestsTableHeader() {
    return Table(
      border: TableBorder.all(color: Colors.white),
      columnWidths: {
        0: FractionColumnWidth(0.085),
        1: FractionColumnWidth(0.095),
        2: FractionColumnWidth(0.1175),
        3: FractionColumnWidth(0.095),
        4: FractionColumnWidth(0.105),
        5: FractionColumnWidth(0.1275),
        6: FractionColumnWidth(0.11),
        7: FractionColumnWidth(0.1325),
        8: FractionColumnWidth(0.1325),
      },
      children: <TableRow>[
        TableRow(
          children: <Widget>[
            buildTableCell('ID', 13.0),
            buildTableCell('Test Name', 12.0),
            buildTableCell('Description', 12.5),
            buildTableCell('User', 12.5),
            buildTableCell('Status', 12.5),
            buildTableCell('Created At', 12.5),
            buildTableCell('Elapsed Time', 12.0),
            buildTableCell('Save', 15.0),
            buildTableCell('Delete', 15.0),
          ],
        ),
      ],
    );
  }

  Widget buildTableCell(String text, double fontSize) {
    return TableCell(
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontSize: fontSize,
          ),
        ),
      ),
    );
  }

  Widget loadTestsTableRow(Map<String, dynamic> test) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          buildTableCell(test['id'].toString(), 13.0),
          buildTableCell(test['testName'].toString(), 12.0),
          buildTableCell(test['testDescription'].toString(), 12.5),
          buildTableCell(test['user'].toString(), 12.5),
          buildTableCell(test['status'].toString(), 12.5),
          buildTableCell(test['createdAt'].toString(), 12.5),
          buildTableCell(test['elapsedTime'].toString(), 12.0),
          buildTableCell('Save', 15.0),
          buildTableCell('Delete', 15.0),
        ],
      ),
    );
  }

  Widget buildSaveButton(String id) {
    return ElevatedButton(
      onPressed: () {
        _databaseHelper!.saveData(id);
        // İlgili işlemleri gerçekleştirin.
      },
      child: Text('SAVE'),
    );
  }

  Widget buildDeleteButton(String id) {
    return ElevatedButton(
      onPressed: () {
        _databaseHelper!.deleteData(id);
        // İlgili işlemleri gerçekleştirin.
      },
      child: Text('DELETE'),
    );
  }
}

class CanliTest extends StatefulWidget {
  final Test test; // Test nesnesini alacak alan

  CanliTest({required this.test});
  @override
  _CanliTestState createState() => _CanliTestState();
}

class _CanliTestState extends State<CanliTest> {
  Timer? timer;
  Timer? timer2;
  int startTime = 0;
  int startTime2 = 0;
  bool isTimerRunning = false;
  bool isTimerRunning2 = false;
  String createdAt = "";
  int pausedTime = 0;
  int elapsedTime = 0;
  int pausedTime2 = 0;
  int elapsedTime2 = 0;
  bool stopStatus = true;
  bool stopStatus2 = true;
  bool testFinished = true;
  bool testFinished2 = true;
  bool stopReading1 = true;
  bool stopReading2 = true;
  TextEditingController offsetController = TextEditingController();

  void initState() {
    startTime = 0;
    startTime2 = 0;
    torqueData = '';
    torqueData2 = '';
    tempData = '';
    torqueData2 = '';
    String? selectedDevice = widget.test.selectedValue1;
    String? selectedDevice2 = widget.test.selectedValue4;
    deviceName = selectedDevice!;
    deviceName2 = selectedDevice2!;

    if (stopStatus!) {
      startTime = DateTime.now().millisecondsSinceEpoch;
      timer = Timer.periodic(Duration(milliseconds: 100), _updateTimer);
    }
    if (stopStatus2!) {
      startTime2 = DateTime.now().millisecondsSinceEpoch;
      timer2 = Timer.periodic(Duration(milliseconds: 100), _updateTimer2);
    }
    ConnectBluetoothDevice();
    super.initState();
  }

  @override
  void dispose() {
    if (bluetoothConnection != null || bluetoothConnection!.isConnected) {
      bluetoothConnection!.close();
      torqueData = '';
      tempData = '';
    }
    if (bluetoothConnection2 != null || bluetoothConnection2!.isConnected) {
      bluetoothConnection2!.close();
      torqueData2 = '';
      tempData2 = '';
    }
    timer!.cancel();
    timer2!.cancel();
    super.dispose();
  }

  void _updateTimer(Timer timer) {
    elapsedTime =
        DateTime.now().millisecondsSinceEpoch - startTime + pausedTime;
    _updateTimeValues(elapsedTime, 1);
  }

  void _updateTimer2(Timer timer2) {
    elapsedTime2 =
        DateTime.now().millisecondsSinceEpoch - startTime2 + pausedTime2;
    _updateTimeValues(elapsedTime2, 2);
  }

  void _updateTimeValues(int elapsedTime, index) {
    if (index == 1) {
      setState(() {
        hours = (elapsedTime / (1000 * 60 * 60)).toInt();
        minutes = (elapsedTime / (1000 * 60)).toInt();
        seconds = (elapsedTime / 1000 % 60).toInt();
        milliseconds = (elapsedTime % 1000).toInt();
      });
    }
    if (index == 2) {
      setState(() {
        hours2 = (elapsedTime2 / (1000 * 60 * 60)).toInt();
        minutes2 = (elapsedTime2 / (1000 * 60)).toInt();
        seconds2 = (elapsedTime2 / 1000 % 60).toInt();
        milliseconds2 = (elapsedTime2 % 1000).toInt();
      });
    }
  }

  void _pauseTimer(int index) {
    if (index == 1) {
      pausedTime = elapsedTime;
      isTimerRunning = false;
      timer!.cancel();
    } else if (index == 2) {
      pausedTime2 = elapsedTime2;
      isTimerRunning2 = false;
      timer2!.cancel();
    }
  }

  void _resumeTimer(int index) {
    if (index == 1) {
      if (!isTimerRunning) {
        startTime = DateTime.now().millisecondsSinceEpoch;
        isTimerRunning = true;
        timer = Timer.periodic(Duration(milliseconds: 1), _updateTimer);
      }
    } else if (index == 2) {
      if (!isTimerRunning2) {
        startTime2 = DateTime.now().millisecondsSinceEpoch;
        isTimerRunning2 = true;
        timer2 = Timer.periodic(Duration(milliseconds: 1), _updateTimer2);
      }
    }
  }

  String _formatElapsedTime() {
    createdAt = DateFormat('dd-MM-yyyy').format(DateTime.now());
    if (isChecked) {
      String twoDigits(int n) {
        if (n >= 10) return "$n";
        return "0$n";
      }

      return "${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}";
    } else {
      return '';
    }
  }

  String _formatElapsedTime2() {
    if (isChecked2) {
      String twoDigits(int n) {
        if (n >= 10) return "$n";
        return "0$n";
      }

      return "${twoDigits(hours2)}:${twoDigits(minutes2)}:${twoDigits(seconds2)}";
    } else {
      return '';
    }
  }

  void applyNewOffset(index) {
    if (index == 1) {
      setState(() {
        isVisible = false;
        var newDiv = int.parse(offsetController.text);
        div = newDiv;
      });
    } else if (index == 2) {
      setState(() {
        isVisible = false;
        var newDiv2 = int.parse(offsetController.text);
        div = newDiv2;
      });
    }
  }

  void restoreOffset(index) {
    if (index == 1) {
      setState(() {
        isVisible = false;
        div = 1;
      });
      isVisible = false;
    } else if (index == 2) {
      setState(() {
        isVisible = false;
        div2 = 1;
      });
    }
  }

  void closeOffset(index) {
    if (index == 1) {
      setState(() {
        isVisible = false;
        div = 1;
        offset = false;
        lowhigh = false;
      });
      isVisible = false;
    } else if (index == 2) {
      setState(() {
        isVisible = false;
        div2 = 1;
        offset2 = false;
        lowhigh2 = false;
      });
    }
  }

  Future<void> requestPermission2() async {
    final bluetoothPermission = Permission.bluetoothScan;
    final permissionStatus = await bluetoothPermission.request();

    if (permissionStatus.isGranted) {
      // Bluetooth izni verildiğinde yapılacak işlemler
    } else {
      // Bluetooth izni verilmediğinde yapılacak işlemler
    }
  }

  void ConnectBluetoothDevice() async {
    isConnectedDevice1 = false;
    isConnectedDevice2 = false;
    requestPermission2();
    String? deviceAddress1 = widget.test.selectedDeviceAddress1;
    String? deviceAddress2 = widget.test.selectedDeviceAddress2;
    if (kIsWeb || mobile.Platform.isWindows) {
      if (isChecked) {
        await ConnectWithRetry(deviceAddress: deviceAddress1, deviceIndex: 1);
      }
      if (isChecked2) {
        await ConnectWithRetry(deviceAddress: deviceAddress2, deviceIndex: 2);
      }

      if (isConnectedDevice1 && isConnectedDevice2) {
        showToast("Her iki Bluetooth aygıtına da bağlandı");
        finishTest();
        finishTest2();
      } else if (isConnectedDevice1 && !isConnectedDevice2) {
        finishTest();
      } else if (!isConnectedDevice1 && isConnectedDevice2) {
        finishTest2();
      } else {
        cancelCanliTestFragment();
      }
    } else {
      if (deviceAddress1 != null && deviceAddress2 != null) {
        showToast("Bağlanacak cihaz bulunamadı");
        return;
      }
      try {
        if (deviceAddress1 != null) {
          await ConnectWithRetry(deviceAddress: deviceAddress1, deviceIndex: 1);
        }
        if (deviceAddress2 != null) {
          await ConnectWithRetry(deviceAddress: deviceAddress2, deviceIndex: 2);
        }

        if (isConnectedDevice1 && isConnectedDevice2) {
          showToast("Her iki Bluetooth aygıtına da bağlandı");
          finishTest();
          finishTest2();
        } else if (isConnectedDevice1 && !isConnectedDevice2) {
          finishTest();
        } else if (!isConnectedDevice1 && isConnectedDevice2) {
          finishTest2();
        } else {
          cancelCanliTestFragment();
        }
      } catch (e) {
        showToast("Hata oluştu: $e");
      }
    }
  }

  Future<void> ConnectWithRetry(
      {String? deviceAddress, int? deviceIndex}) async {
    connectionAttempts = 0;
    isBluetoothConnected = false;
    Completer<void> connectionCompleter = Completer<void>();
    while (
        !isBluetoothConnected && connectionAttempts < maxConnectionAttempts) {
      try {
        if (deviceIndex == 1) {
          // Yanıtın JSON formatındaki içeriğini çözümle
          if (kIsWeb || mobile.Platform.isWindows) {
            try {
              final String apiUrl =
                  'https://localhost:5002/api/devices/$deviceName';
              final response = await http.get(Uri.parse(apiUrl));

              if (response.statusCode == 200) {
                print(response.body);
                print("1. Cihaz Bağlandı.");
                showToast("1. Cihaz Bağlandı.");
                setState(() {
                  isOpen = true;
                  isConnectedDevice1 = true;
                  isBluetoothConnected = true;
                });
              } else {
                // Yanıt alınamadı
                print('Failed to load devices: ${response.body}');
                torqueData = '';
                tempData = '';
              }
            } catch (error) {
              showToast("$error");
              torqueData = '';
              tempData = '';
            }
          } else if (mobile.Platform.isAndroid) {
            try {
              bluetoothConnection =
                  await flutterBluetooth.BluetoothConnection.toAddress(
                      deviceAddress);
              if (bluetoothConnection!.isConnected) {
                showToast("1. Cihaz Bağlandı.");
                setState(() {
                  isOpen = true;
                  isConnectedDevice1 = true;
                  isBluetoothConnected = true;
                });
              } else {
                showToast("Bağlantı kurulamadı, tekrar deneniyor...");
                torqueData = '';
                tempData = '';
                connectionAttempts++;
                if (connectionAttempts >= maxConnectionAttempts) {
                  connectionCompleter.completeError("Bağlantı hatası");
                }
              }
            } catch (error) {
              showToast("Bağlantı hatası, tekrar deneniyor...");
              torqueData = '';
              tempData = '';
              connectionAttempts++;
              if (connectionAttempts >= maxConnectionAttempts) {
                connectionCompleter.completeError("Bağlantı hatası");
              }
            }
          } else if (mobile.Platform.isIOS) {
            try {
              bool isConnected = await bluetoothManager.isConnected;
              if (isConnected) {
                showToast("1. Cihaz Bağlandı.");
                setState(() {
                  isOpen = true;
                  isConnectedDevice1 = true;
                  isBluetoothConnected = true;
                });
              } else {
                showToast("Bağlantı kurulamadı, tekrar deneniyor...");
                torqueData = '';
                tempData = '';
                connectionAttempts++;
                if (connectionAttempts >= maxConnectionAttempts) {
                  connectionCompleter.completeError("Bağlantı hatası");
                }
              }
            } catch (error) {
              showToast("Bağlantı hatası, tekrar deneniyor... $error");
              torqueData = '';
              tempData = '';
              connectionAttempts++;
              if (connectionAttempts >= maxConnectionAttempts) {
                connectionCompleter.completeError("Bağlantı hatası");
              }
            }
          }
        } else {
          if (kIsWeb || mobile.Platform.isWindows) {
            try {
              final String apiUrl =
                  'https://localhost:5002/api/devices/$deviceName';
              final response = await http.get(Uri.parse(apiUrl));
              print(response.body);
              if (response.statusCode == 200) {
                print("2. Cihaz Bağlandı.");
                showToast("2. Cihaz Bağlandı.");
                setState(() {
                  isOpen2 = true;
                  isConnectedDevice2 = true;
                  isBluetoothConnected = true;
                });
              } else {
                // Yanıt alınamadı
                print('Failed to load devices: ${response.statusCode}');
              }
            } catch (error) {
              showToast("$error");
              torqueData2 = '';
              tempData2 = '';
            }
          } else if (mobile.Platform.isAndroid) {
            try {
              bluetoothConnection2 =
                  await flutterBluetooth.BluetoothConnection.toAddress(
                      deviceAddress);
              if (bluetoothConnection2!.isConnected) {
                showToast("2. Cihaz Bağlandı.");
                setState(() {
                  isOpen2 = true;
                  isConnectedDevice2 = true;
                  isBluetoothConnected = true;
                });
              } else {
                showToast("Bağlantı kurulamadı, tekrar deneniyor...");
                torqueData2 = '';
                tempData2 = '';
                connectionAttempts2++;
                if (connectionAttempts2 >= maxConnectionAttempts2) {
                  connectionCompleter.completeError("Bağlantı hatası");
                }
              }
            } catch (error) {
              showToast("Bağlantı hatası, tekrar deneniyor... $error");
              torqueData2 = '';
              tempData2 = '';
              connectionAttempts2++;
              if (connectionAttempts2 >= maxConnectionAttempts2) {
                connectionCompleter.completeError("Bağlantı hatası");
              }
            }
          } else if (mobile.Platform.isIOS) {}
        }
      } catch (error) {
        connectionAttempts++;
        showToast("Bağlantı kurulamadı, tekrar deneniyor...");
        if (connectionAttempts >= maxConnectionAttempts) {
          connectionCompleter.completeError("Bağlantı hatası");
          break;
        }
      }
    }

    if (isBluetoothConnected) {
      connectionCompleter.complete();
    } else {
      connectionCompleter.completeError("Bağlantı hatası");
    }

    return connectionCompleter.future;
  }

  void cancelCanliTestFragment() {
    Navigator.popUntil(
        context as BuildContext, (route) => route.settings.name == '/AnaSayfa');
  }

  void finishTest() async {
    if (stopStatus) {
      stopStatus = false;
      stopReading1 = false;
      testFinished = false;
      _resumeTimer(1);
      ReadingData({
        'stopReading': stopReading1,
        'stopStatus': stopStatus,
        'bluetoothConnection': bluetoothConnection!,
        'index': 1,
      });
    } else {
      setState(() {
        stopStatus = true;
        stopReading1 = true;
        testFinished = true;
        _pauseTimer(1);
      });
    }
  }

  void finishTest2() async {
    if (stopStatus2) {
      setState(() {
        stopStatus2 = false;
        stopReading2 = false;
        testFinished2 = false;
        _resumeTimer(2);
      });
      await ReadingData({
        'stopReading': stopReading2,
        'stopStatus': stopStatus2,
        'bluetoothConnection': bluetoothConnection2!,
        'index': 2,
      });
    } else {
      setState(() {
        stopStatus2 = true;
        stopReading2 = true;
        testFinished2 = true;
        _pauseTimer(2);
      });
    }
  }

  Future<void> ReadingData(Map<String, dynamic> data) async {
    bool stopReading = data['stopReading'];
    bool stopStatus = data['stopStatus'];
    flutterBluetooth.BluetoothConnection bluetoothConnection =
        data['bluetoothConnection'];
    int index = data['index'];
    String SelectedData = widget.test.selectedValue2;
    String SelectedData2 = widget.test.selectedValue3;
    String SelectedData3 = widget.test.selectedValue5;
    String SelectedData4 = widget.test.selectedValue6;
    String? SelectedDevice = widget.test.selectedValue1;
    String? SelectedDevice2 = widget.test.selectedValue4;
    try {
      inputStream = bluetoothConnection?.input;
      var utf8Decoder = Utf8Decoder();
      var lines = inputStream!.transform(StreamTransformer.fromHandlers(
        handleData: (List<int> data, EventSink<String> sink) {
          var decodedString = utf8Decoder.convert(data);
          sink.add(decodedString);
        },
      )).transform(LineSplitter());

      await for (var line in lines) {
        if (stopReading) {
          break;
        }
        // Gelen veriyi işlemek için ayrı bir fonksiyon kullanabilirsiniz.
        torqueData = processReceivedData(line, SelectedData, SelectedData2,
            SelectedData3, SelectedData4, index, 1);
        tempData = processReceivedData(line, SelectedData, SelectedData2,
            SelectedData3, SelectedData4, index, 2);
      }
    } catch (error) {}
  }

  String? processReceivedData(dynamic line, SelectedData, SelectedData2,
      SelectedData3, SelectedData4, int index, int dataIndex) {
    try {
      if (index == 1 && dataIndex == 1) {
        try {
          if (SelectedData == ('Torque') || SelectedData2 == ('Torque')) {
            RegExp torquePattern = RegExp(r'Torque=\s*(-?(\d+)?)');
            Match? torqueMatch = torquePattern.firstMatch(line);
            if (torqueMatch != null) {
              String? formattedTorque = torqueMatch.group(1);
              if (offset!) {
                try {
                  sabitTorque = (formattedTorque)!;
                  return formattedTorque;
                } catch (error) {
                  showToast("$error");
                }
              } else {
                try {
                  return offsetTorqueData(formattedTorque!, sabitTorque!, index)
                      .toString();
                } catch (error) {
                  showToast("hata1: $error");
                }
              }
            }
          }
        } catch (e) {
          showToast('Error processing data: $e');
        }
      } else if (index == 1 && dataIndex == 2) {
        if (SelectedData == ('Temperature') ||
            SelectedData2 == ('Temperature')) {
          RegExp tempPattern = RegExp(r'Temp=\s*(-?\d+(\.\d+)?)');
          Match? tempMatch = tempPattern.firstMatch(line);
          if (tempMatch != null) {
            var formattedTemp = tempMatch.group(1);
            return formattedTemp;
          }
        }
      } else if (index == 2 && dataIndex == 1) {
        try {
          if (SelectedData3 == ('Torque') || SelectedData4 == ('Torque')) {
            RegExp torquePattern = RegExp(r'Torque=\s*(-?(\d+)?)');
            Match? torqueMatch = torquePattern.firstMatch(line);
            if (torqueMatch != null) {
              var formattedTorque2 = torqueMatch.group(1)!;
              if (offset2!) {
                return formattedTorque2;
              } else {
                return offsetTorqueData(formattedTorque2, sabitTorque2!, index)
                    .toString();
              }
            }
          } else {
            if (SelectedData3 == ('Temperature') ||
                SelectedData4 == ('Temperature')) {
              RegExp tempPattern = RegExp(r'Temp=\s*(-?\d+(\.\d+)?)');
              Match? tempMatch = tempPattern.firstMatch(line);
              if (tempMatch != null) {
                var formattedTemp2 = tempMatch.group(1)!;
                return formattedTemp2;
              }
            }
          }
        } catch (e) {
          showToast('Error processing data: $e');
        }
      }
    } catch (e) {
      showToast('Error processing data: $e');
    }
  }

  dynamic offsetTorqueData(String offsetTorque, String sabitTork, int index) {
    if (index == 1) {
      try {
        var offsetTorque1 =
            ((int.parse(offsetTorque) - int.parse(sabitTork)) / div);
        if (offsetTorque1 != null && lowhigh) {
          if (offsetTorque1 > int.parse(highestTorque)) {
            highestTorque = offsetTorque1 as String;
          }
          if (offsetTorque1 < int.parse(lowestTorque)) {
            lowestTorque = offsetTorque1 as String;
          }
        }
        return offsetTorque1;
      } catch (error) {
        showToast("Hata2: $error");
      }
    } else if (index == 2) {
      var offsetTorque2 =
          ((int.parse(offsetTorque) - int.parse(sabitTork)) / div2);
      if (offsetTorque2 != null && lowhigh2) {
        if (offsetTorque2 > int.parse(highestTorque2)) {
          highestTorque2 = offsetTorque2 as String;
        }
        if (offsetTorque2 < int.parse(lowestTorque2)) {
          lowestTorque2 = offsetTorque2 as String;
        }
      }
      return offsetTorque2;
    }
  }

  String twoDigits(int n) {
    if (n >= 10) return "$n";
    return "0$n";
  }

  Future<void> savePropertiesToDatabase() async {
    showToast("fonksiyona girildi");
    DatabaseHelper dbHelper = DatabaseHelper();
    try {
    Database db = await dbHelper.db;
    String testName = widget.test.testNameText;
    String testDescription = widget.test.testDescriptionText;
    String status = testFinished && testFinished2 ? 'Passive' : 'Active';
    String elapsedTime =
        "${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}";
    ;
    String savedAt = createdAt;
    String id = DateFormat('ddMMHHmmss').format(DateTime.now());


      var values = {
        'id': id,
        'testName': testName,
        'testDescription': testDescription,
        'status': status,
        'createdAt': savedAt,
        'elapsedTime': elapsedTime,
      };

      var result = await db.insert('test_results', values);

      // Diğer işlemler
    } catch (e) {
      showToast("$e");
    } finally {
      await dbHelper.db;
    }

    showToast('Başarıyla kaydedildi');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true, // Başlığı yatay olarak ortala
        title: Text(
          'LIVE TEST',
          style: TextStyle(
            color: myCustomColor,
            fontWeight: FontWeight.bold,
            fontSize: 22.0,
          ),
        ),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back, // Geri dönme tuşu için ikon
            color: myCustomColor, // Geri dönme tuşunun rengi
          ),
          onPressed: () {
            // Geri dönme tuşuna tıklanınca yapılacak işlemleri burada tanımlayabilirsiniz.
            Navigator.of(context).pop(); // Geri dönme işlemi
          },
        ),
      ),
      body: Center(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: 850.0,
            maxHeight: 850.0,
          ),
          child: ColorFiltered(
            colorFilter: ColorFilter.mode(
              myCustomColor.withAlpha(50),
              BlendMode.srcATop,
            ),
            child: Stack(children: [
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                        'assets/images/background.jpg'), // Kullanmak istediğiniz arka plan resminin yolunu belirtin
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Visibility(
                visible:
                    isVisible, // true ise görünür, false ise görünmez olacak
                child: Align(
                  alignment: Alignment(0, -0.2),
                  child: FractionallySizedBox(
                    widthFactor: 0.6,
                    heightFactor: 0.2,
                    child: Container(
                      color: Colors.white54, // Beyaz arkaplan rengi
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextFormField(
                            controller: offsetController,
                            decoration: InputDecoration(
                              hintText: 'Offset...',
                              hintStyle: TextStyle(color: Colors.black),
                            ),
                            style: TextStyle(color: Colors.black),
                          ),
                          SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    if (changing) {
                                      applyNewOffset(1);
                                      changing = false;
                                    } else {
                                      applyNewOffset(2);
                                    }
                                  });
                                },
                                borderRadius: BorderRadius.circular(35),
                                child: Ink(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.blue,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(9),
                                    child:
                                        Icon(Icons.check, color: Colors.green),
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    if (changing) {
                                      restoreOffset(1);
                                      changing = false;
                                    } else {
                                      restoreOffset(2);
                                    }
                                  });
                                },
                                borderRadius: BorderRadius.circular(35),
                                child: Ink(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.blue,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(9),
                                    child: Icon(Icons.restore,
                                        color: Colors.amber),
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    if (changing) {
                                      closeOffset(1);
                                      changing = false;
                                    } else {
                                      closeOffset(2);
                                    }
                                  });
                                },
                                borderRadius: BorderRadius.circular(35),
                                child: Ink(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.blue,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(9),
                                    child: Icon(Icons.clear, color: Colors.red),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Visibility(
                visible:
                    isVisible2, // true ise görünür, false ise görünmez olacak
                child: Align(
                  alignment: Alignment(0, 0.945),
                  child: FractionallySizedBox(
                    widthFactor: 0.6,
                    heightFactor: 0.25,
                    child: Container(
                      color: Colors.white, // Beyaz arkaplan rengi
                      child: Center(
                        child: Text(
                          'Merhaba, bu bir Container!',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Visibility(
                visible:
                    isVisible3, // true ise görünür, false ise görünmez olacak
                child: Align(
                  alignment: Alignment(0, 0.945),
                  child: FractionallySizedBox(
                    widthFactor: 0.6,
                    heightFactor: 0.6,
                    child: Container(
                      color: Colors.white, // Beyaz arkaplan rengi
                      child: Center(
                        child: Text(
                          'Merhaba, bu bir Container!',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Visibility(
                visible:
                    isVisible4, // true ise görünür, false ise görünmez olacak
                child: Align(
                  alignment: Alignment(0, 0.945),
                  child: FractionallySizedBox(
                    widthFactor: 0.6,
                    heightFactor: 0.6,
                    child: Container(
                      color: Colors.white, // Beyaz arkaplan rengi
                      child: Center(
                        child: Text(
                          'Merhaba, bu bir Container!',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Visibility(
                visible:
                    isVisible5, // true ise görünür, false ise görünmez olacak
                child: Align(
                  alignment: Alignment(0, 0.945),
                  child: FractionallySizedBox(
                    widthFactor: 0.6,
                    heightFactor: 0.6,
                    child: Container(
                      color: Colors.white, // Beyaz arkaplan rengi
                      child: Center(
                        child: Text(
                          'Merhaba, bu bir Container!',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment(-0.8, -0.925),
                child: FractionallySizedBox(
                  widthFactor: 0.2,
                  heightFactor: 0.06,
                  child: ElevatedButton(
                    onPressed: () {
                      // Butona tıklama işlemini burada belirleyebilirsiniz.
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.white, // Buton rengi
                      onPrimary: myCustomColor, // Buton metin rengi
                    ),
                    child: Align(
                      alignment: Alignment.center, // Metni yatay olarak ortala
                      child: Text(
                        'TORQUE GRAPHIC',
                        style: TextStyle(
                          fontSize: 11.0, // Metin boyutu
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment(0.8, -0.925),
                child: FractionallySizedBox(
                  widthFactor: 0.2,
                  heightFactor: 0.06,
                  child: ElevatedButton(
                    onPressed: () {
                      // Butona tıklama işlemini burada belirleyebilirsiniz.
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.white, // Buton rengi
                      onPrimary: myCustomColor, // Buton metin rengi
                    ),
                    child: Align(
                      alignment: Alignment.center, // Metni yatay olarak ortala
                      child: Text(
                        'TEMP GRAPHIC',
                        style: TextStyle(
                          fontSize: 11.0, // Metin boyutu
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment(-0.9, -0.525),
                child: FractionallySizedBox(
                  widthFactor: 0.28,
                  heightFactor: 0.06,
                  child: ElevatedButton(
                    onPressed: () {
                      savePropertiesToDatabase();
                      // Butona tıklama işlemini burada belirleyebilirsiniz.
                    },
                    style: ElevatedButton.styleFrom(
                      primary: myCustomColor2, // Buton rengi
                      onPrimary: Colors.white, // Buton metin rengi
                    ),
                    child: Text(
                      'SAVE',
                      style: TextStyle(fontSize: 15.0),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment(0, -0.525),
                child: FractionallySizedBox(
                  widthFactor: 0.28,
                  heightFactor: 0.06,
                  child: ElevatedButton(
                    onPressed: () {
                      isVisible = true;
                      if (offset == false) {
                        changing = true;
                        offset = true;
                        lowhigh = true;
                      } else {
                        changing = true;
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.white, // Buton rengi
                      onPrimary: myCustomColor, // Buton metin rengi
                    ),
                    child: Text(
                      'OFFSET',
                      style: TextStyle(
                          fontSize: 15.0, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment(0.9, -0.525),
                child: FractionallySizedBox(
                  widthFactor: 0.28,
                  heightFactor: 0.06,
                  child: ElevatedButton(
                    onPressed: () {
                      finishTest();
                    },
                    style: ElevatedButton.styleFrom(
                      primary: stopReading1
                          ? yesilRenk
                          : kirmiziRenk, // Duruma göre renk seçimi
                      onPrimary: Colors.white, // Buton metin rengi
                    ),
                    child: Text(
                      stopReading1
                          ? 'START'
                          : 'STOP', // Duruma göre metin seçimi
                      style: TextStyle(fontSize: 15.0),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment(-0.8, 0.1),
                child: FractionallySizedBox(
                  widthFactor: 0.2,
                  heightFactor: 0.06,
                  child: ElevatedButton(
                    onPressed: () {
                      // Butona tıklama işlemini burada belirleyebilirsiniz.
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.white, // Buton rengi
                      onPrimary: myCustomColor, // Buton metin rengi
                    ),
                    child: Text(
                      'TORQUE GRAPHIC',
                      style: TextStyle(
                        fontSize: 11.0, // Metin boyutu
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment(0.8, 0.1),
                child: FractionallySizedBox(
                  widthFactor: 0.2,
                  heightFactor: 0.06,
                  child: ElevatedButton(
                    onPressed: () {
                      // Butona tıklama işlemini burada belirleyebilirsiniz.
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.white, // Buton rengi
                      onPrimary: myCustomColor, // Buton metin rengi
                    ),
                    child: Text(
                      'TEMP GRAPHIC',
                      style: TextStyle(
                        fontSize: 11.0, // Metin boyutu
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment(-0.9, 0.5),
                child: FractionallySizedBox(
                  widthFactor: 0.28,
                  heightFactor: 0.06,
                  child: ElevatedButton(
                    onPressed: () {
                      savePropertiesToDatabase();
                      // Butona tıklama işlemini burada belirleyebilirsiniz.
                    },
                    style: ElevatedButton.styleFrom(
                      primary: myCustomColor2, // Buton rengi
                      onPrimary: Colors.white, // Buton metin rengi
                    ),
                    child: Text(
                      'SAVE',
                      style: TextStyle(fontSize: 15.0),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment(0, 0.5),
                child: FractionallySizedBox(
                  widthFactor: 0.28,
                  heightFactor: 0.06,
                  child: ElevatedButton(
                    onPressed: () {
                      isVisible = true;
                      lowhigh2 = true;
                      offset2 = true;
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.white, // Buton rengi
                      onPrimary: myCustomColor, // Buton metin rengi
                    ),
                    child: Text(
                      'OFFSET',
                      style: TextStyle(
                          fontSize: 15.0, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment(0.9, 0.5),
                child: FractionallySizedBox(
                  widthFactor: 0.28,
                  heightFactor: 0.06,
                  child: ElevatedButton(
                    onPressed: () {
                      finishTest2();
                    },
                    style: ElevatedButton.styleFrom(
                      primary: stopReading2
                          ? yesilRenk
                          : kirmiziRenk, // Duruma göre renk seçimi
                      onPrimary: Colors.white, // Buton metin rengi
                    ),
                    child: Text(
                      stopReading2
                          ? 'START'
                          : 'STOP', // Duruma göre metin seçimi
                      style: TextStyle(fontSize: 15.0),
                    ),
                  ),
                ),
              ),
              Align(
                alignment:
                    Alignment(0, -0.925), // Align widget'ı merkeze hizala
                child: FractionallySizedBox(
                  widthFactor: 0.28, // Genişlik faktörü
                  heightFactor: 0.06,
                  child: Container(
                    color: Colors.white, // Beyaz arka plan rengi
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        'Device 1',
                        style: TextStyle(
                          color: myCustomColor, // Metin rengi (siyah)
                          fontSize: 16.0, // Metin boyutu
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment(0, 0.1), // Align widget'ı merkeze hizala
                child: FractionallySizedBox(
                  widthFactor: 0.28, // Genişlik faktörü
                  heightFactor: 0.06,
                  child: Container(
                    color: Colors.white, // Beyaz arka plan rengi
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        'Device 2',
                        style: TextStyle(
                          color: myCustomColor, // Metin rengi (siyah)
                          fontSize: 16.0, // Metin boyutu
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment(0, -0.77),
                child: Table(
                  border: TableBorder.all(color: Colors.white),
                  columnWidths: {
                    0: FractionColumnWidth(0.1175),
                    1: FractionColumnWidth(0.1225),
                    2: FractionColumnWidth(0.1525),
                    3: FractionColumnWidth(0.1425),
                    4: FractionColumnWidth(0.1225),
                    5: FractionColumnWidth(0.11),
                    6: FractionColumnWidth(0.1225),
                    7: FractionColumnWidth(0.11),
                  },
                  children: <TableRow>[
                    TableRow(
                      children: <Widget>[
                        TableCell(
                          child: Padding(
                            padding: EdgeInsets.all(2),
                            child: Align(
                              alignment: Alignment.center, // Metni ortala
                              child: Text(
                                'Device Name',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Text(
                            'Elapsed Time',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11.0,
                            ),
                          ),
                        ),
                        TableCell(
                          child: Padding(
                            padding: EdgeInsets.all(2),
                            child: Text(
                              'Torque (Nm)',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Padding(
                            padding: EdgeInsets.all(2),
                            child: Text(
                              'Temp (C°)',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Padding(
                            padding: EdgeInsets.all(2),
                            child: Text(
                              'Highest Torque',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12.0,
                              ),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Padding(
                            padding: EdgeInsets.all(2),
                            child: Text(
                              'Lowest Torque',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12.0,
                              ),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Padding(
                            padding: EdgeInsets.all(2),
                            child: Text(
                              'Highest Temp',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12.0,
                              ),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Padding(
                            padding: EdgeInsets.all(2),
                            child: Text(
                              'Lowest Temp',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12.0,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    TableRow(
                      children: <TableCell>[
                        TableCell(
                          child: Container(
                            padding: EdgeInsets.all(6),
                            child: Text(
                              '$deviceName', // Veriyi buraya ekleyin
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11.0,
                              ),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Container(
                            padding: EdgeInsets.all(6),
                            child: Text(
                              _formatElapsedTime(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Container(
                            padding: EdgeInsets.all(6),
                            child: Text(
                              '$torqueData', // Veriyi buraya ekleyin
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Container(
                            padding: EdgeInsets.all(6),
                            child: Text(
                              '$tempData', // Veriyi buraya ekleyin
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Container(
                            padding: EdgeInsets.all(6),
                            child: Text(
                              '$highestTorque', // Veriyi buraya ekleyin
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Container(
                            padding: EdgeInsets.all(6),
                            child: Text(
                              '$lowestTorque', // Veriyi buraya ekleyin
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Container(
                            padding: EdgeInsets.all(6),
                            child: Text(
                              '$highestTemperature', // Veriyi buraya ekleyin
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Container(
                            padding: EdgeInsets.all(6),
                            child: Text(
                              '$lowestTemperature', // Veriyi buraya ekleyin
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment(0, 0.275),
                child: Table(
                  border: TableBorder.all(color: Colors.white),
                  columnWidths: {
                    0: FractionColumnWidth(0.1175),
                    1: FractionColumnWidth(0.1225),
                    2: FractionColumnWidth(0.1525),
                    3: FractionColumnWidth(0.1425),
                    4: FractionColumnWidth(0.1225),
                    5: FractionColumnWidth(0.11),
                    6: FractionColumnWidth(0.1225),
                    7: FractionColumnWidth(0.11),
                  },
                  children: <TableRow>[
                    TableRow(
                      children: <TableCell>[
                        TableCell(
                          child: Padding(
                            padding: EdgeInsets.all(2),
                            child: Align(
                              alignment: Alignment.center,
                              child: Text('Device Name',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12.0,
                                  )),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Padding(
                            padding: EdgeInsets.all(2),
                            child: Text('Elapsed Time',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.0,
                                )),
                          ),
                        ),
                        TableCell(
                          child: Padding(
                            padding: EdgeInsets.all(2),
                            child: Text('Torque (Nm)',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.bold,
                                )),
                          ),
                        ),
                        TableCell(
                          child: Padding(
                            padding: EdgeInsets.all(2),
                            child: Text('Temp (C°)',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.bold,
                                )),
                          ),
                        ),
                        TableCell(
                          child: Padding(
                            padding: EdgeInsets.all(2),
                            child: Text('Highest Torque',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.0,
                                )),
                          ),
                        ),
                        TableCell(
                          child: Padding(
                            padding: EdgeInsets.all(2),
                            child: Text('Lowest Torque',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.0,
                                )),
                          ),
                        ),
                        TableCell(
                          child: Padding(
                            padding: EdgeInsets.all(2),
                            child: Text('Highest Temp',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.0,
                                )),
                          ),
                        ),
                        TableCell(
                          child: Padding(
                            padding: EdgeInsets.all(2),
                            child: Text('Lowest Temp',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.0,
                                )),
                          ),
                        ),
                      ],
                    ),
                    TableRow(
                      children: <TableCell>[
                        TableCell(
                          child: Container(
                            padding: EdgeInsets.all(6),
                            child: Text(
                              '$deviceName2', // Veriyi buraya ekleyin
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11.0,
                              ),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Padding(
                            padding: EdgeInsets.all(6),
                            child: Text(
                              _formatElapsedTime2(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Container(
                            padding: EdgeInsets.all(6),
                            child: Text(
                              '$torqueData2', // Veriyi buraya ekleyin
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Container(
                            padding: EdgeInsets.all(6),
                            child: Text(
                              '$tempData2', // Veriyi buraya ekleyin
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Container(
                            padding: EdgeInsets.all(6),
                            child: Text(
                              '$highestTorque2', // Veriyi buraya ekleyin
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Container(
                            padding: EdgeInsets.all(6),
                            child: Text(
                              '$lowestTorque2', // Veriyi buraya ekleyin
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Container(
                            padding: EdgeInsets.all(6),
                            child: Text(
                              '$highestTemperature2', // Veriyi buraya ekleyin
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Container(
                            padding: EdgeInsets.all(6),
                            child: Text(
                              '$lowestTemperature2', // Veriyi buraya ekleyin
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            ]),
          ),
        ),
      ),
      backgroundColor: myCustomColor,
    );
  }
}

@override
Widget build(BuildContext context) {
  // TODO: implement build
  throw UnimplementedError();
}

enum DataType {
  Torque,
  Temperature,
}
