import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/bengali_formatter.dart';
import '../../../auth/domain/models/app_user.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../projects/domain/models/project.dart';
import '../controllers/accounts_controller.dart';
import '../../domain/models/material_item.dart';
import '../../domain/models/expense_item.dart';
import '../../domain/models/bill_statement.dart';
import 'package:flutter/services.dart';

class ProjectAccountsScreen extends ConsumerStatefulWidget {
  final Project project;

  const ProjectAccountsScreen({
    super.key,
    required this.project,
  });

  @override
  ConsumerState<ProjectAccountsScreen> createState() =>
      _ProjectAccountsScreenState();
}

class _ProjectAccountsScreenState extends ConsumerState<ProjectAccountsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(projectAccountsControllerProvider(widget.project.id).notifier)
          .loadAll(
            projectName: widget.project.name,
            budgetOrContractValue: widget.project.budget ??
                ((widget.project.ratePerSqft ?? 0.0) *
                    (widget.project.totalSqft ?? 0.0)),
          );
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state =
        ref.watch(projectAccountsControllerProvider(widget.project.id));
    final controller = ref
        .read(projectAccountsControllerProvider(widget.project.id).notifier);
    final user = ref.watch(currentUserProvider).value;
    final isContractor = user?.role == UserRole.contractor;
    final isClient = user?.role == UserRole.client;
    final isSupervisor = user?.role == UserRole.supervisor;

    final budgetOrValue = widget.project.budget ??
        ((widget.project.ratePerSqft ?? 0.0) * (widget.project.totalSqft ?? 0.0));

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.project.name} - হিসাব ও খতিয়ান'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'সারসংক্ষেপ'),
            Tab(text: 'শ্রমিক-বিল খতিয়ান'),
            Tab(text: 'মালামাল'),
            Tab(text: 'সাইট খরচ'),
            Tab(text: 'প্রাপ্ত বিল'),
            Tab(text: 'বিল স্টেটমেন্ট'),
          ],
        ),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(state, budgetOrValue),
                _buildLedgerTab(state, controller, isContractor, budgetOrValue),
                _buildMaterialsTab(state, controller, isContractor || isSupervisor || isClient),
                _buildExpensesTab(state, controller, isContractor || isSupervisor),
                _buildClientPaymentsTab(state, controller, isContractor),
                _buildStatementsTab(state, controller, isContractor, isClient, budgetOrValue),
              ],
            ),
    );
  }

  // 1. Overview Tab
  Widget _buildOverviewTab(ProjectAccountsState state, double budget) {
    final s = state.summary;
    if (s == null) {
      return const Center(child: Text('হিসাবের তথ্য লোড হচ্ছে...'));
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          elevation: 2,
          color: AppColors.primary,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'মোট চুক্তি / বাজেট',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 6),
                Text(
                  BengaliFormatter.toCurrency(s.totalBudgetOrContractValue),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Divider(color: Colors.white24, height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('ক্লায়েন্ট থেকে প্রাপ্ত',
                            style: TextStyle(color: Colors.white70, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(
                          BengaliFormatter.toCurrency(s.totalClientPaid),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('ক্লায়েন্টের বাকি',
                            style: TextStyle(color: Colors.white70, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(
                          BengaliFormatter.toCurrency(s.clientDue),
                          style: const TextStyle(
                              color: Colors.amberAccent,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'প্রজেক্টের খরচ বিবরণী',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        _buildExpenseRow('শ্রমিক মজুরি (অর্জিত)', s.totalWagesEarned, Icons.people, Colors.blue),
        _buildExpenseRow('মালামাল ক্রয় খরচ', s.totalMaterialsCost, Icons.inventory, Colors.teal),
        _buildExpenseRow('অন্যান্য সাইট খরচ', s.totalExpensesCost, Icons.receipt_long, Colors.orange),
        const Divider(height: 24),
        Card(
          color: Colors.grey.shade100,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'মোট প্রজেক্ট খরচ',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  BengaliFormatter.toCurrency(s.totalProjectExpenses),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExpenseRow(String title, double amount, IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.1),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontSize: 14)),
        trailing: Text(
          BengaliFormatter.toCurrency(amount),
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  // 2. Worker-Bill Ledger Tab
  Widget _buildLedgerTab(ProjectAccountsState state,
      ProjectAccountsController controller, bool isContractor, double budget) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          color: Colors.grey.shade100,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('সব'),
                    selected: state.activePreset == 'all',
                    onSelected: (_) => controller.setPreset('all', widget.project.name, budget),
                  ),
                  ChoiceChip(
                    label: const Text('এই সপ্তাহ'),
                    selected: state.activePreset == 'weekly',
                    onSelected: (_) =>
                        controller.setPreset('weekly', widget.project.name, budget),
                  ),
                  ChoiceChip(
                    label: const Text('এই মাস'),
                    selected: state.activePreset == 'monthly',
                    onSelected: (_) =>
                        controller.setPreset('monthly', widget.project.name, budget),
                  ),
                ],
              ),
              if (isContractor)
                ElevatedButton.icon(
                  onPressed: () => _showSendStatementDialog(context, state, controller),
                  icon: const Icon(Icons.send, size: 16),
                  label: const Text('পাঠান ও লক'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: state.wages.isEmpty
              ? const Center(
                  child: Text(
                    'কোনো মজুরি রেকর্ড নেই',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: state.wages.length,
                  itemBuilder: (ctx, index) {
                    final item = state.wages[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.workerName ?? 'অজ্ঞাত শ্রমিক',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${BengaliFormatter.toBnDate(item.workDate)} • ${item.designationTitle ?? 'শ্রমিক'}',
                                  style: TextStyle(
                                      color: Colors.grey.shade600, fontSize: 12),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  BengaliFormatter.toCurrency(item.totalEarned),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: Colors.indigo,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: item.isPaid
                                        ? Colors.green.shade100
                                        : Colors.amber.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    item.isPaid ? 'পরিশোধিত' : 'বকেয়া',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: item.isPaid
                                          ? Colors.green.shade800
                                          : Colors.amber.shade900,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // 3. Materials Tab
  Widget _buildMaterialsTab(
      ProjectAccountsState state, ProjectAccountsController controller, bool canAdd) {
    final total = state.materials.fold<double>(0.0, (s, m) => s + m.totalPrice);
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: canAdd
          ? FloatingActionButton.extended(
              onPressed: () => _showAddMaterialDialog(context, controller),
              icon: const Icon(Icons.add),
              label: const Text('মালামাল যোগ'),
              backgroundColor: AppColors.primary,
            )
          : null,
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.teal.shade50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'মালামালের মোট খরচ:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  BengaliFormatter.toCurrency(total),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.teal),
                ),
              ],
            ),
          ),
          Expanded(
            child: state.materials.isEmpty
                ? const Center(
                    child: Text('কোনো মালামাল এন্ট্রি নেই',
                        style: TextStyle(color: Colors.grey)),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: state.materials.length,
                    itemBuilder: (ctx, index) {
                      final item = state.materials[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          title: Text(item.name,
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(
                            '${BengaliFormatter.toBnNumber(item.qty.toStringAsFixed(1))} ${item.unit} × ${BengaliFormatter.toCurrency(item.unitPrice)} • ${BengaliFormatter.toBnDate(item.purchaseDate)}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                BengaliFormatter.toCurrency(item.totalPrice),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              if (canAdd)
                                IconButton(
                                  icon: const Icon(Icons.delete_outline,
                                      size: 18, color: Colors.red),
                                  onPressed: () =>
                                      controller.deleteMaterial(item.id),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // 4. Site Expenses Tab
  Widget _buildExpensesTab(
      ProjectAccountsState state, ProjectAccountsController controller, bool canAdd) {
    final total = state.expenses.fold<double>(0.0, (s, e) => s + e.amount);
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: canAdd
          ? FloatingActionButton.extended(
              onPressed: () => _showAddExpenseDialog(context, controller),
              icon: const Icon(Icons.add),
              label: const Text('খরচ যোগ'),
              backgroundColor: AppColors.primary,
            )
          : null,
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.orange.shade50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'সাইটের মোট অন্যান্য খরচ:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  BengaliFormatter.toCurrency(total),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.deepOrange),
                ),
              ],
            ),
          ),
          Expanded(
            child: state.expenses.isEmpty
                ? const Center(
                    child: Text('কোনো সাইট খরচ এন্ট্রি নেই',
                        style: TextStyle(color: Colors.grey)),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: state.expenses.length,
                    itemBuilder: (ctx, index) {
                      final item = state.expenses[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.orange.shade100,
                            child: const Icon(Icons.receipt,
                                color: Colors.deepOrange, size: 20),
                          ),
                          title: Text(item.category,
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(
                            '${BengaliFormatter.toBnDate(item.expenseDate)}${item.note != null ? " • ${item.note}" : ""}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                BengaliFormatter.toCurrency(item.amount),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              if (canAdd)
                                IconButton(
                                  icon: const Icon(Icons.delete_outline,
                                      size: 18, color: Colors.red),
                                  onPressed: () =>
                                      controller.deleteExpense(item.id),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // 5. Client Payments Tab
  Widget _buildClientPaymentsTab(ProjectAccountsState state,
      ProjectAccountsController controller, bool canAdd) {
    final total = state.clientPayments.fold<double>(0.0, (s, p) => s + p.amount);
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: canAdd
          ? FloatingActionButton.extended(
              onPressed: () => _showRecordClientPaymentDialog(context, controller),
              icon: const Icon(Icons.add),
              label: const Text('বিল জমা নিন'),
              backgroundColor: AppColors.primary,
            )
          : null,
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.green.shade50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'মোট প্রাপ্ত বিল:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  BengaliFormatter.toCurrency(total),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.green),
                ),
              ],
            ),
          ),
          Expanded(
            child: state.clientPayments.isEmpty
                ? const Center(
                    child: Text('কোনো প্রাপ্ত বিল রেকর্ড নেই',
                        style: TextStyle(color: Colors.grey)),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: state.clientPayments.length,
                    itemBuilder: (ctx, index) {
                      final item = state.clientPayments[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.green.shade100,
                            child: const Icon(Icons.account_balance_wallet,
                                color: Colors.green, size: 20),
                          ),
                          title: Text(
                            BengaliFormatter.toCurrency(item.amount),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.green),
                          ),
                          subtitle: Text(
                            '${BengaliFormatter.toBnDate(item.paymentDate)} • মাধ্যম: ${item.paymentMethod}${item.note != null ? " • ${item.note}" : ""}',
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // Add Material Dialog
  void _showAddMaterialDialog(
      BuildContext context, ProjectAccountsController controller) {
    final nameCtrl = TextEditingController();
    final unitCtrl = TextEditingController(text: 'বস্তা');
    final qtyCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final user = ref.read(currentUserProvider).value;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('নতুন মালামাল যোগ'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'মালামালের নাম (যেমন: সিমেন্ট)'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: unitCtrl,
                decoration: const InputDecoration(labelText: 'একক (বস্তা, সিএফটি, টন, পিস)'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: qtyCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'পরিমাণ'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: priceCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'প্রতি এককের দর (৳)'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('বাতিল'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameCtrl.text.trim();
              final qty = double.tryParse(qtyCtrl.text.trim()) ?? 0.0;
              final price = double.tryParse(priceCtrl.text.trim()) ?? 0.0;
              if (name.isEmpty || qty <= 0 || price <= 0 || user == null) return;

              final item = MaterialItem(
                id: '',
                organizationId: widget.project.organizationId,
                projectId: widget.project.id,
                name: name,
                unit: unitCtrl.text.trim().isEmpty ? 'বস্তা' : unitCtrl.text.trim(),
                qty: qty,
                unitPrice: price,
                totalPrice: qty * price,
                purchaseDate: DateTime.now(),
                addedBy: user.id,
                createdAt: DateTime.now(),
              );

              final ok = await controller.addMaterial(item);
              if (ok && ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('সংরক্ষণ'),
          ),
        ],
      ),
    );
  }

  // Add Expense Dialog
  void _showAddExpenseDialog(
      BuildContext context, ProjectAccountsController controller) {
    String category = 'পরিবহন';
    final amountCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    final user = ref.read(currentUserProvider).value;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('সাইট খরচ যোগ'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: category,
                  decoration: const InputDecoration(labelText: 'খরচের ধরন'),
                  items: const [
                    DropdownMenuItem(value: 'পরিবহন', child: Text('পরিবহন')),
                    DropdownMenuItem(value: 'যন্ত্রপাতি', child: Text('যন্ত্রপাতি')),
                    DropdownMenuItem(value: 'চা-নাস্তা', child: Text('চা-নাস্তা')),
                    DropdownMenuItem(value: 'ইউটিলিটি', child: Text('ইউটিলিটি')),
                    DropdownMenuItem(value: 'অন্যান্য', child: Text('অন্যান্য')),
                  ],
                  onChanged: (v) => setDialogState(() => category = v ?? 'অন্যান্য'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: amountCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'খরচের পরিমাণ (৳)'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: noteCtrl,
                  decoration: const InputDecoration(labelText: 'বিবরণ / নোট'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('বাতিল'),
            ),
            ElevatedButton(
              onPressed: () async {
                final amount = double.tryParse(amountCtrl.text.trim()) ?? 0.0;
                if (amount <= 0 || user == null) return;

                final item = ExpenseItem(
                  id: '',
                  organizationId: widget.project.organizationId,
                  projectId: widget.project.id,
                  category: category,
                  amount: amount,
                  expenseDate: DateTime.now(),
                  note: noteCtrl.text.trim().isEmpty ? null : noteCtrl.text.trim(),
                  addedBy: user.id,
                  createdAt: DateTime.now(),
                );

                final ok = await controller.addExpense(item);
                if (ok && ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('সংরক্ষণ'),
            ),
          ],
        ),
      ),
    );
  }

  // Record Client Payment Dialog
  void _showRecordClientPaymentDialog(
      BuildContext context, ProjectAccountsController controller) {
    String method = 'bank';
    final amountCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    final refCtrl = TextEditingController();
    final user = ref.read(currentUserProvider).value;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('ক্লায়েন্ট বিল জমা নিন'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: amountCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'জমার পরিমাণ (৳)'),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: method,
                  decoration: const InputDecoration(labelText: 'পেমেন্ট মাধ্যম'),
                  items: const [
                    DropdownMenuItem(value: 'bank', child: Text('ব্যাংক')),
                    DropdownMenuItem(value: 'cash', child: Text('ক্যাশ')),
                    DropdownMenuItem(value: 'cheque', child: Text('চেক')),
                    DropdownMenuItem(value: 'bkash', child: Text('বিকাশ')),
                    DropdownMenuItem(value: 'nagad', child: Text('নগদ')),
                  ],
                  onChanged: (v) => setDialogState(() => method = v ?? 'bank'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: refCtrl,
                  decoration: const InputDecoration(labelText: 'চেক/ট্রানজেকশন নম্বর'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: noteCtrl,
                  decoration: const InputDecoration(labelText: 'নোট'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('বাতিল'),
            ),
            ElevatedButton(
              onPressed: () async {
                final amount = double.tryParse(amountCtrl.text.trim()) ?? 0.0;
                if (amount <= 0 || user == null) return;

                final item = ClientPayment(
                  id: '',
                  organizationId: widget.project.organizationId,
                  projectId: widget.project.id,
                  amount: amount,
                  paymentDate: DateTime.now(),
                  paymentMethod: method,
                  referenceNo: refCtrl.text.trim().isEmpty ? null : refCtrl.text.trim(),
                  note: noteCtrl.text.trim().isEmpty ? null : noteCtrl.text.trim(),
                  receivedBy: user.id,
                  createdAt: DateTime.now(),
                );

                final ok = await controller.recordClientPayment(item);
                if (ok && ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('সংরক্ষণ'),
            ),
          ],
        ),
      ),
    );
  }

  // 6. Bill Statements Tab
  Widget _buildStatementsTab(
    ProjectAccountsState state,
    ProjectAccountsController controller,
    bool isContractor,
    bool isClient,
    double budgetOrValue,
  ) {
    final statements = state.statements;

    return Column(
      children: [
        if (isContractor)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: AppColors.primary.withValues(alpha: 0.05),
            child: Row(
              children: [
                const Icon(Icons.lock_clock_outlined, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'স্টেটমেন্ট পাঠালে হিসাব স্ন্যাপশট লক হয়ে ক্লায়েন্ট দেখতে পাবে।',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showGenerateStatementDialog(
                    context,
                    state,
                    controller,
                    budgetOrValue,
                  ),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('নতুন স্টেটমেন্ট'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    visualDensity: VisualDensity.compact,
                    textStyle: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: statements.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.receipt_long_outlined, size: 56, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        const Text(
                          'কোনো বিল স্টেটমেন্ট তৈরি করা হয়নি',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          isContractor
                              ? 'নতুন স্টেটমেন্ট তৈরি করে ক্লায়েন্টকে পাঠান।'
                              : 'ঠিকাদার কর্তৃক প্রেরিত স্টেটমেন্ট এখানে সংরক্ষিত থাকবে।',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: statements.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = statements[index];
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: item.isLocked ? Colors.green.shade300 : Colors.grey.shade300,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: (item.isLocked ? Colors.green : Colors.blue)
                                        .withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    item.isLocked ? 'লক ও প্রেরিত' : 'খসড়া',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: item.isLocked ? Colors.green.shade800 : Colors.blue.shade800,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    item.preset == 'weekly'
                                        ? 'সাপ্তাহিক'
                                        : item.preset == 'monthly'
                                            ? 'মাসিক'
                                            : 'কাস্টম',
                                    style: const TextStyle(fontSize: 11, color: Colors.black87),
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  BengaliFormatter.toRelativeTime(item.createdAt),
                                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'সময়কাল: ${BengaliFormatter.formatDate(item.periodFrom)} হতে ${BengaliFormatter.formatDate(item.periodTo)}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            if (item.sentToClientAt != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                'প্রেরিত: ${BengaliFormatter.formatDate(item.sentToClientAt!)}',
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                              ),
                            ],
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                OutlinedButton.icon(
                                  onPressed: () => _showStatementReportDialog(context, item),
                                  icon: const Icon(Icons.visibility_outlined, size: 16),
                                  label: const Text('রিপোর্ট ও কপি'),
                                  style: OutlinedButton.styleFrom(
                                    visualDensity: VisualDensity.compact,
                                    textStyle: const TextStyle(fontSize: 12),
                                  ),
                                ),
                                if (isContractor && !item.isLocked) ...[
                                  const SizedBox(width: 8),
                                  ElevatedButton.icon(
                                    onPressed: () => _confirmLockAndSend(
                                      context,
                                      item,
                                      controller,
                                      budgetOrValue,
                                      state,
                                    ),
                                    icon: const Icon(Icons.send, size: 16),
                                    label: const Text('লক ও পাঠান'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                      visualDensity: VisualDensity.compact,
                                      textStyle: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _showStatementReportDialog(BuildContext context, BillStatement item) {
    final report = item.toFormattedReport(
      projectName: widget.project.name,
      clientName: widget.project.clientName,
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('বিল স্টেটমেন্ট রিপোর্ট'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: SelectableText(
              report,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('বন্ধ করুন'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: report));
              if (ctx.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('রিপোর্ট ক্লিপবোর্ডে কপি করা হয়েছে!'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            icon: const Icon(Icons.copy, size: 16),
            label: const Text('রিপোর্ট কপি করুন'),
          ),
        ],
      ),
    );
  }

  void _showGenerateStatementDialog(
    BuildContext context,
    ProjectAccountsState state,
    ProjectAccountsController controller,
    double budgetOrValue,
  ) {
    String preset = 'weekly';
    DateTime from = DateTime.now().subtract(const Duration(days: 7));
    DateTime to = DateTime.now();
    bool sendImmediately = true;
    final user = ref.read(currentUserProvider).value;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('বিল স্টেটমেন্ট তৈরি করুন'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: preset,
                  decoration: const InputDecoration(labelText: 'সময়কাল প্রিসেট'),
                  items: const [
                    DropdownMenuItem(value: 'weekly', child: Text('সাপ্তাহিক (গত ৭ দিন)')),
                    DropdownMenuItem(value: 'monthly', child: Text('মাসিক (চলতি মাস)')),
                    DropdownMenuItem(value: 'custom', child: Text('কাস্টম তারিখ-পরিসর')),
                  ],
                  onChanged: (v) {
                    if (v == null) return;
                    setDialogState(() {
                      preset = v;
                      final now = DateTime.now();
                      if (preset == 'weekly') {
                        from = now.subtract(const Duration(days: 7));
                        to = now;
                      } else if (preset == 'monthly') {
                        from = DateTime(now.year, now.month, 1);
                        to = now;
                      }
                    });
                  },
                ),
                const SizedBox(height: 12),
                Text(
                  'সময়সীমা: ${BengaliFormatter.formatDate(from)} হতে ${BengaliFormatter.formatDate(to)}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: sendImmediately,
                  title: const Text('তৈরি করে সরাসরি ক্লায়েন্টকে পাঠান ও লক করুন', style: TextStyle(fontSize: 13)),
                  onChanged: (v) => setDialogState(() => sendImmediately = v ?? true),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('বাতিল'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (user == null) return;

                final snapshot = {
                  'project_id': widget.project.id,
                  'project_name': widget.project.name,
                  'generated_at': DateTime.now().toIso8601String(),
                  'period_from': from.toIso8601String().split('T').first,
                  'period_to': to.toIso8601String().split('T').first,
                  'summary': {
                    'total_budget': budgetOrValue,
                    'total_client_paid': state.summary?.totalClientPaid ?? 0,
                    'client_due': state.summary?.clientDue ?? 0,
                    'total_project_expenses': state.summary?.totalProjectExpenses ?? 0,
                    'total_wages_earned': state.summary?.totalWagesEarned ?? 0,
                    'total_wages_paid': state.summary?.totalWagesPaid ?? 0,
                    'total_materials_cost': state.summary?.totalMaterialsCost ?? 0,
                    'total_expenses_cost': state.summary?.totalExpensesCost ?? 0,
                  },
                };

                final stmt = BillStatement(
                  id: '',
                  organizationId: widget.project.organizationId,
                  projectId: widget.project.id,
                  periodFrom: from,
                  periodTo: to,
                  preset: preset,
                  generatedBy: user.id,
                  sentToClientAt: sendImmediately ? DateTime.now() : null,
                  isLocked: sendImmediately,
                  lockedSnapshot: sendImmediately ? snapshot : null,
                  createdAt: DateTime.now(),
                );

                final ok = await controller.createBillStatement(stmt);
                if (ok && ctx.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        sendImmediately
                            ? 'স্টেটমেন্ট তৈরি ও ক্লায়েন্টকে সফলভাবে পাঠানো হয়েছে!'
                            : 'স্টেটমেন্ট খসড়া হিসেবে তৈরি হয়েছে।',
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: const Text('তৈরি করুন'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmLockAndSend(
    BuildContext context,
    BillStatement item,
    ProjectAccountsController controller,
    double budgetOrValue,
    ProjectAccountsState state,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('ক্লায়েন্টকে স্টেটমেন্ট পাঠান'),
        content: Text(
          'সময়কাল: ${BengaliFormatter.formatDate(item.periodFrom)} হতে ${BengaliFormatter.formatDate(item.periodTo)}\n\nপাঠানোর মুহূর্তে একটি স্ন্যাপশট লক হবে, যাতে পরে হিসাব পরিবর্তন হলেও ক্লায়েন্টের কপি অপরিবর্তিত থাকে। আপনি কি নিশ্চিত?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('বাতিল'),
          ),
          ElevatedButton(
            onPressed: () async {
              final snapshot = {
                'project_id': widget.project.id,
                'project_name': widget.project.name,
                'generated_at': DateTime.now().toIso8601String(),
                'period_from': item.periodFrom.toIso8601String().split('T').first,
                'period_to': item.periodTo.toIso8601String().split('T').first,
                'summary': {
                  'total_budget': budgetOrValue,
                  'total_client_paid': state.summary?.totalClientPaid ?? 0,
                  'client_due': state.summary?.clientDue ?? 0,
                  'total_project_expenses': state.summary?.totalProjectExpenses ?? 0,
                  'total_wages_earned': state.summary?.totalWagesEarned ?? 0,
                  'total_wages_paid': state.summary?.totalWagesPaid ?? 0,
                  'total_materials_cost': state.summary?.totalMaterialsCost ?? 0,
                  'total_expenses_cost': state.summary?.totalExpensesCost ?? 0,
                },
              };

              final ok = await controller.lockAndSendStatement(item.id, snapshot);
              if (ok && ctx.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('স্টেটমেন্ট লক ও ক্লায়েন্টকে সফলভাবে পাঠানো হয়েছে!'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('লক ও পাঠান'),
          ),
        ],
      ),
    );
  }

  // Send Statement Dialog & Snapshot Lock from Ledger Tab
  void _showSendStatementDialog(
      BuildContext context, ProjectAccountsState state, ProjectAccountsController controller) {
    final budgetOrValue = widget.project.budget ??
        ((widget.project.ratePerSqft ?? 0.0) * (widget.project.totalSqft ?? 0.0));
    _showGenerateStatementDialog(context, state, controller, budgetOrValue);
  }
}

