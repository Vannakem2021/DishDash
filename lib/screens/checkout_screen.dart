import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../utils/app_theme.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({Key? key}) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentStep = 0;

  // Delivery Address Form Controllers
  final _streetController = TextEditingController();
  final _apartmentController = TextEditingController();
  final _cityController = TextEditingController();
  final _zipController = TextEditingController();
  final _instructionsController = TextEditingController();

  // Payment Method Controllers
  final _cardNumberController = TextEditingController();
  final _nameOnCardController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  String _selectedPaymentMethod = 'Credit Card';

  // Form Keys
  final _addressFormKey = GlobalKey<FormState>();
  final _paymentFormKey = GlobalKey<FormState>();

  // Add a loading state flag
  bool _isPlacingOrder = false;

  @override
  void dispose() {
    _pageController.dispose();
    _streetController.dispose();
    _apartmentController.dispose();
    _cityController.dispose();
    _zipController.dispose();
    _instructionsController.dispose();
    _cardNumberController.dispose();
    _nameOnCardController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  Future<void> _goToNextStep() async {
    if (_currentStep < 3) {
      // Handle steps 0-2: Address, Payment, Confirmation
      if (_currentStep == 0) {
        // Validate address form
        if (_addressFormKey.currentState!.validate()) {
          setState(() {
            _currentStep++;
          });
          _pageController.animateToPage(
            1,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      } else if (_currentStep == 1) {
        // Validate payment form
        if (_paymentFormKey.currentState!.validate() ||
            _selectedPaymentMethod == 'Cash on Delivery') {
          setState(() {
            _currentStep++;
          });
          _pageController.animateToPage(
            2,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      } else if (_currentStep == 2) {
        // Moving to final step (summary)
        setState(() {
          _currentStep++;
        });
      }
    } else {
      // Handle order placement on the final step
      if (_addressFormKey.currentState!.validate() &&
          (_selectedPaymentMethod != 'Credit Card' ||
              _paymentFormKey.currentState!.validate())) {
        setState(() {
          _isPlacingOrder = true;
        });

        try {
          final fullAddress = _buildFullAddress();

          // Place the order and get the order ID
          final orderId = await Provider.of<CartProvider>(
            context,
            listen: false,
          ).checkout(fullAddress, _selectedPaymentMethod);

          // Navigate to the order confirmation screen with the order ID
          if (mounted) {
            Navigator.of(
              context,
            ).pushNamed('/order-confirmation', arguments: orderId);
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to place order: ${e.toString()}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        } finally {
          if (mounted) {
            setState(() {
              _isPlacingOrder = false;
            });
          }
        }
      } else {
        // Show validation errors
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please check all required fields'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _goToPreviousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pop(context);
    }
  }

  String _buildFullAddress() {
    return '${_streetController.text}, ${_apartmentController.text}\n${_cityController.text}, ${_zipController.text}';
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Checkout',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Checkout steps indicator
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 12.0,
            ),
            child: Row(
              children: [
                _buildStepIndicator(1, 'Delivery Address', _currentStep >= 0),
                _buildStepConnector(_currentStep >= 1),
                _buildStepIndicator(2, 'Payment Method', _currentStep >= 1),
                _buildStepConnector(_currentStep >= 2),
                _buildStepIndicator(3, 'Order Summary', _currentStep >= 2),
              ],
            ),
          ),

          // Page content
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildDeliveryAddressStep(),
                _buildPaymentMethodStep(),
                _buildOrderSummaryStep(cart),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Step indicator widgets
  Widget _buildStepIndicator(int step, String label, bool isActive) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: isActive ? AppTheme.primaryColor : Colors.grey[300],
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Text(
              step.toString(),
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey[700],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        if (step == _currentStep + 1)
          Container(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
      ],
    );
  }

  Widget _buildStepConnector(bool isActive) {
    return Expanded(
      child: Container(
        height: 2,
        color: isActive ? AppTheme.primaryColor : Colors.grey[300],
      ),
    );
  }

  // Step content builders
  Widget _buildDeliveryAddressStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _addressFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Street Address Field
            _buildAddressTextField(
              controller: _streetController,
              labelText: 'Street Address',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your street address';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Apartment, Suite, etc. (optional)
            _buildAddressTextField(
              controller: _apartmentController,
              labelText: 'Apartment, Suite, etc. (optional)',
              isRequired: false,
            ),
            const SizedBox(height: 16),

            // City and ZIP Code
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: _buildAddressTextField(
                    controller: _cityController,
                    labelText: 'City',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your city';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: _buildAddressTextField(
                    controller: _zipController,
                    labelText: 'ZIP Code',
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your ZIP code';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Delivery Instructions (optional)
            _buildAddressTextField(
              controller: _instructionsController,
              labelText: 'Delivery Instructions (optional)',
              isRequired: false,
              maxLines: 3,
            ),
            const SizedBox(height: 40),

            // Next button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _goToNextStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'NEXT',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _paymentFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Payment Method',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),

            // Payment method radio buttons
            _buildPaymentMethodOption(
              title: 'Credit Card',
              value: 'Credit Card',
              groupValue: _selectedPaymentMethod,
              onChanged: (value) {
                setState(() {
                  _selectedPaymentMethod = value!;
                });
              },
            ),
            _buildPaymentMethodOption(
              title: 'Cash on Delivery',
              value: 'Cash on Delivery',
              groupValue: _selectedPaymentMethod,
              onChanged: (value) {
                setState(() {
                  _selectedPaymentMethod = value!;
                });
              },
            ),
            const SizedBox(height: 24),

            // Credit card fields (visible only if credit card is selected)
            if (_selectedPaymentMethod == 'Credit Card') ...[
              _buildAddressTextField(
                controller: _cardNumberController,
                labelText: 'Card Number',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your card number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              _buildAddressTextField(
                controller: _nameOnCardController,
                labelText: 'Name on Card',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the name on your card';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: _buildAddressTextField(
                      controller: _expiryController,
                      labelText: 'Expiry Date',
                      hintText: 'MM/YY',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 1,
                    child: _buildAddressTextField(
                      controller: _cvvController,
                      labelText: 'CVV',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 40),

            // Navigation buttons
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 56,
                    child: OutlinedButton(
                      onPressed: _goToPreviousStep,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey[300]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'BACK',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _goToNextStep,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'NEXT',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummaryStep(CartProvider cart) {
    final subtotal = cart.totalAmount;
    final tax = subtotal * 0.08; // 8% tax
    final deliveryFee = 2.99;
    final total = subtotal + tax + deliveryFee;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Order',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Order items
          ...cart.items
              .map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      Text(
                        '${item.quantity}x ${item.foodItem.name}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const Spacer(),
                      Text(
                        '\$${(item.foodItem.price * item.quantity).toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),

          const Divider(height: 32),

          // Order summary
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Subtotal'),
              Text('\$${subtotal.toStringAsFixed(2)}'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Tax (8%)'),
              Text('\$${tax.toStringAsFixed(2)}'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Delivery Fee'),
              Text('\$${deliveryFee.toStringAsFixed(2)}'),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                '\$${total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Delivery address summary
          const Text(
            'Delivery Address',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            _streetController.text +
                (_apartmentController.text.isNotEmpty
                    ? ', ${_apartmentController.text}'
                    : '') +
                ', ${_cityController.text}, ${_zipController.text}',
            style: TextStyle(color: Colors.grey[700]),
          ),

          const SizedBox(height: 24),

          // Payment method summary
          const Text(
            'Payment Method',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            _selectedPaymentMethod,
            style: TextStyle(color: Colors.grey[700]),
          ),

          const SizedBox(height: 40),

          // Navigation buttons
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: OutlinedButton(
                    onPressed: _goToPreviousStep,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey[300]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'BACK',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _goToNextStep,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'PLACE ORDER',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper widgets
  Widget _buildAddressTextField({
    required TextEditingController controller,
    required String labelText,
    String? hintText,
    bool isRequired = true,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: Colors.grey[100],
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppTheme.primaryColor),
            ),
          ),
          validator:
              isRequired
                  ? validator ??
                      (value) {
                        if (value == null || value.isEmpty) {
                          return 'This field is required';
                        }
                        return null;
                      }
                  : null,
        ),
      ],
    );
  }

  Widget _buildPaymentMethodOption({
    required String title,
    required String value,
    required String groupValue,
    required void Function(String?) onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(
          color:
              groupValue == value ? AppTheme.primaryColor : Colors.grey[300]!,
          width: groupValue == value ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: RadioListTile<String>(
        title: Text(
          title,
          style: TextStyle(
            fontWeight:
                groupValue == value ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        value: value,
        groupValue: groupValue,
        onChanged: onChanged,
        activeColor: AppTheme.primaryColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
