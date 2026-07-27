import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/data/models/customer_model.dart';

void main() {
  group('CustomerModel', () {
    test('lê numero e photoUrl com aliases do Firestore', () {
      final customer = CustomerModel.fromJson({
        'email': 'teste@email.com',
        'nomeCompleto': 'Teste',
        'n': '123',
        'photoUrl': 'https://example.com/photo.jpg',
        'uid': 'abc',
      });

      expect(customer.n, '123');
      expect(customer.hasPhoto, isTrue);
    });

    test('hasPhoto retorna false quando photoURL está vazio', () {
      final customer = CustomerModel(email: 'a@b.com', photoURL: '  ');
      expect(customer.hasPhoto, isFalse);
    });
  });
}
