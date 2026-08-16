import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '小黄的创意空间 | 登录',
      theme: ThemeData(fontFamily: 'sans-serif'),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _message;
  bool _isSuccess = false;

  // 用于保存从后端读取到的 list.txt 的全部内容
  String _listFileContent = '暂无记录，请登录以生成数据...';

  // 连接 Dart 后端的方法
  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _message = null;
    });

    // 后端地址 (如果在安卓模拟器运行，请把 localhost 改成 10.0.2.2)
    final url = Uri.parse('http://localhost:8080/api/login');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': _usernameController.text,
          'password': _passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _isSuccess = data['success'] ?? false;
          _message = data['message'];
          // 获取后端返回的 list.txt 最新内容！
          _listFileContent = data['fileContent'] ?? '文件为空';
        });
      } else {
        setState(() {
          _isSuccess = false;
          _message = '服务器错误: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _isSuccess = false;
        _message = '网络连接失败，请确保 Dart 后端已启动。';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1. 还原小黄.html 中的紫粉色渐变背景
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 2. 登录卡片
                Container(
                  width: 450,
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('欢迎来到小黄的创意世界', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
                      const SizedBox(height: 8),
                      Text('登录以继续您的创意旅程 ✨', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                      const SizedBox(height: 30),

                      // 输入框
                      _buildInputField(controller: _usernameController, label: '你的名字 / 账号', icon: Icons.person_outline),
                      const SizedBox(height: 15),
                      _buildInputField(controller: _passwordController, label: '密码', icon: Icons.lock_outline, isPassword: true),
                      const SizedBox(height: 25),

                      // 登录按钮
                      SizedBox(
                        width: double.infinity,
                        height: 45,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Color(0xFF667EEA), Color(0xFF764BA2)]),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent, shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                            ),
                            child: _isLoading
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Text('登 录', style: TextStyle(fontSize: 16, color: Colors.white, letterSpacing: 2)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),

                      // 消息提示
                      if (_message != null)
                        Center(
                          child: Text(_message!, textAlign: TextAlign.center, style: TextStyle(color: _isSuccess ? Colors.green : Colors.red, fontWeight: FontWeight.bold, fontSize: 14)),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 3. 【新增】显示 list.txt 内容的卡片 (完美融合你最初的需求)
                Container(
                  width: 450,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3), // 半透明黑色背景
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.description_outlined, color: Colors.white),
                          SizedBox(width: 8),
                          Text('📄 list.txt 最新全部内容', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                      const Divider(color: Colors.white24, height: 20),
                      // 显示文件内容
                      Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(maxHeight: 150),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                        child: SingleChildScrollView(
                          child: Text(
                            _listFileContent.isEmpty ? '(文件为空)' : _listFileContent,
                            style: const TextStyle(color: Colors.white70, fontSize: 12, fontFamily: 'monospace'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 底部版权
                Padding(
                  padding: const EdgeInsets.only(top: 30),
                  child: Text('用热情与创意打造 | 小黄 © 2026', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({required TextEditingController controller, required String label, required IconData icon, bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF764BA2)),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF764BA2), width: 2)),
      ),
    );
  }
}