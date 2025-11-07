import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

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
    const backgroundColor = Color(0xFFFFF8E1); // Light cream
    const accentColor = Color(0xFFFFC107); // Warm yellow-orange
    const textColor = Color(0xFF2E2E2E); // Dark text

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: accentColor,
        title: const Text(
          "Seller Profile",
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: textColor),

        // ✅ Settings button in the AppBar
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: onOpenSettings, // <-- triggers the settings page
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Seller Info Section
            Container(
              padding: const EdgeInsets.all(16),
              color: backgroundColor,
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
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          sellerLocation,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          sellerBio,
                          style: const TextStyle(
                            fontSize: 15,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),

            const Divider(thickness: 1),

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

            // Product Grid Section
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: const [
                  Text(
                    "Available Products",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),

            GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              shrinkWrap: true, // ✅ allow GridView to size itself properly
              physics:
                  const NeverScrollableScrollPhysics(), // ✅ prevent inner scroll conflict
              itemCount: products.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.7, // 🔧 adjust to make sure no overflow
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
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Color(0xFF2E2E2E),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                product["price"]!,
                                style: const TextStyle(
                                  color: Color(0xFFFFC107),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                product["desc"]!,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.black87,
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
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
