import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:tddcleanarchitecture/core/error/failures.dart';
import 'package:tddcleanarchitecture/core/usecases/usecase.dart';
import 'package:tddcleanarchitecture/core/util/input_converter.dart';
import 'package:tddcleanarchitecture/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:tddcleanarchitecture/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:tddcleanarchitecture/features/number_trivia/domain/usecases/get_random_number_trivia.dart';

part 'number_trivia_event.dart';
part 'number_trivia_state.dart';

const String SERVER_FAILURE_MESSAGE = 'Server Failure';
const String CACHE_FAILURE_MESSAGE = 'Cache Failure';
const String INVALID_INPUT_FAILURE_MESSAGE =
    'Invalid Input - The number must be a positive integer or zero.';

class NumberTriviaBloc extends Bloc<NumberTriviaEvent, NumberTriviaState> {
  final GetConcreteNumberTrivia getConcreteNumberTrivia;
  final GetRandomNumberTrivia getRandomNumberTrivia;
  final InputConverter inputConverter;

  NumberTriviaBloc(
      {required concrete, required random, required this.inputConverter})
      : getConcreteNumberTrivia = concrete,
        getRandomNumberTrivia = random,
        super(Empty()) {
    on<GetTriviaForConcreteNumber>(_onGetTriviaForConcreteNumber);
    on<GetTriviaForRandomNumber>(_onGetTriviaForRandomNumber);
  }

  _onGetTriviaForConcreteNumber(GetTriviaForConcreteNumber event, emit) {
    final inputEither =
        inputConverter.stringToUnsignedInteger(event.numberString);
    inputEither.fold(
      (failure) async {
        emit(const Error(message: INVALID_INPUT_FAILURE_MESSAGE));
      },
      (integer) async {
        emit(Loading());
        final failureOrTrivia = await getConcreteNumberTrivia(integer);
        _eitherLoadedOrErrorState(failureOrTrivia, emit);
      },
    );
  }

  _onGetTriviaForRandomNumber(GetTriviaForRandomNumber event, emit) async {
    emit(Loading());
    final failureOrTrivia = await getRandomNumberTrivia(NoParams());
    _eitherLoadedOrErrorState(failureOrTrivia, emit);
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return SERVER_FAILURE_MESSAGE;
      case CacheFailure:
        return CACHE_FAILURE_MESSAGE;
      default:
        return 'Unexpected error';
    }
  }

  void _eitherLoadedOrErrorState(
      Either<Failure, NumberTrivia> failureOrTrivia, emit) {
    emit(failureOrTrivia.fold(
        (failure) => Error(message: _mapFailureToMessage(failure)),
        (trivia) => Loaded(trivia: trivia)));
  }
}
