class InquiryAddress {
  final String streetAddress;
  final String city;
  final String state;
  final String postalCode;
  final String? country;
  final String? landmark;

  InquiryAddress({
    required this.streetAddress,
    required this.city,
    required this.state,
    required this.postalCode,
    this.country,
    this.landmark,
  });

  Map<String, String> toJson() {
    final map = {
      'street_address': streetAddress,
      'city': city,
      'state': state,
      'postal_code': postalCode,
    };
    
    if (country != null && country!.isNotEmpty) {
      map['country'] = country!;
    }
    
    if (landmark != null && landmark!.isNotEmpty) {
      map['landmark'] = landmark!;
    }
    
    return map;
  }
}

class SellPhoneInquiry {
  final String sellMobileId;
  final String userId;
  final String buyerPhone;
  final String selectedVariant; // like "128GB"
  final String selectedCondition; // like "Good"
  final InquiryAddress address;
  final String? status;

  SellPhoneInquiry({
    required this.sellMobileId,
    required this.userId,
    required this.buyerPhone,
    required this.selectedVariant,
    required this.selectedCondition,
    required this.address,
    this.status = 'pending',
  });

  Map<String, dynamic> toJson() {
    return {
      'sell_mobile_id': sellMobileId,
      'user_id': userId,
      'buyer_phone': buyerPhone,
      'selected_variant': selectedVariant,
      'selected_condition': selectedCondition,
      'address': address.toJson(),
      if (status != null) 'status': status,
    };
  }
}
