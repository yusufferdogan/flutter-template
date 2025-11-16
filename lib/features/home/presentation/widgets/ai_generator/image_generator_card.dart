import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ImageGeneratorCard extends StatelessWidget {
  final VoidCallback onGenerateTap;

  const ImageGeneratorCard({
    super.key,
    required this.onGenerateTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 343.w,
      height: 137.h,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF312A41), Color(0xFF1E1C2B)],
        ),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Image Generator',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Turn your ideas into stunning images',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13.sp,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  ElevatedButton(
                    onPressed: onGenerateTap,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.w,
                        vertical: 8.h,
                      ),
                      backgroundColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                    ).copyWith(
                      backgroundColor: MaterialStateProperty.all(
                        Colors.transparent,
                      ),
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF7C3AED), Color(0xFFDB2777)],
                        ),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 8.h,
                        ),
                        child: Text(
                          'Generate',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            // Abstract illustration placeholder
            Container(
              width: 80.w,
              height: 80.h,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                Icons.image,
                size: 40.sp,
                color: Colors.white.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
