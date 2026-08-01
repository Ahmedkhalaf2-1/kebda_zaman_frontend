import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:kebda_zaman/core/theme/kz_design_system.dart';
import 'package:kebda_zaman/features/customer/presentation/notifiers/auth_notifier.dart';
import 'package:kebda_zaman/core/responsive/responsive_container.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _identifierCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isAdminLogin = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _identifierCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final identifier = _identifierCtrl.text.trim();
    final password = _passwordCtrl.text.trim();

    bool success = false;
    if (_isAdminLogin) {
      success = await ref
          .read(authNotifierProvider.notifier)
          .adminLogin(identifier: identifier, password: password);
    } else {
      success = await ref
          .read(authNotifierProvider.notifier)
          .login(identifier: identifier, password: password);
    }

    if (success && mounted) {
      final user = ref.read(authNotifierProvider).user;
      if (_isAdminLogin || user?.role == 'ADMIN') {
        context.go('/admin/dashboard');
      } else if (user?.role == 'CASHIER') {
        // Cashiers never see customer navigation — they land directly on
        // Orders Management, the only admin section they're allowed into.
        context.go('/admin/orders');
      } else {
        context.go('/home');
      }
    }
  }

  InputDecoration _buildInputDecoration({
    required String hint,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: KZ.onSurfaceVariant.withValues(alpha: 0.55),
        fontSize: 15,
        fontWeight: FontWeight.w400,
      ),
      prefixIcon: Icon(prefixIcon, color: KZ.onSurfaceVariant, size: 22),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: KZ.outlineVariant, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: KZ.outlineVariant, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: KZ.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: KZ.error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: KZ.error, width: 1.5),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 6),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: KZ.onSurfaceVariant,
          height: 1.3,
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required String label,
    required Widget icon,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: KZ.outlineVariant, width: 1),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                icon,
                const SizedBox(width: 10),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: KZ.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      backgroundColor: KZ.surface, // #fcf9f5
      body: SafeArea(
        child: Column(
          children: [
            // Optional Top Bar for Back Navigation if pushed from elsewhere
            if (Navigator.canPop(context))
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: KZ.primary,
                    size: 26,
                  ),
                  tooltip: 'common.back'.tr(),
                  splashRadius: 22,
                  onPressed: () => context.pop(),
                ),
              )
            else
              const SizedBox(height: 16),

            // Main Content Area
            Expanded(
              child: ResponsiveContainer(
                maxWidth: 448, // max-w-md (448px in tailwind)
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  child: Column(
                    children: [
                      // Branding Logo Area
                      _buildHeader(),

                      const SizedBox(height: 24),

                      // Error Banner
                      if (authState.errorMessage != null) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: KZ.errorContainer,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: KZ.error.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.error_outline_rounded,
                                color: KZ.error,
                                size: 22,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  authState.errorMessage!,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: KZ.error,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Login Form
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Email or Username
                            _buildFieldLabel('auth.email_or_username'.tr()),
                            TextFormField(
                              controller: _identifierCtrl,
                              keyboardType: TextInputType.emailAddress,
                              style: const TextStyle(
                                fontSize: 15,
                                color: KZ.onSurface,
                              ),
                              decoration: _buildInputDecoration(
                                hint: 'ahmed@example.com',
                                prefixIcon: Icons.person_outline_rounded,
                              ),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return 'auth.fill_all_fields'.tr();
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 18),

                            // Password
                            _buildFieldLabel('auth.password'.tr()),
                            TextFormField(
                              controller: _passwordCtrl,
                              obscureText: _obscurePassword,
                              style: const TextStyle(
                                fontSize: 15,
                                color: KZ.onSurface,
                              ),
                              decoration: _buildInputDecoration(
                                hint: 'Min. 8 characters',
                                prefixIcon: Icons.lock_outline_rounded,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: KZ.onSurfaceVariant,
                                    size: 22,
                                  ),
                                  splashRadius: 20,
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                              ),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return 'auth.fill_all_fields'.tr();
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 16),

                            // Admin Login Toggle & Forgot Password Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _isAdminLogin = !_isAdminLogin;
                                    });
                                  },
                                  behavior: HitTestBehavior.opaque,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 4,
                                    ),
                                    child: Text(
                                      _isAdminLogin
                                          ? 'auth.switch_to_customer_login'.tr()
                                          : 'auth.switch_to_admin_login'.tr(),
                                      style: const TextStyle(
                                        color: KZ.onSurfaceVariant,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    // Forgot password
                                  },
                                  behavior: HitTestBehavior.opaque,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 4,
                                    ),
                                    child: Text(
                                      'auth.forgot_password'.tr(),
                                      style: const TextStyle(
                                        color: KZ.primary,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            // Login Button (pill shape with rich primary shadow)
                            Container(
                              width: double.infinity,
                              height: 56,
                              decoration: BoxDecoration(
                                color: KZ.primary,
                                borderRadius: BorderRadius.circular(
                                  999,
                                ), // rounded-full
                                boxShadow: [
                                  BoxShadow(
                                    color: KZ.primary.withValues(alpha: 0.25),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: authState.isLoading
                                      ? null
                                      : _handleLogin,
                                  borderRadius: BorderRadius.circular(999),
                                  child: Center(
                                    child: authState.isLoading
                                        ? const SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2.5,
                                            ),
                                          )
                                        : Text(
                                            'auth.login_btn'.tr(),
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Divider ("Or continue with")
                      Row(
                        children: [
                          const Expanded(
                            child: Divider(
                              color: KZ.outlineVariant,
                              thickness: 1,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'auth.or_continue'.tr(),
                              style: const TextStyle(
                                color: KZ.onSurfaceVariant,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const Expanded(
                            child: Divider(
                              color: KZ.outlineVariant,
                              thickness: 1,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Social Logins (Google & Apple) - White with outline border
                      Row(
                        children: [
                          _buildSocialButton(
                            label: 'auth.google'.tr(),
                            icon: const SizedBox(
                              width: 20,
                              height: 20,
                              child: CustomPaint(painter: _GoogleLogoPainter()),
                            ),
                            onTap: () {},
                          ),
                          const SizedBox(width: 16),
                          _buildSocialButton(
                            label: 'auth.apple'.tr(),
                            icon: const Icon(
                              Icons.apple,
                              size: 24,
                              color: KZ.onSurface,
                            ),
                            onTap: () {},
                          ),
                        ],
                      ),

                      const SizedBox(height: 40),

                      // Footer: Go to Sign Up
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'auth.no_account'.tr(),
                            style: const TextStyle(
                              color: KZ.onSurfaceVariant,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: () => context.push('/signup'),
                            behavior: HitTestBehavior.opaque,
                            child: Text(
                              'auth.signup_link'.tr(),
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: KZ.primary,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // 80x80 White Rounded Box with 1px outline border & shadow (matching HTML)
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32), // rounded-[2rem]
            border: Border.all(color: KZ.outlineVariant, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Center(
            child: Icon(Icons.restaurant_rounded, size: 40, color: KZ.primary),
          ),
        ),

        const SizedBox(height: 24),

        Text(
          'auth.login_title'.tr(),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            height: 1.3,
            color: KZ.onSurface,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          'auth.login_subtitle'.tr(),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            color: KZ.onSurfaceVariant,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  const _GoogleLogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(2, 2, size.width - 4, size.height - 4);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    // Red arc
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(rect, -3.14159 * 0.8, 3.14159 * 0.6, false, paint);

    // Yellow arc
    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(rect, 3.14159 * 0.7, 3.14159 * 0.5, false, paint);

    // Green arc
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(rect, 3.14159 * 0.1, 3.14159 * 0.6, false, paint);

    // Blue arc
    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(rect, -3.14159 * 0.2, 3.14159 * 0.3, false, paint);

    // Blue horizontal bar
    paint.style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTRB(
        size.width * 0.45,
        size.height * 0.42,
        size.width * 0.9,
        size.height * 0.58,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
