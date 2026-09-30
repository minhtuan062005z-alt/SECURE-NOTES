import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

void main() {
  runApp(const SecureNotesApp());
}

class SecureNotesApp extends StatelessWidget {
  const SecureNotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Secure Notes',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.light,
        ),
      ),
      home: const LockScreen(),
    );
  }
}

// ============================================================
// LOCK SCREEN
// ============================================================

class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final LocalAuthentication auth = LocalAuthentication();

  bool isAuthenticating = false;

  Future<void> authenticate() async {
    if (isAuthenticating) return;

    setState(() {
      isAuthenticating = true;
    });

    try {
      final bool supported = await auth.isDeviceSupported();

      if (!supported) {
        showMessage('Thiết bị không hỗ trợ xác thực sinh trắc học.');
        return;
      }

      final List<BiometricType> biometrics =
      await auth.getAvailableBiometrics();

      if (biometrics.isEmpty) {
        showMessage(
          'Chưa có sinh trắc học được đăng ký trên thiết bị.',
        );
        return;
      }

      final bool authenticated = await auth.authenticate(
        localizedReason: 'Xác thực để mở Secure Notes',
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );

      if (!mounted) return;

      if (authenticated) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const HomeScreen(),
          ),
        );
      } else {
        showMessage('Xác thực không thành công.');
      }
    } on LocalAuthException catch (e) {
      if (!mounted) return;

      showMessage(
        'Xác thực thất bại\nMã lỗi: ${e.code}',
      );
    } catch (e) {
      if (!mounted) return;

      showMessage(
        'Có lỗi xảy ra\n$e',
      );
    } finally {
      if (mounted) {
        setState(() {
          isAuthenticating = false;
        });
      }
    }
  }

  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FF),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 30),

                // LOGO
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    color: Colors.indigo,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.indigo.withOpacity(0.25),
                        blurRadius: 25,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.lock_rounded,
                    color: Colors.white,
                    size: 55,
                  ),
                ),

                const SizedBox(height: 28),

                const Text(
                  'Secure Notes',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF172554),
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  'Bảo vệ thông tin bằng\nxác thực sinh trắc học',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    color: Colors.black54,
                  ),
                ),

                const SizedBox(height: 40),

                // SECURITY CARD
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.07),
                        blurRadius: 25,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.fingerprint_rounded,
                        size: 85,
                        color: Colors.indigo,
                      ),

                      const SizedBox(height: 18),

                      const Text(
                        'Xác thực danh tính',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        'Sử dụng vân tay của bạn để\ntruy cập thông tin bảo mật.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: Colors.black54,
                        ),
                      ),

                      const SizedBox(height: 25),

                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton.icon(
                          onPressed:
                          isAuthenticating ? null : authenticate,
                          icon: Icon(
                            isAuthenticating
                                ? Icons.hourglass_top_rounded
                                : Icons.fingerprint_rounded,
                          ),
                          label: Text(
                            isAuthenticating
                                ? 'Đang xác thực...'
                                : 'Xác thực bằng vân tay',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor:
                            Colors.indigo.withOpacity(0.5),
                            disabledForegroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.verified_user_outlined,
                      size: 18,
                      color: Colors.green,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Thông tin được bảo vệ',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// HOME SCREEN
// ============================================================

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void lockAgain(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const LockScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FF),
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.shield_rounded),
            SizedBox(width: 10),
            Text(
              'Secure Notes',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Khóa ứng dụng',
            onPressed: () => lockAgain(context),
            icon: const Icon(Icons.lock_outline_rounded),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            // SUCCESS MESSAGE
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: Colors.green.shade200,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      color: Colors.green.shade700,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Xác thực thành công',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Bạn đã được cấp quyền truy cập.',
                          style: TextStyle(
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            const Text(
              'Thông tin bảo mật',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF172554),
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Những thông tin dưới đây chỉ được hiển thị sau khi xác thực.',
              style: TextStyle(
                color: Colors.black54,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 22),

            const SecureInformation(
              icon: Icons.person_outline_rounded,
              title: 'Họ và tên',
              value: 'Nguyễn Văn A',
            ),

            const SizedBox(height: 14),

            const SecureInformation(
              icon: Icons.email_outlined,
              title: 'Email',
              value: 'example@gmail.com',
            ),

            const SizedBox(height: 14),

            const SecureInformation(
              icon: Icons.phone_outlined,
              title: 'Số điện thoại',
              value: '0123456789',
            ),

            const SizedBox(height: 14),

            const SecureInformation(
              icon: Icons.location_on_outlined,
              title: 'Địa chỉ',
              value: 'Thành phố Hồ Chí Minh',
            ),

            const SizedBox(height: 30),

            // SECURITY STATUS
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.security_rounded,
                    color: Colors.indigo,
                    size: 30,
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'Dữ liệu đang được bảo vệ bằng xác thực sinh trắc học.',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // LOCK BUTTON
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: () => lockAgain(context),
                icon: const Icon(Icons.lock_rounded),
                label: const Text(
                  'Khóa thông tin',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.indigo,
                  side: const BorderSide(
                    color: Colors.indigo,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// INFORMATION CARD
// ============================================================

class SecureInformation extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const SecureInformation({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.indigo.shade50,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: Colors.indigo,
              size: 25,
            ),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const Icon(
            Icons.lock_outline_rounded,
            color: Colors.green,
            size: 20,
          ),
        ],
      ),
    );
  }
}