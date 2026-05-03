// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_answers.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OnboardingAnswers _$OnboardingAnswersFromJson(Map<String, dynamic> json) =>
    _OnboardingAnswers(
      name: json['name'] as String? ?? '',
      motivations:
          (json['motivations'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      goal: json['goal'] as String? ?? '',
    );

Map<String, dynamic> _$OnboardingAnswersToJson(_OnboardingAnswers instance) =>
    <String, dynamic>{
      'name': instance.name,
      'motivations': instance.motivations,
      'goal': instance.goal,
    };
