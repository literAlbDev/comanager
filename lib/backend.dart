import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:comanager/constants.dart';

class Backend {
  Map<String, String> headers = {
    "Content-Type": "application/json",
    "Accept": "application/json",
  };
  int statusCode = 0;
  late BuildContext _context;

  void setContext(BuildContext context){
    this._context = context;
  }

  Future<dynamic> signup(String name, String email, String password) async {
    var url = Uri.parse(Constants.baseUrl + "/user");
    String request = jsonEncode({
      "name" : name,
      "email": email,
      "password": password,
    });

    var response = await http.post(
      url,
      headers: headers,
      body: request,
    );
    statusCode = response.statusCode;

    print(statusCode);
    print(response.body);

    if (statusCode >= 300) {
      Map errors_map = jsonDecode(response.body)['errors'];
      String errors = '';
      errors_map.forEach((key, value) {
        errors += value[0] + "\n";
      });
      return errors;
    }
    String result = response.body;
    return login(email, password);
  }

  Future<dynamic> login(String email, String password) async {
    var url = Uri.parse(Constants.baseUrl + "/createToken");
    String request = jsonEncode({
      "email": email,
      "password": password,
      "device_name": "flutter_app",
    });

    var response = await http.post(
      url,
      headers: headers,
      body: request,
    );
    statusCode = response.statusCode;

    if (statusCode != 200) {
      Map errors_map = jsonDecode(response.body)['errors'];
      String errors = '';
      errors_map.forEach((key, value) {
        errors += value[0] + "\n";
      });
      return errors;
    }
    String result = response.body;
    return result;
  }

  Future<dynamic> logout(String token) async {
    var url = Uri.parse(Constants.baseUrl + "/revokeToken");
    Map<String, String> headersWithToken = headers;
    headersWithToken.addAll({
      'Authorization': "Bearer $token",
    });

    var response = await http.delete(
      url,
      headers: headersWithToken,
      body: "",
    );
    statusCode = response.statusCode;

    if (statusCode != 200) {
      Map errors_map = jsonDecode(response.body)['errors'] ?? {};
      String errors = '';
      errors_map.forEach((key, value) {
        errors += value[0] + "\n";
      });
      return errors;
    }
    String result = response.body;
    return result;
  }

  Future<dynamic> me(String token) async {
    var url = Uri.parse(Constants.baseUrl + "/me");
    Map<String, String> headersWithToken = headers;
    headersWithToken.addAll({
      'Authorization': "Bearer $token",
    });

    var response = await http.get(
      url,
      headers: headersWithToken,
    );
    statusCode = response.statusCode;

    if (statusCode != 200) {
      Map errors_map = jsonDecode(response.body)['errors'] ?? {};
      String errors = '';
      errors_map.forEach((key, value) {
        errors += value[0] + "\n";
      });
      return errors;
    }
    Map result = jsonDecode(response.body);
    return result;
  }

  Future<dynamic> tasks(String token) async {
    var url = Uri.parse(Constants.baseUrl + "/task");
    Map<String, String> headersWithToken = headers;
    headersWithToken.addAll({
      'Authorization': "Bearer $token",
    });

    var response = await http.get(
      url,
      headers: headersWithToken,
    );
    statusCode = response.statusCode;

    if (statusCode != 200) {
      Map errors_map = jsonDecode(response.body)['errors'] ?? {};
      String errors = '';
      errors_map.forEach((key, value) {
        errors += value[0] + "\n";
      });
      return errors;
    }
    Map result = jsonDecode(response.body);
    return result;
  }

  Future<dynamic> acceptTask(String token, int id) async {
    var url = Uri.parse(Constants.baseUrl + "/task/$id");
    Map<String, String> headersWithToken = headers;
    headersWithToken.addAll({
      'Authorization': "Bearer $token",
    });
    String request = jsonEncode({
      "status": "doing",
    });

    var response = await http.put(
      url,
      body: request,
      headers: headersWithToken,
    );
    statusCode = response.statusCode;

    if (statusCode != 200) {
      Map errors_map = jsonDecode(response.body)['errors'] ?? {};
      String errors = '';
      errors_map.forEach((key, value) {
        errors += value[0] + "\n";
      });
      return errors;
    }
    Map result = jsonDecode(response.body);
    return result;
  }

  Future<dynamic> finishTask(String token, int id) async {
    var url = Uri.parse(Constants.baseUrl + "/task/$id");
    Map<String, String> headersWithToken = headers;
    headersWithToken.addAll({
      'Authorization': "Bearer $token",
    });
    String request = jsonEncode({
      "status": "finished",
    });

    var response = await http.put(
      url,
      body: request,
      headers: headersWithToken,
    );
    statusCode = response.statusCode;

    if (statusCode != 200) {
      Map errors_map = jsonDecode(response.body)['errors'] ?? {};
      String errors = '';
      errors_map.forEach((key, value) {
        errors += value[0] + "\n";
      });
      return errors;
    }
    Map result = jsonDecode(response.body);
    return result;
  }

  Future<dynamic> rejectTask(String token, int id, String reason) async {
    var url = Uri.parse(Constants.baseUrl + "/task/$id");
    Map<String, String> headersWithToken = headers;
    headersWithToken.addAll({
      'Authorization': "Bearer $token",
    });
    String request = jsonEncode({
      "status": "rejected",
      "reason" : reason,
    });

    var response = await http.put(
      url,
      body: request,
      headers: headersWithToken,
    );
    statusCode = response.statusCode;

    if (statusCode != 200) {
      Map errors_map = jsonDecode(response.body)['errors'] ?? {};
      String errors = '';
      errors_map.forEach((key, value) {
        errors += value[0] + "\n";
      });
      return errors;
    }
    Map result = jsonDecode(response.body);
    return result;
  }

  Future<dynamic> workers(String token) async {
    var url = Uri.parse(Constants.baseUrl + "/user");
    Map<String, String> headersWithToken = headers;
    headersWithToken.addAll({
      'Authorization': "Bearer $token",
    });

    var response = await http.get(
      url,
      headers: headersWithToken,
    );
    statusCode = response.statusCode;

    if (statusCode != 200) {
      Map errors_map = jsonDecode(response.body)['errors'] ?? {};
      String errors = '';
      errors_map.forEach((key, value) {
        errors += value[0] + "\n";
      });
      return errors;
    }
    Map result = jsonDecode(response.body);
    return result;
  }

  Future<dynamic> addWorker(String token, String name, String email, String password, int id) async {
    var url = Uri.parse(Constants.baseUrl + "/user");
    Map<String, String> headersWithToken = headers;
    headersWithToken.addAll({
      'Authorization': "Bearer $token",
    });
    String request = jsonEncode({
      "name" : name,
      "email": email,
      "password": password,
      "manager_id": id,
    });

    var response = await http.post(
      url,
      body: request,
      headers: headersWithToken,
    );
    statusCode = response.statusCode;

    if (statusCode > 300) {
      Map errors_map = jsonDecode(response.body)['errors'] ?? {};
      String errors = '';
      errors_map.forEach((key, value) {
        errors += value[0] + "\n";
      });
      return errors;
    }
    Map result = jsonDecode(response.body);
    return result;
  }

  Future<dynamic> deleteWorker(String token, int id) async {
    var url = Uri.parse(Constants.baseUrl + "/user/$id");
    Map<String, String> headersWithToken = headers;
    headersWithToken.addAll({
      'Authorization': "Bearer $token",
    });

    var response = await http.delete(
      url,
      headers: headersWithToken,
    );
    statusCode = response.statusCode;

    if (statusCode > 300) {
      Map errors_map = jsonDecode(response.body)['errors'] ?? {};
      String errors = '';
      errors_map.forEach((key, value) {
        errors += value[0] + "\n";
      });
      return errors;
    }
    Map result = jsonDecode(response.body);
    return result;
  }

  Future<dynamic> editWorker(String token, String? name, String? email, String? password, int workerId) async {
    var url = Uri.parse("${Constants.baseUrl}/user/$workerId");
    Map<String, String> headersWithToken = headers;
    headersWithToken.addAll({
      'Authorization': "Bearer $token",
    });
    String request = jsonEncode({
      "name" : name,
      "email": email,
      "password": password,
    });

    var response = await http.put(
      url,
      body: request,
      headers: headersWithToken,
    );
    statusCode = response.statusCode;

    if (statusCode > 300) {
      Map errors_map = jsonDecode(response.body)['errors'] ?? {};
      String errors = '';
      errors_map.forEach((key, value) {
        errors += value[0] + "\n";
      });
      return errors;
    }
    Map result = jsonDecode(response.body);
    return result;
  }

  Future<dynamic> addTask(String token, String title, String description, int workerId) async {
    var url = Uri.parse(Constants.baseUrl + "/task");
    Map<String, String> headersWithToken = headers;
    headersWithToken.addAll({
      'Authorization': "Bearer $token",
    });
    String request = jsonEncode({
      "title" : title,
      "description": description,
      "worker_id": workerId,
    });

    var response = await http.post(
      url,
      body: request,
      headers: headersWithToken,
    );
    statusCode = response.statusCode;

    if (statusCode > 300) {
      Map errors_map = jsonDecode(response.body)['errors'] ?? {};
      String errors = '';
      errors_map.forEach((key, value) {
        errors += value[0] + "\n";
      });
      return errors;
    }
    Map result = jsonDecode(response.body);
    return result;
  }

  Future<dynamic> deleteTask(String token, int id) async {
    var url = Uri.parse(Constants.baseUrl + "/task/$id");
    Map<String, String> headersWithToken = headers;
    headersWithToken.addAll({
      'Authorization': "Bearer $token",
    });

    var response = await http.delete(
      url,
      headers: headersWithToken,
    );
    statusCode = response.statusCode;

    if (statusCode > 300) {
      Map errors_map = jsonDecode(response.body)['errors'] ?? {};
      String errors = '';
      errors_map.forEach((key, value) {
        errors += value[0] + "\n";
      });
      return errors;
    }
    Map result = jsonDecode(response.body);
    return result;
  }

  Future<dynamic> editTask(String token,int id, String? title, String? description, int workerId) async {
    var url = Uri.parse("${Constants.baseUrl}/task/$id");
    Map<String, String> headersWithToken = headers;
    headersWithToken.addAll({
      'Authorization': "Bearer $token",
    });
    String request = jsonEncode({
      "title" : title,
      "description": description,
      "worker_id": workerId,
    });

    var response = await http.put(
      url,
      body: request,
      headers: headersWithToken,
    );
    statusCode = response.statusCode;

    if (statusCode > 300) {
      Map errors_map = jsonDecode(response.body)['errors'] ?? {};
      String errors = '';
      errors_map.forEach((key, value) {
        errors += value[0] + "\n";
      });
      return errors;
    }
    Map result = jsonDecode(response.body);
    return result;
  }

}
