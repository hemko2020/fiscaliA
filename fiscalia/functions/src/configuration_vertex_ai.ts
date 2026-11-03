import { configureGenkit } from '@genkit-ai/core';
import { vertexAI } from '@genkit-ai/vertexai';

type OptionsConfigurationVertexAi = {
  projectId?: string;
  logLevel?: 'debug' | 'info' | 'warn' | 'error';
  enableTracingAndMetrics?: boolean;
};

type ConfigurationVertexAi = {
  projectId: string;
  location: string;
};

function obtenirProjectId(projectId?: string): string {
  return (
    projectId ??
    process.env.GCLOUD_PROJECT ??
    process.env.GCP_PROJECT ??
    process.env.GOOGLE_CLOUD_PROJECT ??
    'fiscalia-f1eaa'
  );
}

export function obtenirConfigurationVertexAi(
  projectId?: string,
): ConfigurationVertexAi {
  return {
    projectId: obtenirProjectId(projectId),
    location: process.env.VERTEX_AI_LOCATION ?? 'europe-west1',
  };
}

export function configurerGenkitVertexAi(
  options: OptionsConfigurationVertexAi = {},
): ConfigurationVertexAi {
  const configurationVertexAi = obtenirConfigurationVertexAi(options.projectId);

  configureGenkit({
    plugins: [vertexAI(configurationVertexAi)],
    logLevel: options.logLevel ?? 'info',
    enableTracingAndMetrics: options.enableTracingAndMetrics ?? false,
  });

  return configurationVertexAi;
}
