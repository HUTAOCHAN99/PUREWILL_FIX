import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purewill/ui/habit-tracker/widget/clean_bottom_navigation_bar.dart';
import 'package:purewill/ui/membership/plan_provider.dart';
import 'package:purewill/domain/model/plan_model.dart';

class MembershipScreen extends ConsumerStatefulWidget {
  const MembershipScreen({super.key});
  @override
  ConsumerState<MembershipScreen> createState() => _MembershipScreenState();
}

class _MembershipScreenState extends ConsumerState<MembershipScreen> {
  int _selectedPlanIndex = 1; // Default ke monthly
  int _currentIndex = 0;
  String _planType = 'monthly'; // 'monthly' or 'yearly'

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(planProvider.notifier).loadPlans();
    });
  }

  void _onNavBarTap(int index) {
    if (index == 2) {
      Navigator.of(context).pop();
    } else {
      setState(() {
        _currentIndex = index;
      });
      if (index == 0) {
        Navigator.of(context).pop();
      }
    }
  }

  void _handlePlanTypeChange(String type) {
    setState(() {
      _planType = type;
      // Reset selection ke plan pertama dari tipe yang dipilih
      _selectedPlanIndex = 0;
    });
  }

  Future<void> _handleSubscribe(PlanModel plan) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      await ref.read(planProvider.notifier).subscribeToPlan(plan.id);

      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Berhasil berlangganan ${plan.name}!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Kembali ke home setelah beberapa detik
        await Future.delayed(const Duration(seconds: 2));
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal berlangganan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final planState = ref.watch(planProvider);
    final currentUserPlan = planState.currentPlan;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Membership',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/home/bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: planState.isLoading
              ? const Center(child: CircularProgressIndicator())
              : planState.error != null
                  ? Center(child: Text(planState.error!))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Logo dan Title
                          Image.asset(
                            'assets/images/logo.png',
                            height: 60,
                            width: 60,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'PureWill',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Choose Your Plan',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black54,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 40),
                            child: Text(
                              'Unlock your full potential with premium features',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black45,
                              ),
                            ),
                          ),
                          
                          // Tampilkan plan current user jika ada
                          if (currentUserPlan != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.green[50],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.green),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.check_circle,
                                        color: Colors.green, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Current Plan: ${currentUserPlan.name}',
                                      style: const TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          
                          const SizedBox(height: 32),

                          // Free Plan Card
                          if (planState.freePlan != null)
                            _buildPlanCard(
                              plan: planState.freePlan!,
                              isSelected: _selectedPlanIndex == 0 &&
                                  planState.freePlan!.type == 'free',
                              onTap: () => setState(() => _selectedPlanIndex = 0),
                              onSubscribe: _handleSubscribe,
                            ),

                          const SizedBox(height: 20),
                          const Divider(thickness: 2),
                          const SizedBox(height: 20),

                          // Toggle untuk monthly/yearly jika ada premium plans
                          if (planState.premiumPlans.isNotEmpty)
                            _buildPlanTypeToggle(
                              onChanged: _handlePlanTypeChange,
                              initialValue: _planType,
                            ),
                          if (planState.premiumPlans.isNotEmpty)
                            const SizedBox(height: 20),

                          // Premium Plan Cards berdasarkan tipe
                          ...planState.premiumPlans
                              .where((plan) => plan.type == _planType)
                              .toList()
                              .asMap()
                              .entries
                              .map((entry) {
                            final index = entry.key;
                            final plan = entry.value;
                            return Padding(
                              padding: EdgeInsets.only(bottom: 20),
                              child: _buildPlanCard(
                                plan: plan,
                                isSelected: _selectedPlanIndex == index + 1,
                                onTap: () => setState(() => _selectedPlanIndex = index + 1),
                                onSubscribe: _handleSubscribe,
                              ),
                            );
                          }).toList(),

                          const SizedBox(height: 40),

                          // Terms and Conditions
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              'Dengan memilih paket, Anda menyetujui Syarat & Ketentuan dan Kebijakan Privasi PureWill',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
        ),
      ),
      bottomNavigationBar: CleanBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onNavBarTap,
      ),
    );
  }

  Widget _buildPlanTypeToggle({
    required Function(String) onChanged,
    required String initialValue,
  }) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged('monthly'),
              child: Container(
                decoration: BoxDecoration(
                  color: initialValue == 'monthly'
                      ? Colors.deepPurple
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Center(
                  child: Text(
                    'Monthly',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: initialValue == 'monthly'
                          ? Colors.white
                          : Colors.black87,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged('yearly'),
              child: Container(
                decoration: BoxDecoration(
                  color: initialValue == 'yearly'
                      ? Colors.deepPurple
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Center(
                  child: Text(
                    'Yearly',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: initialValue == 'yearly'
                          ? Colors.white
                          : Colors.black87,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard({
    required PlanModel plan,
    required bool isSelected,
    required VoidCallback onTap,
    required Function(PlanModel) onSubscribe,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? plan.type == 'free'
                    ? Colors.blue
                    : Colors.deepPurple
                : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Badge jika ada
            if (plan.badgeText != null ||
                plan.isPromoActive ||
                plan.hasPromo) ...[
              Row(
                children: [
                  if (plan.badgeText != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: plan.badgeText == 'POPULAR'
                            ? Colors.orange
                            : Colors.green,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        plan.badgeText!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  if (plan.isPromoActive && plan.hasPromo) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${plan.discountPercentage.toStringAsFixed(0)}% OFF',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                  if (plan.isPromoActive) ...[
                    const SizedBox(width: 8),
                    Text(
                      'Berlaku hingga ${plan.promoEndDate!.day}/${plan.promoEndDate!.month}/${plan.promoEndDate!.year}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),
            ],

            // Title
            Text(
              plan.name,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: plan.type == 'free'
                    ? Colors.blue
                    : Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 8),

            // Price
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  plan.formattedPrice,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: plan.type == 'free'
                        ? Colors.green
                        : Colors.deepPurple,
                  ),
                ),
                if (plan.type != 'free') const SizedBox(width: 4),
                if (plan.type != 'free')
                  Text(
                    plan.type == 'yearly' ? '/tahun' : '/bulan',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),

            // Original Price jika ada diskon
            if (plan.hasPromo && plan.formattedOriginalPrice != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  plan.formattedOriginalPrice!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ),

            const SizedBox(height: 16),
            const Divider(color: Colors.grey, height: 1),

            // Features
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: plan.features
                  .map(
                    (feature) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: plan.type == 'free'
                                ? Colors.blue
                                : Colors.deepPurple,
                            size: 18,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              feature,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),

            const SizedBox(height: 20),

            // Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => onSubscribe(plan),
                style: ElevatedButton.styleFrom(
                  backgroundColor: plan.type == 'free'
                      ? Colors.blue
                      : Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  plan.type == 'free'
                      ? 'Gunakan Sekarang'
                      : 'Pilih Paket Ini',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}