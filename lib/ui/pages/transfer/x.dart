import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_ewallet/utils/shared_values.dart';
import 'package:http/http.dart' as http;
import 'package:archive/archive.dart'; // Import archive package for zip handling

class IDCard {
  final Uint8List imageData;
  bool isInForeground;

  IDCard({required this.imageData, this.isInForeground = false});
}

class IDCardWidget extends StatelessWidget {
  final IDCard idCard;
  final Function() onTap;

  const IDCardWidget({super.key, required this.idCard, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: 200,
          width: 287,
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0),
            color: idCard.isInForeground ? Colors.white : Colors.grey[900],
          ),
          child: Stack(
            children: [
              const Positioned(
                top: 8,
                right: 8,
                child: Text(
                  'ID Card',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: Image.memory(idCard.imageData),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class IDCardScreen extends StatefulWidget {
  const IDCardScreen({super.key});

  @override
  _IDCardScreenState createState() => _IDCardScreenState();
}

class _IDCardScreenState extends State<IDCardScreen> {
  List<IDCard> idCards = [];

  @override
  void initState() {
    super.initState();
    fetchIDCards();
  }

  Future<void> fetchIDCards() async {
    try {
      final response = await http.get(Uri.parse('${SharedValues.baseUrl}/image/user/1/cards'));
      if (response.statusCode == 200) {
        final List<int> zipBytes = response.bodyBytes;
        final Archive archive = ZipDecoder().decodeBytes(zipBytes);

        final List<IDCard> fetchedIDCards = [];

        for (final ArchiveFile file in archive) {
          final Uint8List imageData = file.content as Uint8List;
          fetchedIDCards.add(IDCard(imageData: imageData));
        }

        setState(() {
          idCards = fetchedIDCards;
        });
      } else {
        throw Exception('Failed to fetch ID cards');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ID Cards'),
      ),
      body: idCards.isEmpty
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Center(
            child: Stack(
                children: [
                  for (int i = 0; i < idCards.length; i++)
                    Positioned(
                      top: i * 20.0, // Adjust as needed
                      left: i * 20.0, // Adjust as needed
                      child: IDCardWidget(
                        idCard: idCards[i],
                        onTap: () {
                          setState(() {
                            idCards[i].isInForeground = !idCards[i].isInForeground;
                            // Bring the tapped card to the top
                            idCards.insert(0, idCards.removeAt(i));
                          });
                        },
                      ),
                    ),
                ],
              ),
          ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: IDCardScreen(),
  ));
}
