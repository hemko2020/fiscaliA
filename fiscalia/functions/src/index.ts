import * as functions from 'firebase-functions/v2';
import * as admin from 'firebase-admin';
import { generate, retrieve } from '@genkit-ai/ai';
import { gemini15Flash, textMultilingualEmbedding002 } from '@genkit-ai/vertexai';
import { defineFirestoreRetriever } from '@genkit-ai/firebase';
import { configurerGenkitVertexAi } from './configuration_vertex_ai';

admin.initializeApp();

// Initialize Genkit with Vertex AI using Firebase/GCP Application Default Credentials
configurerGenkitVertexAi({
  enableTracingAndMetrics: false,
});

// Configure Firestore Retriever for French tax laws RAG
const retrieverLoisFiscales = defineFirestoreRetriever({
  name: 'retrieverLoisFiscales',
  firestore: admin.firestore(),
  collection: 'lois_fiscales',
  vectorField: 'embedding',
  contentField: 'contenu',
  embedder: textMultilingualEmbedding002,
  distanceMeasure: 'COSINE',
});

export const interrogerAgentFiscal = functions.https.onCall(
  {
    region: 'europe-west1',
    enforceAppCheck: false,
    memory: '512MiB',
    timeoutSeconds: 60,
  }, // En production, passer enforceAppCheck à true
  async (request) => {
    const userQuestion = request.data.question;
    const contextData = request.data.contextData;

    if (!userQuestion) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        'La question est obligatoire.'
      );
    }

    // Retrieve relevant tax laws using Vector Search (RAG)
    let retrievedDocs: any[] = [];
    try {
      retrievedDocs = await retrieve({
        retriever: retrieverLoisFiscales,
        query: userQuestion,
        options: { limit: 3 } // Limiter aux 3 lois les plus pertinentes
      });
    } catch (error) {
      console.warn("Erreur lors de la récupération des documents RAG:", error);
      // On continue même si le retriever échoue pour fournir une réponse de base
    }

    // Build the prompt for the Fiscal AI Agent
    let prompt = `Tu es le "Copilote Fiscal", un agent d'intelligence artificielle expert en fiscalité française.
Tu dois répondre à la question de l'utilisateur de manière précise, courtoise, et basée sur la législation française.
Quand le contexte RAG contient des sources officielles, priorise-les et cite leur nom lorsqu'il est visible.
Distingue clairement la loi, la doctrine administrative, l'algorithme officiel et les guides pratiques.
Si tu n'es pas sûr, précise-le.`;

    if (contextData) {
      prompt += `\n\nVoici les données extraites du document fiscal de l'utilisateur (via OCR) qui peuvent être utiles pour ta réponse :
---
${contextData}
---`;
    }

    if (retrievedDocs && retrievedDocs.length > 0) {
      const loisContext = retrievedDocs.map(doc => doc.text()).join('\n\n');
      prompt += `\n\nVoici des extraits de la législation fiscale française qui pourraient être pertinents :
---
${loisContext}
---`;
    }

    prompt += `\n\nQuestion de l'utilisateur : ${userQuestion}`;

    try {
      // Call Gemini 1.5 Flash via Genkit
      const llmResponse = await generate({
        model: gemini15Flash,
        prompt: prompt,
        // context: retrievedDocs, // Optionnel, on peut aussi l'ajouter nativement via context si supporté
        config: {
          temperature: 0.2, // Low temperature for more factual responses
        }
      });

      return {
        reponse: llmResponse.text(),
      };
    } catch (error) {
      console.error("Erreur lors de l'appel à l'agent IA:", error);
      throw new functions.https.HttpsError(
        'internal',
        "Une erreur s'est produite lors de la génération de la réponse fiscale."
      );
    }
  }
);
