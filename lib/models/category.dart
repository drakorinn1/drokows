import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class ServiceCategory {
  final String slug;
  final String name;
  final String description;
  final IconData icon;

  const ServiceCategory({
    required this.slug,
    required this.name,
    required this.description,
    required this.icon,
  });
}

/// lib/categories.ts dosyasındaki CATEGORIES listesinin birebir karşılığı.
const List<ServiceCategory> kCategories = [
  ServiceCategory(
    slug: 'boya-badana',
    name: 'Boya / Badana',
    description: 'İç ve dış cephe boyama, badana, dekoratif boya',
    icon: CupertinoIcons.paintbrush,
  ),
  ServiceCategory(
    slug: 'elektrik',
    name: 'Elektrik Tesisatı',
    description: 'Priz, aydınlatma, pano ve arıza onarımı',
    icon: CupertinoIcons.bolt,
  ),
  ServiceCategory(
    slug: 'su-tesisati',
    name: 'Su Tesisatı',
    description: 'Sızıntı, tıkanıklık, batarya ve tesisat işleri',
    icon: CupertinoIcons.drop,
  ),
  ServiceCategory(
    slug: 'tadilat-marangoz',
    name: 'Tadilat / Marangoz',
    description: 'Mobilya montajı, ahşap işleri, genel tadilat',
    icon: Icons.handyman_outlined,
  ),
  ServiceCategory(
    slug: 'temizlik',
    name: 'Temizlik',
    description: 'Ev, ofis ve inşaat sonrası detaylı temizlik',
    icon: CupertinoIcons.sparkles,
  ),
  ServiceCategory(
    slug: 'klima-beyaz-esya',
    name: 'Klima / Beyaz Eşya',
    description: 'Klima montajı, bakım ve beyaz eşya tamiri',
    icon: Icons.ac_unit_outlined,
  ),
];

final Map<String, ServiceCategory> kCategoryMap = {
  for (final c in kCategories) c.slug: c,
};

String categoryName(String slug) => kCategoryMap[slug]?.name ?? slug;

class RequestStatusInfo {
  final String label;
  final String tone; // open | assigned | done | cancelled
  const RequestStatusInfo(this.label, this.tone);
}

/// lib/categories.ts -> REQUEST_STATUS
const Map<String, RequestStatusInfo> kRequestStatus = {
  'open': RequestStatusInfo('Usta bekleniyor', 'open'),
  'assigned': RequestStatusInfo('Usta atandı', 'assigned'),
  'completed': RequestStatusInfo('Tamamlandı', 'done'),
  'cancelled': RequestStatusInfo('İptal edildi', 'cancelled'),
};
