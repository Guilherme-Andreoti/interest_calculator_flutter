import 'dart:math';

import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:intrest_calculator/helpers/constants.dart';
import 'package:intrest_calculator/models/payment_slip.dart';
import 'package:intrest_calculator/models/result_payment_slip.dart';

class Controller {
  // Controler para o TextFormField
  final moneyController = new MoneyMaskedTextController();
  final feeController = new MoneyMaskedTextController();
  final interestController = new MoneyMaskedTextController();

  // Classe modelo que armazena as informações da tela
  final paymentSlip = new PaymentSlip(
    feeType: Constants.rateLabels[0],
    interestType: Constants.rateLabels[0],
    interestPeriod: Constants.periodLabels[0],
  );

  // Função para calcular o resultado
  ResultPaymentSlip calculate() {
    // Valor a ser pago
    ResultPaymentSlip result = ResultPaymentSlip();
    result.value = paymentSlip.money;

    var payDate = DateTime(paymentSlip.payDate.year, paymentSlip.payDate.month, paymentSlip.payDate.day);
    var dueDate = DateTime(paymentSlip.dueDate.year, paymentSlip.dueDate.month, paymentSlip.dueDate.day);
    // Verifica se deve aplicar os juros
    // Data de pagamento > Data de vencimento
    if (payDate.isAfter(dueDate)) {
      // Calculo da multa
      result.fee = _calculateFeeValue();
      result.value += result.fee;

      // Verifica quantos dias esta em atraso
      result.days = paymentSlip.payDate.difference(paymentSlip.dueDate).inDays;
      if (paymentSlip.interestPeriod == Constants.periodLabels[1]) {
        result.days = result.days ~/ 30;
      }

      // Calculo dos juros
      result.interest = _calculateInterestValue(result.days);
      result.value += result.interest;
    }

    return result;
  }

  _calculateFeeValue() {
    // Inicialmente supomos que a multa esta em valor monetário
    var value = paymentSlip.feeValue;
    // Caso a multa esteja em porcentagem, calculos o valor monetário dela
    if (paymentSlip.feeType == Constants.rateLabels[1]) {
      value = paymentSlip.feeValue / 100.0 * paymentSlip.money;
    }

    return value;
  }

  _calculateInterestValue(int days) {
    // Calcula a porcentagem de juros
    double rate = paymentSlip.interestValue / 100.0;
    if (paymentSlip.interestType == Constants.rateLabels[0]) {
      rate = paymentSlip.interestValue / paymentSlip.money;
    }

    // Calcula o juros composto
    // valor = montante * (1 + porcentagem)^dias
    print('value = ${paymentSlip.money} * (1 + $rate) ^ $days');
    var value = paymentSlip.money * pow(1 + rate, days);
    return value - paymentSlip.money;
  }

  // Função para apagar (reiniciar) as informações da tela
  // Esta função faz parte do desafio, por isso ela não esta codificada
  void clear() {}
}