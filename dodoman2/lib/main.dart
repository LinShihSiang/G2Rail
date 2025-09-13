import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DoDoMan天鵝堡門票',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const TicketPage(),
    );
  }
}

class TicketPage extends StatefulWidget {
  const TicketPage({super.key});

  @override
  State<TicketPage> createState() => _TicketPageState();
}

class _TicketPageState extends State<TicketPage> {
  final _formKey = GlobalKey<FormState>();
  String passportName = '';
  int adults = 1;
  int children = 0;
  DateTime? selectedDate;
  String timeSlot = '上午'; // 上午 或 下午

  // 票價常量
  static const int adultPrice = 690;
  static const int childPrice = 0;

  // 計算總價
  int get totalPrice => adults * adultPrice + children * childPrice;

  Future<void> _sendOrderEmail() async {
    final totalTickets = adults + children;
    final dateString =
        '${selectedDate!.year}/${selectedDate!.month}/${selectedDate!.day}';

    final subject = Uri.encodeComponent('DoDoMan天鵝堡門票訂單 - $passportName');
    final body = Uri.encodeComponent(
      '天鵝堡門票訂單資訊\n'
      '====================\n\n'
      '護照姓名: $passportName\n'
      '大人數量: $adults 位\n'
      '小孩數量: $children 位\n'
      '總票數: $totalTickets 張\n'
      '參觀日期: $dateString\n'
      '參觀時段: $timeSlot\n\n'
      '票價明細:\n'
      '大人票 ($adults 位): NT\$ ${adults * adultPrice}\n'
      '小孩票 ($children 位): 免費\n'
      '總計: NT\$ $totalPrice\n\n'
      '訂單時間: ${DateTime.now().toString().substring(0, 19)}\n\n',
    );

    final emailUri = Uri(
      scheme: 'mailto',
      path: 'baluce@gmail.com',
      query: 'subject=$subject&body=$body',
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      throw 'Could not launch email';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DoDoMan天鵝堡門票'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          // 上半部：天鵝堡門票圖片
          Expanded(
            flex: 1,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.3),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                child: Image.asset('image/castle.jpg', fit: BoxFit.cover),
              ),
            ),
          ),
          // 下半部：訂單資訊輸入表單
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '訂單資訊',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: '護照姓名',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                        hintText: '請輸入與護照相同的姓名',
                      ),
                      validator: (value) =>
                          value == null || value.isEmpty ? '請輸入護照姓名' : null,
                      onSaved: (value) => passportName = value ?? '',
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(
                              labelText: '大人數量',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.person),
                            ),
                            keyboardType: TextInputType.number,
                            initialValue: '1',
                            validator: (value) {
                              if (value == null || value.isEmpty)
                                return '請輸入大人數量';
                              final n = int.tryParse(value);
                              if (n == null || n < 1) return '至少需要1位大人';
                              return null;
                            },
                            onSaved: (value) =>
                                adults = int.tryParse(value ?? '1') ?? 1,
                            onChanged: (value) {
                              setState(() {
                                int newAdults = int.tryParse(value) ?? 1;
                                if (newAdults < 1) newAdults = 1; // 確保至少有1位大人
                                adults = newAdults;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(
                              labelText: '小孩數量',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.child_care),
                            ),
                            keyboardType: TextInputType.number,
                            initialValue: '0',
                            validator: (value) {
                              if (value == null || value.isEmpty)
                                return '請輸入小孩數量';
                              final n = int.tryParse(value);
                              if (n == null || n < 0) return '小孩數量不能小於0';
                              return null;
                            },
                            onSaved: (value) =>
                                children = int.tryParse(value ?? '0') ?? 0,
                            onChanged: (value) {
                              setState(() {
                                int newChildren = int.tryParse(value) ?? 0;
                                if (newChildren < 0)
                                  newChildren = 0; // 確保小孩數量不能小於0
                                children = newChildren;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365),
                          ),
                        );
                        if (picked != null) {
                          setState(() {
                            selectedDate = picked;
                          });
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: '參觀日期',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          selectedDate == null
                              ? '請選擇參觀日期'
                              : '${selectedDate!.year}/${selectedDate!.month}/${selectedDate!.day}',
                          style: TextStyle(
                            color: selectedDate == null
                                ? Colors.grey
                                : Colors.black,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: '參觀時段',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.access_time),
                      ),
                      initialValue: timeSlot,
                      items: const [
                        DropdownMenuItem(
                          value: '上午',
                          child: Text('上午 (09:00-12:00)'),
                        ),
                        DropdownMenuItem(
                          value: '下午',
                          child: Text('下午 (13:00-17:00)'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          timeSlot = value ?? '上午';
                        });
                      },
                      validator: (value) => value == null ? '請選擇參觀時段' : null,
                    ),
                    const SizedBox(height: 20),
                    // 票價顯示區域
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.blue.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '票價明細',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('大人票 ($adults 位)'),
                              Text(
                                'NT\$ ${(adults * adultPrice).toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('小孩票 ($children 位)'),
                              const Text('免費'),
                            ],
                          ),
                          const Divider(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                '總計',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'NT\$ ${totalPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState?.validate() ?? false) {
                            if (selectedDate == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('請選擇參觀日期')),
                              );
                              return;
                            }
                            _formKey.currentState?.save();

                            // 顯示處理中的提示
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('正在發送訂單郵件...'),
                                duration: Duration(seconds: 2),
                              ),
                            );

                            try {
                              // 自動發送郵件
                              await _sendOrderEmail();

                              // 發送成功後顯示確認對話框
                              final totalTickets = adults + children;
                              if (context.mounted) {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('訂單已送出'),
                                    content: Text(
                                      '護照姓名: $passportName\n'
                                      '大人: $adults 位\n'
                                      '小孩: $children 位\n'
                                      '總票數: $totalTickets 張\n'
                                      '參觀日期: ${selectedDate!.year}/${selectedDate!.month}/${selectedDate!.day}\n'
                                      '參觀時段: $timeSlot\n\n'
                                      '票價明細:\n'
                                      '大人票: NT\$ ${adults * adultPrice}\n'
                                      '小孩票: 免費\n'
                                      '總計: NT\$ $totalPrice\n\n'
                                      '訂單郵件已自動發送至 baluce@gmail.com\n'
                                      '感謝您的購買！',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                        child: const Text('確定'),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('郵件發送失敗: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 15,
                          ),
                          textStyle: const TextStyle(fontSize: 18),
                        ),
                        child: const Text('送出訂單'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
