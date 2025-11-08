import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../theme/app_theme.dart';

class SellerProfilePage extends StatelessWidget {
  final String sellerName = "Nenas Maju";

  // ✅ Add a callback to open the Settings Page
  final VoidCallback? onOpenSettings;

  SellerProfilePage({super.key, this.onOpenSettings});

  final String sellerBio =
      "Passionate seller of fresh and high-quality pineapples directly from the farm to your table.";
  final String sellerLocation = "Kuala Lumpur, Malaysia";

  final List<String> promoBanners = [
    "assets/images/demobanner1.jpg",
    "assets/images/demobanner1.jpg",
    "assets/images/demobanner1.jpg",
  ];

  final List<Map<String, String>> products = [
    {
      "name": "Nenas",
      "price": "RM199",
      "image": "assets/images/demoprdct1.jpg",
      "desc": "High-quality sound with noise cancellation."
    },
    {
      "name": "Nenas",
      "price": "RM299",
      "image": "assets/images/demoprdct2.jpg",
      "desc": "Track fitness, health, and notifications easily."
    },
    {
      "name": "Nenas",
      "price": "RM89",
      "image": "assets/images/demoprdct2.jpg",
      "desc": "RGB lighting with ultra-fast response time."
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Seller Profile'),
        backgroundColor: AppTheme.primaryGold,
        foregroundColor: AppTheme.textDark,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                  // Seller Info Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.borderColor),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundImage: NetworkImage(
                              "https://www.google.com/url?sa=i&url=https%3A%2F%2Fms.pngtree.com%2Ffreebackground%2Fyellow-pineapple-june-fruit-poster-background_1098734.html&psig=AOvVaw19FFxOgKFIONcAqnJ_bP_W&ust=1762603667157000&source=images&cd=vfe&opi=89978449&ved=0CBUQjRxqFwoTCLjn2r2A4JADFQAAAAAdAAAAABAE"),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                sellerName,
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textDark,
                                    ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                sellerLocation,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AppTheme.textLight,
                                    ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                sellerBio,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AppTheme.textDark,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        // Settings button
                        IconButton(
                          icon: const Icon(Icons.settings),
                          onPressed: onOpenSettings,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Promotion Carousel
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: CarouselSlider(
                      options: CarouselOptions(
                        height: 180.0,
                        enlargeCenterPage: true,
                        autoPlay: true,
                        aspectRatio: 16 / 9,
                        autoPlayCurve: Curves.fastOutSlowIn,
                        enableInfiniteScroll: true,
                        autoPlayAnimationDuration:
                            const Duration(milliseconds: 800),
                        viewportFraction: 0.85,
                      ),
                      items: promoBanners.map((imagePath) {
                        final isNetwork = imagePath.startsWith('http');
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: isNetwork
                              ? Image.network(
                                  imagePath,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                )
                              : Image.asset(
                                  imagePath,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Product Grid Section
                  Text(
                    "Available Products",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                  ),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: products.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.7,
                    ),
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        color: Colors.white,
                        elevation: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(12)),
                              child: product["image"]!.startsWith("http")
                                  ? Image.network(
                                      product["image"]!,
                                      height: 120,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.asset(
                                      product["image"]!,
                                      height: 120,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product["name"]!,
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.textDark,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      product["price"]!,
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            color: AppTheme.primaryYellow,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      product["desc"]!,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: AppTheme.textLight,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        );
  }
}
