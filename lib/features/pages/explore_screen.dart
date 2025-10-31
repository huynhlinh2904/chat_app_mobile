import 'package:flutter/material.dart';

class ChatExploreSimpleScreen extends StatefulWidget {
  const ChatExploreSimpleScreen({super.key});

  @override
  State<ChatExploreSimpleScreen> createState() => _ChatExploreSimpleScreenState();
}

class _ChatExploreSimpleScreenState extends State<ChatExploreSimpleScreen> {
  final _searchCtl = TextEditingController();
  int _filterIndex = 0;

  @override
  void dispose() {
    _searchCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filters = ['Tất cả', 'Bạn bè', 'Nhóm', 'Bot'];
    final quickActions = [
      _QA('Tin nhắn mới', Icons.chat_bubble_outline, () {
        Navigator.pushNamed(context, '/chat_new');
      }),
      _QA('Tạo nhóm', Icons.group_add_outlined, () {
        Navigator.pushNamed(context, '/create_group');
      }),
      _QA('Danh bạ', Icons.contacts_outlined, () {
        Navigator.pushNamed(context, '/contacts');
      }),
    ];
    final features = const [
      _Feature('Kênh cộng đồng', Icons.campaign_outlined),
      _Feature('Nhóm gần đây', Icons.group_outlined),
      _Feature('Bot & Tiện ích', Icons.smart_toy_outlined),
      _Feature('Cuộc gọi', Icons.call_outlined),
      _Feature('File đã chia sẻ', Icons.folder_open_outlined),
      _Feature('Tin nhắn đã ghim', Icons.push_pin_outlined),
    ];

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          title: const Text('Khám phá chat', style: TextStyle(fontWeight: FontWeight.w700)),
          centerTitle: false,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search
              _SearchField(controller: _searchCtl),

              const SizedBox(height: 12),

              // Filter chips
              SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: filters.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) => ChoiceChip(
                    label: Text(filters[i]),
                    selected: _filterIndex == i,
                    onSelected: (_) => setState(() => _filterIndex = i),
                    selectedColor: const Color(0xFFE8F5E9),
                    labelStyle: TextStyle(
                      fontWeight: _filterIndex == i ? FontWeight.w700 : FontWeight.w500,
                    ),
                    side: const BorderSide(color: Color(0x11000000)),
                    backgroundColor: const Color(0xFFF7F7F7),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Quick actions
              const Text('Tính năng chat', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              Row(
                children: quickActions
                    .map((qa) => Expanded(child: _QuickActionTile(qa: qa)))
                    .toList(),
              ),

              const SizedBox(height: 20),

              // Features grid
              const Text('Gợi ý', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: features.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 2.1,
                ),
                itemBuilder: (_, i) => _FeatureTile(feature: features[i]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ========== Widgets nhỏ, đơn giản ==========

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFFF2F5F4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        textInputAction: TextInputAction.search,
        decoration: const InputDecoration(
          hintText: 'Search',
          prefixIcon: Icon(Icons.search),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({required this.qa});
  final _QA qa;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: qa.onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            height: 74,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0x11000000)),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF7FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(qa.icon, color: const Color(0xFF1E88E5)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(qa.label, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  const _FeatureTile({required this.feature});
  final _Feature feature;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x11000000)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFF6F6F6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(feature.icon, color: Colors.black54),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(feature.label, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

/// ========== Models nho nhỏ ==========

class _QA {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _QA(this.label, this.icon, this.onTap);
}

class _Feature {
  final String label;
  final IconData icon;
  const _Feature(this.label, this.icon);
}
