import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/data/models/company_model.dart';

void main() {
  group('CompanyModel visibility', () {
    test('esconde quando falta geo e categoria', () {
      final json = <String, dynamic>{
        'nomeFantasia': 'Loja incompleta',
      };
      expect(CompanyModel.isVisibleFromJson(json), isFalse);
      expect(CompanyModel.isMappableFromJson(json), isFalse);
    });

    test('aparece na lista com categoria e sem geo', () {
      final json = <String, dynamic>{
        'categoria': 'Alimentação',
      };
      expect(CompanyModel.isVisibleFromJson(json), isTrue);
      expect(CompanyModel.isMappableFromJson(json), isFalse);
    });

    test('aparece no mapa com geo válida', () {
      final json = <String, dynamic>{
        'geolocalizacao': {'lat': -23.5, 'lng': -46.6, 'accuracy': 10},
      };
      expect(CompanyModel.isVisibleFromJson(json), isTrue);
      expect(CompanyModel.isMappableFromJson(json), isTrue);
    });

    test('fromJson tolera campos nulos', () {
      final company = CompanyModel.fromJson(const {});
      expect(company.nomeFantasia, '');
      expect(company.categoria, '');
      expect(company.hasValidGeolocation, isFalse);
    });
  });

  group('Cashback caps (regras de domínio)', () {
    test('5% até R\$200 → máximo R\$10 de ganho', () {
      double ganho(double valorCompra) {
        final base = valorCompra > 200 ? 200.0 : valorCompra;
        return base * 0.05;
      }

      expect(ganho(100), 5);
      expect(ganho(200), 10);
      expect(ganho(500), 10);
    });

    test('utilizaValor não pode passar do valor da compra', () {
      double capUtilizavel(double saldo, double valorCompra) {
        final capped = saldo < valorCompra ? saldo : valorCompra;
        return capped < 0 ? 0 : capped;
      }

      expect(capUtilizavel(80, 50), 50);
      expect(capUtilizavel(30, 50), 30);
      expect(capUtilizavel(0, 50), 0);
    });

    test('parceira lifetime 50% por crédito', () {
      double parceiraRestante({
        required double cashback,
        required double jaUsadoEmParceira,
      }) {
        final limite = cashback * 0.5;
        final restante = limite - jaUsadoEmParceira;
        return restante < 0 ? 0 : restante;
      }

      expect(parceiraRestante(cashback: 20, jaUsadoEmParceira: 0), 10);
      expect(parceiraRestante(cashback: 20, jaUsadoEmParceira: 7), 3);
      expect(parceiraRestante(cashback: 20, jaUsadoEmParceira: 10), 0);
    });
  });
}
