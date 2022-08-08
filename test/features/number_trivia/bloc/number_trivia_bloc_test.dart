import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tddcleanarchitecture/core/error/failures.dart';
import 'package:tddcleanarchitecture/core/usecases/usecase.dart';
import 'package:tddcleanarchitecture/core/util/input_converter.dart';
import 'package:tddcleanarchitecture/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:tddcleanarchitecture/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:tddcleanarchitecture/features/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'package:tddcleanarchitecture/features/number_trivia/presentation/bloc/number_trivia_bloc.dart';

import 'number_trivia_bloc_test.mocks.dart';

@GenerateMocks([GetConcreteNumberTrivia, GetRandomNumberTrivia, InputConverter])
void main() {
  late NumberTriviaBloc bloc;
  late MockGetConcreteNumberTrivia mockGetConcreteNumberTrivia;
  late MockGetRandomNumberTrivia mockGetRandomNumberTrivia;
  late MockInputConverter mockInputConverter;

  setUp(() {
    mockGetConcreteNumberTrivia = MockGetConcreteNumberTrivia();
    mockGetRandomNumberTrivia = MockGetRandomNumberTrivia();
    mockInputConverter = MockInputConverter();
    bloc = NumberTriviaBloc(
        concrete: mockGetConcreteNumberTrivia,
        random: mockGetRandomNumberTrivia,
        inputConverter: mockInputConverter);
  });

  test("initialState should be Empty", () {
    // assert
    expect(bloc.state, equals(Empty()));
  });

  group("GetTriviaForConcreteNumber", () {
    const tNumberString = "1";
    const tNumberParsed = 1;
    const tNumberTrivia = NumberTrivia(number: 1, text: "test trivia");

    void setUpMockInputConverterSuccess() =>
        when(mockInputConverter.stringToUnsignedInteger(any))
            .thenReturn(const Right(tNumberParsed));

    test(
        "should call the InputConverter to validate and convert the string to an unsigned integer",
        () async {
      // arrange
      setUpMockInputConverterSuccess();
      when(mockGetConcreteNumberTrivia(any))
          .thenAnswer((_) async => const Right(tNumberTrivia));
      // act
      bloc.add(const GetTriviaForConcreteNumber(tNumberString));
      await untilCalled(mockInputConverter.stringToUnsignedInteger(any));
      // assert
      verify(mockInputConverter.stringToUnsignedInteger(tNumberString));
    });

    blocTest<NumberTriviaBloc, NumberTriviaState>(
      "should emit [Error] when the input is invalid",
      build: () {
        when(mockInputConverter.stringToUnsignedInteger(any))
            .thenReturn(Left(InvalidInputFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(const GetTriviaForConcreteNumber(tNumberString)),
      expect: () => <NumberTriviaState>[
        const Error(message: INVALID_INPUT_FAILURE_MESSAGE),
      ],
    );

    test("should get data from the concrete use case", () async {
      // arrange
      setUpMockInputConverterSuccess();
      when(mockGetConcreteNumberTrivia(any))
          .thenAnswer((_) async => const Right(tNumberTrivia));
      // act
      bloc.add(const GetTriviaForConcreteNumber(tNumberString));
      await untilCalled(mockGetConcreteNumberTrivia(any));
      // assert
      verify(mockGetConcreteNumberTrivia(tNumberParsed));
    });

    blocTest<NumberTriviaBloc, NumberTriviaState>(
      "should emit [Loading, Loaded] when data is gotten successful",
      build: () {
        setUpMockInputConverterSuccess();
        when(mockGetConcreteNumberTrivia(any))
            .thenAnswer((_) async => const Right(tNumberTrivia));
        return bloc;
      },
      act: (bloc) => bloc.add(const GetTriviaForConcreteNumber(tNumberString)),
      expect: () => <NumberTriviaState>[
        Loading(),
        const Loaded(trivia: tNumberTrivia),
      ],
    );

    blocTest<NumberTriviaBloc, NumberTriviaState>(
      "should emit [Loading, Error] when getting data fails",
      build: () {
        setUpMockInputConverterSuccess();
        when(mockGetConcreteNumberTrivia(any))
            .thenAnswer((_) async => Left(ServerFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(const GetTriviaForConcreteNumber(tNumberString)),
      expect: () => <NumberTriviaState>[
        Loading(),
        const Error(message: SERVER_FAILURE_MESSAGE),
      ],
    );

    blocTest<NumberTriviaBloc, NumberTriviaState>(
      "should emit [Loading, Error] with a proper message for the error when getting data fails",
      build: () {
        setUpMockInputConverterSuccess();
        when(mockGetConcreteNumberTrivia(any))
            .thenAnswer((_) async => Left(CacheFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(const GetTriviaForConcreteNumber(tNumberString)),
      expect: () => <NumberTriviaState>[
        Loading(),
        const Error(message: CACHE_FAILURE_MESSAGE),
      ],
    );
  });
  group("GetTriviaForRandomNumber", () {
    const tNumberTrivia = NumberTrivia(number: 1, text: "test trivia");

    test("should get data from the concrete use case", () async {
      // arrange
      when(mockGetRandomNumberTrivia(any))
          .thenAnswer((_) async => const Right(tNumberTrivia));
      // act
      bloc.add(GetTriviaForRandomNumber());
      await untilCalled(mockGetRandomNumberTrivia(any));
      // assert
      verify(mockGetRandomNumberTrivia(NoParams()));
    });

    blocTest<NumberTriviaBloc, NumberTriviaState>(
      "should emit [Loading, Loaded] when data is gotten successful",
      build: () {
        when(mockGetRandomNumberTrivia(any))
            .thenAnswer((_) async => const Right(tNumberTrivia));
        return bloc;
      },
      act: (bloc) => bloc.add(GetTriviaForRandomNumber()),
      expect: () => <NumberTriviaState>[
        Loading(),
        const Loaded(trivia: tNumberTrivia),
      ],
    );

    blocTest<NumberTriviaBloc, NumberTriviaState>(
      "should emit [Loading, Error] when getting data fails",
      build: () {
        when(mockGetRandomNumberTrivia(any))
            .thenAnswer((_) async => Left(ServerFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(GetTriviaForRandomNumber()),
      expect: () => <NumberTriviaState>[
        Loading(),
        const Error(message: SERVER_FAILURE_MESSAGE),
      ],
    );

    blocTest<NumberTriviaBloc, NumberTriviaState>(
      "should emit [Loading, Error] with a proper message for the error when getting data fails",
      build: () {
        when(mockGetRandomNumberTrivia(any))
            .thenAnswer((_) async => Left(CacheFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(GetTriviaForRandomNumber()),
      expect: () => <NumberTriviaState>[
        Loading(),
        const Error(message: CACHE_FAILURE_MESSAGE),
      ],
    );
  });
}
