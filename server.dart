import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;

void main() async {
  // 跨域配置，允许 Flutter Web 访问
  var corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'POST, OPTIONS',
    'Access-Control-Allow-Headers': 'Origin, Content-Type',
  };

  // 定义 list.txt 文件
  File file = File('list.txt');
  if (!file.existsSync()) {
    file.createSync(); // 如果不存在就创建
  }

  var handler = const Pipeline().addMiddleware(logRequests()).addHandler((Request request) async {
    if (request.method == 'OPTIONS') {
      return Response.ok('', headers: corsHeaders);
    }

    // 处理登录 API
    if (request.url.path == 'api/login' && request.method == 'POST') {
      try {
        // 1. 读取 Flutter 发来的 JSON
        String requestBody = await request.readAsString();
        Map<String, dynamic> jsonMap = jsonDecode(requestBody);

        String? username = jsonMap['username'];
        String? password = jsonMap['password'];

        print('🎨 收到小黄前端的请求 -> 用户: $username');

        // ==========================================
        // 2. 融合你最初的 list.txt 写入逻辑！
        // ==========================================
        String logEntry = '[$username] 在 ${DateTime.now().toString().split('.')[0]} 尝试登录 (密码: $password)';

        // 追加写入 list.txt (就像你之前用的 FileMode.append)
        file.writeAsStringSync('$logEntry\n', mode: FileMode.append);
        print('✅ 已将记录追加写入 list.txt');

        // 3. 读取 list.txt 的最新全部内容 (就像你之前用的 readAsStringSync)
        String latestContent = file.readAsStringSync();
        print('📖 已读取 list.txt 最新内容');

        // ==========================================
        // 4. 验证逻辑并返回结果
        // ==========================================
        if (username == 'xiaohuang' && password == '123456') {
          return Response.ok(
            jsonEncode({
              'success': true,
              'message': '🎉 登录成功！欢迎回到你的创意空间, $username！',
              'fileContent': latestContent // 把 list.txt 的全部内容发给前端！
            }),
            headers: {'Content-Type': 'application/json', ...corsHeaders},
          );
        } else {
          return Response.ok(
            jsonEncode({
              'success': false,
              'message': '❌ 账号或密码错误 (试试 xiaohuang / 123456)',
              'fileContent': latestContent // 就算失败，也把最新的记录发给前端看
            }),
            headers: {'Content-Type': 'application/json', ...corsHeaders},
          );
        }
      } catch (e) {
        return Response.internalServerError(body: 'Error: $e', headers: corsHeaders);
      }
    }

    return Response.notFound('Not Found', headers: corsHeaders);
  });

  var server = await io.serve(handler, InternetAddress.anyIPv4, 8080);
  print('🚀 小黄的后端 API 已启动: http://localhost:${server.port}/api/login');
  print('📁 数据将保存在: ${file.absolute.path}');
}