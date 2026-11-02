import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final String? error;

  ChatState({
    this.messages = const [],
    this.isLoading = false,
    this.error,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    String? error,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error, // Can be null intentionally
    );
  }
}

class AiAssistantNotifier extends StateNotifier<ChatState> {
  AiAssistantNotifier() : super(ChatState()) {
    // Initial welcome message
    state = state.copyWith(
      messages: [
        ChatMessage(
          text: "Bonjour ! Je suis votre Copilote Fiscal. Comment puis-je vous aider avec vos impôts aujourd'hui ?",
          isUser: false,
        )
      ],
    );
  }

  Future<void> sendMessage(String text, {String? contextData}) async {
    if (text.trim().isEmpty) return;

    // Add user message
    final userMessage = ChatMessage(text: text, isUser: true);
    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isLoading: true,
      error: null,
    );

    try {
      // Call Firebase Cloud Function
      final functions = FirebaseFunctions.instanceFor(region: 'europe-west1'); // Example region
      final callable = functions.httpsCallable('interrogerAgentFiscal');
      
      final response = await callable.call(<String, dynamic>{
        'question': text,
        'contextData': contextData,
      });

      final aiText = response.data['reponse'] as String? ?? "Désolé, je n'ai pas pu générer de réponse.";
      
      final aiMessage = ChatMessage(text: aiText, isUser: false);
      state = state.copyWith(
        messages: [...state.messages, aiMessage],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: "Erreur de connexion avec l'agent fiscal : $e",
      );
    }
  }
}

final aiAssistantProvider = StateNotifierProvider<AiAssistantNotifier, ChatState>((ref) {
  return AiAssistantNotifier();
});
