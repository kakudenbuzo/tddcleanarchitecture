import 'package:dartz/dartz.dart';
import 'package:tddcleanarchitecture/core/error/failures.dart';
import 'package:tddcleanarchitecture/core/usecases/usecase.dart';
import 'package:tddcleanarchitecture/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:tddcleanarchitecture/features/number_trivia/domain/repositories/number_trivia_repository.dart';

class GetConcreteNumberTrivia implements UseCase<NumberTrivia, int> {
  final NumberTriviaRepository repository;

  GetConcreteNumberTrivia(this.repository);

  @override
  Future<Either<Failure, NumberTrivia>> call(int number) async {
    return await repository.getConcreteNumberTrivia(number);
  }
}
