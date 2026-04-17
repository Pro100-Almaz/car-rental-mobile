import 'package:flutter/material.dart';

class CarCategory {
  const CarCategory(this.id, this.label);
  final String id;
  final String label;
}

const List<CarCategory> kCarCategories = [
  CarCategory('all', 'All'),
  CarCategory('suv', 'SUV'),
  CarCategory('sedan', 'Sedan'),
  CarCategory('electric', 'Electric'),
  CarCategory('van', 'Van'),
];

class CarListing {
  const CarListing({
    required this.id,
    required this.name,
    required this.tagline,
    required this.imageUrl,
    required this.pricePerDay,
    required this.rating,
    required this.reviewCount,
    required this.distanceMiles,
    required this.category,
    required this.seats,
    required this.transmission,
    required this.year,
    this.ownerName = 'Michael Reese',
    this.ownerAvatarUrl =
        'https://lh3.googleusercontent.com/aida-public/AB6AXuD32RBWw_lx6e5VERrglMdlt0LmJIvThKKmlXtoV_Qm_Xl99OZA_JZ5FfZxGsHHMaZA7G3IK-en0uiwCQl-g1wcmmXKf8ZLRJZv2Y498TJDJyjmlLaVRrVRnNrNnX8OrGEddzLO7rrMje87wlRKcJEZMwcL-t08EM6EMBXhbAR9Jym1cmCbZ2NDofZ78mscibh9UTetIYnhSaQiGcwq-PmkokWTlD_Ka-exeYy9v_stxcWZnlVxX14imVVYa_4_ciiGKkW0Zv046fXi',
    this.description =
        'Experience the future of performance with this meticulously maintained vehicle. Sports DNA meets electric efficiency — perfect for city cruises or coastal escapes.',
  });

  final String id;
  final String name;
  final String tagline;
  final String imageUrl;
  final double pricePerDay;
  final double rating;
  final int reviewCount;
  final double distanceMiles;
  final String category;
  final int seats;
  final String transmission;
  final int year;
  final String ownerName;
  final String ownerAvatarUrl;
  final String description;
}

const List<CarListing> kNearbyCars = [
  CarListing(
    id: 'tesla-model-3',
    name: 'Tesla Model 3',
    tagline: 'Clean electric daily driver',
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuCSn5OvPec5q6JvkFyRskxBcna8MlbYtAIEHMsCIi5yfezWKIDEHqTh_VwfM21mQsXHjm0xUmpNgGCW8RlD3u1fkrZfHakTtCEiSW627SpNtPw0nb4J91y35wF_FswrUZb7nC2njbjQGoxTQiFd1W8c1ab7DvVsESCNdOtqij_YbcdMh37GeVKZ_gGru9Vn5P8UFUvw0rb1mGlJD8f6dbELTml3WEgw2JmXQ4GZVlkYauTRrN67VXGo249doBM4ou1_EiEIshh62STs',
    pricePerDay: 95,
    rating: 4.9,
    reviewCount: 212,
    distanceMiles: 1.2,
    category: 'electric',
    seats: 5,
    transmission: 'Auto',
    year: 2023,
  ),
  CarListing(
    id: 'range-rover-velar',
    name: 'Range Rover Velar',
    tagline: 'Luxury SUV for long weekends',
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuBDe9WAU9Y32fp7mxm8VT7HH7a4EXUA7ULshade1wI3HZ7HKP0j0KILQ5e4FqDDjHurkbN-eA_F19QM0sMo2JVO4BR7qi360LK7UeoL4_eV_jvRo4LpmnnIa4GsDMBvnXPtiowRdsq2KbWSLN0VeH6aPEJ_HegHlJV_X4MxI2OY4a0H6DZI2yscBi3cpOvp3EZs1HXzTUVg4HxX-UlEOjXb8JePipRI16TkF0Bs0RKPwriS93B08bj0gTX-6mJNUo_atghiAhY9PlX2',
    pricePerDay: 140,
    rating: 5.0,
    reviewCount: 86,
    distanceMiles: 2.5,
    category: 'suv',
    seats: 5,
    transmission: 'Auto',
    year: 2023,
  ),
  CarListing(
    id: 'porsche-taycan',
    name: 'Porsche Taycan',
    tagline: 'Sports car DNA, electric drive',
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuBAeZFhSSJsoutDhcuWnNfgh-d7ZpjUCjrWIVYQSVPkYKB9wU4sTPgkfBY550hCuJ2zIEaRck5ASG--i8xZlE8T9mNEr-wz4YwkSPVApKpPjhWpIJfcRC8vsUk99-xZGz_isFzlmSWdKQmKAFfJmlRdsvZTGpyoN0CKtpL6WZ_Qh3fGSvzlstw_mngcM70ZAaBY-Q5HVupX1wOvBauUmxXKHTTXjHi9tBVVcx4P06RYB5qQALV-2wlbWK4EO4GthICf6ETmJig6sRWM',
    pricePerDay: 210,
    rating: 4.8,
    reviewCount: 128,
    distanceMiles: 0.8,
    category: 'electric',
    seats: 4,
    transmission: 'Auto',
    year: 2023,
  ),
];

const List<CarListing> kTopRated = [
  CarListing(
    id: 'audi-rs-etron-gt',
    name: 'Audi RS e-tron GT',
    tagline: 'High-performance electric gran turismo',
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuCVf_bNClrNRpg6iiPogTtENm7qdAcqE9-9MEKrM_odC22IQi9-h8Ttia86N3kfFLfWMYnwKKFIImOLXkgo2urDGxeXyXiCufg7AY0hWa0MAeUwmu_nkMjuCjTH9diYXaOUCjb_jArFLSGydOA-Sm5lDEmBefr6MriV_Iuna81cMz5ByyGLfN_XgW_1I6f0pdW7Mn3Z4b1kILN33b2calhm49J-fyA4izaqcxi0sMh7lMs4ilAn-u0rK06MW3ary9aW35q2OPI_WG5o',
    pricePerDay: 185,
    rating: 4.9,
    reviewCount: 120,
    distanceMiles: 3.4,
    category: 'electric',
    seats: 4,
    transmission: 'Auto',
    year: 2024,
  ),
  CarListing(
    id: 'mercedes-s-class',
    name: 'Mercedes-Benz S-Class',
    tagline: 'The pinnacle of luxury sedan comfort',
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuBXd2mNDto6UZ2qBRG7mGMvKLf9cxqkNGfRpqmxBrBXYZy1vbSpUct9rjeDvKvpBjmDOOxysHs2eqb6zeJGvLRv2q-DVzmIrfa3POBl1YQXK0SxPY4Uqt3PZ5ugF_QkgtpOaGz6rMtehqdLH63rWW5fKPFlmfzo4DKxKhTrS-CpCLju8TDYRvlFRJ9IYjewgOgjz2FPX2Z9V0oFVtgqgKusP9PJefkYS5QikKg3z2_yvzt8HQ6IbMNUFlrelvXTn91DzcRcWYJ9aPMk',
    pricePerDay: 160,
    rating: 5.0,
    reviewCount: 85,
    distanceMiles: 4.1,
    category: 'sedan',
    seats: 5,
    transmission: 'Auto',
    year: 2023,
  ),
];

class BookingSummary {
  const BookingSummary({
    required this.id,
    required this.carName,
    required this.imageUrl,
    required this.tag,
    required this.dateRange,
    required this.status,
    required this.total,
    required this.statusColor,
  });

  final String id;
  final String carName;
  final String imageUrl;
  final String tag;
  final String dateRange;
  final String status;
  final double total;
  final Color statusColor;
}

const List<BookingSummary> kUpcomingBookings = [
  BookingSummary(
    id: 'b1',
    carName: 'Jeep Wrangler',
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuBgX6gvNsdDqjarsBP5NG2-mvXtENO7c8q3yDxTdvaWowT2XKBcuT5RLEcPHGl9XBUN5g9-faB67vu2cjTZ-jTuPAmh2sI9AT6vb8gd0ZD5tk-IkLxVvZFPRyjKkQ3euNkJE7mZDKY1BUnrwZVsjh9MA7Caw8vuTQKwrsjtReoh77TQpaYsAxfCRdkM0c6wsaMwglQq8R2G95F952I42aPe4bZrll_7a7JgnRBccMGOAXIApfnYUHsvwDEomSP-YuY5kQtM1j52SW7v',
    tag: 'Adventure',
    dateRange: 'Oct 12 – 15',
    status: 'Confirmed',
    total: 445,
    statusColor: Color(0xFF008378),
  ),
  BookingSummary(
    id: 'b2',
    carName: 'Porsche 911 Carrera',
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuALL4nIg4zzrYI9Zi71VmGAnQcasipFNTj4NHD-m8d5N0Q11OK5mJ0blOI1alcVT5b5sWoHWN-Z4834FBlQfikHvwc7spxJf87YKub6fWNeLaAz_mcFf3WYxww9mdLVM8xdA9qRA8yzyUV8-Q1kcZPyvFsWI2FgCtzEjy4TBpAguHyRkZdBJ0DxJ7deJrQL7bI-8cWb5FOK8p9NyhtLSIK7L263MW23X48rTlaU8UmEClcG3xiCBWx_i4uH-JX1wMbdcasD9DRuAdIZ',
    tag: 'Premium',
    dateRange: 'Nov 02 – 05',
    status: 'Confirmed',
    total: 1250,
    statusColor: Color(0xFF008378),
  ),
];

class OwnerListing {
  const OwnerListing({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.imageUrl,
    required this.pricePerDay,
    required this.status,
    required this.statusColor,
    this.faded = false,
  });

  final String id;
  final String name;
  final String subtitle;
  final String imageUrl;
  final double pricePerDay;
  final String status;
  final Color statusColor;
  final bool faded;
}

const List<OwnerListing> kOwnerListings = [
  OwnerListing(
    id: 'audi-a4',
    name: 'Audi A4',
    subtitle: 'Premium • 2022',
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuCo0ctsnNyjKt4ynR8NQlaIWPsws0G2OuujlZAXfVo8hOji0LiHb4qNOJgN3m7tgYlejFegrgIpgRQoSs2gH4ZH1iSXsFTNj8XH_oqGdhf4qzuS3C41i-AycUDlgdCm3QZRmurWWiC-F7-OZfMF1xfHaKPu2Bvp32OoO2alBAGKR57Z1IN2JL1BCLLrwFiRRaHUx7uHZBNT6aNTltmJHL3tgxz7uvkNekGYDH6YZHSXEmdpvbzxxTW9Isp8hkLSa8t3jleIcYFAgsWv',
    pricePerDay: 85,
    status: 'Available',
    statusColor: Color(0xFF00685F),
  ),
  OwnerListing(
    id: 'tesla-model-3-own',
    name: 'Tesla Model 3',
    subtitle: 'Electric • 2023',
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuDs-3SWacq5kq6M-L8Txdb3ruwbms1ohkY3t_h3D4OrwCeiBZ7q136JW0wA-ufmKV3Z4wl7dyfeWN-e3lZH0J1dCXOFIovxmjYU05HfqBGuUOc4WEMzwaAJ3CMK3AVqlK5aOkQaMFzWohBsuXQB4j3l1jcWuGP9WzcBu07M2EuDCEt15hZS9XHvEZPxeuTf3h7Imrk9900E0ihNiuovUfjW92A7f9BUBe5144IdEKXYRbHHqDfrKestDu6t5SCvyHwvomyI6WiqZ46E',
    pricePerDay: 120,
    status: 'Booked',
    statusColor: Color(0xFFAC331D),
  ),
  OwnerListing(
    id: 'bmw-x5',
    name: 'BMW X5',
    subtitle: 'SUV • 2021',
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuC9n4NA57Ibb4THPoJSiJzUfNcgICa8TVKInLMFkuvpMqhglV-OQ6cmcK6e17Oehgf5qTAhDPD44qZtk3Pfhge-ADU7bGwqchrRoXxYjmMEOFLvL33WUE5jzvzPWVzKqxGZgsERDjlWnNRjhDHSmf23unqOpmhh4zM18B0qwlbxlNgU6m1mEeCUKQdRA9-dg7R6Q08SAzoc9UcR6Cp2efptJmUhRFqvNnxYVr5W0VXNZptfN95LBck4EdjHGl_L5TKqlW_qjZDGglcK',
    pricePerDay: 150,
    status: 'Maintenance',
    statusColor: Color(0xFF6D7A77),
    faded: true,
  ),
];
