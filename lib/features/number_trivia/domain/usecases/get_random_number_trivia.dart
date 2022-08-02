import 'package:dartz/dartz.dart';
import 'package:tddcleanarchitecture/core/error/failures.dart';
import 'package:tddcleanarchitecture/core/usecases/usecase.dart';
import 'package:tddcleanarchitecture/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:tddcleanarchitecture/features/number_trivia/domain/repositories/number_trivia_repository.dart';

class GetRandomNumberTrivia implements UseCase<NumberTrivia, int> {
  final NumberTriviaRepository repository;

  GetRandomNumberTrivia(this.repository);

  @override
  Future<Either<Failure, NumberTrivia>> call(_) async {
    return await repository.getRandomNumberTrivia();
  }
}
