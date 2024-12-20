import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:hedieaty_kevin_sherif_20p9405/services/login_service_unit_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_test.mocks.dart'; // Generated mock file

@GenerateMocks([
  FirebaseAuth,
  UserCredential,
  User,
])
void main() {
  late MockFirebaseAuth mockAuth;
  late LoginService loginService;
  late MockUser mockUser;

  setUp(() {
    // Initialize mocks and inject into the LoginService
    mockAuth = MockFirebaseAuth();
    mockUser = MockUser();
    loginService = LoginService(auth: mockAuth); // Modified constructor
  });

  test('login should return User when valid email and password are provided', () async {
    // Arrange: Mock the behavior of FirebaseAuth
    final mockUserCredential = MockUserCredential();
    when(mockAuth.signInWithEmailAndPassword(
      email: anyNamed('email'),
      password: anyNamed('password'),
    )).thenAnswer((_) async => mockUserCredential);
    when(mockUserCredential.user).thenReturn(mockUser);

    // Act: Call the login method
    final result = await loginService.login('test@example.com', 'password123');

    // Assert: Validate that the returned user is not null
    expect(result, isNotNull);
    expect(result, equals(mockUser));
    verify(mockAuth.signInWithEmailAndPassword(
      email: 'test@example.com',
      password: 'password123',
    )).called(1);
  });

  test('login should return null when incorrect email or password is provided', () async {
    // Arrange: Mock FirebaseAuth to throw an exception
    when(mockAuth.signInWithEmailAndPassword(
      email: anyNamed('email'),
      password: anyNamed('password'),
    )).thenThrow(FirebaseAuthException(code: 'user-not-found'));

    // Act: Call the login method with invalid credentials
    final result = await loginService.login('wrong@example.com', 'wrongpassword');

    // Assert: Validate that the result is null
    expect(result, isNull);
    verify(mockAuth.signInWithEmailAndPassword(
      email: 'wrong@example.com',
      password: 'wrongpassword',
    )).called(1);
  });
}
