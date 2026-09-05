import 'package:flutter/material.dart';

class CategoryGrid extends StatelessWidget {
  final Function(String category)? onTap;
  final Function(String category)? onCategoryTap;

  const CategoryGrid({
    super.key,
    this.onTap,
    this.onCategoryTap,
  });

  final List<Map<String, String>> _categories = const [
    {
      'title': 'Boya / Badana',
      'subtitle': 'İç ve dış cephe boyama, badana, dekoratif boya',
      'image': 'https://images.unsplash.com/photo-1589939705384-5185137a7f0f?q=80&w=500&auto=format&fit=crop',
    },
    {
      'title': 'Elektrik Tesisatı',
      'subtitle': 'Priz, aydınlatma, pano ve arıza onarımı',
      'image': 'https://images.unsplash.com/photo-1621905251189-08b45d6a269e?q=80&w=500&auto=format&fit=crop',
    },
    {
      'title': 'Su Tesisatı',
      'subtitle': 'Sızıntı, tıkanıklık, batarya ve tesisat işleri',
      'image': 'https://images.unsplash.com/photo-1585704032915-c3400ca199e7?q=80&w=500&auto=format&fit=crop',
    },
    {
      'title': 'Tadilat / Marangoz',
      'subtitle': 'Mobilya montajı, ahşap işleri, genel tadilat',
      'image': 'https://images.unsplash.com/photo-1538688525198-9b88f6f53126?q=80&w=500&auto=format&fit=crop',
    },
    {
      'title': 'Temizlik',
      'subtitle': 'Ev, ofis ve inşaat sonrası detaylı temizlik',
      'image': 'https://images.unsplash.com/photo-1581578731548-c64695cc6952?q=80&w=500&auto=format&fit=crop',
    },
    {
      'title': 'Klima / Beyaz Eşya',
      'subtitle': 'Klima montajı, bakım ve beyaz eşya tamiri',
      'image': 'https://images.unsplash.com/photo-1621905252507-b35492cc74b4?q=80&w=500&auto=format&fit=crop',
    },
  ];

  void _handleTap(String category) {
    if (onTap != null) {
      onTap!(category);
    } else if (onCategoryTap != null) {
      onCategoryTap!(category);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = constraints.maxWidth > 600 ? 2 : 1;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.5,
          ),
          itemCount: _categories.length,
          itemBuilder: (context, index) {
            final item = _categories[index];
            return Card(
              clipBehavior: Clip.antiAlias,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              child: InkWell(
                onTap: () => _handleTap(item['title']!),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        color: const Color(0xFFF1F5F9),
                        child: Image.network(
                          item['image']!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Icon(Icons.image_not_supported, color: Colors.grey),
                            );
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['title']!,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item['subtitle']!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}