import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:tddcleanarchitecture/core/util/input_converter.dart';
import 'package:tddcleanarchitecture/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:tddcleanarchitecture/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:tddcleanarchitecture/features/number_trivia/domain/usecases/get_random_number_trivia.dart';

part 'number_trivia_event.dart';
part 'number_trivia_state.dart';

const String SERVER_FAILURE_MESSAGE = 'Server Failure';
const String SERVER_CACHE_MESSAGE = 'Cache Failure';
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
  }

  _onGetTriviaForConcreteNumber(GetTriviaForConcreteNumber event, emit) {
    final inputEither =
        inputConverter.stringToUnsignedInteger(event.numberString);
    emit(inputEither.fold(
      (failure) => const Error(message: INVALID_INPUT_FAILURE_MESSAGE),
      (integer) => const Loaded(trivia: NumberTrivia(number: 1, text: "")),
    ));
  }
}
