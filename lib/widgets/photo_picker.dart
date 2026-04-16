import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_colors.dart';

class PhotoPicker extends StatefulWidget {
  final Function(List<File>) onPhotosSelected;

  const PhotoPicker({super.key, required this.onPhotosSelected});

  @override
  State<PhotoPicker> createState() => _PhotoPickerState();
}

class _PhotoPickerState extends State<PhotoPicker> {
  final List<File> _photos = [];
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        _photos.add(File(image.path));
      });
      widget.onPhotosSelected(_photos);
    }
  }

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                  leading: const Icon(Icons.photo_library, color: AppColors.primary),
                  title: const Text('Galerie', style: TextStyle(color: Colors.white)),
                  onTap: () {
                    _pickImage(ImageSource.gallery);
                    Navigator.of(context).pop();
                  }),
              ListTile(
                leading: const Icon(Icons.photo_camera, color: AppColors.primary),
                title: const Text('Appareil photo', style: TextStyle(color: Colors.white)),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Photos',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _photos.length + 1,
            itemBuilder: (context, index) {
              if (index == _photos.length) {
                return GestureDetector(
                  onTap: () => _showPicker(context),
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primary.withOpacity(0.5), width: 2),
                    ),
                    child: const Icon(Icons.add_a_photo, color: AppColors.primary, size: 32),
                  ),
                );
              }
              return Container(
                width: 100,
                height: 100,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: FileImage(_photos[index]),
                    fit: BoxFit.cover,
                  ),
                  border: Border.all(color: AppColors.primary, width: 2),
                ),
                child: Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _photos.removeAt(index);
                      });
                      widget.onPhotosSelected(_photos);
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(4.0),
                      child: CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.red,
                        child: Icon(Icons.close, color: Colors.white, size: 14),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
