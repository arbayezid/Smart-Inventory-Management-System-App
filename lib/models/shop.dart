// lib/models/shop.dart

enum ShopStatus { active, pending, rejected }

class Shop {
  final String id;
  String name;
  String ownerEmail;
  String plan;
  String mrr;
  ShopStatus status;
  String joinedDate;

  Shop({
    required this.id,
    required this.name,
    required this.ownerEmail,
    required this.plan,
    required this.mrr,
    required this.status,
    required this.joinedDate,
  });
}

/// Centralized mock data for the Super Admin dashboard.
final List<Shop> mockShops = [
  Shop(
    id: '1',
    name: "bayezids Shop",
    ownerEmail: "bayezida@gmail.com",
    plan: "Basic",
    mrr: "\$20",
    status: ShopStatus.active,
    joinedDate: "Jun 2, 2026",
  ),
  Shop(
    id: '2',
    name: "Demo Shop",
    ownerEmail: "demo@example.com",
    plan: "Basic",
    mrr: "\$20",
    status: ShopStatus.pending,
    joinedDate: "Jun 2, 2026",
  ),
  Shop(
    id: '3',
    name: "vfgh",
    ownerEmail: "ab@gmail.com",
    plan: "Basic",
    mrr: "\$20",
    status: ShopStatus.pending,
    joinedDate: "May 20, 2026",
  ),
  Shop(
    id: '4',
    name: "My Shop",
    ownerEmail: "sayedgpt206@gmail.com",
    plan: "Basic",
    mrr: "\$20",
    status: ShopStatus.pending,
    joinedDate: "May 18, 2026",
  ),
  Shop(
    id: '5',
    name: "My Shop",
    ownerEmail: "rakhibishwas10@gmail.com",
    plan: "Basic",
    mrr: "\$20",
    status: ShopStatus.pending,
    joinedDate: "May 6, 2026",
  ),
  Shop(
    id: '6',
    name: "My Shop",
    ownerEmail: "bayezidar0@gmail.com",
    plan: "Basic",
    mrr: "\$20",
    status: ShopStatus.active,
    joinedDate: "May 2, 2026",
  ),
  Shop(
    id: '7',
    name: "AR Bayezid",
    ownerEmail: "bayezid2000@gmail.com",
    plan: "Basic",
    mrr: "\$20",
    status: ShopStatus.rejected,
    joinedDate: "May 2, 2026",
  ),
  Shop(
    id: '8',
    name: "Tech Store",
    ownerEmail: "techstore@gmail.com",
    plan: "Pro",
    mrr: "\$20",
    status: ShopStatus.active,
    joinedDate: "Apr 15, 2026",
  ),
  Shop(
    id: '9',
    name: "Fashion Hub",
    ownerEmail: "fashionhub@gmail.com",
    plan: "Basic",
    mrr: "\$20",
    status: ShopStatus.pending,
    joinedDate: "Apr 10, 2026",
  ),
  Shop(
    id: '10',
    name: "Grocery Mart",
    ownerEmail: "grocerymart@gmail.com",
    plan: "Basic",
    mrr: "\$20",
    status: ShopStatus.rejected,
    joinedDate: "Apr 5, 2026",
  ),
  Shop(
    id: '11',
    name: "Electronics Plus",
    ownerEmail: "electronicsplus@gmail.com",
    plan: "Pro",
    mrr: "\$20",
    status: ShopStatus.pending,
    joinedDate: "Mar 28, 2026",
  ),
  Shop(
    id: '12',
    name: "Book World",
    ownerEmail: "bookworld@gmail.com",
    plan: "Basic",
    mrr: "\$20",
    status: ShopStatus.active,
    joinedDate: "Mar 20, 2026",
  ),
];
