
import 'package:connectivity/connectivity.dart';

class InfoService {

  static ConnectivityResult connectivity;

  static void init() async {
    connectivity = await (Connectivity().checkConnectivity());
  }

}
