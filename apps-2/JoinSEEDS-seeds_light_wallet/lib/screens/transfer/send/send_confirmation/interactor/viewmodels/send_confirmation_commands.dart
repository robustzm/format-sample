import 'package:seeds/datasource/local/models/fiat_data_model.dart';
import 'package:seeds/datasource/remote/model/generic_transaction_model.dart';
import 'package:seeds/datasource/remote/model/profile_model.dart';
import 'package:seeds/datasource/remote/model/transaction_model.dart';
import 'package:seeds/domain-shared/page_command.dart';

abstract class TransactionPageCommand extends PageCommand {}

class ShowTransactionSuccess extends TransactionPageCommand {
  final GenericTransactionModel transactionModel;

  ShowTransactionSuccess(this.transactionModel);
}

class ShowTransferSuccess extends TransactionPageCommand {
  final TransactionModel transactionModel;
  ProfileModel? from;
  ProfileModel? to;
  FiatDataModel? fiatAmount;

  ShowTransferSuccess({
    required this.transactionModel,
    this.from,
    this.to,
    this.fiatAmount,
  });
}
