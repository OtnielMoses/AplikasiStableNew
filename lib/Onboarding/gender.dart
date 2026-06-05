import 'package:flutter/material.dart';

enum Gender { none, male, female }

class GenderSelectionPage extends StatefulWidget {
  final Function(Gender gender)? onContinue;
  final VoidCallback? onSkip;

  const GenderSelectionPage({
    super.key,
    this.onContinue,
    this.onSkip,
  });

  @override
  State<GenderSelectionPage> createState() => _GenderSelectionPageState();
}

class _GenderSelectionPageState extends State<GenderSelectionPage>
    with SingleTickerProviderStateMixin {

  Gender _selectedGender = Gender.none;

  static const Color _femaleActiveColor = Color(0xFFD87AE8);
  static const Color _maleActiveColor = Color(0xFFCEF542);
  static const Color _inactiveColor = Color(0xFF3A3A4A);

  void _onSelectGender(Gender gender) {
    setState(() {
      _selectedGender = gender;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isFemaleSelected = _selectedGender == Gender.female;
    final bool isMaleSelected = _selectedGender == Gender.male;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const SizedBox(height: 16),

              GestureDetector(
                onTap: () => Navigator.maybePop(context),
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 32),

              const Text(
                'Tell us about yourself!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Please choose your gender or preferred identity.',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.55),
                ),
              ),

              const SizedBox(height: 40),

              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [

                    // FEMALE
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 350),
                      top: isFemaleSelected ? 20 : 0,
                      left: 0,
                      child: GestureDetector(
                        onTap: () => _onSelectGender(Gender.female),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 350),
                          width: isFemaleSelected ? 220 : 120,
                          height: isFemaleSelected ? 220 : 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isFemaleSelected
                                ? _femaleActiveColor
                                : _inactiveColor,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '♀',
                                style: TextStyle(
                                  fontSize: isFemaleSelected ? 72 : 36,
                                  color: isFemaleSelected
                                      ? Colors.black
                                      : Colors.white,
                                ),
                              ),
                              Text(
                                'Female',
                                style: TextStyle(
                                  fontSize: isFemaleSelected ? 20 : 13,
                                  fontWeight: FontWeight.bold,
                                  color: isFemaleSelected
                                      ? Colors.black
                                      : Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // MALE
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 350),
                      bottom: isMaleSelected ? 20 : 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () => _onSelectGender(Gender.male),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 350),
                          width: isMaleSelected ? 220 : 120,
                          height: isMaleSelected ? 220 : 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isMaleSelected
                                ? _maleActiveColor
                                : _inactiveColor,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '♂',
                                style: TextStyle(
                                  fontSize: isMaleSelected ? 72 : 36,
                                  color: isMaleSelected
                                      ? Colors.black
                                      : Colors.white,
                                ),
                              ),
                              Text(
                                'Male',
                                style: TextStyle(
                                  fontSize: isMaleSelected ? 20 : 13,
                                  fontWeight: FontWeight.bold,
                                  color: isMaleSelected
                                      ? Colors.black
                                      : Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Row(
                children: [

                  // SKIP
                  Expanded(
                    child: TextButton(
                      onPressed: widget.onSkip,
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFF2A2A36),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Skip',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // CONTINUE
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _selectedGender != Gender.none
                          ? () {
                              widget.onContinue?.call(_selectedGender);
                            }
                          : null,
                      child: Text(
                        'Continue',
                        style: TextStyle(
                          color: _selectedGender != Gender.none
                              ? Colors.black
                              : Colors.white54,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}